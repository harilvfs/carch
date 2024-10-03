CC = gcc
CFLAGS = -Wall

all: build run

build:
	$(CC) $(CFLAGS) -o lvfs cxfs.c -lncurses

run:
	./lfvs

clean:
	rm -f lfvs
