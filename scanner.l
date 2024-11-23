%{
    #include "parser.h"
    #include "string.h"
    #include <stdio.h>
    char msg[80];
%}

%option outfile="scanner.c"
%option header-file="scanner.h"
%option noinput
%option nounput
%option yylineno

digito_decimal      [0-9]
letra               [a-zA-Z_] 
espacio             [[:space:]]
identificador       {letra}({letra}|{digito_decimal})* 
constante_entera    {digito_decimal}+
cualquier_caracter  . 

/* otros representa caracteres no alfanuméricos, excluyendo espacios y operadores especificados */
otros               [[:^alnum:]]{-}[[:space:]]{-}[-+*/();,>%]

%%
entero                               return ENTERO;
leer                                 return LEER;
escribir                             return ESCRIBIR;
programa                             return PROGRAMA;
fin-programa                         return FIN_PROGRAMA;
{identificador}                      yylval = strdup(yytext); return ID;
{constante_entera}                   yylval = strdup(yytext); return CONSTANTE;
":="                                 return ASIGNACION;
"+"                                  return '+';
"-"                                  return '-';
"*"                                  return '*';                                
"/"                                  return '/';
"%"                                  return '%';
","                                  return ',';
"("                                  return '(';
")"                                  return ')';
";"                                  return ';';
{espacio}+                           ;
"//"{cualquier_caracter}*            ;

{identificador}{otros}({letra}|{digito_decimal}|{otros})*   {yylexerrs++; strcat(strcpy(msg, "Error léxico: identificador inválido: "), yytext); yyerror(msg);}
{constante_entera}({letra}|{digito_decimal})*               {yylexerrs++; strcat(strcpy(msg, "Error léxico: Constante Inválida: "), yytext); yyerror(msg);}
{otros}+                                                    {yylexerrs++; strcat(strcpy(msg, "Error léxico: Cadena inválida: "), yytext); yyerror(msg);}
