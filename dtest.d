/+
 + D Programming Language "bindings" to libev
 + <http://software.schmorp.de/pkg/libev.html> test program.
 +
 + Written by Leandro Lucarella (2008).
 +
 + Placed under BOLA license <http://auriga.wearlab.de/~alb/bola/> which is
 + basically public domain.
 +
 +/

import std.stdio;
import ev.d;

void main()
{
	auto iow = new Io(0, READ,
		(Io w, int revents)
		{
			writefln("stdin ready");
			char[] ln = readln();
			writef("read %d bytes: %s", ln.length, ln);
			w.stop; // just a syntax example
			assert (w.loop !is null);
			w.loop.unloop(Unloop.ALL); // leave all loop calls
		}
	);
	assert (iow.loop !is null);
	iow.start;
	auto timerw = new Timer(5.5,
		(Timer w, int revents)
		{
			writefln("timeout, revents = ", revents);
			w.loop.unloop(Unloop.ONE); // example syntax
		}
	);
	assert (timerw.loop !is null);
	timerw.start;
	loop.loop;
}

