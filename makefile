all: flex bison
	gcc *.c -Wall -g -lfl && \
	./a.out < enunciado/entradaok.txt > enunciado/1-salidaok-tp2.txt  && \
	./a.out < enunciado/entradaerr.txt > enunciado/2-salidaerr-tp2.txt  && \
	./a.out < enunciado/entradaerr2.txt > enunciado/3-salidaerr2-tp2.txt  && \
	make clean && \
	echo '\n'Compilacion y ejecucion realizada con éxito

flex:
	flex scanner.l

bison:
	bison -d parser.y

clean:
	rm scanner.c 
	rm scanner.h
	rm parser.c
	rm parser.h
	