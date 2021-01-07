#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(int argc, char* argv[])
{
	FILE *fptr;

	//if invokation error
	if(argc != 2){
		printf("File not found\n");
		exit(1);
	}  

	//opening the file                             
    	fptr = fopen(argv[1],"rb");                 
	if(fptr == NULL){
		printf("File not found");
		fclose(fptr);
		exit(1);
	}

	//reading the memory width
	unsigned short int keyValue[1];
	fseek(fptr, 0, SEEK_SET);                                 
    	fread(keyValue,sizeof(keyValue),1,fptr);		
	int width;
	if(keyValue[0]==0x08aa){width = 8;}
	else{width = 16;}
	//printf("Keyvalue: 0x%04x\n",keyValue[0]);
	//printf("Width : %x\n",width);
	

	
	//22nd bit stores the information about the first block
	fseek(fptr,22,SEEK_SET);

	// flag tells us if we have reached the end of all section
	int flag=0;
	while(flag==0){

		//finding the block size
		unsigned short int blockSize[1];
		fread(blockSize,sizeof(blockSize),1,fptr);
		//printf("0x%04x\n",blockSize[0]);
		if(blockSize[0]==0){flag=1;}
		else{
			//finding the starting address of each block
			unsigned short int address[2];
			unsigned int destinationAddress[1];
			fread(address,sizeof(address),1,fptr);
			destinationAddress[0] = address[1] | (address[0]<<16);
			printf("\nNew block starts at: 0x%08x\n",destinationAddress[0]);

			//reading the block entries
			unsigned short int blockWord[1];
			for(int i=0;i<blockSize[0];i++){
				fread(blockWord,sizeof(blockWord),1,fptr);
				printf("0x%08x -- 0x%04x\n",destinationAddress[0]+i,blockWord[0]);
			}
			
		}
	}
 	fclose(fptr);                                                                   
    	return 0;
}
