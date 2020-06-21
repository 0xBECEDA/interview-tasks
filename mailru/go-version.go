package main
import (
	"fmt"
	"strconv"
	"os"
	"syscall"
)

func analyzeNum (userNum int, mask int, cntBits int)  int {
	returnValue := 0

	for i := cntBits - 1; i > 0;  i-- {
		var andRes int = userNum & mask

		if andRes == mask {
			returnValue = -1
			break
		}
		mask = mask >> 1
	}
	return returnValue
}


func main() {

	// считали ввод с stdin
	var numStr string
	fmt.Scan(&numStr)

	// преобразование строки в число
	userNum, atoiErr := strconv.Atoi(numStr)

	if atoiErr != nil {
		fmt.Println("atoiErr : ",  atoiErr)
		os.Exit(0)
	}

	if userNum > 65535 {
		fmt.Println("Error : too big num\n")
		os.Exit(0)
	}

	var mask int = 32768
	cntBits := 0

	// считаем кол-во битов в числе
	for i := 16; i > 0;  i-- {
		var andRes int = userNum & mask

		if andRes == mask {
			cntBits = i
			break
		}
		mask = mask >> 1
	}
    // устанавливаем маску, которая будет участвовать в создании строчного бинарного
	// представления чисел
	maskForBinPrint := 32768

	// устанавливаем маску, с помощью которой будем искать соседние единицы в числах
	mask = 49152
	for i := 16 - cntBits; i > 0;  i-- {

		mask = mask >> 1
	}

	// выделяем память под числа
	amoutBites := (cntBits + 1) * userNum
	buf := make([]byte, amoutBites)

	// устанавливаем счетчик заполнения памяти
	fullMemoryCnt := 0

	maskForBinPrintCopy := maskForBinPrint

	//запускаем анализ чисел
	for i := 0; i < userNum;  i++ {
		returnValue:= analyzeNum(i, mask, cntBits)
		// если число подходит
		if returnValue == 0 {
			for j:= cntBits; j >= 0; j-- {
				//создаем его бинарное представление в виде строки и пишем его в память
				if j == 0 {
					buf[fullMemoryCnt] = 10
					fullMemoryCnt++
					maskForBinPrint = maskForBinPrintCopy

				}else if i & maskForBinPrint == maskForBinPrint {
					buf[fullMemoryCnt] = 49
					fullMemoryCnt++
					maskForBinPrint = maskForBinPrint >> 1

				}else {
					buf[fullMemoryCnt] = 48
					fullMemoryCnt++
					maskForBinPrint = maskForBinPrint >> 1
				}
			}
		}
	}

	// копируем все полученные строки в отдельный массив, чтоб не печатать пустые байтыч
	bufEnd := make([]byte, fullMemoryCnt)

	for i := 0; i < fullMemoryCnt;  i++ {

		bufEnd[i] = buf[i]
	}

	// печатаем все в stdout
	syscall.Write(1, bufEnd)
}
