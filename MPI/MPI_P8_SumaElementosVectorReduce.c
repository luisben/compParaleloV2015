#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]){

int numprocs,rank,namelen;
char processor_name[MPI_MAX_PROCESSOR_NAME];

int size = 1000;
int splitsize;
//make arrays
int *a = malloc(size * sizeof(int));
int result = 0;
int idx = 0;
int sub_result = 0;

for(idx = 0;idx <size;idx++){
    a[idx]=idx;
}

MPI_Init(&argc,&argv);
MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
MPI_Comm_rank(MPI_COMM_WORLD,&rank);

splitsize = (int) size/numprocs;
int *sub_a = malloc(splitsize * sizeof(int));

MPI_Scatter(a,splitsize,MPI_INT,sub_a,splitsize,MPI_INT,0,MPI_COMM_WORLD);

for(idx=0;idx<splitsize;idx++)
    sub_result += sub_a[idx];

MPI_Reduce(&sub_result,&result,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);

MPI_Finalize();

if(rank==0){
	printf("\n results is %i, should be %i  \n ",result,(size*(size-1))/2);
}

free(a);

free(sub_a);

return 0;
}

