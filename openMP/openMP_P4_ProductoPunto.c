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
int step_size = size/10;
int *a = malloc(size * sizeof(int) );
int *b = malloc(size * sizeof(int) );

int idx=0,idx_a=0,idx_b=0;
uintmax_t result=0;
for(idx=0;idx<size*2;idx++){
    if(idx%2==0){
        a[idx_a] = idx;
        idx_a++;
    }else{
        b[idx_b] = idx;
        idx_b++;
    }
}
printf("\n Dot product of two vectors \n");
idx =0, result=0;

double start = omp_get_wtime();
//#pragma omp parallel for \
reduction(+:result) \
ordered
for(idx=0;idx<size;idx++){
    uintmax_t tmpResult = a[idx]*b[idx];
    if(/*idx%step_size==0 ||*/ idx >= 1470 ){
        printf("\nresult at %i is %u",idx,result);
        printf("\n a * b are %i * %i = %u",a[idx],b[idx],tmpResult);
    }
    result += tmpResult;
}
double end = omp_get_wtime();
printf("\n Dot product completed successfully: %u\n",result);

free(a);
free(b);

return 0;
}
