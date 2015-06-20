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

int size = 1173;
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
printf("idx_a ends at %i, idx_b ends at %i\n",idx_a,idx_b);
printf("\na ends at %i, b ends at %i\n",a[size-1],b[size-1]);
printf("\n Dot product of two vectors \n");
idx =0, result=0;

printf("pre-eliminary results are : %i \n",result);
double start = omp_get_wtime();
//#pragma omp parallel for \
reduction(+:result) \
ordered
for(idx=0;idx<size;idx++){
    if(idx%10000==0 || idx >= size - 1 ){
        printf("\nresult at %i is %i",idx,result);
        printf("\n a and b at %i are %i and %i",idx,a[idx],b[idx]);
    }
    int tmpResult = a[idx]*b[idx];
    result += tmpResult;
    if(idx%10000==0 || idx >= size - 1 ){
        printf("\n result at %i is %i",idx,result);
        printf("\n a*b at %i is  %i ",idx,a[idx]*b[idx]);
        printf("\n a*b at %i is  %i ",idx,tmpResult);

    }
}
double end = omp_get_wtime();
printf("\n end at %i \n",idx);
printf("\n Dot product completed successfully: %i\n",result);

free(a);
free(b);

return 0;
}
