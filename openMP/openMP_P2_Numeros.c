/******************************************************************************
* FILE: omp_hello.c
* DESCRIPTION:
*   OpenMP Example - Hello World - C/C++ Version
*   In this simple example, the master thread forks a parallel region.
*   All threads in the team obtain their unique thread number and print it.
*   The master thread only prints the total number of threads.  Two OpenMP
*   library routines are used to obtain the number of threads and each
*   thread's number.
* AUTHOR: Blaise Barney  5/99
* LAST REVISED: 04/06/05
******************************************************************************/
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

int main (int argc, char *argv[])
{
int nthreads, numprocs, tid, maxthreads;
printf("Este es nuestro segundo ejemplo en OpenMP\n");
//omp_set_dynamic(0);
//omp_set_num_threads(2);
/* Fork a team of threads giving them their own copies of variables */
#pragma omp parallel private(nthreads, tid)
  {

  /* Obtain thread number */
  tid = omp_get_thread_num();
  nthreads = omp_get_num_threads();
  printf("%i:Hello World from thread = %i out of %i\n", tid,tid,nthreads);

  /* Only master thread does this */
  if (tid == 0)
    {
    numprocs = omp_get_num_procs();
    maxthreads = omp_get_max_threads();
    printf("Number of threads = %d\n", nthreads);
    printf("Number of processors available : %d\n", numprocs);
    printf("Maximum number of threads : %d\n", maxthreads);
    }

  }  /* All threads join master thread and disband */

}

