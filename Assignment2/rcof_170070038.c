#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(int argc, char* argv[])
{
    	//char fileName[128];               		            			
    	//printf("Enter the file name\n");
    	//scanf("%[^\n]%*c",fileName);				//input

	FILE *fptr;
	
	if(argc != 2){
		printf("Give the file name as arguement\n");
		exit(1);
	}                               
    	fptr = fopen(argv[1],"rb");                 
	if(fptr == NULL){
		printf("File not found");			//if file not found
		fclose(fptr);
		exit(1);
	}

    	int sectionStart=22; 					//section info starts from 22 byte
    	unsigned short int sectionNum[1];                       
    	unsigned short int opheadsize[1];			//if optional header file present
    	
    	fseek(fptr, 2, SEEK_SET);                                 
    	fread(sectionNum,sizeof(sectionNum),1,fptr);		//first 2 bytes for section represent the section number                
    	fseek(fptr, 16, SEEK_SET);
    	fread(opheadsize,sizeof(opheadsize),1,fptr);		//16-17 bits store optional header size ( 0 or 28)
    	//printf("No of Sec: %d\n", sectionNum[0]);
    	sectionStart += opheadsize[0];


    	for(int i=1; i<sectionNum[0]; i++){			//starting from named section therefore i = 1

		char sectionName[8];                           
    		int sectionPhysicalAddress[1];
    		int sectionVirtualAddress[1];
		int sectionPointer[1];
    		int sectionSize[1];
    		short int sectionRawData[1];
		fseek(fptr, sectionStart+(i*48), SEEK_SET);				//size of section header is 48 
    		fread(sectionName, sizeof(sectionName),1,fptr); 			//first 8 bytes store name
		printf("Section name: %s\n", sectionName);
		printf("\n");
		//fseek(fptr, sectionStart+(i*48)+8, SEEK_SET);		
   		fread(sectionPhysicalAddress, sizeof(sectionPhysicalAddress),1,fptr);	//next 4 bytes section physical address
		//fseek(fptr, sectionStart+(i*48)+12, SEEK_SET);
		//printf("Address: %04x\n", sectionPhysicalAddress[0]);
   		fread(sectionVirtualAddress, sizeof(sectionVirtualAddress),1,fptr);	//next 4 bytes section virtual address
		//fseek(fptr, sectionStart+(i*48)+20, SEEK_SET);
   		fread(sectionSize, sizeof(sectionSize),1,fptr);				//next 4 size of section
		//fseek(fptr, sectionStart+(i*48)+24, SEEK_SET);
   		fread(sectionPointer, sizeof(sectionPointer),1,fptr);			//next 4 file pointer to raw data
   		//printf("Size: %04x\n", sectionSize[0]);
   		//printf("Sec Pointer to raw Data: %04x\n", sectionPointer[0]);	
		fseek(fptr, sectionPointer[0], SEEK_SET);				//we set the pointer at section raw data
		printf("Section raw data:\n");
		for(int j=0;j<sectionSize[0];j++){
			fread(sectionRawData,sizeof(sectionRawData),1,fptr);		
			printf("0x%08x -- 0x%hx\n",sectionPhysicalAddress[0]+j,sectionRawData[0]);		//we add physical address to each raw data entry
		}
		printf("-- Section %s end --\n",sectionName);
		printf("\n");
		printf("\n");
	}
 	fclose(fptr);                                                                   
    	return 0;
}
