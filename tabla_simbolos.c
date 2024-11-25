#include "tabla_simbolos.h"
#include "scanner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIMBOLOS_MAX 50

typedef union { // Contiene la información de la variable
    char str[255];//254 elementos + 1 para el caracter nulo
    int entero;
} Contenido;

typedef struct {
    char id[33];//32 elementos + 1 para el caracter nulo
    int constante; // 1 si es constante, 0 si no
    int entero; // 1 si es int, 0 si es string
    int nuevo; // 1 si es nuevo, 0 si no
    Contenido contenido;

} Simbolo;

Simbolo tablaSimbolos[SIMBOLOS_MAX];
int cantSimbolos = 0;

int agregarSimbolo(const int permanencia, const int tipo, const char *id) {
    
    if(encontrarSimbolo(id) != -1){
        errorSemantico();
        printf("Redeclaración del simbolo %s.\n", id);
        return 0;
    }

    if(cantSimbolos >= SIMBOLOS_MAX){
        printf("Se ha alcanzado el máximo de símbolos (%d).\n", SIMBOLOS_MAX);
        return 0;
    }

        tablaSimbolos[cantSimbolos].constante = permanencia;
        tablaSimbolos[cantSimbolos].entero = tipo;
        tablaSimbolos[cantSimbolos].nuevo = 1;
        strcpy(tablaSimbolos[cantSimbolos].id, id);
        printf("Simbolo %s guardado (constante: %d, entero: %d nuevo: %d) en posición %d.\n", tablaSimbolos[cantSimbolos].id, tablaSimbolos[cantSimbolos].constante, tablaSimbolos[cantSimbolos].entero,tablaSimbolos[cantSimbolos].nuevo , cantSimbolos); //! Solo para testear. Borrar
        cantSimbolos++;
        return 1;
}

int encontrarSimbolo(const char *id) { //Devuelve la posición o -1 en caso de no encontrarlo
    for (int i = 0; i < cantSimbolos; i++) {
        if (strcmp(tablaSimbolos[i].id, id) == 0) {
            return i;
        }
    }
    return -1;
}

void errorSemantico() {
    printf("#%d Error semántico: ", yylineno);
}

void imprimirTablaSimbolos() {
    printf("Tabla de símbolos:\n");
    for (int i = 0; i < cantSimbolos; i++) {
        printf("Simbolo %s (constante: %d, entero: %d).\n", tablaSimbolos[i].id, tablaSimbolos[i].constante, tablaSimbolos[i].entero);
    }
}

void asignarEntero(const char *id, int entero) {
    int i = encontrarSimbolo(id);

    if (i == -1) {
        errorSemantico();
        printf("El simbolo %s no fue declarado.\n", id);
        return;
    }
    if (!tablaSimbolos[i].entero) { //Detecta si se está asignando un entero a un string
        errorSemantico();
        printf("Asignación str := int al simbolo %s (string)\n", id);
        return;
    }

    if (tablaSimbolos[i].constante && !tablaSimbolos[i].nuevo) {
        errorSemantico();
        printf("Asignación a constante ya instanciada (%s).\n", id);
        return;
    }

    //!Implementar que tire todos los errores

    tablaSimbolos[i].contenido.entero = entero;
    tablaSimbolos[i].nuevo = 0;
    printf("Asignación int := %d al simbolo %s en posición %d\n", tablaSimbolos[i].contenido.entero, id, i);
    return;
}