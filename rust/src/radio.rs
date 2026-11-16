//! Vendor module access is deliberately separate from the mesh codec.
use serde_json::{json, Value};
use std::{
    fs::File,
    io,
    mem::MaybeUninit,
    os::fd::{AsRawFd, FromRawFd},
};
pub fn capabilities() -> Value {
    json!({"backend":"E220-900T30S UART (firmware not identified)","native_rf_tx":false,
    "blockers":["OpaqueAirFraming","UnknownSyncWord","NoVerifiedFrameBoundaries"],
    "documented_vendor_mtu":200,"snr":null,"cad":"unknown","mode_gpio_mapping":"unverified"})
}

pub struct Uart {
    file: File,
    original: libc::termios,
}
impl Uart {
    pub fn open(baud: u32) -> Result<Self, String> {
        let speed = match baud {
            1200 => libc::B1200,
            2400 => libc::B2400,
            4800 => libc::B4800,
            9600 => libc::B9600,
            19200 => libc::B19200,
            38400 => libc::B38400,
            57600 => libc::B57600,
            115200 => libc::B115200,
            _ => return Err("unsupported baud".into()),
        };
        let fd = unsafe {
            libc::open(
                c"/dev/ttysWK2".as_ptr(),
                libc::O_RDWR
                    | libc::O_NOCTTY
                    | libc::O_NONBLOCK
                    | libc::O_CLOEXEC
                    | libc::O_NOFOLLOW,
            )
        };
        if fd < 0 {
            return Err(os_error("open WK2"));
        }
        let file = unsafe { File::from_raw_fd(fd) };
        if unsafe { libc::flock(fd, libc::LOCK_EX | libc::LOCK_NB) } < 0 {
            return Err(os_error("cooperative UART lock"));
        }
        let mut original = MaybeUninit::uninit();
        if unsafe { libc::tcgetattr(fd, original.as_mut_ptr()) } < 0 {
            return Err(os_error("tcgetattr"));
        }
        let original = unsafe { original.assume_init() };
        let mut t = original;
        unsafe {
            libc::cfmakeraw(&mut t);
            libc::cfsetispeed(&mut t, speed);
            libc::cfsetospeed(&mut t, speed);
        }
        t.c_iflag &= !(libc::IXON | libc::IXOFF | libc::IXANY);
        t.c_cflag &= !(libc::CSIZE | libc::PARENB | libc::CSTOPB | libc::CRTSCTS | libc::HUPCL);
        t.c_cflag |= libc::CS8 | libc::CLOCAL | libc::CREAD;
        t.c_cc[libc::VMIN] = 0;
        t.c_cc[libc::VTIME] = 0;
        if unsafe { libc::tcsetattr(fd, libc::TCSANOW, &t) } < 0 {
            let err = os_error("tcsetattr");
            unsafe {
                libc::tcsetattr(fd, libc::TCSANOW, &original);
            }
            return Err(err);
        }
        Ok(Self { file, original })
    }
    pub fn read(&self) -> Result<Vec<u8>, String> {
        let mut p = libc::pollfd {
            fd: self.file.as_raw_fd(),
            events: libc::POLLIN,
            revents: 0,
        };
        let ready = unsafe { libc::poll(&mut p, 1, 0) };
        if ready < 0 {
            if io::Error::last_os_error().kind() == io::ErrorKind::Interrupted {
                return Ok(vec![]);
            }
            return Err(os_error("poll"));
        }
        if p.revents & (libc::POLLERR | libc::POLLHUP | libc::POLLNVAL) != 0 {
            return Err("UART disconnected".into());
        }
        let mut b = vec![0; 512];
        let n = unsafe { libc::read(p.fd, b.as_mut_ptr().cast(), b.len()) };
        if n < 0 {
            let e = io::Error::last_os_error();
            if matches!(
                e.kind(),
                io::ErrorKind::WouldBlock | io::ErrorKind::Interrupted
            ) {
                return Ok(vec![]);
            }
            return Err(os_error("read"));
        }
        b.truncate(n as usize);
        Ok(b)
    }
    pub fn close(self) -> Result<(), String> {
        if unsafe { libc::tcsetattr(self.file.as_raw_fd(), libc::TCSANOW, &self.original) } < 0 {
            return Err(os_error("restore UART"));
        }
        Ok(())
    }
}
impl Drop for Uart {
    fn drop(&mut self) {
        unsafe {
            libc::tcsetattr(self.file.as_raw_fd(), libc::TCSANOW, &self.original);
        }
    }
}
fn os_error(op: &str) -> String {
    let e = io::Error::last_os_error();
    format!(
        "{op}: errno={} ({e}); SELinux={}",
        e.raw_os_error().unwrap_or(0),
        std::fs::read_to_string("/proc/self/attr/current")
            .unwrap_or_default()
            .trim_end_matches('\0')
    )
}

#[derive(Clone, Copy)]
pub enum Model {
    E220,
    E22,
}
/// Read-only C1 request. Caller must establish configuration mode; never auto-send.
pub fn read_registers(model: Model, address: u8, length: u8) -> Result<[u8; 3], String> {
    let end = match model {
        Model::E220 => 8,
        Model::E22 => 9,
    };
    if length == 0 || address as u16 + length as u16 > end {
        return Err("register read outside known block".into());
    }
    Ok([0xc1, address, length])
}
#[derive(Default)]
pub struct RegisterReply {
    bytes: Vec<u8>,
}
impl RegisterReply {
    pub fn feed(&mut self, b: &[u8], address: u8, length: u8) -> Result<Option<Vec<u8>>, String> {
        if b.len() + self.bytes.len() > 32 {
            return Err("register reply overflow".into());
        }
        self.bytes.extend(b);
        if self.bytes.first().is_some_and(|v| *v != 0xc1) {
            return Err("unexpected register command response".into());
        }
        if self.bytes.len() >= 3 && self.bytes[..3] != [0xc1, address, length] {
            return Err("stale or mismatched register response".into());
        }
        if self.bytes.len() < 3 + length as usize {
            return Ok(None);
        }
        if self.bytes.len() != 3 + length as usize {
            return Err("trailing bytes in register response".into());
        }
        Ok(Some(self.bytes[3..].to_vec()))
    }
}

/// Recovered vendor ABI: I/O @0, state @8, position @12; 28 bytes total.
/// This does not map or drive the unverified M0/M1 logical I/O lines.
#[repr(C)]
#[derive(Debug, PartialEq)]
pub struct ExpandArg(pub [i32; 7]);
impl ExpandArg {
    pub fn new(position: i32, io: i32, state: bool) -> Self {
        let mut a = [0; 7];
        a[0] = io;
        a[2] = state as i32;
        a[3] = position;
        Self(a)
    }
}
const _: () = assert!(std::mem::size_of::<ExpandArg>() == 28);
pub struct Expansion {
    file: File,
    owned: bool,
}
impl Expansion {
    pub fn power_on() -> Result<Self, String> {
        let fd = unsafe {
            libc::open(
                c"/dev/expand".as_ptr(),
                libc::O_RDWR | libc::O_CLOEXEC | libc::O_NOFOLLOW,
            )
        };
        if fd < 0 {
            return Err(os_error("open /dev/expand"));
        }
        let mut e = Self {
            file: unsafe { File::from_raw_fd(fd) },
            owned: false,
        };
        e.request(0xc01c5301, 0, true)?;
        e.owned = true;
        e.request(0xc01c5302, 1, true)?;
        // DMD's traced sequence waits 100 ms before opening WK2.
        std::thread::sleep(std::time::Duration::from_millis(100));
        Ok(e)
    }
    fn request(&self, request: libc::c_ulong, io: i32, state: bool) -> Result<(), String> {
        let mut arg = ExpandArg::new(2, io, state);
        if unsafe { libc::ioctl(self.file.as_raw_fd(), request as _, &mut arg) } < 0 {
            return Err(os_error("expansion ioctl"));
        }
        Ok(())
    }
    pub fn power_off(&mut self) -> Result<(), String> {
        if !self.owned {
            return Ok(());
        }
        // Attempt both even if the first fails. Leave owned=true on failure for Drop retry.
        let io = self.request(0xc01c5302, 1, false);
        let power = self.request(0xc01c5301, 0, false);
        io.and(power)?;
        self.owned = false;
        Ok(())
    }
}
impl Drop for Expansion {
    fn drop(&mut self) {
        let _ = self.power_off();
    }
}
