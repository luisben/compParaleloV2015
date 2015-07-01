#include <stdio.h>
#define THREADS 64

__global__ void vecSum(int *a, int *b, int size){
	
	__shared__ int c[THREADS];
	int tid = blockDim.x*blockIdx.x+threadIdx.x;
	int stid = threadIdx.x;
	if(tid < size){
		c[stid] = a[tid];
		c[stid] += b[tid];
	}
		__syncthreads();
	if(tid < size){
		a[tid] = c[stid];
	}
	
}

int main(int argc, char* argv[]){

	//initialization code
	int size,threads,blocks;
	float total_time;
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	size = 2048*2048;
	blocks = size/THREADS;
	threads = THREADS;
	while(blocks*threads < size)
		blocks++;
	int totalSize = size * sizeof(int);
	
	int *a,*b,*dev_a,*dev_b;

	cudaMalloc((void**)&dev_a,totalSize);
	cudaMalloc((void**)&dev_b,totalSize);

	a = (int*) malloc(totalSize);
	b = (int*) malloc(totalSize);
	//end mallocs

	int idx;

	for(idx=0;idx<size;idx++){
		a[idx] = idx;
		b[idx] = idx*2;
	}
	
	//copy to dev
	cudaMemcpy(dev_a,a,totalSize,cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,totalSize,cudaMemcpyHostToDevice);

	int iteration = 0;
	float avg_time = 0.0;
	for(iteration=0;iteration<10;iteration++){
	//call kernel and measure times
	cudaEventRecord(start,0);
	vecSum<<<blocks,threads>>>(dev_a,dev_b,size);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&total_time,start,stop);
	printf("\n time for %i blocks of %i threads : %f \n",blocks,threads,total_time);
	avg_time+=total_time;
	}
	avg_time/=10.0;
	printf("average time for %i size vector mult is %f ",size,avg_time);
	//copy back and prints
	cudaMemcpy(a,dev_a,totalSize,cudaMemcpyDeviceToHost);
	for(idx=0;idx<size;idx+=size/5)
		printf("\n a[%i]=%i\n",idx,a[idx]);
 
	//free
	free(a);
	free(b);

	cudaFree(dev_a);
	cudaFree(dev_b);
	
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
		
	return 0;
}


