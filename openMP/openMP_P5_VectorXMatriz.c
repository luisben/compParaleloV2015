/*
Parallel and Distributed computing class
OpenMP

Practice 5: Parallelizing the product of 1 vector and 1 matrix.
*/

#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#include <stdint.h>

int main(){

int size = 1000;
float *mat = malloc(size * size * sizeof(float));
float *vec = malloc(size * sizeof(float));
float *result = malloc(size * sizeof(float));
float tmpResult;

int iteration = 0;
double total_time =0;
for(iteration=0;iteration<1;iteration++){

int idx_rows=0,idx_cols=0;
for(idx_rows=0;idx_rows<size;idx_rows++){
    vec[idx_rows] = idx_rows + 1.0f;
    for(idx_cols=0;idx_cols<size;idx_cols++)
        mat[idx_rows*size + idx_cols] = idx_rows * 2.0f;
}

printf("\n Multiply vector * matrix \n");
double start = omp_get_wtime();
omp_set_dynamic(0);
omp_set_num_threads(1);

#pragma omp parallel for \
private(tmpResult)
for(idx_rows=0;idx_rows<size;idx_rows++){
    tmpResult = 0;
    #pragma omp parallel for \
    reduction(+:tmpResult)
    for(idx_cols=0;idx_cols<size;idx_cols++)
        tmpResult += mat[idx_rows*size + idx_cols]*vec[idx_rows];
    result[idx_rows] = tmpResult;
}
double end = omp_get_wtime();

for(idx_rows=0;idx_rows<size;idx_rows+=size/10){
    printf("\n result[%i] = %f should be %i \n",idx_rows,result[idx_rows],(2*size*(idx_rows*idx_rows+idx_rows)));
}
printf("\n Vector * Matrix multiplication completed successfully in %f \n",end - start);
total_time += (end-start);
}
//result[idx] = (idx+1)(idx*2)*size = 2*size*(idx^2+idx)
printf("promedio de tiempo de ejecucion: %f",total_time/10);
free(mat);
free(vec);
free(result);

return 0;
}
