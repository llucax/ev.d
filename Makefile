DFLAGS = -Wall

# Debug
DFLAGS += -ggdb

# Unittest
#DFLAGS += -funittest -fversion=UnitTest

# Release
#DFLAGS += -frelease -O3

all: test

test.o: test.d ev.d
	gdc -c $(DFLAGS) test.d

ev.o: ev.d
	gdc -c $(DFLAGS) ev.d

test: test.o ev.o
	gdc -o test -lev $(DFLAGS) test.o ev.o

clean:
	$(RM) -v *.o test

.PHONY: clean all

