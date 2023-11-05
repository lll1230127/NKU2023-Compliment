#include <iostream>
#include <string.h>
#include <unistd.h>
#include "common.h"
#include "SymbolTable.h"

extern FILE *yyin;
extern FILE *yyout;

int yylex();

char outfile[256] = "a.out";
std::string table_path_str = "null";
char* table_path;
dump_type_t dump_type = ASM;

int main(int argc, char *argv[])
{
    int opt;
    while ((opt = getopt(argc, argv, "to:")) != -1)
    {
        switch (opt)
        {
        case 'o':
            strcpy(outfile, optarg);
            table_path_str = outfile;
            table_path_str = table_path_str.replace(table_path_str.size()-5,5,".tab");
            table_path = const_cast<char*>(table_path_str.c_str());
            break;
        case 't':
            dump_type = TOKENS;
            break;
        default:
            fprintf(stderr, "Usage: %s [-o outfile] infile\n", argv[0]);
            exit(EXIT_FAILURE);
            break;
        }
    }
    if (optind >= argc)
    {
        fprintf(stderr, "no input file\n");
        exit(EXIT_FAILURE);
    }
    if (!(yyin = fopen(argv[optind], "r")))
    {
        fprintf(stderr, "%s: No such file or directory\nno input file\n", argv[optind]);
        exit(EXIT_FAILURE);
    }
    if (!(yyout = fopen(outfile, "w")))
    {
        fprintf(stderr, "%s: fail to open output file\n", outfile);
        exit(EXIT_FAILURE);
    }
    yylex();
    FILE* table_out = fopen(table_path, "w");
    if(table_out){
        printAllTable(table_out);
    }
    return 0;
}


int yywrap()
{
    while (!symbolTableStack.empty()) {
        symbolTableQueue.push(symbolTableStack.top());
        symbolTableStack.pop();
    }
	return 1;
}