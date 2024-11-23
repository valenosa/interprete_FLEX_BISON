## Como compilar y ejecutar

# Usando makefile
```
make
```

# Manualmente
1. Compilar el Scanner (`scanner.l`)
```bash
flex scanner.l
```

2. Compilar el parser (`parser.y`)
```bash
bison -d parser.y
```

3. Compilar todos los archivos `.c`
```bash
gcc -Wall -g *.c -lfl
```
*NOTA: Por defecto, el nombre del ejecutable será a.out (incluído en .gitignore)*

4. Ejecutar
```bash
./a.out < enunciado/entrada.txt  > enunciado/salida.txt 
```