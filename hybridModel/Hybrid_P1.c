/*
Ejemplo por default de
mpi+openmp
*/
#include <stdio.h>
#include "mpi.h"
#include <omp.h>
int main(int argc,char *argv[]) {
int numprocs,rank,namelen;
char processor_name[MPI_MAX_PROCESSOR_NAME];
int soy = 0,np = 1;

MPI_Init(&argc, &argv);
//inicia el paralelismo con mpi
MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
 //obtiene el número de proceso
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
// rango. Cantidad de procesos totales
MPI_Get_processor_name(processor_name, &namelen);
//nombre de la computadora
  #pragma omp parallel default(shared) \
  private(soy,np)
  {
    np  = omp_get_num_threads();
//obtiene el número de hilos totales
    soy = omp_get_thread_num();
    //obtiene el número del hilo dentro del total
printf("Hola... Desde el hilo %d de un total de %d hilos ejecutado dentro del proceso %d de un total de %d procesos en %s\n",soy,np,rank,numprocs,processor_name);
  }
  printf("Np, soy : %i,%i",np,soy);
MPI_Finalize();
//finaliza paralelismo con mpi
}
