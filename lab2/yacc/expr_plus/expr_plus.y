%{
//一、预处理部分
//1、包含我们所需的头文件
#include<stdio.h>
#include<stdlib.h>
#include<string.h> 
#include<ctype.h>

//2、定义所需的函数和全局变量,从上到下为:
//词法分析器、yacc生成的语法分析器、输入文件、错误输出函数
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

//3、定义符号表
struct symbol {
    char *sym;
    double val;
}sym_maps[100];

//符号表插入函数
struct symbol* insert(char *s);
%}

//定义我们的yacc程序最终产生值的类型,这里由于存在标识符和值两种,采用union定义
%union {
        double  val;  //运算式的值
        struct symbol* sym; //符号
}


//二、单词定义和优先级定义
//TODO:给每个符号定义一个单词类别
%token ADD SUB
%token MUL DIV
%token <val> NUMBER
%token LEFTPAR
%token RIGHTPAR
//新增的赋值运算和标识符
%token EQUAL 
%token <sym> IDENT

%left ADD SUB
%left MUL DIV
%left LEFTPAR RIGHTPAR

%right EQUAL
%right UMINUS

%type <val> expr
%type <val> equalexpr

//三、CFG规则定义部分
%%
//该非终结符表示输入的全部信息,最新一行为输入的表达式
lines   :       lines equalexpr ';' { 
                printf("Result:\n%f\nPlease enter a expression:\n", $2); }
        |       lines ';'
        |       //说明一个语句可以仅由;组成
        ;
//TODO:完善表达式的规则
equalexpr :  IDENT EQUAL equalexpr {$1->val=$3; $$=$3;}
        |   expr {$$=$1;}
        ;
expr    :   expr ADD expr { $$ = $1 + $3; }
		| 	expr SUB expr { $$ = $1 - $3; }
		| 	expr MUL expr { $$ = $1 * $3; }
		| 	expr DIV expr { $$ = $1 / $3; }
		| 	LEFTPAR expr RIGHTPAR { $$ = $2; }
        |   SUB expr %prec UMINUS   { $$ = -$2; }
        |   NUMBER { $$ = $1;}
        |   IDENT {$$=$1->val;} 
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
            int i = 0; 
            //这里由于c语言特性,需要注意应该动态分配,直接声明的字符数组会产生随机值
            char *numStr=(char *)malloc(15 * sizeof(char));
            while(isdigit(t)){
                numStr[i] = t;
                t = getchar();
                i++;
            }
            numStr[i]='\0';
            //yylval是此时yylex与后续bison处理的沟通值,会赋值给此时识别出的标识符
            int num = atoi(numStr);
            yylval.val = num;
            //将现在读取到的非数字字符退回输入流
            ungetc(t,stdin); 
            return NUMBER;
        }
        else if(isalpha(t)||(t=='_')){
            //对于标识符,一直读取直到不是字母、数字、下划线
            int i = 0; 
            //这里由于c语言特性,需要注意应该动态分配,直接声明的字符数组会产生随机值
            char *idStr=(char *)malloc(30 * sizeof(char));
            while(isalpha(t)||(t=='_')||isdigit(t)){
                idStr[i] = t;
                t = getchar();
                i++;
            }
            idStr[i]='\0';
            //yylval是此时yylex与后续bison处理的沟通值,会赋值给此时识别出的标识符
            yylval.sym=insert(idStr); 
            //将现在读取到的非数字字符退回输入流
            ungetc(t,stdin); 
            return IDENT;
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
        else if(t=='='){
			return EQUAL;
		}
        else{
            return t;
        }
    }
}
struct symbol* insert(char *s){
    char* p;
    for(int i = 0;i<100;i++){
        //已存在该符号,返回并前置(优先队列待实现)
        if(sym_maps[i].sym && strcmp(sym_maps[i].sym,s) == 0)
            return &sym_maps[i];
        //符号表项不存在,表明已到结尾,新建一个即可
        if(!sym_maps[i].sym){ 
            sym_maps[i].sym=strdup(s);
            return &sym_maps[i];
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