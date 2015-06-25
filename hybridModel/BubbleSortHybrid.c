#include "mpi.h"
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){

int iteration =0;
double totaltime=0;





int numprocs,rank,namelen;
char processor_name[MPI_MAX_PROCESSOR_NAME];
MPI_Init(&argc,&argv);

for (iteration=0;iteration<10;iteration++){


srand(19813267);
int size = 10000;
int splitsize;
//make arrays
int *a = malloc(size * sizeof(int));
int *result = malloc(size * sizeof(int));
int idx = 0;

//init arrays with omp
double startparallel = omp_get_wtime();
#pragma omp parallel for
for(idx = 0;idx <size;idx++){
    a[idx]=rand();
}

MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
MPI_Comm_rank(MPI_COMM_WORLD,&rank);
MPI_Get_processor_name(processor_name,&namelen);
splitsize = (int) size/numprocs;
int *sub_a = malloc(splitsize * sizeof(int));
MPI_Scatter(a,splitsize,MPI_INT,sub_a,splitsize,MPI_INT,0,MPI_COMM_WORLD);

int *sub_result = malloc(splitsize * sizeof(int));

idx = 0;
int idx2 = 0;
int tmp;
//sort subarray
for(idx=0;idx<splitsize-2;idx++)
if(idx%2==0)
#pragma omp parallel default(shared) 
{
for(idx2=0;idx2<(splitsize/2)-1;idx2++)
    if(sub_a[2*idx2] < sub_a[2*idx2 +1]){
	tmp = sub_a[2*idx2];
	sub_a[2*idx2] = sub_a[2*idx2 +1];
	sub_a[2*idx2 +1] = tmp;
	}
}
else
#pragma omp parallel default(shared) 
{
for(idx2=0;idx2<(splitsize/2)-2;idx2++)
    if(sub_a[2*idx2+1] < sub_a[2*idx2 +2]){
        tmp = sub_a[2*idx2+1];
        sub_a[2*idx2+1] = sub_a[2*idx2 +2];
        sub_a[2*idx2 +2] = tmp; 
        }
}

MPI_Gather(sub_a,splitsize,MPI_INT,result,splitsize,MPI_INT,0,MPI_COMM_WORLD);

//sort results gain
for(idx=0;idx<size-2;idx++)
if(idx%2==0)
#pragma omp parallel default(shared) 
{
for(idx2=0;idx2<(size/2)-1;idx2++)
    if(result[2*idx2] < result[2*idx2 +1]){
        tmp = result[2*idx2];
        result[2*idx2] = result[2*idx2 +1];
        result[2*idx2 +1] = tmp; 
        }
}
else
#pragma omp parallel default(shared) 
{
for(idx2=0;idx2<(size/2)-2;idx2++)
    if(result[2*idx2+1] < result[2*idx2 +2]){
        tmp = result[2*idx2+1];
        result[2*idx2+1] = result[2*idx2 +2];
        result[2*idx2 +2] = tmp; 
        }
}



if(rank==0){
//	for(idx=0;idx<size;idx+=(int) size/10)
//		printf("\n results at %i is %i \n ",idx,result[idx]);
	double endparallel = omp_get_wtime();
	printf("\n parallel time: %f  \n",endparallel-startparallel);
	totaltime += (endparallel-startparallel);

}

free(a);
free(result);

free(sub_a);
free(sub_result);


}

MPI_Finalize();

printf("average time : %f:",totaltime/10.0f);

return 0;
}


