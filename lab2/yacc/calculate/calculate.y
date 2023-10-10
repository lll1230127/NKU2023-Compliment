%{
//一、预处理部分
//1、包含我们所需的头文件
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>

//2、定义我们的yacc程序最终产生值的类型,这里由于是计算,故为double类型
#ifndef YYSTYPE
#define YYSTYPE double
#endif

//3、定义所需的函数和全局变量,从上到下为词法分析器、yacc生成的语法分析器、输入文件、错误输出函数
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

//二、单词定义和优先级定义
//TODO:给每个符号定义一个单词类别
%token ADD SUB
%token MUL DIV
%token NUMBER
%token LEFTPAR
%token RIGHTPAR

%left ADD SUB
%left MUL DIV
%right UMINUS

//三、CFG规则定义部分
%%
//该非终结符表示输入的全部信息,最新一行为输入的表达式
lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |       //说明一个语句可以仅由;组成
        ;
//TODO:完善表达式的规则

expr    :       expr ADD expr   { $$=$1+$3; }
        |       expr SUB expr   { $$=$1-$3; }
        |       expr MUL expr   { $$=$1*$3; }
        |       expr DIV expr   { $$=$1/$3; }
        |       LEFTPAR expr RIGHTPAR      { $$=$2;}
        |       SUB expr %prec UMINUS   {$$=-$2;}
        |       NUMBER
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
        else if(isdigit(t)){
            //TODO:解析多位数字返回数字类型 
            //对于数字,一直读取直到不是数字
            char numStr[15];
            int i = 0; 
            while(isdigit(t)){
                numStr[i] = t;
                t = getchar();
                i++;
            }
            numStr[i]='\0';
            //强转为int类型
            int num = atoi(numStr);
            //yylval是此时yylex与后续bison处理的沟通值,会赋值给此时识别出的标识符
            yylval = num;cd
            ungetc(t,stdin); 
            return NUMBER;
        }
        else if(t=='+'){
            return ADD;
        }
        else if(t=='-'){
            return SUB;
        }
        //TODO:识别其他符号
        else if(t=='*'){
            return MUL;
        }
        else if(t=='/'){
            return DIV;
        }
        else if(t=='('){
            return LEFTPAR;
        }
        else if(t==')'){
            return RIGHTPAR;
        }
        else{
            return t;
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}