%{
#include <stdio.h>
#include <stdlib.h>
#include "part3_helpers.hpp"
#include "parser.h"
void errorHandler(const char *lexeme, int line);
%}

%option yylineno noyywrap
%option outfile="lexer.c" header-file="lexer.h"

digit       [0-9]
letter      ([a-zA-Z])
escaped     (\\[tn\"\\])
relop       (==|<>|<|<=|>|>=)
addop       (\+|\-)
mulop       (\*|\/)
assign      =
and         (&&)
or          (\|\|)
not         !
whitespace  ([\t\n ])
punctuation ([(){};:,])

%%
"#"[^\n]*                       ;  // Ignore comments
{whitespace}                    ;  // Ignore whitespaces
"int"                           { return TK_INT; }
"float"                         { return TK_FLOAT; }
"void"                          { return TK_VOID; }
"return"                        { return TK_RETURN; }
"write"                         { return TK_WRITE; }
"read"                          { return TK_READ; }
"if"                            { return TK_IF; }
"then"                          { return TK_THEN; }
"else"                          { return TK_ELSE; }
"while"                         { return TK_WHILE; }
"do"                            { return TK_DO; }
"va_arg"                        { return TK_VA_ARG; }
{assign}                        { return TK_ASSIGN; }
{or}                            { return TK_OR; }
{and}                           { return TK_AND; }
{not}                           { return TK_NOT; }
{relop}                         { yylval.name = yytext; return TK_RELOP; }
{addop}                         { yylval.name = yytext; return TK_ADDOP; }
{mulop}                         { yylval.name = yytext; return TK_MULOP; }
{letter}({letter}|{digit}|_)*   { yylval.name = yytext; return TK_ID; }
{digit}+                        { yylval.name = yytext; return TK_INTEGERNUM; }
{digit}+"."{digit}+             { yylval.name = yytext; return TK_REALNUM; }
\"([^\"\\\n]|{escaped})*\"      { char *stripped = strdup(yytext + 1); // Skip the leading quote
                                  stripped[strlen(stripped) - 1] = '\0'; // Remove the trailing quote
                                  yylval.name = stripped;
                                  return TK_STR; }
{punctuation}                   { if (strcmp(yytext, "(") == 0) return '(';
                                  if (strcmp(yytext, ")") == 0) return ')';
                                  if (strcmp(yytext, "{") == 0) return '{';
                                  if (strcmp(yytext, "}") == 0) return '}';
                                  if (strcmp(yytext, ";") == 0) return ';';
                                  if (strcmp(yytext, ":") == 0) return ':';
                                  if (strcmp(yytext, ",") == 0) return ',';
                                  return yytext[0]; }  // Return punctuation directly
"..."                           { return TK_ELLIPSIS; }
"."                               errorHandler(yytext, yylineno);
%%

void errorHandler(const char *lexeme, int line) {
    printf("Lexical error: '%s' in line number %d\n", lexeme, line);
    exit(1);  // Stop execution
}
