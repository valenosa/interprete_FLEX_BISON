/*
Grupo 4
Integrantes: Copa, Rocío Belén; Iglesias, Tobías; Salinas, Julián
*/

#include <stdio.h>
#include "parser.h"
#include "tabla_simbolos.h"

extern int yynerrs;
int yylexerrs = 0;

int main(void){	
	switch(yyparse()){
		case 0:
			printf("\nCompilación terminada con éxito");
			break;		
		case 1:
			printf("\nErrores de compilación");
			break;
		case 2:
			printf("\nNo hay memoria suficiente");
			break;		
		}
	
	printf("\nErrores sintácticos: %d - Errores léxicos: %d - Errores semánticos: %d\n", yynerrs, yylexerrs, yysemerrs);

	return 0;
}