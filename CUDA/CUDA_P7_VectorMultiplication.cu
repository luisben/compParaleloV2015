#include <stdio.h>

__global__ void vecMult(int *a, int *b, int *c, int length){
	
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	if(tid < length)
		c[tid] = a[tid] * b[tid];
}

int main(int argc, char* argv[]){

	//initialization code
	int size,threads,blocks,totalSize;
	float total_time;
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	if(argv[2])
		size = atoi(argv[2]);
	else 
		size = 65536;
	if(argv[1])
		threads = atoi(argv[1]);
	else
		threads = 64;
	blocks = (size/threads);
	if(blocks*threads != size)
		blocks++;
	totalSize = size*sizeof(int);
	printf("\n%i blocks of %i threads = %i threads total \n",blocks,threads,blocks*threads);
	//end init
	
	//start mallocs
	int *a,*dev_a,*b,*dev_b,*c,*dev_c;

	cudaMalloc((void**)&dev_a,totalSize);
	cudaMalloc((void**)&dev_b,totalSize);
	cudaMalloc((void**)&dev_c,totalSize);

	a = (int*) malloc(totalSize);
	b = (int*) malloc(totalSize);
	c = (int*) malloc(totalSize);
	//end mallocs

	//problem specific
	int idx;

	for(idx=0;idx<size;idx++){
		a[idx] = idx;
		b[idx] = idx*2;
	}
	
	//copy to dev
	cudaMemcpy(dev_a,a,totalSize,cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,totalSize,cudaMemcpyHostToDevice);
	//end copy
	
	int iteration = 0;
	float avg_time = 0.0;
	for(iteration=0;iteration<10;iteration++){
	//call kernel and measure times
	cudaEventRecord(start,0);
	vecMult<<<blocks,threads>>>(dev_a,dev_b,dev_c,size);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&total_time,start,stop);
	printf("\n time for %i blocks of %i threads : %f \n",blocks,threads,total_time);
	avg_time+=total_time;
	}
	avg_time/=10.0;
	printf("average time for %i size vector mult is %f ",size,avg_time);
	//copy back and prints
	cudaMemcpy(c,dev_c,totalSize,cudaMemcpyDeviceToHost);
	for(idx=0;idx<size;idx+=size/5)
		printf("\n a[%i]=%i\n",idx,c[idx]);
 
	//free
	free(a);
	free(b);
	free(c);

	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
		
	return 0;
}


