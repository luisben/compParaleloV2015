/*
Parallel and Distributed computing class
OpenMP

Practice 2: Parallelizing the dot product of 2 vectors
*/

#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#include <stdint.h>

int main(){

int size = 100;
float *mat = malloc(size * size * sizeof(float));
float *vec = malloc(size * sizeof(float));
float *result = malloc(size * sizeof(float));
float tmpResult;

int idx_rows=0,idx_cols=0;
for(idx_rows=0;idx_rows<size;idx_rows++){
    vec[idx_rows] = idx_rows + 1.0f;
    for(idx_cols=0;idx_cols<size;idx_cols++)
        mat[idx_rows*size + idx_cols] = idx_rows * 2.0f;
}

printf("\n Multiply vector * matrix \n");
double start = omp_get_wtime();
#pragma omp parallel for \
reduction(+:tmpResult)
for(idx_rows=0;idx_rows<size;idx_rows++){
    tmpResult = 0;
    for(idx_cols=0;idx_cols<size;idx_cols++)
        tmpResult += mat[idx_rows*size + idx_cols]*vec[idx_rows];
    result[idx_rows] = tmpResult;
}
double end = omp_get_wtime();

for(idx_rows=0;idx_rows<size;idx_rows++){
    printf("\n result[%i] = %f should be %i \n",idx_rows,result[idx_rows],(2*size*(idx_rows*idx_rows+idx_rows)));
}
printf("\n Vector * Matrix multiplication completed successfully in %f\n",end - start);

//result[idx] = (idx+1)(idx*2)*size = 2*size*(idx^2+idx)

free(mat);
free(vec);
free(result);

return 0;
}
