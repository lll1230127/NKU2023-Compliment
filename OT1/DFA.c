#include "DFA.h"

// 初始化符号表
char sym_maps[100] = {0};
int sym_maps_size = 0;
DFA * NFA_result;

// 初始化DFA
void initializeDFA(DFA *dfa, int num_states, int num_symbols) {
    dfa->num_states = num_states;
    dfa->num_symbols = num_symbols;
    dfa->start_state = 0;
    dfa->empty_max = 1;
    for (int i = 0; i < num_states; i++) {
        dfa->accept_states[i] = 0;
        for (int j = 0; j < 100; j++) {
            dfa->transition[i][j] = -1; // 初始化为-1表示无效状态
        }
        for (int j = 0; j < 100; j++) {
            dfa->empty_transition[i][j] = -1; // 初始化为-1表示无效状态
        }
    }
}

// 设置终止状态
void setAcceptState(DFA *dfa, int state) {
    if (state >= 0 && state < dfa->num_states) {
        dfa->accept_states[state] = 1;
    }
}

// 设置状态转移
void setTransition(DFA *dfa, int from_state, int symbol, int to_state) {
    if (from_state >= 0 && from_state < dfa->num_states &&
        symbol >= 0 && symbol < dfa->num_symbols &&
        to_state >= 0 && to_state < dfa->num_states) {
        dfa->transition[from_state][symbol] = to_state;
    }
}

// 设置空集状态转移
void setEmptyTransition(DFA *dfa, int from_state,  int to_state) {
    if (from_state >= 0 && from_state < dfa->num_states &&
        to_state >= 0 && to_state < dfa->num_states) {
        for (int j = 0; j < dfa->num_states; j++) {
            if(dfa->empty_transition[from_state][j] == -1){
                dfa->empty_transition[from_state][j] = to_state;
                if( j+1 >= dfa->empty_max) dfa->empty_max = j+1;
                break;
            }
        }
    }
}

int find(char s){
    for(int i = 0;i<100;i++){
        //已存在该符号,返回其索引
        if(sym_maps[i] == s)
            return i;
        //符号表项不存在,已到结尾,出错
        if(sym_maps[i] == 0){ 
            return -1;
        }
    }
} 

int insert(char s){
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
}

// 计算状态的ε-closure
void epsilonClosure(DFA *dfa, int state, bool *visited, int *closure) {
    visited[state] = true;
    closure[state] = 1;
    for (int symbol = 0; symbol < dfa->empty_max; symbol++) {
        int to_state = dfa->empty_transition[state][symbol];
        if (to_state != -1 && !visited[to_state]) {
            epsilonClosure(dfa, to_state, visited, closure);
        }
    }
}

// 比较ε-closure是否相同
bool compareClosure(DFA *dfa, int *closure1,int *closure2){
    for (int i = 0; i < dfa->num_states; i++) {
        if (closure1[i] != closure2[i]) {
            return false;
        }
    }
    return true;
}

// 合并两个ε-closure，存储到第一个闭包中
void mergeClosure(DFA *dfa, int *closure1,int *closure2){
    for (int i = 0; i < dfa->num_states; i++) {
        if (closure2[i] == 1) {
            closure1[i] =1;
        }
    }
}

// 清空visited和closure
void clearClosure(DFA *dfa, bool *visited,int *closure){
    for (int i = 0; i < dfa->num_states; i++) {
        closure[i] = 0;
        visited[i] = false;
    }
}
                
// 将NFA转化为DFA
void convertNFAToDFA(DFA *dfa2, DFA *dfa) {
    int num_closure = 0;
    bool visited[MAX_STATES];
    int closure[MAX_STATES];
    int all_closure[MAX_STATES][MAX_STATES];
    int trans[MAX_STATES][MAX_ALPHABET_SIZE];
    int accept[MAX_STATES] = {0};

    // 计算起始状态的空集闭包
    epsilonClosure(dfa, dfa->start_state, visited, closure);
    mergeClosure(dfa,all_closure[0],closure);

    num_closure++;

    for(int c_num= 0;c_num<num_closure;c_num++){
        // 遍历当前闭包的所有输入的结果，若有多个到达的
        int c_now =c_num;
        for (int i =0; i< dfa->num_symbols; i++){
            trans[c_now][i] = -1;
            // 做一下清空
            clearClosure(dfa,visited,closure);

            // 遍历当前所有状态,得到总输出闭包
            for (int j = 0; j < dfa->num_states; j++) {
                if(all_closure[c_num][j] == 1){
                    int state = j;
                    int to_state = dfa->transition[state][i];
                    bool temp_visited[MAX_STATES];
                    int temp_closure[MAX_STATES];
                    clearClosure(dfa,temp_visited,temp_closure);
                    if (to_state != -1) {
                        epsilonClosure(dfa, to_state, temp_visited, temp_closure);
                        mergeClosure(dfa, closure, temp_closure);
                    }
                }
            }
            // 检查该闭包之前是否出现,若没有就加一
            for(int j =0; j<num_closure;j++){
                if(compareClosure(dfa,all_closure[j],closure)){
                    trans[c_now][i] = j;
                    break;
                }
                if(j == num_closure-1){
                    mergeClosure(dfa,all_closure[num_closure],closure);
                    trans[c_now][i] = num_closure;
                    if(closure[dfa->num_states-1]==1){
                        accept[num_closure] =1;
                    }
                    num_closure++;
                    break;
                }
            }
        }
    }

    //做DFA的初始化
    initializeDFA(dfa2,num_closure, dfa->num_symbols);
    for(int i = 0;i<num_closure;i++){
        for(int j = 0; j< dfa->num_symbols;j++){
            if(trans[i][j] !=-1){
                setTransition(dfa2,i,j,trans[i][j]);
            }
        }
        if(accept[i]==1) setAcceptState(dfa2,i);
    }
}

// 执行DFA，接受或拒绝输入字符串
bool runDFA(DFA *dfa, const char *input) {
    int current_state = dfa->start_state;
    for (int i = 0; input[i] != '\0'; i++) {
        int symbol = find(input[i]); 
        if (symbol < 0 || symbol >= dfa->num_symbols) {
            // 无效符号
            return false;
        }
        current_state = dfa->transition[current_state][symbol];
        if (current_state == -1) {
            // 无效状态转移
            return false;
        }
    }
    return dfa->accept_states[current_state];
}

// 执行NFA，接受或拒绝输入字符串，包括ε-closure
bool runNFA(DFA *dfa, const char *input) {
    int current_states[MAX_STATES];
    int num_current_states = 0;
    bool visited[MAX_STATES] = {false};
    int closure[MAX_STATES] = {0};

    epsilonClosure(dfa, dfa->start_state, visited, closure);
    for (int i = 0; i < dfa->num_states; i++) {
        if (closure[i] == 1) {
            current_states[num_current_states++] =i;
        }
    }

    for (int i = 0; input[i] != '\0'; i++) {
        int symbol = find(input[i]); 
        int new_states[MAX_STATES];
        int num_new_states = 0;

        for (int j = 0; j < num_current_states; j++) {
            int state = current_states[j];
            int to_state = dfa->transition[state][symbol];

            if (to_state != -1) {
                new_states[num_new_states++] = to_state;
                // 做一下清空
                for (int i = 0; i < dfa->num_states; i++) {
                    closure[i] = 0;
                    visited[i] = false;
                }
                epsilonClosure(dfa, to_state, visited, closure);
                for (int i = 0; i < dfa->num_states; i++) {
                    if (closure[i] == 1) {
                        new_states[num_new_states ++] =i;
                    }
                }
            }
        }
        num_current_states = 0;
        for (int j = 0; j < num_new_states; j++) {
            current_states[num_current_states++] = new_states[j];
        }
    }

    for (int i = 0; i < num_current_states; i++) {
        if (dfa->accept_states[current_states[i]]) {
            return true;
        }
    }

    return false;
}


// 合并两个DFA
void mergeNFA(DFA *dfa1, DFA *dfa2, int Connection) {
    int old_num_states = dfa1->num_states;
    // 更新符号数
    if(dfa1->num_symbols < dfa2->num_symbols){
        dfa1->num_symbols = dfa2->num_symbols;
    }
    // 更新最大空集状态转移数
    if(dfa1->empty_max < dfa2->empty_max){
        dfa1->empty_max = dfa2->empty_max;
    }
    
    // 更新终止状态
    for (int i = 0; i < dfa2->num_states; i++) {
        if (dfa2->accept_states[i]) {
            dfa1->accept_states[old_num_states + i] = 1;
        }
    }

    // 更新状态转移函数
    for (int i = 0; i < dfa2->num_states; i++) {
        // 这里处理需注意
        for (int j = 0; j <100; j++) {
            if(dfa2->transition[i][j] !=-1){
                dfa1->transition[old_num_states + i][j] = dfa2->transition[i][j] + old_num_states ;
            }
            else{
                dfa1->transition[old_num_states + i][j] = -1;
            }
        }
        for (int j = 0; j < 100; j++) {
            if(dfa2->empty_transition[i][j] !=-1){
                dfa1->empty_transition[old_num_states + i][j] = dfa2->empty_transition[i][j] + old_num_states;
            }
            else{
                dfa1->empty_transition[old_num_states + i][j] = -1;
            }
        }
    }
    // 更新扩展大小的空转移函数
    dfa1->num_states += (dfa2->num_states);
    for (int i = 0; i <  dfa1->num_states; i++) {
        for (int j = old_num_states; j < dfa1->num_states; j++) {
            if(dfa2->empty_transition[i][j] == 0){
                dfa1->empty_transition[i][j] = -1;
            }
        }
    }
    for (int i = old_num_states; i <  dfa1->num_states; i++) {
        for (int j = dfa2->num_states; j < dfa1->num_states; j++) {
            if(dfa2->empty_transition[i][j] == 0){
                dfa1->empty_transition[i][j] = -1;
            }
        }
    }
    // 将合并后的NFA用空集联结
    if( Connection == -1){
        setEmptyTransition(dfa1,old_num_states-1,old_num_states);
    }
    else{
        setEmptyTransition(dfa1,Connection,old_num_states);
    }
}

// Hopcroft 最小化算法
void hopcroftMinimizeDFA(DFA *dfa,DFA * new_dfa) {
    int par_num = 2;
    int partitions[dfa->num_states];
    // 初始划分为两个类，分为终结态和非终结态(0和1)
    for(int i =0 ;i<dfa->num_states;i++){
        if(dfa->accept_states[i] == 1){
            partitions[i] = 0;
            partitions[i] = 1;
        }
        else {
            partitions[i] = 1;
            partitions[i] = 0;
        }
    }
    while(true){
        int mark =0;
        //遍历字符，找到一个能够划分结果的
        for (int i=0;i<dfa->num_symbols;i++){
            for(int j =0 ;j<par_num;j++){
                int remember = -1;
                int new_partition[dfa->num_states];
                for(int k =0; k<dfa->num_states;k++){
                    if(partitions[k] == j && dfa->transition[k][i]!=-1){
                        int to_state = dfa->transition[k][i];
                        if(remember==-1){
                            remember = partitions[to_state];
                            new_partition[k] = 0;
                        }
                        else if(partitions[to_state]!= remember){
                            mark = 1;
                            new_partition[k] = 1;
                        }
                    }
                }
                //按照归类划分，将其他组踢出去，标记mark为1
                if(mark == 1){
                    for(int k =0; k<dfa->num_states;k++){
                        if( new_partition[k] == 1){
                            partitions[k] = par_num;
                        }
                    }
                    par_num++;
                    break;
                }
            }
            if(mark == 1) break;
        }
        if(mark == 0) break;
    }
    initializeDFA(new_dfa,par_num,dfa->num_symbols);
    for (int i=0;i<dfa->num_symbols;i++){
        for(int k =0;k<dfa->num_states;k++){
            if(dfa->accept_states[k] == 1) setAcceptState(new_dfa,partitions[k]);
            setTransition(new_dfa,partitions[k],i,dfa->transition[k][i]);
        }
    }
}

// 打印转移结果
void printTransitionMatrix(DFA *dfa) {
    printf("Transition Matrix:\n");
    for (int i = 0; i < dfa->num_states; i++) {
        printf("Node%d: ",i);
        for (int j = 0; j < dfa->num_symbols; j++) {
            if(dfa->transition[i][j] !=-1 ){
                printf("   --%c-->%d", sym_maps[j],dfa->transition[i][j]);
            }
        }
        printf("\n");
    }
    // //打印转移函数矩阵
    // for (int i = 0; i < dfa->num_states; i++) {
    //     for (int j = 0; j < dfa->num_symbols; j++) {
    //         printf("  %d", dfa->transition[i][j]);
    //     }
    //     printf("\n");
    // }
}

// 打印空集转移结果
void printEmptyTransitionMatrix(DFA *dfa) {
    printf("EmptyTransition Matrix:\n");
    for (int i = 0; i < dfa->num_states; i++) {
        printf("Node%d: ",i);
        for (int j = 0; j < dfa->empty_max; j++) {
            if(dfa->empty_transition[i][j] !=-1 ){
                printf("   --empty-->%d", dfa->empty_transition[i][j]);
            }
        }
        printf("\n");
    }
    // //打印空集转移函数矩阵
    // for (int i = 0; i < dfa->num_states; i++) {
    //     for (int j = 0; j < dfa->empty_max; j++) {
    //         printf("  %d", dfa->empty_transition[i][j]);
    //     }
    //     printf("\n");
    // }
}

int main() {
    // // DFA/NFA接口测试
    // DFA dfa;
    // int num_states = 3;
    // int num_symbols = 2; // 假设字母表包含26个小写字母

    // initializeDFA(&dfa, num_states, num_symbols);
    // setAcceptState(&dfa, 2);

    // // 设置状态转移
    // setTransition(&dfa, 0, 0, 1);
    // setTransition(&dfa, 0, 1, 0);
    // setTransition(&dfa, 1, 0, 2);
    // setTransition(&dfa, 1, 1, 0);
    // setTransition(&dfa, 2, 0, 1);
    // setTransition(&dfa, 2, 1, 2);

    // printTransitionMatrix(&dfa);

    // //由于符号表插入在yacc中词法分析完成，这里我们手动插入符号表
    // insert('a');
    // insert('b');

    // const char *input = "abbaab";
    // if (runDFA(&dfa, input)) {
    //     printf("Accepted\n");
    // } else {
    //     printf("Rejected\n");
    // }

    // input = "abbaaba";
    // if (runDFA(&dfa, input)) {
    //     printf("Accepted\n");
    // } else {
    //     printf("Rejected\n");
    // }
    DFA dfa;
    DFA dfa2;
    
    int num_states = 5;
    int num_symbols = 2; // 假设字母表大小为2

    initializeDFA(&dfa, num_states, num_symbols);
    setAcceptState(&dfa, 2);
    setTransition(&dfa, 0, 0, 1);
    setTransition(&dfa, 0, 1, 0);
    setTransition(&dfa, 1, 0, 2);
    setTransition(&dfa, 1, 1, 0);
    setTransition(&dfa, 2, 0, 1);
    setTransition(&dfa, 2, 1, 2);
    setTransition(&dfa, 3, 0, 3);
    setTransition(&dfa, 3, 1, 4);
    setTransition(&dfa, 4, 0, 3);
    setTransition(&dfa, 4, 1, 4);

    hopcroftMinimizeDFA(&dfa,&dfa2);

    printTransitionMatrix(&dfa2);
    printEmptyTransitionMatrix(&dfa2);       
    return 0;
}