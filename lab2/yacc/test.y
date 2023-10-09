// 1.定义部分：包含头文件，声明词法符号，抛出函数声明等
%{
//(1)包含头文件
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

//(2)确定yacc语法分析栈的作用类型，在本实验中是字符串
#define YYSTYPE char* // 用于确定$$的变量类型

//(3)声明全局变量，抛出函数声明
int yylex();  //我们自定义的词法分析器
extern int yyparse(); //yacc生成的语法分析器
void yyerror(char* s); //错误输出
char idStr[101];  //标识符
char numStr[101]; //操作数
%}

//(4)声明词法符号，定义优先级，越靠下的越优先
%token NUMBER //数字
%token ID  //标识符
%token ADD
%token SUB
%token MUL
%token DIV
%token LEFT_PAR
%token RIGHT_PAR

%left ADD 
%left SUB
%left MUL
%left DIV
// -可以是单目运算符，表示取相反数，此时-是一个右结合的运算符
%right UMINUS 

//2.规则部分，定义CFG
%%
//定义非终结符line，表示输入的行 
line  :    line expr ';' { printf("%s\n", $2); } //这个行可以是多个line跟一个表达式和分号，当匹配到这种规则时，输出表达式
      |    line ';' //这条语句可以只有一个分号
      |    // 这条语句可以什么也没有
      ;
//$$ 代表产生式左部的值
//实现思路：a+b => a b + ；实际上就是一个字符串的拼接
expr  :    expr ADD expr  { 
        $$ = (char*)malloc(100*sizeof(char)); 
        strcpy($$,$1); strcat($$,$3); 
        strcat($$,"+"); 
    }
      |    expr SUB expr  { 
            $$ = (char*)malloc(100*sizeof(char)); 
            strcpy($$,$1); 
            strcat($$,$3); 
            strcat($$,"- "); 
        }
      |    expr MUL expr  { 
            $$ = (char*)malloc(100*sizeof(char)); 
            strcpy($$,$1); 
            strcat($$,$3); 
            strcat($$,"* "); 
        }
      |    expr DIV expr  { 
            $$ = (char*)malloc(100*sizeof(char)); 
            strcpy($$,$1); 
            strcat($$,$3);
            strcat($$,"/ "); 
        }
      |    LEFT_PAR expr RIGHT_PAR   { $$ = $2; }
      |    SUB  expr %prec UMINUS  {
            $$ = (char*)malloc(50*sizeof(char)); 
            strcpy($$,"- "); 
            strcat($$,$2); 
         }
      |    NUMBER         { 
            $$ = (char*)malloc(100*sizeof(char)); 
            strcpy($$,$1); 
            strcat($$," "); 
        }
      |    ID             { 
            $$ = (char*)malloc(100*sizeof(char)); 
            strcpy($$,$1);
            strcat($$," "); 
        }
      ;
%%

//3.用户子程序部分
int yylex() //自定义的词法分析器
{
    int ch;
    while(1){
        ch=getchar();
        if(ch==' ' || ch=='\t' || ch=='\n') //忽略空白符
            ;
        else if ((ch>='0' && ch<= '9')){ //如果是数字，就一直读取，直到不是数字
            int i=0;
            while((ch>='0'&&ch<='9')){
                numStr[i]=ch;
                ch=getchar();
                i++;
            }
            numStr[i]='\0';
            yylval=numStr; //yylval是lex和yacc沟通的变量，赋值给了识别出的标识符
            ungetc(ch,stdin); //将首个非数字字符退回输入流
            return NUMBER;
        }
        //识别出标识符，一直读到非字母数字下划线的字符
        else if ((ch>='a'&& ch<='z') || (ch>='A' && ch<='Z') || (ch=='_')){
            int i=0;
            while((ch>='a'&& ch<='z') || (ch>='A' && ch<='Z') || (ch=='_') || (ch>='0' && ch<='9')){
                idStr[i]=ch;
                i++;
                ch=getchar();
            }
            idStr[i]='\0';
            yylval=idStr;
            ungetc(ch,stdin);
            return ID;
        }
        else if(ch=='+') {
            return ADD;  
        }
        else if(ch=='-'){
            return SUB;
        }
        else if(ch=='*'){
            return MUL;
        }
        else if(ch=='/'){
            return DIV;
        }
        else if(ch=='('){
            return LEFT_PAR;
        }
        else if(ch==')'){
            return RIGHT_PAR;
        }
        else {
            return ch; //处理其他字符，特别是分号
        }
    }
}

int main(void)
{
    FILE* cin = stdin;
    do{
        yyparse();
    } while(!feof(cin));
    return 0;
}
void yyerror(char* s){
    fprintf(stderr, "error: %s\n", s);
    exit(1);
}