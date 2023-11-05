#include<stack>
#include<map>
#include<string>
#include<queue>

// 符号表项结构
struct SymbolTableEntry {
    std::string word;              // 单词
    std::string lexeme;            // 词素
    int line_number;          // 行号
    int column_number;        // 列号
    SymbolTableEntry * ptr ;  //符号表项指针，指向自己
};


// 符号表
class SymbolTable {

private:
    std::map<std::string, SymbolTableEntry> table;  // 词素和符号表项的映射

public:
    SymbolTable() = default; 
    SymbolTable(const SymbolTable& t) : table(t.table) {}
    // 插入一个新的词素及其符号表项
    void insert(std::string lexeme, SymbolTableEntry entry) {
        table[lexeme] = entry;
    }
    // 查询词素，返回其符号表项
    SymbolTableEntry* findEntry(std::string lexeme) {
        if (table.find(lexeme) != table.end()) {
            return &table[lexeme];
        }
        return nullptr;
    }
    // 打印符号表
    void printTable(FILE* out) {
        std::map<std::string, SymbolTableEntry>::iterator it;
        for (it = table.begin(); it != table.end(); it++) {
            SymbolTableEntry entry = it->second;
            fprintf(out, "NAME:%s\t ROW:%d\t COL:%d\t ATTRIBUTE:%p\n", entry.lexeme.c_str(), entry.line_number,entry.column_number,entry.ptr); 
        }
        fprintf(out,"\n");
    }
};

// 使用栈来管理作用域，栈顶是当前的符号表，便于词法分析
extern std::stack<SymbolTable> symbolTableStack;
// 使用队列来存储词法分析结果的符号表，便于语义分析
extern std::queue<SymbolTable> symbolTableQueue;

// 打印queue所有符号表
extern void printAllTable(FILE* out) ;