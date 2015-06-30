#include <stdio.h>
#include <time.h>

__global__ void vecAdd(int *a, int *b, int *c, int length){
	
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	if(tid < length)
		c[tid] = a[tid] + b[tid];
}

int main(int argc, char* argv[]){

	int size = 16384;
	int *a,*b,*c;
	int *dev_a,*dev_b,*dev_c;
	int totalSize = size*sizeof(int);
	int idx;
	//timemeasure
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float time_128,time_256,time_512;
	
	cudaMalloc((void**)&dev_a,totalSize);
	cudaMalloc((void**)&dev_b,totalSize);
	cudaMalloc((void**)&dev_c,totalSize);

	a = (int*) malloc(totalSize);
	b = (int*) malloc(totalSize);
	c = (int*) malloc(totalSize);
	
	for(idx=0;idx<size;idx++){
		a[idx] = idx;
		b[idx] = idx+1;
	}

	cudaMemcpy(dev_a,a,totalSize,cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,totalSize,cudaMemcpyHostToDevice);
	
	cudaEventRecord(start,0);
	vecAdd<<<512,32>>>(dev_a,dev_b,dev_c,size);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time_512,start,stop);
	printf("time for 512 blocks of 32 threads : %f",time_512);
	
	cudaMemcpy(c,dev_c,totalSize,cudaMemcpyDeviceToHost);
	for(idx=0;idx<size;idx+=size/5)
		printf("\n%i+%i=%i\n",a[idx],b[idx],c[idx]);
	
	cudaEventRecord(start,0);
	vecAdd<<<256,64>>>(dev_a,dev_b,dev_c,size);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time_256,start,stop);
	printf("time for 256 blocks of 64 threads : %f",time_256);
	
	cudaMemcpy(c,dev_c,totalSize,cudaMemcpyDeviceToHost);
	for(idx=0;idx<size;idx+=size/5)
		printf("\n%i+%i=%i\n",a[idx],b[idx],c[idx]);
	
	cudaEventRecord(start,0);
	vecAdd<<<128,128>>>(dev_a,dev_b,dev_c,size);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time_128,start,stop);
	printf("time for 128 blocks of 128 threads : %f",time_128);

	cudaMemcpy(c,dev_c,totalSize,cudaMemcpyDeviceToHost);
	for(idx=0;idx<size;idx+=size/5)
		printf("\n%i+%i=%i\n",a[idx],b[idx],c[idx]);

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


