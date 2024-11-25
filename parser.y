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
}

%token <val> CONST_INT
%token <str> LITERAL_CADENA

%type <val> expresion_c constante_op tipo
%type <str> expresion_s

%type <str> programa_micro lista_sentencias sentencia error

%token <str> ENTERO LEER ESCRIBIR INICIO FIN ID ASIGNACION CONSTANTE STRING

%left '+' '-'
%precedence NEG

%%

programa_micro: INICIO { printf("inicio\n\n"); } lista_sentencias FIN { printf("\nfin\n"); }
                { if (yynerrs || yylexerrs) YYABORT; else YYACCEPT; };

lista_sentencias: sentencia lista_sentencias 
                | %empty
                ;

             constante_op tipo ID';' {if(!agregarSimbolo($1, $2, $3)){errorSemantico("Redeclaración del simbolo", $3);};} //!
sentencia:  | ID ASIGNACION expresion_c ';' {} //! Chequear que exista el id, y que su tipo coincida con el de la expresion
            | ID ASIGNACION expresion_s ';' {}
            | constante_op tipo ID ASIGNACION expresion_c ';' {} //!
            | constante_op tipo ID ASIGNACION expresion_s ';' {}
            | LEER '(' lista_identificadores ')' ';' { printf("leer\n"); }
            | ESCRIBIR '(' lista_expresiones ')' ';' { printf("escribir\n"); }
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
            | ID { /* Manejo de identificadores */ } //! hay que verificar que el tipo coincida
            ;

expresion_s:   LITERAL_CADENA { $$ = $1; }
            | ID { /* Manejo de identificadores */ } //! hay que verificar que el tipo coincida
            ;

lista_identificadores:    lista_identificadores ',' ID 
                        | ID
                        ;

%%

void yyerror(const char *msg) {
    printf("Línea #%d: %s\n", yylineno, msg);
    return;
}
