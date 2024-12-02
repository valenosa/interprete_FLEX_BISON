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

	int choice;
    char filename[256];

	printf("Seleccione modo:\n0. Modo debug\n1. Modo de corte\n");
	scanf("%d", &use_yyabort);
	
	printf("Seleccione entrada:\n0. Ingresar texto por consola\n1. Redirigir entrada desde un archivo\n");
    scanf("%d", &choice);

	if (choice == 1) {
        printf("Ingrese el nombre del archivo: ");
        scanf("%s", filename);
        freopen(filename, "r", stdin); // Redirigir la entrada estándar desde el archivo
    } else if (choice != 0) {
        printf("Opción no válida.\n");
        return 1;
    }


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