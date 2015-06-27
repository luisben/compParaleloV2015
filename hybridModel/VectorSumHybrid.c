#include "mpi.h"
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){

double startall = omp_get_wtime();

int numprocs,rank,namelen;
char processor_name[MPI_MAX_PROCESSOR_NAME];

int size = 10000000;
int splitsize;
//make arrays
int *a = malloc(size * sizeof(int));
int *b = malloc(size * sizeof(int));
int *result = malloc(size * sizeof(int));
int idx = 0;

//init arrays with omp
double startparallel = omp_get_wtime();
#pragma omp parallel for
for(idx = 0;idx <size;idx++){
    a[idx]=idx;
    b[idx]=idx*2;
}

MPI_Init(&argc,&argv);
MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
MPI_Comm_rank(MPI_COMM_WORLD,&rank);
MPI_Get_processor_name(processor_name,&namelen);
splitsize = (int) size/numprocs;
int *sub_a = malloc(splitsize * sizeof(int));
MPI_Scatter(a,splitsize,MPI_INT,sub_a,splitsize,MPI_INT,0,MPI_COMM_WORLD);

int *sub_b = malloc(splitsize * sizeof(int));
MPI_Scatter(b,splitsize,MPI_INT,sub_b,splitsize,MPI_INT,0,MPI_COMM_WORLD);

int *sub_result = malloc(splitsize * sizeof(int));

idx = 0;
#pragma omp parallel default(shared) 
{
for(idx=0;idx<splitsize;idx++)
    sub_result[idx] = sub_a[idx]+sub_b[idx];
}

MPI_Gather(sub_result,splitsize,MPI_INT,result,splitsize,MPI_INT,0,MPI_COMM_WORLD);

MPI_Finalize();

if(rank==0){
	double endparallel = omp_get_wtime();
	printf("\n parallel time: %f  \n",endparallel-startparallel);
	for(idx=0;idx<size;idx+=(int) size/10)
		printf("\n results at %i  %i+%i=%i \n ",idx,a[idx],b[idx],result[idx]);
}

free(a);
free(b);
free(result);

free(sub_a);
free(sub_b);
free(sub_result);

if(rank==0){
	double endall = omp_get_wtime();
	printf("\n total time: %f  \n",endall-startall);
}
return 0;
}


