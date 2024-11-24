%code top {
    #include <stdio.h>
    #include "scanner.h"
    #include "tabla_simbolos.h"
}

%code provides {
    void yyerror(const char *);
    extern int yylexerrs;
}

%defines "parser.h"
%output "parser.c"

%define api.value.type {char *}
%define parse.error verbose

%start programa_micro

%token ENTERO LEER ESCRIBIR INICIO FIN ID CONST_INT ASIGNACION LITERAL_CADENA CONSTANTE STRING

%left '+' '-'
%precedence NEG

%%

programa_micro: INICIO { printf("inicio\n\n"); } lista_sentencias FIN { printf("\nfin\n"); }
                { if (yynerrs || yylexerrs) YYABORT; else YYACCEPT; };

lista_sentencias: sentencia lista_sentencias 
                | %empty
                ;

sentencia:    ID ASIGNACION expresion ';' {} //! Chequear que exista el id, y que su tipo coincida con el de la expresion
            | CONSTANTE ENTERO ID ASIGNACION expresion ';' {} //! Guarda que al tener expresiones como 2 - (514 + 4) se asigna solo el 2
            | CONSTANTE STRING ID ASIGNACION LITERAL_CADENA ';' {} //!
            | ENTERO ID ASIGNACION expresion ';' {} //!
            | STRING ID ASIGNACION LITERAL_CADENA ';' {} //! 
            | ENTERO ID ';'  {} //! Chequear que no se haya creado antes
            | CONSTANTE ENTERO ID ';' {} //! Chequear que no se haya creado antes
            | STRING ID ';' {} //! Chequear que no se haya creado antes
            | CONSTANTE STRING ID ';' {} //! Chequear que no se haya creado antes
            | LEER '(' lista_identificadores ')' ';' { printf("leer\n"); }
            | ESCRIBIR '(' lista_expresiones ')' ';' { printf("escribir\n"); }
            | error ';'
            ;

lista_expresiones:    lista_expresiones expresion 
                    | expresion
                    ;

expresion:    expresion '+' expresion {}
            | expresion '-' expresion {}
            | '(' expresion ')' {}
            | CONST_INT 
            | ID
            ;

lista_identificadores:    lista_identificadores ',' ID 
                        | ID
                        ;

%%

void yyerror(const char *msg) {
    printf("Línea #%d: %s\n", yylineno, msg);
    return;
}
