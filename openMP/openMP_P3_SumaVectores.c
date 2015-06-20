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
//omp_set_dynamic(0);
//omp_set_num_threads(2);
printf("Omp start time: %d\n",omp_get_wtime());

#pragma omp parallel for
for(i=0; i<size; ++i){
    c[i] = a[i]+b[i];
}
printf("Omp end time: %d\n",omp_get_wtime());
}

int main(){

int size = 10000000;
int *a = malloc(size * sizeof(int) );
int *b = malloc(size * sizeof(int) );
int *c = malloc(size * sizeof(int) );

int idx=0;
for(idx=0;idx<size;idx++){
    c[idx] = 0;
    b[idx] = idx;
    a[idx] = idx*2;
}


int main(){

int size = 10000000;
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

return 0;
}
