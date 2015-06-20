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

int size = 1500;
int step_size  = (int) size/100;
uint64_t *a = malloc(size * sizeof(uint64_t) );
uint64_t *b = malloc(size * sizeof(uint64_t) );

int idx=0,idx_n=0;
uint64_t result = 0;
for(idx=0;idx<size;idx++){
        a[idx] = idx_n;
        b[idx] = idx_n + 1 ;
        idx_n+=2;
}
printf("ends in idx:%i, a:%u,n:%u",idx,a[idx-1],b[idx-1]);

printf("\n Dot product of two vectors \n");
idx =0, result=0;

double start = omp_get_wtime();
#pragma omp parallel for \
reduction(+:result) 
for(idx=0;idx<size;idx++){
	if(idx >= 1470)
	printf("\npartial result at %i is  %u, + %u*%u\n",idx,result,a[idx],b[idx]);
	result += (uint64_t) a[idx]*b[idx];
}
double end = omp_get_wtime();
printf("\n Dot product completed successfully: %u\n",result);

free(a);
free(b);

return 0;
}
