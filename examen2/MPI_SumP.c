#include <mpi.h>
#include <stdio.h>

int main(int argc, char *argv[]){

int rank, finalP=0,myP;

MPI_Init(&argc,&argv);
MPI_Comm_rank(MPI_COMM_WORLD,&rank);

myP = rank+1;

MPI_Reduce(&myP,&finalP,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);

MPI_Finalize();

if(rank==0)
	printf("\nP es : %i\n",finalP);

return 0;
}

