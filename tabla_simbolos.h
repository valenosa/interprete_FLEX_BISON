#ifndef TABLA_SIMBOLOS_H
#define TABLA_SIMBOLOS_H

extern int yysemerrs;

int agregarSimbolo(const int permanencia, const int tipo, const char *id);
int encontrarSimbolo(const char *id);
void asignarEntero(const char *id, int entero);
void asignarString(const char *id, const char *string);

void imprimirTablaSimbolos();

void errorSemantico();

int contenidoEntero(int *temp, const char *id);
int contenidoString(char *str, const char *id);

int tipo(const char *id);

#endif // TABLA_SIMBOLOS_H