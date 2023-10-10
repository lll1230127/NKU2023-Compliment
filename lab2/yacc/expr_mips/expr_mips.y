%{
//一、预处理部分
//1、包含我们所需的头文件
#include<stdio.h>
#include<stdlib.h>
#include<string.h> 
#include<ctype.h>

//2、定义我们的yacc程序最终y产生值的类型,这里存储寄存器号,故为int类型
#ifndef YYSTYPE
#define YYSTYPE int
#endif

//3、定义所需的函数和全局变量,从上到下为词法分析器、yacc生成的语法分析器、输入文件、错误输出函数
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

//4、定义寄存器
struct reg {
    int using;
    double val;
}regs[8];

// //5、定义expr状态
// struct state{
//     int num;  //对应寄存器值
//     double val;
// }

//找一个空闲寄存器函数
int use(int* rs);

//释放一个寄存器函数;
void release(int rs);

//清空寄存器函数;
void clear();
%}

//二、单词定义和优先级定义
//TODO:给每个符号定义一个单词类别
%token ADD SUB
%token MUL DIV
%token NUMBER
%token LEFTPAR
%token RIGHTPAR
//新增的赋值运算和标识符
%token EQUAL 
%token IDENT

%right EQUAL
%left ADD SUB
%left MUL DIV
%left LEFTPAR RIGHTPAR
%right UMINUS

//三、CFG规则定义部分
%%
//该非终结符表示输入的全部信息,最新一行为输入的表达式
lines   :       lines expr ';' { 
                printf("\nPlease enter a expression:\n");
                clear(); }
        |       lines ';'
        |       //说明一个语句可以仅由;组成
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { 
            printf("ADD $s%d $s%d $s%d\n",use(&$$),$1,$3);
            release($1);
            release($3);
            }
        |       expr SUB expr   { 
            printf("SUB $s%d $s%d $s%d\n",use(&$$),$1,$3);
            release($1);
            release($3);
            }
        |       expr MUL expr   { 
            printf("MUL $s%d $s%d $s%d\n",use(&$$),$1,$3);
            release($1);
            release($3);
            }
        |       expr DIV expr   { 
            printf("DIV $s%d $s%d $s%d\n",use(&$$),$1,$3);
            release($1);
            release($3);
            }
        |       LEFTPAR expr RIGHTPAR      { $$=$2;}
        |   IDENT EQUAL expr {
            printf("ADD $s%d $zero $s%d\n",use(&$$),$3);
            release($3);
            }
        |       SUB expr %prec UMINUS   { 
            printf("NEG $s%d, $s%d\n",$1,$1);
            $$=$1;
            }
        |       NUMBER { 
            printf("ADDI $s%d $zero %d\n",use(&$$),$1);
            }
        |   IDENT {} 
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
            int num = atoi(numStr);
            //yylval是此时yylex与后续bison处理的沟通值,会赋值给此时识别出的标识符
            yylval = num;
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

int use(int* rs){
    int i =0;
    while(i<8){
        if(regs[i].using == 0){
            regs[i].using =1;
            *rs = i;
            return i;
        }
        i++;
    }
    printf("regs is full!");
}


void release(int rs){
    if(regs[rs].using == 1){
        regs[rs].using =0;
    }
}

void clear(){
    int i =0;
    while(i<8){
        regs[i].using = 0;
    }
}

int main(void)
{
    yyin=stdin;
    do{
        printf("Please enter a expression:\n");
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}