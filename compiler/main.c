#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define INS_SIZE 32768
#define ADDR_WIDTH 8
#define OPCODE_WIDTH 4

enum Opcode
{
    NOP,
    LOAD_A,
    LOAD_B,
    ADD,
    SUB,
    MUL,
    DOT,
    BUFFER_RES_1,
    BUFFER_RES_2,
    STORE,
    STOP
};

const char *opcode_to_str(enum Opcode opcode)
{
    switch (opcode)
    {
    case NOP: return "NOP";
    case LOAD_A: return "LOAD_A";
    case LOAD_B: return "LOAD_B";
    case ADD: return "ADD";
    case SUB: return "SUB";
    case MUL: return "MUL";
    case DOT: return "DOT";
    case BUFFER_RES_1: return "BUFFER_RES_1";
    case BUFFER_RES_2: return "BUFFER_RES_2";
    case STORE: return "STORE";
    case STOP: return "STOP";
    default: return "UNKNOWN";
    }
}

uint16_t ins[INS_SIZE];

uint16_t op_mat_mul(int M, int N, int P, int W)
{
    uint16_t pc = 0;
    ins[pc++] = NOP;

    for (int m = 0; m < M; m++)
    {
        for (int p = 0; p < P; p += W)
        {
            for (int w = 0; w < W; w++)
            {
                for (int n = 0; n < N / W; n++)
                {
                    ins[pc++] = m * N / W + n << OPCODE_WIDTH | LOAD_A;
                    ins[pc++] = (p + w) * N / W + n << OPCODE_WIDTH | LOAD_B;
                    ins[pc++] = DOT;
                }
                ins[pc++] = BUFFER_RES_2;
            }
            ins[pc++] = m * P / W + p / W << OPCODE_WIDTH | STORE;
        }
    }
    ins[pc++] = STOP;
    uint16_t count = 2 + M * (P / W) * (1 + W * (1 + 3 * N / W));
    printf("count = %d\n", count);
    printf("pc = %d\n", pc);
    return pc;
}

uint16_t op_elem(int op,int M, int N, int W)
{
    uint16_t pc = 0;
    uint16_t addr;
    ins[pc++] = NOP;

    for (int m = 0; m < M; m++)
    {
        for (int n = 0; n < N; n+=W)
        {
            addr = m * N / W + n / W << OPCODE_WIDTH;
            ins[pc++] = addr | LOAD_A;
            ins[pc++] = addr | LOAD_B;
            ins[pc++] = op;
            ins[pc++] = BUFFER_RES_1;
            ins[pc++] = addr | STORE;
        }
    }
    ins[pc++] = STOP;
    return pc;
}

void write_to_asm(const char *filepath, const uint16_t *ins, int size)
{
    FILE *file = fopen(filepath, "w");
    if (file == NULL)
    {
        printf("Failed to open file for writing.\n");
        return;
    }

    for (int i = 0; i < size; i++)
    {
        uint16_t instruction = ins[i];
        enum Opcode opcode = instruction & ((1 << OPCODE_WIDTH) - 1);
        uint16_t addr = instruction >> OPCODE_WIDTH;

        if (opcode == NOP || opcode == STOP || opcode == ADD || opcode == SUB || opcode == MUL || opcode == DOT || opcode == BUFFER_RES_1 || opcode == BUFFER_RES_2)
        {
            fprintf(file, "%s\n", opcode_to_str(opcode));
        }
        else
        {
            fprintf(file, "%s %d\n", opcode_to_str(opcode), addr);
        }
    }

    fclose(file);
}

void write_to_file(const char *filepath, const uint16_t *ins, int size)
{
    FILE *file = fopen(filepath, "w");
    if (file == NULL)
    {
        printf("Failed to open file for writing.\n");
        return;
    }

    for (int i = 0; i < size; i++)
    {
        for (int j = ADDR_WIDTH + OPCODE_WIDTH - 1; j >= 0; j--)
            fprintf(file, "%s", (ins[i] & (1 << j)) ? "1" : "0");
        fprintf(file, "\n");
    }

    fclose(file);
}

int main()
{
    // Your existing code here...
    uint16_t pc = op_mat_mul(8, 8, 8, 4);
    //uint16_t pc = op_elem(ADD, 8, 8, 4);

    // Write binary and assembly outputs
    write_to_file("./cmds/MUL_8x8_4.binc.txt", ins, pc);
    write_to_asm("./cmds/MUL_8x8_4.asm.txt", ins, pc);

    return 0;
}


