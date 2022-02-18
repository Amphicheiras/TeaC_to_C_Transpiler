%{						/*************** declarations ****************/
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>	
#include "teaclib.h"	
#include "cgen.c"

extern int yylex(void);
extern int line_num;
%}

%union
{
	char* crepr;
}

%token 	<crepr> IDENT
%token 	<crepr> POSINT 
%token 	<crepr> REAL 
%token 	<crepr> BOOLEAN
%token 	<crepr> STRING

%token 	KW_START 
%token 	KW_CONST
%token 	KW_LET

%token 	KW_INT
%token 	KW_REAL
%token 	KW_BOOLEAN
%token 	KW_STRING

%token 	KW_TRUE
%token 	KW_FALSE
%token 	KW_IF
%token 	KW_THEN
%token 	KW_ELSE
%token 	KW_FI
%token 	KW_WHILE
%token 	KW_LOOP
%token 	KW_POOL
%token 	KW_RETURN
%right 	KW_NOT
%left 	KW_AND
%left 	KW_OR

%token 	ASSIGN
%token 	ARROW

%left 	OR_OP
%left 	AND_OP
%left 	'=' '<' NOT_EQUAL SMALLER_THAN_EQUAL
%left 	'+' '-'
%left 	'*' '/' '%'
%right 	'!'

%left 	';'
%left 	'('
%left 	')'
%left 	','
%left 	'['
%left 	']'
%left 	':'
%left 	'{'
%left 	'}'

%start 	program

%type 	<crepr> decl_list body decl
%type 	<crepr> let_decl_body const_decl_body let_decl_list const_decl_list let_decl_init const_decl_init decl_id func_decl_body func_decl_sm func_decl_type function_stmt_list func_decl_list
%type 	<crepr> stmt if_stmt while_stmt ass_stmt return_stmt function_stmt 
%type 	<crepr> stmts if_lse
%type 	<crepr> type_spec
%type 	<crepr> expr

%%						/**************** rules ****************/

program: decl_list KW_CONST KW_START ASSIGN '(' ')' ':' KW_INT ARROW '{' body '}' { 
/* We have a successful parse! 
  Check for any errors and generate output. 
*/
	if(yyerror_count==0) {
    // include the teaclib.h file
	  puts(c_prologue); 
	  printf("/* program */ \n\n");
	  printf("%s\n\n", $1);
	  printf("int main(){\n\n%s\n} \nThanks bye!\n", $11);
	}
}
;

decl_list: decl_list decl 						{$$ = template("%s\n%s", $1, $2);}
| decl 											{$$ = template("%s", $1);}
;			
			
decl: KW_CONST const_decl_body 					{$$ = template("const %s", $2);}
| KW_CONST func_decl_body						{$$ = template("%s", $2);}
| KW_LET let_decl_body							{$$ = template("%s", $2);}
;			
			
const_decl_body: 			
const_decl_list ':' type_spec ';' 				{$$ = template("%s %s;", $3, $1);}
;			
		
let_decl_body:
let_decl_list ':' type_spec ';'					{$$ = template("%s %s;", $3, $1);}
;

const_decl_list: 			
const_decl_init ',' const_decl_list 			{$$ = template("%s, %s", $1, $3 );}
| const_decl_init								{$$ = template("%s", $1);}
;

let_decl_list:
let_decl_init ',' let_decl_list					{$$ = template("%s, %s", $1, $3 );}
| let_decl_init									{$$ = template("%s", $1);}
;

const_decl_init: decl_id 						{$$ = template("%s", $1);}
| decl_id ASSIGN expr							{$$ = template("%s = %s", $1, $3);}
; 

let_decl_init: decl_id 							{$$ = template("%s", $1);}
| decl_id ASSIGN expr 							{$$ = template("%s = %s", $1, $3);}
;

func_decl_body: 
IDENT ASSIGN '(' func_decl_list ')' ':' type_spec func_decl_sm ';' {$$ = template("\n%s %s(%s)%s", $7, $1, $4, $8);}
;

func_decl_sm: ARROW '{' body '}'				{$$ = template("{\n%s}", $3);}
| '[' ']' ARROW '{' body '}'					{$$ = template("{\n%s}", $5);}
;

func_decl_list: 
func_decl_type ',' func_decl_list				{$$ = template("%s, %s", $1, $3);}
| func_decl_type								{$$ = template("%s", $1);}

func_decl_type: decl_id ':' type_spec			{$$ = template("%s %s", $3, $1);}
;

decl_id: IDENT 									{$$ = template("%s", $1);} 
| IDENT '[' expr ']' 							{$$ = template("*%s", $1);}
;

type_spec: KW_INT 								{$$ = template("int");}
| KW_REAL 										{$$ = template("double");}
| KW_BOOLEAN 									{$$ = template("bool");}
| KW_STRING										{$$ = template("string");}
;

body: 											{$$ = template("");}
| stmts 										{$$ = template("%s\n", $1);}
;

/* EKFRASEIS */
expr: /* empty */								{$$ = template("");}
| IDENT											{$$ = template("%s", $1);}
| POSINT										{$$ = template("%s", $1);}
| REAL 											{$$ = template("%s", $1);}
| BOOLEAN 										{$$ = template("%s", $1);}
| STRING 										{$$ = template("%s", $1);}

| '(' expr ')' 									{$$ = template("(%s)", $2);}

| KW_NOT expr 									{$$ = template("!%s", $2);}

| '+' expr										{$$ = template("%s", $2);}
| '-' expr 										{$$ = template("-%s", $2);}

| expr '/' expr 								{$$ = template("%s / %s", $1, $3);}
| expr '*' expr 								{$$ = template("%s * %s", $1, $3);}
| expr '%' expr 								{$$ = template("%s % %s", $1, $3);}

| expr '+' expr 								{$$ = template("%s + %s", $1, $3);}
| expr '-' expr 								{$$ = template("%s - %s", $1, $3);}

| expr '=' expr 								{$$ = template("%s == %s", $1, $3);}
| expr NOT_EQUAL expr 							{$$ = template("%s != %s", $1, $3);}
| expr '<' expr 								{$$ = template("%s < %s", $1, $3);}
| expr SMALLER_THAN_EQUAL expr 					{$$ = template("%s <= %s", $1, $3);}

| expr KW_AND expr 								{$$ = template("%s && %s", $1, $3);}
| expr KW_OR expr 								{$$ = template("%s || %s", $1, $3);}
;

/* ENTOLES */
stmts: 											{$$ = template("");}
| stmt 											{$$ = template("%s", $1);}
| stmts stmt									{$$ = template("%s\n%s", $1, $2);}
;

stmt: ass_stmt ';'								{$$ = template("%s;", $1);}
| if_stmt ';'	 								{$$ = template("%s", $1);}
| while_stmt ';'								{$$ = template("%s", $1);}
| return_stmt ';' 								{$$ = template("%s", $1);}
| function_stmt ';' 							{$$ = template("%s;", $1);}
| decl_list 									{$$ = template("%s", $1);}
;

ass_stmt: IDENT ASSIGN expr 					{$$ = template("%s = %s", $1, $3);}
| IDENT ASSIGN function_stmt 					{$$ = template("%s = %s", $1, $3);}
;

if_stmt: KW_IF expr KW_THEN stmts if_lse 		{$$ = template("if (%s)\n{\n%s\n}", $2, $4);}
;

if_lse: KW_FI 									{$$ = template("");}
| KW_ELSE stmts KW_FI							{$$ = template("else \n{\n%s\n}\n", $2);}
;

while_stmt: 
KW_WHILE expr KW_LOOP stmts KW_POOL 			{$$ = template("while (%s)\n{\n%s\n}", $2, $4);}
;

return_stmt: KW_RETURN expr  					{$$ = template("return %s;", $2);}
;

function_stmt: IDENT '(' function_stmt_list ')' {$$ = template("%s(%s)", $1, $3);}
;

function_stmt_list:								
expr ',' function_stmt_list						{$$ = template("%s, %s", $1, $3);}
| expr											{$$ = template("%s", $1);}

%%						/**************** epilogue ****************/
void main(){
	if(yyparse()!= 0)
	{
		printf("File is syntacticaly invalid!\n");
	}else
		printf("File is syntacticaly correct!\n");	
}