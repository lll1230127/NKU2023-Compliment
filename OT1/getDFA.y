%{
//一、预处理部分
//1、包含我们所需的头文件
#include<stdio.h>
#include<stdlib.h>
#include<string.h> 
#include<ctype.h>
#include "DFA.h"

//2、定义我们的yacc程序最终y产生值的类型,这里由于是中缀生成后缀,故为字符串类型
#ifndef YYSTYPE
#define YYSTYPE DFA*
#endif

//3、定义所需的函数和全局变量,从上到下为词法分析器、yacc生成的语法分析器、输入文件、错误输出函数
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

//符号表插入函数
int insert(char s);
%}

//二、单词定义和优先级定义
%token CHAR
%token EMPTY

%left '|'
%left '*'
%left '+'
%left '?'

//三、CFG规则定义部分
%%
//该非终结符表示输入的全部信息,最新一行为输入的正则表达式
lines   :       lines exprs ';' { 
                    printTransitionMatrix($2);
                    printEmptyTransitionMatrix($2);
                    setAcceptState($2,$2->num_states-1);
                    printf("%d\n",runNFA($2,"abaad"));
                    DFA dfa;
                    convertNFAToDFA(&dfa, $2);
                    // hopcroftMinimizeDFA(&dfa);
                    printTransitionMatrix(&dfa);
                    printEmptyTransitionMatrix(&dfa);   
                    printf("%d\n",runDFA(&dfa,"abaad"));
                    $$ = $2;
                }
        |       lines ';'
        |       //说明一个语句可以仅由;组成
        ;

exprs   :      exprs expr { 
                mergeNFA($1 , $2, -1);
                $$ = $1;
                free($2);
            }
        |   expr  {
            $$ = $1;
        }
        ;

//TODO:完善表达式的规则
expr    :       expr '|' expr   { 
                DFA* st = (DFA *)malloc(sizeof(DFA));
                DFA* ed = (DFA *)malloc(sizeof(DFA));
                initializeDFA(st,1,sym_maps_size);
                initializeDFA(ed,1,sym_maps_size);
                mergeNFA(st , $1, 0);
                mergeNFA(st , $3, 0);
                mergeNFA(st , ed, -1);
                setEmptyTransition(st, $1->num_states, $1->num_states + $3->num_states+1);
                $$ = st;
                free($1);free($3);free(ed);
            }
        |       expr '*'  { 
                DFA* st = (DFA *)malloc(sizeof(DFA));
                DFA* ed = (DFA *)malloc(sizeof(DFA));
                initializeDFA(st,1,sym_maps_size);
                initializeDFA(ed,1,sym_maps_size);
                setEmptyTransition($1, $1->num_states -1, 0);
                mergeNFA(st , $1, 0);
                mergeNFA(st , ed, -1);
                setEmptyTransition(st, 0, $1->num_states +1);
                $$ = st;
                free($1);free(ed);
            }
        |       expr '+'  { 
                DFA* st = (DFA *)malloc(sizeof(DFA));
                DFA* ed = (DFA *)malloc(sizeof(DFA));
                initializeDFA(st,1,sym_maps_size);
                initializeDFA(ed,1,sym_maps_size);
                setEmptyTransition($1, $1->num_states -1, 0);
                mergeNFA(st , $1, 0);
                mergeNFA(st , ed, -1);
                $$ = st;
                free($1);free(ed);
            }
        |       expr '?'  { 
                DFA* st = (DFA *)malloc(sizeof(DFA));
                DFA* ed = (DFA *)malloc(sizeof(DFA));
                initializeDFA(st,1,sym_maps_size);
                initializeDFA(ed,1,sym_maps_size);
                mergeNFA(st , $1, 0);
                mergeNFA(st , ed, -1);
                setEmptyTransition(st, 0, $1->num_states +1);
                $$ = st;
                free($1);free(ed);
            }
        |       '('exprs')'   {
            $$ = $2;
            }
        |       CHAR { 
            int temp = $1->start_state;
            printf("%d,%d\n",temp,sym_maps_size);
            initializeDFA($1, 2 ,sym_maps_size);
            setTransition($1, 0, temp, 1);
            $$ = $1;
            }
        |       EMPTY { 
            int temp = $1->start_state;
            initializeDFA($1, 2 ,sym_maps_size);
            setEmptyTransition($1, 0, 1);
            $$ = $1;
            }
        ;

%%

// programs section

int yylex()
{
    char t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do noting
        }
        else if(t=='|'){
            return '|';
        }
        else if(t=='*'){
            return '*';
        }
        else if(t=='+'){
            return '+';
        }
        //TODO:识别其他符号
        else if(t=='?'){
            return '?';
        }
        else if(t=='('){
            return '(';
        }
        else if(t==')'){
            return ')';
        }
        else if(t==';'){
            return ';';
        }
        else if(t=='_'){
             //新建一个DFA，顺便存一下对应的符号的索引，之后会重置。
            DFA* dfa;
            dfa = (DFA *)malloc(sizeof(DFA));
            dfa->start_state = sym_maps_size;
            yylval = dfa;
            return EMPTY;
        }
        else{
            //新建一个DFA，顺便存一下对应的符号的索引，之后会重置。
            DFA* dfa;
            dfa = (DFA *)malloc(sizeof(DFA));
            dfa->start_state = insert(t);
            yylval = dfa;
            return CHAR;
        }
        
    }
}
int insert(char s){
    // //为空集留一个位置
    // if(sym_maps[0] == 0){
    //     sym_maps[0] = '_';
    //     sym_maps_size ++;
    // }
    for(int i = 0;i<100;i++){
        //已存在该符号,返回并前置(优先队列待实现)
        if(sym_maps[i] == s)
            return i;
        //符号表项不存在,表明已到结尾,新建一个即可
        if(sym_maps[i] == 0){ 
            sym_maps[i]=s;
            sym_maps_size ++;
            return i;
        }
    }
    yyerror("The Symbol Table is full!");
	exit(1);
}

int main(void)
{
    yyin=stdin;
    do{
        printf("Please enter a postfix expression:\n");
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}