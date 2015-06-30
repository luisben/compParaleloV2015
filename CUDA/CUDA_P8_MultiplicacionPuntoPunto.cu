#include <stdio.h>

__global__ void kernel(int *d, int n){
	
	__shared__ int s[64];
	int tid = threadIdx.x;
	int tr + n - tid - 1;
	s[tid] = d[tid]
	_synchthreads();
	d[tid] = s[tr];
}

int main(int argc, char* argv[]){

	//initialization code
	int size,threads;
	float total_time;
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	size = 1000;
	int totalSize = size * sizeof(int);
	
	int *a,*r,*d,dev_d;

	cudaMalloc((void**)&dev_d,totalSize);

	a = (int*) malloc(totalSize);
	r = (int*) malloc(totalSize);
	d = (int*) malloc(totalSize);
	//end mallocs

	//problem specific
	int idx;

	for(idx=0;idx<size;idx++){
		a[idx] = idx;
		r[idx] = size-idx-1;
		d[idx] = 0;
	}
	
	//copy to dev
	cudaMemcpy(dev_d,a,totalSize,cudaMemcpyHostToDevice);
	
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
	cudaMemcpy(d,dev_d,totalSize,cudaMemcpyDeviceToHost);
	for(idx=0;idx<size;idx+=size/5)
		printf("\n a[%i]=%i\n",idx,c[idx]);
 
	for(idx = 0;idx < n; idx++)
		if(d[i] != r[i])
			printf(”Verificar- Hay un error”); 
 
	//free
	free(a);
	free(r);
	free(d);

	cudaFree(dev_d);
	
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
		
	return 0;
}


