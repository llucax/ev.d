DFLAGS = -Wall

# Debug
DFLAGS += -ggdb

# Unittest
DFLAGS += -funittest -fversion=UnitTest

# Release
#DFLAGS += -frelease -O3

TARGETS = ctest dtest

all: $(TARGETS)

ctest.o: ctest.d ev/c.d
	gdc -c $(DFLAGS) ctest.d

dtest.o: dtest.d ev/c.d ev/d.d
	gdc -c $(DFLAGS) dtest.d

ev/c.o: ev/c.d
	gdc -c -o ev/c.o $(DFLAGS) ev/c.d

ev/d.o: ev/d.d
	gdc -c -o ev/d.o $(DFLAGS) ev/d.d

ctest: ctest.o ev/c.o
	gdc -o ctest -lev $(DFLAGS) ctest.o ev/c.o

dtest: dtest.o ev/c.o ev/d.o
	gdc -o dtest -lev $(DFLAGS) dtest.o ev/c.o ev/d.o

clean:
	$(RM) -v *.o ev/*.o $(TARGETS)

.PHONY: clean all

