#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char** argv) {
// Initialize the MPI environment
MPI_Init(NULL, NULL);
// Find out rank, size
int world_rank;
MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
int world_size;
MPI_Comm_size(MPI_COMM_WORLD, &world_size);
// We are assuming at least 2 processes for this task
if (world_size < 2) {
printf("World size must be greater than 1 for %s\n", argv[0]);
MPI_Abort(MPI_COMM_WORLD, 1);
}
int number;
    MPI_Request sendRequest;
    MPI_Status sendStatus;
    MPI_Request receiveRequest;
    MPI_Status receiveStatus;
if(world_rank==0){
    number = -1;
    MPI_Isend(&number,1,MPI_INT,1,0,MPI_COMM_WORLD,&sendRequest);
} else if(world_rank==1){
    MPI_Irecv(&number,1,MPI_INT,0,0,MPI_COMM_WORLD,&receiveRequest);
    MPI_Wait(&receiveRequest,&receiveStatus);
    printf("Process 1 received number %d from process 0\n",number);
}

if(world_rank==0){
MPI_Wait(&sendRequest,&sendStatus);
}

MPI_Finalize();
}
