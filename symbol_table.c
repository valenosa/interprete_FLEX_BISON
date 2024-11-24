#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 50

typedef union { // Contiene la información de la variable
    char str[255];//254 elementos + 1 para el caracter nulo
    int entero;
} Contenido;

typedef struct {
    char name[33];//32 elementos + 1 para el caracter nulo
    int entero; // 1 si es int, 0 si es string
    int constante; // 1 si es constante, 0 si no
    Contenido contenido;

} Symbol;

Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

int addSymbol(const char *name) {
    if (symbolCount < MAX_SYMBOLS) {
        strcpy(symbolTable[symbolCount].name, name);
        symbolCount++;
        return 1;
    }
    return 0;
}

int findSymbol(const char *name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return 1;
        }
    }
    return 0;
}