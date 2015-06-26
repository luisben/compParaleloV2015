/*
Parallel and Distributed computing class
OpenMP

Practice 3: Parallelizing the sum of 2 vectors
*/

#include <stdio.h>
#include <omp.h>
#include <stdlib.h>

void Suma_Vec(int* a, int* b, int* c, int size){
int i = 0;
#pragma omp parallel for
for(i=0; i<size; ++i)
    c[i] = a[i]+b[i];
}

int main(){
double start = omp_get_wtime();
int size = 50000000;
int *a = malloc(size * sizeof(int) );
int *b = malloc(size * sizeof(int) );
int *c = malloc(size * sizeof(int) );

int idx=0;
for(idx=0;idx<size;idx++){
    c[idx] = 0;
    b[idx] = idx;
    a[idx] = idx*2;
}

printf("\nSuma paralela de dos vectores\n");
Suma_Vec(a,b,c,size);
printf("Suma_Vec completed successfully\n");

free(a);
free(b);
free(c);

double end = omp_get_wtime();
printf("Omp end time: %f\n",end-start);

return 0;
}
