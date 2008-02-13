DFLAGS = -Wall

# Debug
DFLAGS += -ggdb

# Unittest
DFLAGS += -funittest -fversion=UnitTest

# Release
#DFLAGS += -frelease -O3

all: ctest

ctest.o: ctest.d ev/c.d
	gdc -c $(DFLAGS) ctest.d

ev/c.o: ev/c.d
	gdc -c -o ev/c.o $(DFLAGS) ev/c.d

ctest: ctest.o ev/c.o
	gdc -o ctest -lev $(DFLAGS) ctest.o ev/c.o

clean:
	$(RM) -v *.o ev/*.o ctest

.PHONY: clean all

