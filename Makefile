
all: test

test.o: test.d ev.d
	gdc -c -Wall -ggdb test.d

ev.o: ev.d
	gdc -c -Wall -ggdb ev.d

test: test.o ev.o
	gdc -o test -lev test.o ev.o

clean:
	$(RM) -v *.o test

.PHONY: clean all

