#include <stdio.h>
#include <stdbool.h>
#include<stdlib.h>

#define MAX_STATES 100
#define MAX_ALPHABET_SIZE 100

typedef struct DFA {
    int num_states;  // DFA状态的数量
    int num_symbols; // 字母表的大小
    int start_state; // 起始状态
    int accept_states[MAX_STATES]; // 终止状态集合
    int transition[MAX_STATES][MAX_ALPHABET_SIZE]; // 状态转移函数
    // NFA下启用，为空集的多种路径
    int empty_transition[MAX_STATES][MAX_ALPHABET_SIZE]; // 空集状态转移函数
    int empty_max; //单一节点最多的empty分支数，简化输出
} DFA;

// 初始化DFA
void initializeDFA(DFA *dfa, int num_states, int num_symbols);

// 设置终止状态
void setAcceptState(DFA *dfa, int state);

// 设置状态转移
void setTransition(DFA *dfa, int from_state, int symbol, int to_state);

// 设置空集状态转移
void setEmptyTransition(DFA *dfa, int from_state, int to_state);

// 执行DFA，接受或拒绝输入字符串
bool runDFA(DFA *dfa, const char *input);
bool runNFA(DFA *dfa, const char *input);

// 合并两个NFA,参数Connection为建立联系的位置，为-1的时候默认在最后连接
void mergeNFA(DFA *dfa1, DFA *dfa2, int Connection);

// 打印状态转移函数矩阵
void printTransitionMatrix(DFA *dfa);

// 打印空集状态转移函数矩阵
void printEmptyTransitionMatrix(DFA *dfa);

// 计算闭包
void epsilonClosure(DFA *dfa, int state, bool *visited, int *closure);

// 将NFA转化为DFA
void convertNFAToDFA(DFA *nfa, DFA *dfa);

// DFA最小化算法
void hopcroftMinimizeDFA(DFA *dfa);

// 声明符号表
extern char sym_maps[100];
// 符号表大小
extern int sym_maps_size;
// 正则表达式生成的NFA
extern DFA * NFA_result;

// 符号表查找
int find(char s);