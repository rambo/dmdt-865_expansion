use std::io::{self, BufRead};
fn main() {
    let mut host = t865_mesh::Host::default();
    for line in io::stdin().lock().lines() {
        match line {
            Ok(s) => println!("{}", host.command(&s)),
            Err(_) => break,
        }
    }
}
