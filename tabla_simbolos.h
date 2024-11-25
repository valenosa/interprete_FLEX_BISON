#ifndef TABLA_SIMBOLOS_H
#define TABLA_SIMBOLOS_H

int agregarSimbolo(const int permanencia, const int tipo, const char *id);
int encontrarSimbolo(const char *id);
void asignarEntero(const char *id, int entero);
void asignarString(const char *id, const char *string);

void imprimirTablaSimbolos();

void errorSemantico();


#endif // TABLA_SIMBOLOS_H