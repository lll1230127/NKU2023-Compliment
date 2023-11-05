#include "SymbolTable.h"

// 使用栈来管理作用域，栈顶是当前的符号表，便于词法分析
std::stack<SymbolTable> symbolTableStack;

// 使用队列来存储词法分析结果的符号表，便于语义分析
std::queue<SymbolTable> symbolTableQueue;

// 遍历输出队列的所有符号表
void printAllTable(FILE* out) {
    int i=0;
    std::queue<SymbolTable> Queue_copy = symbolTableQueue;
    while (!Queue_copy.empty())
    {
        fprintf(out,"作用域%d的符号表\n",i);
        SymbolTable front = Queue_copy.front();
        front.printTable(out);
        Queue_copy.pop();
        i++;
    }
}