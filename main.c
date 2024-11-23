/*
Grupo 4
Integrantes: Copa, Rocío Belén; Iglesias, Tobías; Salinas, Julián
*/

#include <stdio.h>
#include "parser.h"

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
	
	printf("\nErrores sintácticos: %d - Errores léxicos: %d\n", yynerrs, yylexerrs);

	return 0;
}