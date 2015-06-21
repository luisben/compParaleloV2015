#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#define  PING_PONG_LIMIT  4
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


int ping_pong_count = 0;
int partner_rank = (world_rank + 1) % 2;
while(ping_pong_count < PING_PONG_LIMIT){
    if(world_rank==ping_pong_count%2){
	ping_pong_count++;
	MPI_Send(&ping_pong_count,1,MPI_INT,partner_rank,0,MPI_COMM_WORLD);
	printf("%i sent and incremented ping_pong_count %i to %i \n",world_rank,ping_pong_count,partner_rank);
    } else {
	MPI_Recv(&ping_pong_count,1,MPI_INT,partner_rank,0,MPI_COMM_WORLD,MPI_STATUS_IGNORE);
        printf("%i received ping_pong_count %i from %i 0\n",world_rank,ping_pong_count,partner_rank);
    }
}
MPI_Finalize();
}
