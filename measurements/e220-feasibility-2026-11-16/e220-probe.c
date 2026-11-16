#define _GNU_SOURCE
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>
static volatile sig_atomic_t interrupted;
static void stop(int signal_number) { (void)signal_number; interrupted=1; }
static long long ms(void) {struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);return (long long)t.tv_sec*1000+t.tv_nsec/1000000;}
static void error(const char *where) {int e=errno;printf("{\"kind\":\"error\",\"where\":\"%s\",\"errno\":%d,\"message\":\"%s\"}\n",where,e,strerror(e));}
static int hex(const char*s,uint8_t*out,size_t capacity) {
 size_t n=strlen(s);if(n%2 || n/2>capacity)return -1;
 for(size_t i=0;i<n;i+=2){unsigned a,b;char x=s[i],y=s[i+1];
  if(x>='0'&&x<='9')a=x-'0';else if(x>='a'&&x<='f')a=x-'a'+10;else if(x>='A'&&x<='F')a=x-'A'+10;else return -1;
  if(y>='0'&&y<='9')b=y-'0';else if(y>='a'&&y<='f')b=y-'a'+10;else if(y>='A'&&y<='F')b=y-'A'+10;else return -1;
  out[i/2]=(uint8_t)(a*16+b);
 }return (int)(n/2);
}
static void bytes(const char*kind,const char*label,const uint8_t*b,size_t n) {
 printf("{\"kind\":\"%s\",\"label\":\"%s\",\"t_ms\":%lld,\"bytes\":%zu,\"hex\":\"",kind,label,ms(),n);
 for(size_t i=0;i<n;i++)printf("%02x",b[i]);puts("\"}");
}
static int gpio(int fd,unsigned long request,int io,int state,int*result) {
 int32_t a[7]={io,0,state,2,0,0,0};_Static_assert(sizeof(a)==28,"expand ABI");
 int r=ioctl(fd,request,a);
 printf("{\"kind\":\"ioctl\",\"request\":\"%08lx\",\"io\":%d,\"state\":%d,\"return\":%d,\"errno\":%d,\"raw_result\":%d}\n",request,io,state,r,r<0?errno:0,a[2]);
 if(result)*result=a[2];return r;
}
static int receive(int fd,const char*label,int timeout) {
 long long end=ms()+timeout;int total=0;
 while(!interrupted && ms()<end){
  struct pollfd p={.fd=fd,.events=POLLIN};int r=poll(&p,1,(int)(end-ms()));
  if(r<0){if(errno==EINTR)continue;error("poll");return -1;}
  if(p.revents&(POLLHUP|POLLERR|POLLNVAL)){errno=EIO;error("UART hangup");return -1;}
  if(r>0){uint8_t b[512];ssize_t n=read(fd,b,sizeof(b));if(n>0){bytes("rx",label,b,(size_t)n);total+=(int)n;if(total>16384){errno=EOVERFLOW;error("RX bound");return -1;}}
   else if(n<0 && errno!=EAGAIN && errno!=EWOULDBLOCK && errno!=EINTR){error("read");return -1;}}
 }
 printf("{\"kind\":\"rx_end\",\"label\":\"%s\",\"bytes\":%d}\n",label,total);return total;
}
static int transmit(int fd,const char*label,const uint8_t*b,size_t n) {
 long long end=ms()+1000;size_t sent=0;
 while(sent<n && !interrupted){
  ssize_t r=write(fd,b+sent,n-sent);if(r>0){sent+=(size_t)r;continue;}
  if(r<0 && errno!=EAGAIN && errno!=EINTR && errno!=EWOULDBLOCK){error("write");return -1;}
  if(ms()>=end){errno=ETIMEDOUT;error("write timeout");return -1;}
  struct pollfd p={.fd=fd,.events=POLLOUT};(void)poll(&p,1,10);
 }
 bytes("tx",label,b,sent);return sent==n?0:-1;
}
int main(int argc,char**argv) {
 setvbuf(stdout,NULL,_IOLBF,0);uint8_t b[1024];
 if(argc==2 && !strcmp(argv[1],"--selftest")){assert(hex("00Ff94c3",b,sizeof(b))==4);assert(b[1]==255);assert(hex("0",b,sizeof(b))<0);assert(hex("gg",b,sizeof(b))<0);assert(hex("0000",b,1)<0);puts("hex selftest passed");return 0;}
 if(argc!=2 || (strcmp(argv[1],"--power-on")&&strcmp(argv[1],"--no-power"))){fputs("e220-probe --power-on|--no-power < script\n",stderr);return 2;}
 signal(SIGINT,stop);signal(SIGTERM,stop);
 char context[256]={0};int c=open("/proc/self/attr/current",O_RDONLY);if(c>=0){ssize_t n=read(c,context,sizeof(context)-1);if(n>0)context[n]=0;close(c);}
 printf("{\"kind\":\"identity\",\"uid\":%d,\"selinux\":\"%s\"}\n",getuid(),context);
 int ex=-1,fd=-1,powered=0,have_termios=0,original_io=0,status=1;struct termios original;
 ex=open("/dev/expand",O_RDWR|O_CLOEXEC|O_NOFOLLOW);if(ex<0){error("open expand");goto cleanup;}
 if(gpio(ex,0xc01c5303UL,1,0,&original_io)<0)goto cleanup;
 if(!strcmp(argv[1],"--power-on")){
  if(gpio(ex,0xc01c5301UL,0,1,NULL)<0)goto cleanup;powered=1;
  if(gpio(ex,0xc01c5302UL,1,1,NULL)<0)goto cleanup;
  usleep(100000);
 }
 fd=open("/dev/ttysWK2",O_RDWR|O_NOCTTY|O_NONBLOCK|O_CLOEXEC|O_NOFOLLOW);if(fd<0){error("open WK2");goto cleanup;}
 if(flock(fd,LOCK_EX|LOCK_NB)<0){error("UART advisory lock");goto cleanup;}
 if(tcgetattr(fd,&original)<0){error("tcgetattr");goto cleanup;}have_termios=1;
 struct termios t=original;cfmakeraw(&t);t.c_cflag&=~(CSIZE|PARENB|CSTOPB|CRTSCTS|HUPCL);t.c_cflag|=CS8|CREAD|CLOCAL;t.c_iflag&=~(IXON|IXOFF|IXANY);t.c_cc[VMIN]=0;t.c_cc[VTIME]=0;cfsetispeed(&t,B9600);cfsetospeed(&t,B9600);
 if(tcsetattr(fd,TCSANOW,&t)<0){error("tcsetattr");goto cleanup;}
 puts("{\"kind\":\"open\",\"baud\":9600,\"framing\":\"8N1\"}");
 char line[2300];status=0;
 while(!interrupted && fgets(line,sizeof(line),stdin)){
  char op[16],label[64],hexstring[2100];int timeout=0;
  if(line[0]=='#'||line[0]=='\n')continue;
  if(sscanf(line,"%15s %63s %2099s %d",op,label,hexstring,&timeout)==4 && !strcmp(op,"TX")){
   int n=hex(hexstring,b,sizeof(b));if(n<1||timeout<1||timeout>5000){errno=EINVAL;error("script TX");status=2;break;}
   if(transmit(fd,label,b,(size_t)n)<0||receive(fd,label,timeout)<0){status=1;break;}
  }else if(sscanf(line,"WAIT %d",&timeout)==1 && timeout>0 && timeout<=5000){if(receive(fd,"wait",timeout)<0){status=1;break;}}
  else{errno=EINVAL;error("script syntax");status=2;break;}
 }
cleanup:
 if(have_termios && tcsetattr(fd,TCSANOW,&original)<0){error("restore termios");status=1;}
 if(fd>=0)close(fd);
 if(powered){if(gpio(ex,0xc01c5302UL,1,original_io,NULL)<0)status=1;if(gpio(ex,0xc01c5301UL,0,0,NULL)<0)status=1;}
 if(ex>=0)close(ex);
 printf("{\"kind\":\"close\",\"status\":%d,\"power_off_requested\":%s}\n",status,powered?"true":"false");return status;
}
