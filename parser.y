%code top {
    #include <stdio.h>
    #include "scanner.h"
    #include "tabla_simbolos.h"

    // Valores utilizados para identificar tipos y constantes en tabla_simbolos
    #define CONST 1 
    #define VAR 0
    #define CONST 1
    #define INT 1
    #define STR 0
}

%code requires {

    #define MAX_IDENTIFICADORES 100

    typedef struct {
        char *ids[MAX_IDENTIFICADORES];
        int count;
    } ListaIdentificadores;

}

%code provides {
    void yyerror(const char *);
    extern int yylexerrs;
}
    

%defines "parser.h"
%output "parser.c"

%define parse.error verbose

%start programa_micro

%union {
    int val;
    char *str;
    ListaIdentificadores ids;
}

%token <val> CONST_INT
%token <str> LITERAL_CADENA

%type <val> expresion_c constante_op tipo
%type <str> expresion_s

%type <str> programa_micro lista_sentencias sentencia error

%type <ids> lista_identificadores

%token <str> ENTERO LEER ESCRIBIR INICIO FIN ID ASIGNACION CONSTANTE STRING

%left '+' '-'
%precedence NEG

%%

programa_micro: INICIO { printf("inicio\n\n"); } lista_sentencias FIN { printf("\nfin\n"); }
                { if (yynerrs || yylexerrs) YYABORT; else YYACCEPT; };//?

lista_sentencias: sentencia lista_sentencias 
                | %empty
                ;

sentencia:    constante_op tipo ID';' {agregarSimbolo($1, $2, $3);} //? Que pasa si supero el limite del array?
            | ID ASIGNACION ID ';' { 
                if (tipo($1) != tipo($3)){ 
                    errorSemantico();
                    printf(", asignación entre tipos incompatibles\n");
                } 
                else { 
                    if (tipo($1) == INT) {
                        int temp;
                        contenidoEntero(&temp, $3);
                        asignarEntero($1, temp);
                    } 
                    else { 
                        char buffer[255]; 
                        contenidoString(buffer, $3);      
                        asignarString($1, buffer); 
                    } 
                } 
            }
            | ID ASIGNACION expresion_c ';' {asignarEntero($1, $3);}
            | ID ASIGNACION expresion_s ';' {asignarString($1, $3);}
            | constante_op tipo ID ASIGNACION ID ';' { 
                if ($2 != tipo($5)){ 
                    errorSemantico();
                    printf(", asignación entre tipos incompatibles\n");
                } 
                else { 
                    if(agregarSimbolo($1, $2, $3)){

                        if ($2 == INT) {
                            int temp;
                            contenidoEntero(&temp, $5);
                            asignarEntero($3, temp);
                        } 
                        else { 
                            char buffer[255]; 
                            contenidoString(buffer, $5);      
                            asignarString($3, buffer); 
                        } 
                    }
                } 

            }
            | constante_op tipo ID ASIGNACION expresion_c ';' {if(agregarSimbolo($1, $2, $3)){asignarEntero($3, $5);};} //!
            | constante_op tipo ID ASIGNACION expresion_s ';' {if(agregarSimbolo($1, $2, $3)){asignarString($3, $5);};}
            | LEER '(' lista_identificadores ')' ';' {
                            for (int i = 0; i < $3.count; i++) { //!Esto es un asco, hay que delegarlo a funciones
                                char type[7];
                                if (tipo($3.ids[i]) == INT) {
                                    strcpy(type, "entero");
                                } 
                                if (tipo($3.ids[i]) == STR) {
                                    strcpy(type, "string");
                                }
                                printf("Ingrese valor para %s (%s): ", $3.ids[i], type);
                                if (tipo($3.ids[i]) == INT) {
                                    int temp;
                                    scanf("%d", &temp); //!No me deja hacer el scanf
                                    asignarEntero($3.ids[i], 123);
                                } else {
                                    char buffer[255];
                                    scanf("%s", buffer); //!No me deja hacer el scanf
                                    asignarString($3.ids[i], "test");
                                }
                            }
                        }
            | ESCRIBIR '(' lista_expresiones ')' ';' {}
            | error ';' //manejo de error
            ;

constante_op:    CONSTANTE {$$ = CONST;} //?
             | %empty {$$ = VAR;} //?
             ;

tipo:     ENTERO {$$ = INT;} //?
        | STRING {$$ = STR;} //?
        ;

lista_expresiones:    lista_expresiones expresion 
                    | expresion
                    ;   

expresion:      expresion_c
              | expresion_s
              ;

expresion_c:    expresion_c '+' expresion_c { $$ = $1 + $3; } //! hay que verifica los tipos
            | expresion_c '-' expresion_c { $$ = $1 - $3; }
            | '-' expresion_c %prec NEG { $$ = -$2; }
            | '(' expresion_c ')' { $$ = $2; }
            | CONST_INT { $$ = $1; }
            |ID {if(tipo($1) != INT){errorSemantico(); printf("operación aritmética con string\n"); $$ = 0;} else{int temp; contenidoEntero(&temp, $1); $$ = temp;}}
            ;

expresion_s:   LITERAL_CADENA { $$ = $1; }
            ;

lista_identificadores:    lista_identificadores ',' ID {
                                if ($1.count < MAX_IDENTIFICADORES) {
                                    $1.ids[$1.count] = strdup($3);
                                    $1.count++;
                                    $$ = $1;
                                } else {
                                    yyerror("Demasiados identificadores en la lista");
                                }
                            }   
                        | ID {
                            ListaIdentificadores lista;
                            lista.ids[0] = strdup($1);
                            lista.count = 1;
                            $$ = lista;
                        }
                        ;

%%

void yyerror(const char *msg) {
    printf("Línea #%d: %s\n", yylineno, msg);
    return;
}
