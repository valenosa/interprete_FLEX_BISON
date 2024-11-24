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
    int entero; // 1 si es int, 0 si es string
    int constante; // 1 si es constante, 0 si no
    Contenido contenido;

} Simbolo;

Simbolo tablaSimbolos[SIMBOLOS_MAX];
int cantSimbolos = 0;

int agregarSimbolo(const char *id) {
    if (cantSimbolos < SIMBOLOS_MAX) {
        strcpy(tablaSimbolos[cantSimbolos].id, id);
        cantSimbolos++;
        return 1;
    }
    return 0;
}

int encontrarSimbolo(const char *id) {
    for (int i = 0; i < cantSimbolos; i++) {
        if (strcmp(tablaSimbolos[i].id, id) == 0) {
            return 1;
        }
    }
    return 0;
}