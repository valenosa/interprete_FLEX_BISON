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
literal_cadena              \"[^\"]{0,255}\"
constante_entera    {digito_decimal}+
cualquier_caracter  . 

/* otros representa caracteres no alfanuméricos, excluyendo espacios y operadores especificados */
otros               [[:^alnum:]]{-}[[:space:]]{-}[-+*/();,>%]

%%
const                                return CONSTANTE;
int                                  return ENTERO;
string                               return STRING;
leer                                 return LEER;
escribir                             return ESCRIBIR;
inicio                               return INICIO;
fin                                  return FIN;
{identificador}                      yylval.str = strdup(yytext); return ID;
{literal_cadena}                     yylval.str = strdup(yytext); return LITERAL_CADENA;
{constante_entera}                   yylval.val = atoi(yytext); return CONST_INT;
":="                                 return ASIGNACION;
"+"                                  return '+';
"-"                                  return '-';
","                                  return ',';
"("                                  return '(';
")"                                  return ')';
";"                                  return ';';
{espacio}+                           ;
"//"{cualquier_caracter}*            ;

{identificador}{otros}({letra}|{digito_decimal}|{otros})*   {yylexerrs++; strcat(strcpy(msg, "Error léxico: identificador inválido: "), yytext); yyerror(msg);}
{constante_entera}({letra}|{digito_decimal})*               {yylexerrs++; strcat(strcpy(msg, "Error léxico: Constante Inválida: "), yytext); yyerror(msg);}
{otros}+                                                    {yylexerrs++; strcat(strcpy(msg, "Error léxico: Cadena inválida: "), yytext); yyerror(msg);}
