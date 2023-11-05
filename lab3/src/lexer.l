%option noyywrap
/*解决"yyunput defined but not used" 静态函数定义未使用的warning而引发的错误*/
%option nounput
%option noinput

%top{
    #include<math.h>
    #include<stack>
    #include<map>
    #include<string>
    #include<iostream>
    #include <unistd.h>
    #include "SymbolTable.h"
    using namespace std;
}

%{
// 全局变量定义
int lines=0; //行号
int current_column = 0; //列号
// 符号表结构
extern stack<SymbolTable> symbolTableStack;
extern queue<SymbolTable> symbolTableQueue;
%}

IF          if
ELSE        else
WHILE       while
RETURN      return
BREAK       break
CONTINUE    continue 
CONST       const
INT         int
FLOAT       float
FOR         for
VOID        void

ID      [a-zA-Z_][a-zA-Z0-9_]*
NUM     [0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?

DEC     [1-9][0-9]*|0
OCT     0[0-7]+
HEX     0[xX][0-9a-fA-F]+
FLO   [0-9]*\.[0-9]+([eE][-+]?[0-9]+)?

EQ      ==
NEQ     !=
LT      <
LE      <=
GT      >
GE      >=

ADD              "+"
SUB              "-"
MUL              "*"
DIV              "/"
ASSIGN           "="
ADDASSIGN        "+="
SUBASSIGN        "-="
MULTASSIGN       "*="
DIVASSIGN        "/="
MODASSIGN        "%="
INCREMENT        "++"
DECREMENT        "--"
MODULO           "%"
LEFTPAR          "("
RIGHTPAR         ")"
LEFTMID          "["
RIGHTMID         "]"
LEFTBIG          "{"
RIGHTBIG         "}"
LOGAND           "&&"
LOGOR            "||"
NOT              "!"
COMMA            ","
SEMICOLON        ";"

onelinecommentbegin "//"
onelinecommentend "\n"
%x ONELINECOMMENT
commentbegin "/*"
commentelement .|\n
commentend "*/"
%x COMMENT

%%

{BREAK}       {
    fprintf(yyout, "TOKEN: BREAK\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column);
    current_column += strlen(yytext);
}

{CONST}       {
    fprintf(yyout, "TOKEN: CONST\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{CONTINUE}    {
    fprintf(yyout, "TOKEN: CONTINUE\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{ELSE}        {
    fprintf(yyout, "TOKEN: ELSE\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{FLOAT}       {
    fprintf(yyout, "TOKEN: FLOAT\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{FOR}         {
    fprintf(yyout, "TOKEN: FOR\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{IF}          {
    fprintf(yyout, "TOKEN: IF\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{INT}         {
    fprintf(yyout, "TOKEN: INT\tLEXEME: int\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", lines, current_column);
    current_column += strlen(yytext);
}

{RETURN}      {
    fprintf(yyout, "TOKEN: RETURN\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{VOID}        {
    fprintf(yyout, "TOKEN: VOID\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{WHILE}       {
    fprintf(yyout, "TOKEN: WHILE\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Keyword\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{ADD}       {
    fprintf(yyout, "TOKEN: ADD\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Addition Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{SUB}       {
    fprintf(yyout, "TOKEN: MINUS\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Subtraction Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{MUL}       {
    fprintf(yyout, "TOKEN: MULT\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Multiplication Operator\n", yytext,lines,current_column);
    current_column += strlen(yytext); 
}

{DIV}       {
    fprintf(yyout, "TOKEN: DIV\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Division Operator\n", yytext,lines,current_column);
    current_column += strlen(yytext); 
}

{ASSIGN}          { 
    fprintf(yyout, "TOKEN: ASSIGN\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Assignment Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{ADDASSIGN}      { 
    fprintf(yyout, "TOKEN: ADDASSIGN\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: ADD Assignment Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{SUBASSIGN}     { 
    fprintf(yyout, "TOKEN: SUBASSIGN\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Minus Assignment Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{MULTASSIGN}      { 
    fprintf(yyout, "TOKEN: MULTASSIGN\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Multiplication Assignment Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{DIVASSIGN}       { 
    fprintf(yyout, "TOKEN: DIVASSIGN\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Division Assignment Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{MODASSIGN}       { 
    fprintf(yyout, "TOKEN: MODASSIGN\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Modulo Assignment Operator\n", yytext,lines,current_column);
    current_column += strlen(yytext); 
}

{INCREMENT}       { 
    fprintf(yyout, "TOKEN: INCREMENT\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Increment Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{DECREMENT}       { 
    fprintf(yyout, "TOKEN: DECREMENT\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Decrement Operator\n", yytext,lines,current_column);
    current_column += strlen(yytext); 
}

{MODULO}          { 
    fprintf(yyout, "TOKEN: MODULO\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Modulo Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{EQ}    { 
    fprintf(yyout, "TOKEN: EQ\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Equality Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{NEQ}   { 
    fprintf(yyout, "TOKEN: NEQ\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Not Equal Operator\n", yytext,lines,current_column);
    current_column += strlen(yytext); 
}

{LT}    { 
    fprintf(yyout, "TOKEN: LT\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Less Than Operator\n", yytext,lines,current_column);
    current_column += strlen(yytext);
}

{LE}    { 
    fprintf(yyout, "TOKEN: LE\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Less Than or Equal Operator\n", yytext,lines,current_column);
    current_column += strlen(yytext); 
}

{GT}    { 
    fprintf(yyout, "TOKEN: GT\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Greater Than Operator\n", yytext,lines,current_column);
    current_column += strlen(yytext); 
}

{GE}    { 
    fprintf(yyout, "TOKEN: GE\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Greater Than or Equal Operator\n", yytext,lines,current_column);
    current_column += strlen(yytext);
}

{DEC} {
    int value = strtol(yytext, NULL, 10);
    fprintf(yyout, "TOKEN: INT_CONST\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: %d\n", yytext, lines,current_column,value);
    current_column += strlen(yytext);
}

{OCT} {
    int value = strtol(yytext, NULL, 8);
    fprintf(yyout, "TOKEN: OCT_CONST\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: %d\n", yytext, lines,current_column,value);
    current_column += strlen(yytext);
}

{HEX} {
    int value = strtol(yytext, NULL, 16);
    fprintf(yyout, "TOKEN: HEX_CONST\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: %d\n", yytext, lines,current_column,value);
    current_column += strlen(yytext);
}

{FLO} {
    float value = atof(yytext);
    fprintf(yyout, "TOKEN: FLOAT_CONST\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: %f\n", yytext, lines,current_column,value);
    current_column += strlen(yytext);
}

{LEFTPAR}   { 
    fprintf(yyout, "TOKEN: LEFTPAR\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Left Parenthesis\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{RIGHTPAR}  {
    fprintf(yyout, "TOKEN: RIGHTPAR\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Right Parenthesis\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{LEFTMID}   { 
    fprintf(yyout, "TOKEN: LEFTMID\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Left Middle Parenthesis\n", yytext,lines,current_column); 
    current_column += strlen(yytext);
}

{RIGHTMID}  {
    fprintf(yyout, "TOKEN: RIGHTMID\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Right Middle Parenthesis\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{LOGAND}    { 
    fprintf(yyout, "TOKEN: LOGAND\tLEXEME: %s\tROW:%d\tCOL:%d\tATTRIBUTE: Logical And Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{LOGOR} { 
    fprintf(yyout, "TOKEN: LOGOR\tLEXEME: %s\tROW:%d\tCOL:%d\tATTRIBUTE: Logical Or Operator\n", yytext,lines,current_column); 
    current_column += strlen(yytext); 
}

{NOT}   {
     fprintf(yyout, "TOKEN: NOT\tLEXEME: %s\tROW:%d\tCOL:%d\tATTRIBUTE: Logical Not Operator\n", yytext,lines,current_column); 
     current_column += strlen(yytext); 
}

{ID}    {
    if(symbolTableStack.empty()){
        SymbolTable newTable;
        symbolTableStack.push(newTable);
    }
    
    SymbolTableEntry* entry = nullptr;
    if (!symbolTableStack.empty()) {
        entry = symbolTableStack.top().findEntry(yytext);  // 查找当前符号表
    }
    if (!entry) {
        // 如果词素不存在，创建新的符号表项并插入
        SymbolTableEntry newEntry;
        newEntry.word = yytext;          
        newEntry.lexeme = yytext;
        newEntry.line_number = yylineno;  // 获取当前行号
        newEntry.column_number = current_column;
        newEntry.ptr = &newEntry;
        if (!symbolTableStack.empty()) {
            symbolTableStack.top().insert(yytext, newEntry);
        }      
    }
    //再次查找，找到指针
    SymbolTableEntry* ptr_rtn = symbolTableStack.top().findEntry(yytext);
    fprintf(yyout, "TOKEN: ID\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: %p \n", yytext,lines,current_column,ptr_rtn);
    current_column += strlen(yytext);
}

{SEMICOLON}     { 
    fprintf(yyout, "TOKEN: SEMICOLON\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Semicolon\n", yytext,lines,current_column);
    current_column += strlen(yytext); 
}

{onelinecommentbegin}.*\n { BEGIN(INITIAL); }

{commentbegin} {BEGIN COMMENT;}
<COMMENT>{commentelement} {}
<COMMENT>{commentend} {BEGIN INITIAL;}


{LEFTBIG}     {
    SymbolTable newTable;
    symbolTableStack.push(newTable);
    fprintf(yyout, "TOKEN: LEFTBIG\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Left Brace\n", yytext,lines,current_column);
    current_column += strlen(yytext);
}

{RIGHTBIG}    {
    if (!symbolTableStack.empty()) {
        symbolTableQueue.push(symbolTableStack.top());
        symbolTableStack.pop();
    }
    fprintf(yyout, "TOKEN: RIGHTBIG\tLEXEME: %s\tROW: %d\tCOL:%d\tATTRIBUTE: Right Brace\n", yytext,lines,current_column);
    current_column += strlen(yytext);
}

{COMMA} {current_column += 1;}

<<EOF>> {
    if (!symbolTableStack.empty()) {
        symbolTableQueue.push(symbolTableStack.top());
        symbolTableStack.pop();
    }
    return 0;
}

" "  {   current_column+=1;}
"\t" {}
\n      { lines++; current_column = 0; }  // 重置计数器

%%

