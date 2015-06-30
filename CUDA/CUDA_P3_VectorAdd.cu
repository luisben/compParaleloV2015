#include <stdio.h>
#define N 10

__global__ void vecAdd(int *a, int *b, int *c){
	
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	if(tid < N )
		c[tid] = a[tid] + b[tid];
}

int main(int argc, char* argv[]){

	int a[N],b[N],c[N];
	int *dev_a,*dev_b,*dev_c;
	int totalSize = N*sizeof(int);
	int idx;

	cudaMalloc((void**)&dev_a,totalSize);
	cudaMalloc((void**)&dev_b,totalSize);
	cudaMalloc((void**)&dev_c,totalSize);

	for(idx=0;idx<N;idx++){
		a[idx] = idx;
		b[idx] = idx*2;
	}

	cudaMemcpy(dev_a,a,totalSize,cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,totalSize,cudaMemcpyHostToDevice);

	vecAdd<<<2,5>>>(dev_a,dev_b,dev_c);

	cudaMemcpy(c,dev_c,totalSize,cudaMemcpyDeviceToHost);

	for(idx=0;idx<N;idx++)
		printf("\n%i+%i=%i\n",a[idx],b[idx],c[idx]);

	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	return 0;
}


