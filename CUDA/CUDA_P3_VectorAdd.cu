#include <stdio.h>
#define N 4194304
#define THREADS 64

__global__ void vecAdd(int *a, int *b, int *c){
	
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	if(tid < N )
		c[tid] = a[tid] + b[tid];
}

int main(int argc, char* argv[]){

	int *a,*b,*c;
	int *dev_a,*dev_b,*dev_c;
	int totalSize = N*sizeof(int);
	int idx;
	int size,blocks,threads;
	
	
	float total_time;
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	size = N;
	blocks = size/THREADS;
	threads = THREADS;

	cudaMalloc((void**)&dev_a,totalSize);
	cudaMalloc((void**)&dev_b,totalSize);
	cudaMalloc((void**)&dev_c,totalSize);

	a = (int*) malloc(totalSize);
	b = (int*) malloc(totalSize);
	c = (int*) malloc(totalSize);
	
	for(idx=0;idx<N;idx++){
		a[idx] = idx;
		b[idx] = idx*2;
	}

	cudaMemcpy(dev_a,a,totalSize,cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,totalSize,cudaMemcpyHostToDevice);

	
	int iteration = 0;
	float avg_time = 0.0;
	for(iteration=0;iteration<10;iteration++){
	//call kernel and measure times
	cudaEventRecord(start,0);
	vecAdd<<<blocks,threads>>>(dev_a,dev_b,dev_c);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&total_time,start,stop);
	printf("\n time for %i blocks of %i threads : %f \n",blocks,threads,total_time);
	avg_time+=total_time;
	}
	avg_time/=10.0;
	printf("average time for %i size vector mult is %f ",size,avg_time);
	cudaMemcpy(c,dev_c,totalSize,cudaMemcpyDeviceToHost);
/*
	for(idx=0;idx<N;idx++)
		printf("\n%i+%i=%i\n",a[idx],b[idx],c[idx]);
*/
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	return 0;
}


