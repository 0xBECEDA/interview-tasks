#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

/* проверка, есть ли у числа единицы в соседних битах */
int analyzeNum (int cntBits, unsigned long long checkNum, int usersNum) {

    for (int i = cntBits - 1; i > 0; i--) {

        unsigned long long andResult = usersNum & checkNum;
        if (andResult == checkNum) {
            return -1;
        }
        checkNum = checkNum >> 1;
    }
    return 0;
}

/* запись числа в двоичном формате по заданному указателю в виде строки */
char * writeBinNum (unsigned long long checkNum, unsigned long long curNum,
                    char * memory_p, int cntBits) {

    for (int i = cntBits; i > 0; i--) {

        unsigned long long andResult = curNum & checkNum;
        if (andResult == checkNum) {
            *memory_p = 49;
            memory_p++;
            checkNum = checkNum >> 1;
        }else {
            * memory_p = 48;
            memory_p++;
            checkNum = checkNum >> 1;
        }
    }

    * memory_p = 10;
    memory_p++;
    return memory_p;
}

void main() {

    /* чтение пользовательского ввода с stdin */
    char numStr[100];

    if (fgets(numStr, 20, stdin) == NULL) {
        printf("fgets: didn't read the number from stdin\n");
        exit(0);
    }

    /* преобразование ввода из строки в число */
    char *endptr;
    int base = 10;
    unsigned long usersNum = strtoul(numStr, &endptr, base);
    if (endptr == numStr) {
        puts("strtoul: no conversion\n");
        exit(0);
    }
    /* считаем сколько бит в числе */
    int cntBits;
    /* u в конце числа нужно, чтоб убрать ворнинг компилера */
    unsigned long long checkNum = 9223372036854775808u;

    for (int i = 64; i > 0; i--) {

        unsigned long long andResult = usersNum & checkNum;

        if (andResult == checkNum) {
            cntBits = i;
            break;
        }
        checkNum = checkNum >> 1;
    }

    /* выделяем память для записи чисел в двоичном формате */

    int size = (cntBits + 1) * usersNum;
    char * memory_p = (char*)malloc(size);

    if (memory_p == NULL) {
        puts("malloc: returned NULL pointer\n");
        exit(0);
    }

    /* устанавливаем число-проверку */
    checkNum = 13835058055282163712u;

    for (int i = 64 - cntBits; i > 0; i--) {
        checkNum = checkNum >> 1;
    }

    /* установили счетчик заполняемости выделенной памяти */
    int memoryFull = 0;
    /* сохранили указатель на выделенную память */
    char * memory_pCopy = memory_p;

    /* создаем дополнительно число-проверку - понадобится при записи чисел в память в */
    /* двоичном формате в виде строки */
    unsigned long long checkNumBinPrint = 9223372036854775808u;

    for (int i = 64 - cntBits; i > 0; i--) {
        checkNumBinPrint = checkNumBinPrint >> 1;
    }

    /* начинаем проверку чисел */
    for (int i = 1; i < usersNum; i++) {
        int value = analyzeNum(cntBits, checkNum, i);
        if (value == 0) {
            /* если число подходит, пишем его бинарном представление в память
               как строку */
            memory_p = writeBinNum(checkNumBinPrint, i, memory_p, cntBits);
            memoryFull += cntBits + 1;
        }
    }
    /* вывод всех чисел */
    write(1, memory_pCopy, memoryFull);
}
