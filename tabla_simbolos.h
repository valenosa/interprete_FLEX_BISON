#ifndef TABLA_SIMBOLOS_H
#define TABLA_SIMBOLOS_H

//Estructuras para el manejo de datos
#define MAX_RW 100

typedef enum { ID_TYPE, CONST_TYPE, STRING_TYPE } TipoElemento; //? Podría usar esto para reemplazar los defines?

typedef struct {
    TipoElemento tipo;
    union {
        char *id;
        int val;
        char *str;
    } valor;
} Elemento;

typedef struct {
    Elemento elementos[MAX_RW];
    int count;
} ListaElementos;

// Errores
extern int yysemerrs;

// Funciones
int agregarSimbolo(const int permanencia, const int tipo, const char *id);
int encontrarSimbolo(const char *id);
void asignarEntero(const char *id, int entero);
void asignarString(const char *id, char *string);

void imprimirTablaSimbolos();

void errorSemantico();

int contenidoEntero(int *temp, const char *id);
int contenidoString(char *str, const char *id);

int tipo(const char *id);

void escribirElemento(Elemento elem);

void sacarComillas(char *cadena);
#endif // TABLA_SIMBOLOS_H