all: flex bison
	gcc *.c -Wall -g -lfl && \
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
	