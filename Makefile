CC = gcc
CFLAGS = -Wall

all: build run

build:
	$(CC) $(CFLAGS) -o lvfs cxfs.c -lncurses

run:
	./lvfs

clean:
	rm -f lvfs 
