#ifndef TABLA_SIMBOLOS_H
#define TABLA_SIMBOLOS_H

int agregarSimbolo(const int permanencia, const int tipo, const char *id);
int encontrarSimbolo(const char *id);

void errorSemantico(const char *err, const char *id);

#endif // TABLA_SIMBOLOS_H