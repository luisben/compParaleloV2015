#include <stdio.h>

__global__ void holaCUDA(float e) {
	printf("Hola, soy el hilo %i del bloque %i con valor pi -> %f \n",threadIdx.x,blockIdx.x,e);
}

int main(int argc, char **argv){
	holaCUDA<<<3,4>>>(3.1416);
	cudaDeviceReset();
	return 0;
}