#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]){

int numprocs,rank,namelen;
char processor_name[MPI_MAX_PROCESSOR_NAME];

int size = 100000;
int splitsize;
//make arrays
int *a = malloc(size * sizeof(int));
int result = 0;
int idx = 0;
int sub_result = 0;
float start,end;

for(idx = 0;idx <size;idx++){
    a[idx]=idx;
}

MPI_Init(&argc,&argv);
MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
MPI_Comm_rank(MPI_COMM_WORLD,&rank);

MPI_Barrier(MPI_COMM_WORLD);
start = MPI_Wtime();

splitsize = (int) size/numprocs;
int *sub_a = malloc(splitsize * sizeof(int));
int *sub_results = malloc(numprocs * sizeof(int));

MPI_Scatter(a,splitsize,MPI_INT,sub_a,splitsize,MPI_INT,0,MPI_COMM_WORLD);

for(idx=0;idx<splitsize;idx++)
    sub_result += sub_a[idx];

MPI_Gather(&sub_result,1,MPI_INT,sub_results,1,MPI_INT,0,MPI_COMM_WORLD);

for(idx=0;idx<numprocs;idx++)
    result += sub_results[idx];

MPI_Barrier(MPI_COMM_WORLD);
end = MPI_Wtime();

MPI_Finalize();

if(rank==0){
	printf("\n results is %i, should be %i  \n ",result,(size*(size-1))/2);
	printf("\n time was : %f %f ",end,start);
}

free(a);

free(sub_a);
free(sub_results);

return 0;
}

