/*
Parallel and Distributed computing class
OpenMP

Practice 6: Parallelizing the product of 2 matrices.
*/

#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#include <stdint.h>

int main(){

int size = 100;
float *matA = malloc(size * size * sizeof(float));
float *matB = malloc(size * size * sizeof(float));
float *result = malloc(size * size * sizeof(float));
float tmpResult;

int idx_rows=0,idx_cols=0,idx_results=0;
for(idx_rows=0;idx_rows<size;idx_rows++){
    for(idx_cols=0;idx_cols<size;idx_cols++){
        matA[idx_rows*size + idx_cols] = idx_rows;
        matB[idx_rows*size + idx_cols] = idx_rows;
    }
}
/*
for(idx_rows=0;idx_rows<size;idx_rows++)
    for(idx_cols=0;idx_cols<size;idx_cols++)
        printf("\n matA[%i][%i] = %f\n",idx_rows,idx_cols,matA[idx_rows*size+idx_cols]);

for(idx_rows=0;idx_rows<size;idx_rows++)
    for(idx_cols=0;idx_cols<size;idx_cols++)
        printf("\n matB[%i][%i] = %f \n",idx_rows,idx_cols,matB[idx_rows*size+idx_cols]);
*/
printf("\n Multiply matrix * matrix \n");
double start = omp_get_wtime();
for(idx_results=0;idx_results<size;idx_results++)
#pragma omp parallel for \
reduction(+:tmpResult) \
num_threads(1)
    for(idx_rows=0;idx_rows<size;idx_rows++){
        tmpResult = 0;
        for(idx_cols=0;idx_cols<size;idx_cols++)
            tmpResult += matA[idx_results*size + idx_cols]*matB[idx_cols*size+idx_rows];
        result[idx_results*size + idx_rows] = tmpResult;
    }
double end = omp_get_wtime();

for(idx_rows=0;idx_rows<size;idx_rows++)
    for(idx_cols=0;idx_cols<size;idx_cols++)
        printf("\n result[%i][%i] = %f",idx_rows,idx_cols,result[idx_rows*size+idx_cols]);

printf("\n Matrix * Matrix multiplication completed successfully in %f\n",end - start);

//result[idx] = (idx*idx)*size

free(matA);
free(matB);
free(result);

return 0;
}
