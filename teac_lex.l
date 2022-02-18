%{						/********* definitions *********/
#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "teac_parser.tab.h"
#include "cgen.h"

int line_num = 1;
%}

/*
IDENT 					[a-zA-Z]+([a-zA-Z]|[0-9]|[_])*
DIGIT  					[0-9]
NUMBER  				{DIGIT}{DIGIT}*
DECIMAL 				("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL    				{DECIMAL}([eE][+-]?{NUMBER})?
STRING  				'[^'\n]*'
*/

IDENT					[a-zA-Z_][0-9a-zA-Z_]*
INT 					(([1-9]+[0-9]*)|0)
REAL					({INT}[.][0-9]+("e"|"E")?("+"|"-")?[0]?[1-9][0-9]*)
BOOLEAN 				[true|false]
STRING 					'[^'\n]*'

ECHAR					[\n|\t|\r|\\|\"]
CONST 					({STRING}|{ECHAR})["\n"]'

%x comment

%%						/********** rules **********/

start					return KW_START;
const 					return KW_CONST;
let						return KW_LET;

int         			return KW_INT;
real         			return KW_REAL;
string       			return KW_STRING;
bool					return KW_BOOLEAN;

true					return KW_TRUE;
false					return KW_FALSE;
if 						return KW_IF;
then 					return KW_THEN;
else 					return KW_ELSE;
fi						return KW_FI;
while					return KW_WHILE;
loop 					return KW_LOOP;
pool 					return KW_POOL;
return 					return KW_RETURN;
not 					return KW_NOT;
and 					return KW_AND;
or 						return KW_OR;

{IDENT}  	   			{yylval.crepr = strdup(yytext); return IDENT;}
{INT}					{yylval.crepr = strdup(yytext); return POSINT;}
{REAL}					{yylval.crepr = strdup(yytext); return REAL;}
{BOOLEAN} 				{yylval.crepr = strdup(yytext); return BOOLEAN;}
{STRING}				{yylval.crepr = strdup(yytext); return STRING;}

"<-"		      		return ASSIGN;
"=>"         			return ARROW;
"!="					return NOT_EQUAL;
"<="					return SMALLER_THAN_EQUAL;
"="						return '=';
"<"						return '<';
":"		        		return ':';
","         			return ',';
"+"						return '+';
"-"						return '-';
"*"						return '*';
"/"						return '/';
"%"						return '%';
";"						return ';';
"."						return '.';
"("						return '(';
")"						return ')';

"["						return '[';
"]"						return ']';

"{"						return '{';
"}"						return '}';

"--"[^\n]*  			/* eat line comments */

"(*"					BEGIN(comment);
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*)\n]*   /* eat up '*'s not followed by ')'s */
<comment>\n             ++line_num;
<comment>"*"+")"        BEGIN(INITIAL);

[ \r\t]					/* skip whitespace */
\n 						++line_num;
<<EOF>> 				return EOF;

.             			{yyerror("lexical error: unrecognized literal '%s'\n", yytext);}

%%						/********** user code **********/