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

%start programa_micro

%token ENTERO LEER ESCRIBIR INICIO FIN ID CONSTANTE ASIGNACION

%left '+' '-'
%left '*' '/' '%'
%precedence NEG

%%

programa_micro: INICIO { printf("inicio\n\n"); } lista_sentencias FIN { printf("\nfin\n"); }
                { if (yynerrs || yylexerrs) YYABORT; else YYACCEPT; };

lista_sentencias: sentencia lista_sentencias 
                | %empty
                ;

sentencia:    ID ASIGNACION expresion ';' { printf("asignación\n"); }
            | ENTERO ID ';'  { printf("int %s\n", yylval); }
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
