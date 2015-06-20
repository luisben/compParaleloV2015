#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char** argv) {
MPI_Init(0,0);
//get number of processes
int world_size1;
MPI_Comm_size(MPI_COMM_WORLD,&world_size1);
int world_rank1;
MPI_Comm_rank(MPI_COMM_WORLD,&world_rank1);
char processor_name1[MPI_MAX_PROCESSOR_NAME];
int name_len;
MPI_Get_processor_name(processor_name1,&name_len);
printf("Hola Mundo!!! desde el procesador %s, rank %d out of %d processors\n",processor_name1, world_rank1, world_size1);
MPI_Finalize();
}
