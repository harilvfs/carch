CC = gcc
CFLAGS = -Wall

all: build run

build:
	$(CC) $(CFLAGS) -o lfvs cxfs.c -lncurses

run:
	./lfvs

clean:
	rm -f lfvs
