#include <omp.h>
#include <stdio.h>


int main(){

    printf("Este es nuestro primer ejemplo en OpenMP\n");
    #pragma omp parallel
    {
        printf("Hola mundo\n");
    }
    printf("La version instalada de OpenMP es: %d\n\n",_OPENMP);
    return 0;
}


/*
cuantas veces se imprime?
4
porque?
es el numero default de hilos en esta maquina, que tiene 4 procesadores

que version de openmp tienes?
201107
 */
