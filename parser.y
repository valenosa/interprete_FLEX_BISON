%code top {
    #include <stdio.h>
    #include "scanner.h"
    #include "symbol_table.h"
}

%code provides {
    void yyerror(const char *);
    extern int yylexerrs;
}

%defines "parser.h"
%output "parser.c"

%define api.value.type {char *}
%define parse.error verbose

%start programa_mini

%token ENTERO LEER ESCRIBIR PROGRAMA FIN_PROGRAMA IDENTIFICADOR CONSTANTE ASIGNACION

%left '+' '-'
%left '*' '/' '%'
%precedence NEG

%%

programa_mini: PROGRAMA IDENTIFICADOR { printf("programa %s\n", yylval); } lista_sentencias FIN_PROGRAMA 
                { if (yynerrs || yylexerrs) YYABORT; else YYACCEPT; };

lista_sentencias: sentencia lista_sentencias 
                | %empty
                ;

sentencia:    IDENTIFICADOR ASIGNACION expresion ';' { printf("asignación\n"); }
            | ENTERO IDENTIFICADOR ';'  { printf("entero %s\n", yylval); }
            | LEER '(' lista_identificadores ')' ';' { printf("leer\n"); }
            | ESCRIBIR '(' lista_expresiones ')' ';' { printf("escribir\n"); }
            | error ';'
            ;

lista_expresiones:    lista_expresiones expresion 
                    | expresion
                    ;

expresion:    expresion '+' expresion { printf("suma\n"); }
            | expresion '-' expresion { printf("resta\n"); }
            | '-' expresion %prec NEG { printf("inversión\n"); }
            | expresion '*' expresion { printf("multiplicación\n"); }
            | expresion '/' expresion { printf("división\n"); }
            | expresion '%' expresion { printf("módulo\n"); }
            | '(' expresion ')' { printf("paréntesis\n"); }
            | CONSTANTE
            | IDENTIFICADOR
            ;

lista_identificadores:    lista_identificadores ',' IDENTIFICADOR 
                        | IDENTIFICADOR
                        ;

%%

void yyerror(const char *msg) {
    printf("Línea #%d: %s\n", yylineno, msg);
    return;
}
