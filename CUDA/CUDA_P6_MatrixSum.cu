#include <stdio.h>

__global__ void vecMatSum(int *a, int *b, int *c, int width, int length){
	
	int row = blockIdx.x*blockDim.x + threadIdx.x;
	int col = blockIdx.y*blockDim.y + threadIdx.y;
	int tid = row*width+col;
	if(tid < length)
		c[tid] = a[tid] + b[tid];
}

int main(int argc, char* argv[]){

	//initialization code
	int width,size,threads,blocks,totalSize;
	float total_time;
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	if(argv[2])
		width = atoi(argv[2]);
	else 
		width = 300;
	size = width*width;
	if(argv[1])
		threads = atoi(argv[1]);
	else
		threads = 16;
	dim3 ThreadsInBlock(threads,threads); //will provide threads * threads threads
	blocks = (int) sqrt((float) size / (float) (threads*threads));
	dim3 BlockDim(blocks,blocks);
	while(BlockDim.x*BlockDim.y*threads*threads < size)
		BlockDim.y += 1;
	totalSize = size*sizeof(int);
	printf("\n%ix%i blocks of %ix%i threads = %i threads total \n",BlockDim.x,BlockDim.y,ThreadsInBlock.x,ThreadsInBlock.y,BlockDim.x*BlockDim.y*ThreadsInBlock.x*ThreadsInBlock.y);
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
	float avg_time = 0;
	for(iteration=0;iteration<10;iteration++){
	//call kernel and measure times
	cudaEventRecord(start,0);
	vecMatSum<<<BlockDim,ThreadsInBlock>>>(dev_a,dev_b,dev_c,width,size);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&total_time,start,stop);
	printf("\n time for %i blocks of %i threads : %f \n",blocks,threads,total_time);
	avg_time+=total_time;
	}
	avg_time/=10.0;
	printf("average time for %ix%i matrix sum is %f ",width,width,avg_time);
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


