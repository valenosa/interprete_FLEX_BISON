#include "tabla_simbolos.h"
#include "scanner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//* Estructuras para el manejo de Tabla de Símbolos

#define SIMBOLOS_MAX 50

typedef union { // Contiene la información de la variable
    char str[255];//254 elementos + 1 para el caracter nulo
    int entero;
} Contenido; //! Meter la declaración en struct contenido

typedef struct {
    char id[33];//32 elementos + 1 para el caracter nulo
    int constante; // 1 si es constante, 0 si no
    int entero; // 1 si es int, 0 si es string
    int nuevo; // 1 si es nuevo, 0 si no
    Contenido contenido;

} Simbolo;

Simbolo tablaSimbolos[SIMBOLOS_MAX];
int cantSimbolos = 0;

//* Errores
int yysemerrs = 0; // errores semánticos

//*Lógica de las funciones

int agregarSimbolo(const int permanencia, const int tipo, const char *id) {
    
    if(encontrarSimbolo(id) != -1){
        errorSemantico();
        printf(", redeclaración del simbolo %s.\n", id);
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
    printf("Línea #%d: Error semántico", yylineno);
    ++yysemerrs;
    
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
        printf(", el simbolo %s no fue declarado.\n", id);
        return;
    }
    if (!tablaSimbolos[i].entero) { //Detecta si se está asignando un entero a un string
        errorSemantico();
        printf(", asignación str := int al simbolo %s (string)\n", id);
        return;
    }

    if (tablaSimbolos[i].constante && !tablaSimbolos[i].nuevo) {
        errorSemantico();
        printf(", asignación a constante ya instanciada (%s).\n", id);
        return;
    }

    //!Implementar que tire todos los errores

    tablaSimbolos[i].contenido.entero = entero;
    tablaSimbolos[i].nuevo = 0; //!meter en condicional
    printf("Asignación int := %d al simbolo %s en posición %d\n", tablaSimbolos[i].contenido.entero, id, i);
    return;
}

//!En un futuro deberia intentar unificar asignarEntero() con asignarString()
void asignarString(const char *id, char *string) {
    int i = encontrarSimbolo(id);

    if (i == -1) {
        errorSemantico();
        printf(", el simbolo %s no fue declarado.\n", id);
        return;
    }
    if (tablaSimbolos[i].entero) { //Detecta si se está asignando un string a un entero
        errorSemantico();
        printf(", asignación int := str al simbolo %s (int)\n", id);
        return;
    }

    if (tablaSimbolos[i].constante && !tablaSimbolos[i].nuevo) {
        errorSemantico();
        printf(", asignación a constante ya instanciada (%s).\n", id);
        return;
    }

    //!Implementar que tire todos los errores
    sacarComillas(string);
    strcpy(tablaSimbolos[i].contenido.str, string);
    // printf("String: %s ", string);
    // printf("Contenido: %s ", tablaSimbolos[i].contenido.str);
    tablaSimbolos[i].nuevo = 0; //! mover a un if
    printf("Asignación str := \"%s\" al simbolo %s en posición %d\n", tablaSimbolos[i].contenido.str, id, i);
    return;
}

void sacarComillas(char *cadena) { //Intenté hacer que la REGEX de la string no identifique la comillas y se detecte en la GIC una cadena entre comillas, pero detectaba cualquier cosa como string
    size_t len = strlen(cadena);

    // Verificar que la cadena tenga al menos dos caracteres y que comience y termine con comillas
    if (len >= 2 && cadena[0] == '"' && cadena[len - 1] == '"') {
        // Mover todos los caracteres una posición hacia la izquierda
        memmove(cadena, cadena + 1, len - 2);
        // Añadir el carácter nulo al final de la cadena
        cadena[len - 2] = '\0';
    }
}

int contenidoEntero(int *temp, const char *id) {
    int i = encontrarSimbolo(id);

    if (i == -1) {
        errorSemantico();
        printf(", operación con simbolo no declarado (%s).\n", id);
        printf("Exit\n");
        return 0; //! Esto no debería devolver nada ya que dado el caso de que no exista el simbolo, no puedo hacer la operación. reemplazar con exit
    }
    if (!tablaSimbolos[i].entero){
        errorSemantico();
        printf(", el simbolo %s no es un entero.\n", id);
        printf("Exit\n");
        return 0;
    }

    *temp = tablaSimbolos[i].contenido.entero;
    return 1;
}

int contenidoString(char * str, const char *id) {
    int i = encontrarSimbolo(id);

    if (i == -1) {
        errorSemantico();
        printf(", operación con simbolo no declarado (%s).\n", id);
        printf("Exit\n");
        return 0; //! Esto no debería devolver nada ya que dado el caso de que no exista el simbolo, no puedo hacer la operación. reemplazar con exit
    }

    if (tablaSimbolos[i].entero) { // Detecta si se está intentando obtener un string de un entero
        errorSemantico();
        printf(", el simbolo %s no es un string.\n", id);
        printf("Exit\n");
        return 0; // Indicar error
    }

    strcpy(str, tablaSimbolos[i].contenido.str);
    return 1; // Indicar éxito
}

int tipo(const char *id){
    int i = encontrarSimbolo(id);

    if (i == -1) {
        errorSemantico();
        printf(", operación con simbolo no declarado (%s).\n", id);
        printf("Exit\n");
        return 0; //! Esto no debería devolver nada ya que dado el caso de que no exista el simbolo, no puedo hacer la operación. reemplazar con exit
    }

    return tablaSimbolos[i].entero;
}

void escribirElemento(Elemento elem) {
    switch (elem.tipo) {
        case ID_TYPE:
            if(tipo(elem.valor.id)){
                int temp;
                contenidoEntero(&temp, elem.valor.id);
                printf("%d", temp);
            } else {
                char str[255];
                contenidoString(str, elem.valor.id);
                printf("%s", str);
            }
            break;
        case CONST_TYPE:
            printf("%d", elem.valor.val);
            break;
        case STRING_TYPE:
            sacarComillas(elem.valor.str);
            printf("%s", elem.valor.str);
            break;
    }
}