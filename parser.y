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

    #include "tabla_simbolos.h"

    typedef struct {
        char *ids[MAX_RW];
        int count;
    } ListaIdentificadores;

    
}

%code provides {
    void yyerror(const char *);
    extern int yylexerrs;

    #define ABORT_PARSER() do {if(use_yyabort){printf("Exit\n"); YYABORT;} } while (0) //Se usa el while (0) para evitar errores por ejemplo al usar el macro en un if sin {}, lo que haria que solo se ejecute la primer sentencia y daría error sintáctico. el while(0) hace que se comporte como una única instruccion
}


    

%defines "parser.h"
%output "parser.c"

%define parse.error verbose

%start programa_micro

%union {
    int val;
    char *str;
    ListaIdentificadores ids;
    ListaElementos lista_elem;
    Elemento elem;
}

%token <val> CONST_INT
%token <str> LITERAL_CADENA

%type <val> expresion_c constante_op tipo
%type <str> expresion_s

%type <str> programa_micro lista_sentencias sentencia error

%type <ids> lista_identificadores

%type <lista_elem> lista_elementos

%type <elem> elemento

%token <str> ENTERO LEER ESCRIBIR INICIO FIN ID ASIGNACION CONSTANTE STRING

%left '+' '-'
%precedence NEG

%%

programa_micro: INICIO { printf("inicio\n\n"); } lista_sentencias FIN { printf("\nfin\n"); }
                { if (yynerrs || yylexerrs) YYABORT; else YYACCEPT; };//?

lista_sentencias: sentencia lista_sentencias 
                | %empty
                ;

sentencia:    constante_op tipo ID';' {if(!agregarSimbolo($1, $2, $3)){ABORT_PARSER();}} //? Que pasa si supero el limite del array?
            | ID ASIGNACION ID ';' { 
                if (tipo($1) != tipo($3)){ 
                    errorSemantico();
                    printf(", asignación entre tipos incompatibles\n");
                    ABORT_PARSER();
                } 
                else { 
                    if (tipo($1) == INT) {
                        int temp;
                        contenidoEntero(&temp, $3);
                        if(!asignarEntero($1, temp)){ABORT_PARSER();}
                            
                    } 
                    else { 
                        char buffer[255]; 
                        contenidoString(buffer, $3);      
                        if(!asignarString($1, buffer)){ABORT_PARSER();}
                    } 
                } 
            }
            | ID ASIGNACION expresion_c ';' {if(!asignarEntero($1, $3)){ABORT_PARSER();}}
            | ID ASIGNACION expresion_s ';' {if(!asignarString($1, $3)){ABORT_PARSER();}}
            | constante_op tipo ID ASIGNACION ID ';' { 
                if ($2 != tipo($5)){ 
                    errorSemantico();
                    printf(", asignación entre tipos incompatibles\n");
                    ABORT_PARSER();
                } 
                else { 
                    if(agregarSimbolo($1, $2, $3)){

                        if ($2 == INT) {
                            int temp;
                            if(contenidoEntero(&temp, $5)){ABORT_PARSER();}
                            if(asignarEntero($3, temp)){ABORT_PARSER();}
                        } 
                        else { 
                            char buffer[255]; 
                            if(contenidoString(buffer, $5)){ABORT_PARSER();}      
                            if(asignarString($3, buffer)){ABORT_PARSER();}
                        } 
                    }
                    else{ABORT_PARSER();}
                } 

            }
            | constante_op tipo ID ASIGNACION expresion_c ';' {if(agregarSimbolo($1, $2, $3)){if(asignarEntero($3, $5)){ABORT_PARSER();}} else{ABORT_PARSER();}} //!
            | constante_op tipo ID ASIGNACION expresion_s ';' {if(agregarSimbolo($1, $2, $3)){if(asignarString($3, $5)){ABORT_PARSER();}} else{ABORT_PARSER();}}
            | LEER '(' lista_identificadores ')' ';' {
                            for (int i = 0; i < $3.count; i++) { //!Esto es un asco, hay que delegarlo a funciones
                                int type = tipo($3.ids[i]);
                                char typeStr[7];
                                if(type == -1){
                                    ABORT_PARSER();
                                }
                                if (type == INT) {
                                    strcpy(typeStr, "entero");
                                } 
                                if (type == STR) {
                                    strcpy(typeStr, "string");
                                }
                                printf("Ingrese valor para %s (%s): ", $3.ids[i], typeStr);
                                if (type == INT) {
                                    int temp;
                                    scanf("%d", &temp); //!No me deja hacer el scanf
                                    if(asignarEntero($3.ids[i], 123)){ABORT_PARSER();}
                                } else {
                                    char buffer[255];
                                    scanf("%s", buffer); //!No me deja hacer el scanf
                                    if(asignarString($3.ids[i], "test")){ABORT_PARSER();}
                                }
                            }
                        }
            | ESCRIBIR '(' lista_elementos ')' ';' {
                            for (int i = 0; i < $3.count; i++) {
                                escribirElemento($3.elementos[i]);
                            }
                        }
            | error ';' //manejo de error
            ;

constante_op:    CONSTANTE {$$ = CONST;} //?
             | %empty {$$ = VAR;} //?
             ;

tipo:     ENTERO {$$ = INT;} //?
        | STRING {$$ = STR;} //?
        ;

lista_identificadores:    lista_identificadores ',' ID {
                                if ($1.count < MAX_RW) {
                                    $1.ids[$1.count] = strdup($3);
                                    $1.count++;
                                    $$ = $1;
                                } else {
                                    yyerror("Demasiados identificadores en la lista");
                                    ABORT_PARSER();
                                }
                            }   
                        | ID {
                            ListaIdentificadores lista;
                            lista.ids[0] = strdup($1);
                            lista.count = 1;
                            $$ = lista;
                        }
                        ;

lista_elementos: lista_elementos ',' elemento {
                    if ($1.count < MAX_RW) {
                        $1.elementos[$1.count] = $3;
                        $1.count++;
                        $$ = $1;
                    } else {
                        yyerror("Demasiados elementos en la lista");
                        ABORT_PARSER();
                    }
                }
              | elemento {
                    ListaElementos lista;
                    lista.elementos[0] = $1;
                    lista.count = 1;
                    $$ = lista;
                }
              ;

elemento: ID {
            Elemento elem;
            elem.tipo = ID_TYPE;
            elem.valor.id = strdup($1);
            $$ = elem;
        }
        | expresion_c {
            Elemento elem;
            elem.tipo = CONST_TYPE;
            elem.valor.val = $1;
            $$ = elem;
        }
        | expresion_s {
            Elemento elem;
            elem.tipo = STRING_TYPE;
            elem.valor.str = strdup($1);
            $$ = elem;
        }
        ;

expresion:      expresion_c
              | expresion_s
              ;

expresion_c:    expresion_c '+' expresion_c { $$ = $1 + $3; }
            | expresion_c '-' expresion_c { $$ = $1 - $3; }
            | '-' expresion_c %prec NEG { $$ = -$2; }
            | '(' expresion_c ')' { $$ = $2; }
            | CONST_INT { $$ = $1; }
            |ID {if(tipo($1) != INT){errorSemantico(); printf("operación aritmética con string\n"); $$ = 0; ABORT_PARSER();} else{int temp; if(contenidoEntero(&temp, $1)){ABORT_PARSER();}; $$ = temp;}}
            ;

expresion_s:   LITERAL_CADENA { $$ = $1; }
            ;



%%

void yyerror(const char *msg) {
    printf("Línea #%d: %s\n", yylineno, msg);
    return;
}
