#include <stdio.h>
#include <termios.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

int cport_h; // handle to the communication port
int open_port(char *port, speed_t baudrate) {
  	struct termios options;

  	cport_h = open(port, O_RDWR);
  	if(cport_h < 0)
    		{return cport_h;}
  	tcgetattr(cport_h, &options);

  	cfsetospeed(&options, baudrate);
  	cfsetispeed(&options, baudrate);

  	options.c_iflag |= (IGNPAR | IGNBRK);
  	options.c_iflag &= ~INPCK;
  	options.c_iflag &= ~(IXON | IXOFF | IXANY);
  	options.c_iflag &= ~(INLCR | ICRNL); // Prevents 0xd->0xa translation
  	options.c_cflag &= ~CSTOPB;
  	options.c_cflag &= ~CSIZE;
  	options.c_cflag &= ~PARENB;
  	options.c_cflag |= (CLOCAL | CREAD | CS8);

  	options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
  	options.c_oflag &= ~OPOST;
  	options.c_oflag &= ~(ONLCR | OCRNL); // Prevents 0xd->0xa translation
 	options.c_cc[VMIN] = 255;
  	options.c_cc[VTIME] = 1;

 	tcsetattr(cport_h, TCSANOW, &options);
  	tcflush(cport_h,TCIOFLUSH);
  	return(cport_h);
}

void close_port() {
  	tcflush(cport_h, TCIOFLUSH);
  	close(cport_h);
}

int main(int argc, char* argv[])
{	
	//See if the command has 4 arguements or not
	if(argc != 4){							
		printf("Incorrect invocation\n");
		return 0;
	}
	
	//concatinating the address of the port with the integer
	char portNumber[] = "/dev/ttyUSB";				
	strncat(portNumber,argv[1],1);
	//printf("Port being used: %s\n",portNumber);
	
	//opening the port with given port number and baud rate of 115200
	int openPortBit = open_port(portNumber, B115200);		
	//printf("Port Used : %i\n",openPortBit);
	if(openPortBit<0){
		printf("Unable to open port!! Please check initialization.");
		return 0;
	}

	//Padding the address from where we have to read
	char* temp = argv[2];						
	int len = strlen(argv[2]); 
	char memoryAddress[8];
	for(int i=0;i<8;i++){
		if(8-i>len){memoryAddress[i]= '0';}  
	}
	strncat(memoryAddress,temp,len);
	//printf("Memory Address: %s\n",memoryAddress); 
	
	//initialization of command header
	unsigned char commandHeader[14] = "\x00\x00\xcc\x03\x07\x00\x02\x00\x00\x00\x00\x00\x00\x00";		

	//Changing bytes 2,3,4,5 and 6th according to the address
	for(int i=7;i>=1;i=i-2){
		char temporary[2];temporary[0] = memoryAddress[7-i];temporary[1] = memoryAddress[8-i];
		unsigned char feed = (char)strtol(temporary,NULL,16);
		commandHeader[(i+1)/2 + 1] = feed;
	}
	//printf("%02x%02x%02x%02x\n",commandHeader[5],commandHeader[4],commandHeader[3],commandHeader[2]);

	char temporary[1]; temporary[0]=argv[3][0];
	unsigned char feed = (char)strtol(temporary,NULL,16);
	commandHeader[6] = feed;
	
	//Writing the command header to the SPI port
	for(int i=0;i<14;i++){
		unsigned char t1[1];
		t1[0] = commandHeader[i];
		write(openPortBit,t1,1);
	}

	
	//Initializing array with size 2 times the number of words to be read
	int readBytes = argv[3][0]-48;	
	unsigned char recieved[2*readBytes];
	//printf("%x\n",readBytes);

	//Reading from the SPI port
	for(int i=0;i<2*readBytes;i++){
		unsigned char r1[1];
		int n = read(openPortBit,r1,1);
		recieved[i] = r1[0];
		if(n<0){printf("Error in reading byte: %i\n",i);}
	}

	//Printing the final address and data
	unsigned long movingAddress = (unsigned long)strtol(memoryAddress,NULL,16);
	for(int i=0;i<readBytes;i++){
		printf("0x%08x -- 0x%02x%02x\n",movingAddress+i,recieved[2*i+1],recieved[2*i]);
	}

	//Closing the port
	close_port();
	return 0;

}
