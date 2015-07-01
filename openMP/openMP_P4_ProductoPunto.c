/*
Parallel and Distributed computing class
OpenMP

Practice 2: Parallelizing the dot product of 2 vectors
*/

#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#include <stdint.h>
/*ejecuta varias veces el programa, que sucede, porque
Cada ejecucion resulta en un resultado diferente.
supongo que cada hilo esta escribiendo en su propio espacio de memoria, o compitiendo y sobreescribiendose unos a otros.
*/

int main(){

int size = 1000000;
int step_size  = (int) size/100;
uint64_t *a = malloc(size * sizeof(uint64_t) );
uint64_t *b = malloc(size * sizeof(uint64_t) );

int iteration = 0;
double total_time =0;
for(iteration=0;iteration<10;iteration++){


int idx=0,idx_n=0;
uint64_t result = 0;
for(idx=0;idx<size;idx++){
        a[idx] = idx_n;
        b[idx] = idx_n + 1 ;
        idx_n+=2;
}

printf("\n Dot product of two vectors \n");
idx =0, result=0;

double start = omp_get_wtime();
omp_set_dynamic(0);
omp_set_num_threads(300);
#pragma omp parallel for \
reduction(+:result)
for(idx=0;idx<size;idx++){
    uintmax_t tmpResult = a[idx]*b[idx];
    /*if(idx%step_size==0 || idx >= 1470 ){
        printf("\nresult at %i is %u",idx,result);
        printf("\n a * b are %i * %i = %u",a[idx],b[idx],tmpResult);
    }*/
    result += tmpResult;
}
double end = omp_get_wtime();
printf("\n Dot product completed successfully: %u\n",result);
total_time += (end-start);
}
printf("promedio de tiempo de ejecucion: %f",total_time/10);

free(a);
free(b);

return 0;
}
