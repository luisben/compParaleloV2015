#include <stdio.h>

__global__ void vecIncrease(int *a, int amount, int length){
	
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	if(tid < length)
		a[tid]+=amount;
}

int main(int argc, char* argv[]){

	//generic initialization code
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

	//end generic
	//start mallocs
	int *a,*dev_a;

	cudaMalloc((void**)&dev_a,totalSize);
	a = (int*) malloc(totalSize);
	//end mallocs

	//problem specific
	int idx,incr_amount;
	incr_amount=5;

	for(idx=0;idx<size;idx++){
		a[idx] = idx;
	}
	
	//copy to dev
	cudaMemcpy(dev_a,a,totalSize,cudaMemcpyHostToDevice);
	//end copy
	
	//call kernel and measure times
	cudaEventRecord(start,0);
	vecIncrease<<<blocks,threads>>>(dev_a,incr_amount,size);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&total_time,start,stop);
	printf("\n time for %i blocks of %i threads : %f \n",blocks,threads,total_time);
	
	//copy back and prints
	cudaMemcpy(a,dev_a,totalSize,cudaMemcpyDeviceToHost);
	for(idx=0;idx<size;idx+=size/5)
		printf("\n a[%i]=%i\n",idx,a[idx]);
 
	//free
	free(a);

	cudaFree(dev_a);
	
	cudaEventDestroy(start);
	cudaEventDestroy(stop);

	return 0;
}


