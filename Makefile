DFLAGS = -Wall

# Debug
DFLAGS += -ggdb

# Unittest
DFLAGS += -funittest -fversion=UnitTest

# Release
#DFLAGS += -frelease -O3

all: test

test.o: test.d ev/c.d
	gdc -c $(DFLAGS) test.d

ev/c.o: ev/c.d
	gdc -c -o ev/c.o $(DFLAGS) ev/c.d

test: test.o ev/c.o
	gdc -o test -lev $(DFLAGS) test.o ev/c.o

clean:
	$(RM) -v *.o ev/*.o test

.PHONY: clean all

