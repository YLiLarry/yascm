%{
#include <stdio.h>
#include <stdlib.h>
#include "yascm.h"

void yyerror(struct object_s **obj, const char *s);
%}

%parse-param {struct object_s **obj}

%union {
	struct object_s *var;
	int64_t n;
	long double d;
	char c;
	char *s;
};

%token <var> LP
%token RP
%token DOT
%token QUOTE
%token <n> FIXNUM_T
%token <d> FLOATNUM_T
%token FALSE_T
%token TRUE_T
%token <c> CHAR_T
%token <s> STRING_T
%token DOUBLE_QUOTE
%token <s> SYMBOL_T

%type <s> string
%type <var> object
%type <n> number
%type <var> emptylist
%type <var> quote_list
%type <var> pairs_list 
%type <var> pairs_end
%type <var> pairs

%start exp

%%

/* exp: object {object_print(eval(GENV, $1));} exp */
exp: object {*obj = $1; YYACCEPT;}

string: DOUBLE_QUOTE STRING_T DOUBLE_QUOTE {$$ = $2;}

number: FIXNUM_T {$$ = $1;}
      | FLOATNUM_T {printf("float: not support now\n");}

emptylist: LP RP 

quote_list: QUOTE object {$$ = make_quote($2);}

pairs_list: object {$$ = cons($1, make_emptylist());}
	  | object pairs_list {$$ = cons($1, $2);}

pairs_end: pairs_list RP {$$ = $1;}

pairs: LP pairs_end {$$ = $2;}

object: TRUE_T		{$$ = make_bool(true);}
      | FALSE_T		{$$ = make_bool(false);}
      | CHAR_T		{$$ = make_char($1);}
      | string		{$$ = make_string($1);}
      | number		{$$ = make_fixnum($1);}
      | emptylist	{$$ = make_emptylist();}
      | quote_list	{$$ = $1;}
      | SYMBOL_T	{$$ = make_symbol($1);}
      | pairs		{$$ = $1;}

%%

void yyerror(struct object_s **obj, const char *s)
{
	(void)obj;
	exit(0);
}
