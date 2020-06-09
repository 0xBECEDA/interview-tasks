BINNAME= asm-version

all: compilation

compilation: asm-version.S
		     gcc asm-version.S -fno-pie -no-pie -o $(BINNAME)

start:
	./$(BINNAME)
