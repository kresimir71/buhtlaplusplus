
GPLC = gplc

CC=g++
CXX=g++

COMPILER_FLAGS=-pedantic -Wall -I/usr/local/gprolog-1.4.5/include -g

CFLAGS=$(COMPILER_FLAGS)
CXXFLAGS= -std=c++14 $(COMPILER_FLAGS)

all: buhtla

buhtla: driver.o buhtla.o
	$(GPLC)  --linker $(CXX)  driver.o buhtla.o -o buhtla

driver.o: driver.cpp

buhtla.o: buhtla.pl
	$(GPLC)  -c -C '$(CFLAGS)' buhtla.pl

clean:
	-rm -f *.o  buhtla



