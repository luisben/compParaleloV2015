#include <stdlib.h>
#include <stdio.h>

__global__ void makeAdjMat(int *csizes, int *cstarts, int *cases, int *adjMat, int matSize, int dataSize){

        int my_case_idx,my_case_size,my_case_start,idx_inner,mat_pos,idx;
        my_case_idx = blockIdx.x*blockDim.x + threadIdx.x;
        if(my_case_idx < dataSize){
            my_case_size = csizes[my_case_idx];
            my_case_start = cstarts[my_case_idx];
            for(idx=my_case_start;idx<(my_case_start+my_case_size);idx++){
                for(idx_inner=my_case_start;idx_inner<(my_case_start+my_case_size);idx_inner++){
                    mat_pos = (cases[idx] - 1)*matSize + (cases[idx_inner] - 1);
                    adjMat[mat_pos]++;
                }
            }
            } 
}

void genAdjMat(int *case_sizes, int *cases_afecs, int *case_count, int *input_size, int *adjMatrix, int *adjMatDim){

	int num_cases = case_count[0];
	int num_inputs = input_size[0];
	int mat_size = adjMatDim[0];
	
	float total_time;
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	int case_count_totsize = num_cases * sizeof(int);
	int mat_totsize = mat_size * mat_size * sizeof(int);
	int input_totsize = num_inputs * sizeof(int);

    int *case_stidx = (int*) malloc(case_count_totsize);
	
	int *dev_sizes,*dev_starts,*dev_cases,*dev_matrix;
	
	cudaMalloc((void**)&dev_sizes,case_count_totsize);
	cudaMalloc((void**)&dev_starts,case_count_totsize);
	cudaMalloc((void**)&dev_cases,input_totsize);
	cudaMalloc((void**)&dev_matrix,mat_totsize);
	
	cudaMemset(dev_matrix,0,mat_totsize);
	
    int idx = 0;
    
	case_stidx[0] = 0;
	for(idx=1;idx<num_cases;idx++){
		case_stidx[idx] = case_stidx[idx-1]+case_sizes[idx-1];
	}

	cudaMemcpy(dev_sizes,case_sizes,case_count_totsize,cudaMemcpyHostToDevice);
	cudaMemcpy(dev_starts,case_stidx,case_count_totsize,cudaMemcpyHostToDevice);
	cudaMemcpy(dev_cases,cases_afecs,input_totsize,cudaMemcpyHostToDevice);

        int blockSize = 32;
        int blockCount = num_inputs/blockSize;
        while(blockCount*blockSize < num_inputs)
            blockCount++;

	cudaEventRecord(start,0);
	makeAdjMat<<<blockCount,blockSize>>>(dev_sizes,dev_starts,dev_cases,dev_matrix,mat_size,num_cases);
		
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&total_time,start,stop);
	printf("\n time for kernel processing %i threads in %i blocks : %f \n",blockCount*blockSize,blockCount,total_time);	
	
	cudaMemcpy(adjMatrix,dev_matrix,mat_totsize,cudaMemcpyDeviceToHost);

    free(case_stidx);
	
	cudaFree(dev_sizes);
	cudaFree(dev_starts);
	cudaFree(dev_cases);
	cudaFree(dev_matrix);

}


int main(){

	int cases_sizes[1459] = {2,3,3,3,2,3,2,2,2,2,2,2,2,4,2,2,2,2,4,2,2,2,2,2,2,2,2,3,2,2,2,3,2,5,5,2,2,2,2,2,3,2,2,3,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,4,2,3,3,2,2,3,5,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,3,2,5,2,2,3,3,2,3,2,2,2,2,3,3,2,2,2,2,2,3,2,3,2,3,3,2,2,2,2,2,2,3,3,2,2,3,2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2,2,2,2,2,3,2,3,2,2,2,2,2,2,4,3,3,2,3,3,2,2,2,2,3,2,3,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,3,4,4,3,3,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,3,3,2,3,2,3,2,2,2,2,2,2,3,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,4,2,3,2,2,2,2,2,2,2,2,2,2,3,3,2,2,2,3,2,2,2,3,3,2,2,3,2,2,3,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,3,2,2,3,3,3,2,2,2,3,2,2,2,2,2,2,2,2,3,2,2,3,2,2,2,2,3,2,2,2,2,4,5,2,2,2,4,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,3,2,2,2,2,2,2,2,3,3,3,3,2,2,3,2,2,2,2,2,3,2,2,2,3,2,2,2,2,2,2,2,6,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,3,2,3,2,2,2,2,2,2,2,2,2,4,3,2,4,2,2,2,2,2,2,2,4,2,2,3,2,3,4,2,2,2,3,2,2,3,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,3,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,3,2,3,3,2,2,2,2,2,3,2,2,2,3,2,2,3,2,2,2,2,3,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,3,2,3,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,3,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,3,2,2,3,2,3,2,2,1};
	int cases_data[2222] = {140,244,55,183,62,271,81,80,272,171,55,146,167,272,173,184,12,84,55,27,185,159,153,147,4,271,183,271,27,58,201,272,27,123,271,108,138,272,36,167,185,55,55,83,29,271,276,272,73,276,271,276,157,271,271,276,271,276,140,276,145,276,271,276,276,276,271,271,271,276,276,276,27,60,271,271,35,50,34,271,276,272,276,156,34,159,271,7,23,55,250,272,2,37,171,200,20,55,272,167,137,55,8,272,153,40,167,153,237,158,272,183,173,115,36,98,91,271,117,27,87,34,272,272,159,272,272,55,166,20,234,27,183,272,184,159,65,55,9,198,198,13,62,53,138,272,218,159,272,275,32,77,95,51,171,272,272,183,171,249,118,246,184,140,167,195,62,203,159,157,46,27,97,30,114,167,198,55,272,167,183,27,238,20,36,20,119,277,167,272,147,271,233,27,24,271,192,119,272,55,63,22,21,146,96,246,38,147,271,180,276,181,272,276,198,157,271,197,198,272,272,57,272,198,86,276,276,180,180,276,271,276,276,271,276,276,271,271,271,271,271,276,271,271,181,271,271,171,180,276,276,276,171,271,276,158,276,276,119,159,167,161,198,198,171,37,272,18,198,194,20,123,272,272,55,272,198,271,119,123,198,195,181,151,55,55,125,116,177,182,198,271,272,272,198,198,134,153,272,271,271,272,276,271,276,271,276,276,276,276,276,272,271,156,276,180,271,158,271,276,276,276,271,276,171,272,271,198,272,195,272,274,194,171,272,195,271,195,272,194,251,167,167,276,271,271,276,180,276,271,276,175,271,276,271,276,271,271,140,181,276,272,276,272,276,171,171,276,180,276,271,271,276,180,271,180,272,271,276,276,276,276,271,276,271,276,171,276,171,180,276,271,276,167,271,271,271,276,276,163,272,276,271,276,271,276,276,276,271,276,271,276,276,276,271,276,180,145,138,276,271,180,276,271,271,271,276,171,171,271,271,150,276,276,271,276,276,276,271,276,157,272,167,276,276,272,271,150,276,272,195,183,198,272,158,198,167,272,276,138,180,276,272,272,271,276,271,271,272,195,180,271,271,276,198,183,276,276,145,271,276,156,180,271,276,198,271,198,276,271,271,156,276,276,276,276,276,276,276,276,276,271,276,271,276,276,276,272,271,271,271,271,272,271,180,180,271,272,271,276,271,276,276,276,7,271,272,272,138,141,272,141,201,272,201,201,201,171,272,201,272,276,276,271,276,272,276,145,276,272,157,276,276,276,272,271,276,271,271,203,271,180,276,276,272,150,271,271,271,276,145,276,271,271,276,276,276,271,276,271,180,276,271,180,271,271,271,180,276,276,180,271,180,276,271,276,271,276,272,27,271,271,276,276,180,276,272,276,88,276,20,183,271,62,171,56,191,159,140,140,191,201,171,138,150,171,171,272,146,272,171,272,27,171,171,20,167,171,16,158,271,271,271,211,190,55,222,73,136,27,26,177,55,271,276,271,276,276,276,180,276,180,271,271,271,180,180,271,276,276,271,276,276,271,271,271,276,271,276,271,276,276,276,272,276,180,276,276,276,276,180,271,272,271,276,27,271,271,171,271,276,180,272,271,171,201,272,204,198,272,276,271,39,216,123,158,272,20,236,201,78,201,272,185,171,159,167,201,104,17,125,89,159,159,141,50,218,223,272,272,167,213,272,272,141,272,271,185,272,27,55,34,55,146,213,201,20,171,271,159,272,201,271,159,272,271,272,23,55,201,272,272,20,201,201,44,272,272,128,141,185,159,171,217,235,106,185,224,55,245,171,157,180,276,272,157,276,276,271,276,272,145,271,271,276,272,276,272,276,276,272,180,271,276,271,271,276,276,276,272,272,11,276,276,271,180,276,276,276,271,276,272,271,272,113,151,85,271,158,271,271,271,43,34,171,191,272,271,276,276,27,271,271,180,276,209,141,183,271,167,272,112,201,153,77,178,201,171,140,101,185,271,272,140,144,138,272,171,171,271,246,93,72,69,276,3,271,276,271,180,276,276,272,271,272,276,276,276,139,271,271,276,276,276,271,276,276,55,276,271,271,271,271,272,276,272,276,271,271,271,251,201,27,276,276,180,276,276,271,276,271,271,271,271,271,271,276,276,271,276,271,103,276,271,276,276,272,276,181,271,276,33,271,276,271,272,276,181,128,276,276,158,276,23,146,73,64,27,201,119,55,62,62,271,271,276,276,272,271,271,23,276,276,272,276,55,230,276,33,55,62,119,31,5,271,219,276,4,76,28,111,20,48,256,276,272,276,271,271,276,271,271,276,276,276,271,108,42,194,276,269,271,271,183,276,42,27,41,272,123,140,15,271,276,70,27,119,276,271,138,20,30,66,168,271,195,119,135,272,276,276,55,114,36,140,119,31,272,77,181,27,272,108,119,29,74,276,271,55,271,20,271,276,272,276,276,272,271,272,271,271,276,276,195,123,276,272,271,154,121,271,195,167,159,272,272,198,159,276,276,271,272,276,271,276,271,276,123,276,276,276,276,276,276,276,14,276,276,14,276,276,276,145,133,276,146,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,272,131,134,276,276,276,276,276,276,276,276,271,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,272,276,276,276,276,276,276,272,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,276,79,198,271,272,146,107,100,276,89,146,276,61,198,30,96,260,271,20,271,55,195,272,158,255,110,272,146,272,257,158,271,55,272,158,158,271,93,271,271,271,153,185,158,158,159,167,271,272,191,158,146,147,271,157,183,272,271,159,271,272,272,159,159,183,155,271,171,271,171,155,271,167,167,271,159,271,182,192,171,159,146,142,171,185,158,271,271,188,271,159,271,171,167,271,184,168,271,271,242,158,183,271,184,158,271,138,171,176,271,271,271,171,171,271,272,207,138,271,171,271,153,194,271,150,271,171,158,202,271,178,138,177,198,173,271,272,167,198,272,271,272,146,247,271,272,272,185,271,272,143,271,271,185,194,198,167,271,271,171,271,271,198,171,132,271,271,167,271,159,171,271,194,198,198,138,272,198,272,198,158,183,140,272,190,191,271,272,140,251,159,272,191,271,171,140,184,153,137,147,271,272,171,166,271,184,142,153,171,271,271,271,185,198,195,198,271,271,167,178,272,271,171,171,140,171,272,272,271,271,138,271,138,152,271,171,271,184,271,198,198,271,271,192,272,271,206,138,272,171,272,130,272,271,272,146,262,272,171,171,158,271,182,204,171,192,271,171,272,271,241,185,158,146,140,167,252,171,198,198,198,271,271,271,30,123,214,2,271,271,271,198,171,271,146,272,272,167,164,271,171,201,185,67,271,198,138,153,171,25,271,147,167,167,272,272,198,198,271,171,171,159,157,159,158,146,271,158,271,79,198,271,271,195,185,271,25,273,90,27,192,271,272,220,246,271,195,146,171,171,271,140,171,1,279,198,271,271,272,272,158,71,27,198,271,198,271,140,171,271,171,271,158,79,271,272,182,271,272,171,29,271,279,272,55,59,129,271,122,135,272,199,248,225,271,78,261,272,160,171,279,171,207,25,272,228,44,201,201,272,138,272,25,272,271,141,201,201,272,272,279,271,264,272,201,272,272,272,271,272,271,201,147,272,44,272,272,272,271,219,171,201,55,271,55,272,201,27,272,271,271,272,141,201,271,171,272,27,272,272,167,158,272,27,201,272,201,271,272,271,55,272,272,271,27,272,78,271,208,272,271,272,272,272,201,272,272,187,248,271,141,271,271,272,272,272,272,272,212,279,272,201,101,272,272,251,271,221,272,272,141,272,171,271,272,169,10,272,167,254,272,27,27,272,102,201,272,215,271,189,272,218,272,27,272,74,272,272,124,272,272,272,272,216,186,271,272,141,271,272,272,27,271,231,141,272,171,271,249,265,272,268,272,279,164,272,201,272,271,243,141,201,272,272,272,272,94,272,201,271,167,201,266,219,272,73,201,272,201,272,141,201,167,272,272,272,272,232,240,218,272,272,272,272,272,201,272,272,272,249,105,272,271,272,127,201,201,201,272,47,147,239,201,75,54,272,272,271,201,271,27,272,210,20,201,272,230,52,87,272,272,201,271,271,271,272,250,128,271,82,6,217,83,272,272,272,227,128,226,218,271,146,241,55,49,193,272,272,73,20,250,40,272,109,272,272,271,272,272,55,271,27,272,271,218,73,272,146,89,39,55,253,147,243,73,96,272,272,271,141,38,272,221,201,148,271,271,265,57,2,36,55,55,272,45,224,272,277,119,19,271,272,271,271,271,272,272,272,272,92,272,271,272,114,272,272,272,272,272,229,272,278,272,272,272,118,272,272,276,271,271,271,276,276,276,276,271,276,271,276,271,271,271,272,276,276,276,140,271,200,272,198,194,276,276,198,194,159,276,146,194,158,159,162,196,270,58,159,157,259,185,258,267,272,159,272,138,140,20,276,276,276,276,271,271,271,271,271,157,167,180,272,276,271,276,271,276,271,276,145,271,276,271,276,180,276,272,276,271,271,276,150,180,276,276,271,271,276,271,180,271,276,272,155,271,181,208,271,171,167,120,276,272,7,200,138,276,276,55,276,272,271,271,180,99,185,158,272,276,271,276,207,179,140,68,272,272,103,276,276,171,138,271,55,276,176,185,163,271,138,159,276,159,167,140,171,276,165,174,178,123,138,272,272,27,272,170,171,272,126,137,158,171,132,172,272,185,159,167,205,140,55,271,159,271,272,156,271,103,276,272,271,2,276,119,138,171,271,171,271,3,27,88,89,123,263,119,167,159,272,20,123,272,158,264,61,183,146,34,138,271,171,191,171,271,171,271,181,158,157,272,204,185,191,155,271,153,182,271,272,171,20,263,178,138,140,264,198,272,159,185,27,150,44,271,158,272,167,271,159,171,157,149,55,272,171,158,171,159,272,171,272,171,146,272};
	int case_count[1] = {1459};
    int input_size[1] = {2222};
    int adj_mat_size[1] = {279};
    int adj_mat[279*279] = {0};
    genAdjMat(cases_sizes,cases_data,case_count,input_size,adj_mat,adj_mat_size);
    int idx,row_count=0;
	FILE *f = fopen("adjmat.txt","w");
	if(f==0)
		exit(1);
	
    for(idx=0;idx<adj_mat_size[0]*adj_mat_size[0];idx++){
        if(idx%adj_mat_size[0]==0){
            fprintf(f,"\n%i",row_count);
            row_count++;
        }
        fprintf(f,"| %i |",adj_mat[idx]);
    }
	fclose(f);
}
