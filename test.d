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

import io = std.stdio;
import ev;

extern (C)
{
	static void stdin_cb (ev_loop_t* loop, ev_io *w, int revents)
	{
		io.writefln("stdin ready");
		char[] ln = io.readln();
		io.writef("read %d bytes: %s", ln.length, ln);
		ev_io_stop(loop, w); // just a syntax example
		ev_unloop(loop, how.ALL); // leave all loop calls
	}
	static void timeout_cb(ev_loop_t* loop, ev_timer *w, int revents)
	{
		io.writefln("timeout");
		ev_unloop(loop, how.ONE); // leave one loop call
	}
}

void main()
{
	ev_io    stdin_watcher;
	ev_timer timeout_watcher;

	auto loop = ev_default_loop();

	/* initialise an io watcher, then start it */
	ev_io_init(&stdin_watcher, &stdin_cb, /*STDIN_FILENO*/ 0, READ);
	ev_io_start(loop, &stdin_watcher);

	/* simple non-repeating 5.5 second timeout */
	ev_timer_init(&timeout_watcher, &timeout_cb, 1.5, 0.0);
	ev_timer_start(loop, &timeout_watcher);

	/* loop till timeout or data ready */
	ev_loop(loop, 0);
}

