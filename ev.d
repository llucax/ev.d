/+
 + D Programming Language "bindings" to libev
 + <http://software.schmorp.de/pkg/libev.html>
 +
 + Written by Leandro Lucarella (2008).
 +
 + Placed under BOLA license <http://auriga.wearlab.de/~alb/bola/> which is
 + basically public domain.
 +
 +/

module ev;

enum: uint
{
	UNDEF    = 0xFFFFFFFFL, // guaranteed to be invalid
	NONE     =       0x00L, // no events
	READ     =       0x01L, // ev_io detected read will not block
	WRITE    =       0x02L, // ev_io detected write will not block
	IOFDSET  =       0x80L, // internal use only
	TIMEOUT  = 0x00000100L, // timer timed out
	PERIODIC = 0x00000200L, // periodic timer timed out
	SIGNAL   = 0x00000400L, // signal was received
	CHILD    = 0x00000800L, // child/pid had status change
	STAT     = 0x00001000L, // stat data changed
	IDLE     = 0x00002000L, // event loop is idling
	PREPARE  = 0x00004000L, // event loop about to poll
	CHECK    = 0x00008000L, // event loop finished poll
	EMBED    = 0x00010000L, // embedded event loop needs sweep
	FORK     = 0x00020000L, // event loop resumed in child
	ERROR    = 0x80000000L, // sent when an error occurs
}

enum: uint
{
	// bits for ev_default_loop and ev_loop_new
	// the default
	AUTO       = 0x00000000UL, // not quite a mask
	// flag bits
	NOENV      = 0x01000000UL, // do NOT consult environment
	FORKCHECK  = 0x02000000UL, // check for a fork in each iteration
	// method bits to be ored together
	SELECT     = 0x00000001UL, // about anywhere
	POLL       = 0x00000002UL, // !win
	EPOLL      = 0x00000004UL, // linux
	KQUEUE     = 0x00000008UL, // bsd
	DEVPOLL    = 0x00000010UL, // solaris 8 / NYI
	PORT       = 0x00000020UL, // solaris 10
}

enum
{
	NONBLOCK = 1, // do not block/wait
	ONESHOT  = 2, // block *once* only
}

enum how
{
	CANCEL = 0, // undo unloop
	ONE    = 1, // unloop once
	ALL    = 2, // unloop all loops
}

extern (C)
{

	version (EV_ENABLE_SELECT)
	{
	}
	else
	{
		version = EV_PERIODIC_ENABLE;
		version = EV_STAT_ENABLE;
		version = EV_IDLE_ENABLE;
		version = EV_FORK_ENABLE;
		version = EV_EMBED_ENABLE;
	}

	alias double ev_tstamp;

	struct ev_loop_t;

	template EV_COMMON()
	{
		void* data;
	}

	template EV_CB_DECLARE(TYPE)
	{
		void function (ev_loop_t*, TYPE*, int) cb;
	}

	template EV_WATCHER(TYPE)
	{
		int active;                 // private
		int pending;                // private
		int priority;               // private
		mixin EV_COMMON;            // rw
		mixin EV_CB_DECLARE!(TYPE); // private
	}

	template EV_WATCHER_LIST(TYPE)
	{
		mixin EV_WATCHER!(TYPE);
		ev_watcher_list* next;      // private
	}

	template EV_WATCHER_TIME(TYPE)
	{
		mixin EV_WATCHER!(TYPE);
		ev_tstamp at;               // private
	}

	align (4) {

		struct ev_watcher
		{
			mixin EV_WATCHER!(ev_watcher);
		}

		struct ev_watcher_list
		{
			mixin EV_WATCHER_LIST!(ev_watcher_list);
		}

		struct ev_watcher_time
		{
			mixin EV_WATCHER_TIME!(ev_watcher_time);
		}

		struct ev_io
		{
			mixin EV_WATCHER_LIST!(ev_io);
			int fd;     // ro
			int events; // ro
		}

		struct ev_timer
		{
			mixin EV_WATCHER_TIME!(ev_timer);
			ev_tstamp repeat; // rw
		}

		version (EV_PERIODIC_ENABLE)
		{
			struct ev_periodic
			{
				mixin EV_WATCHER_TIME!(ev_periodic);
				ev_tstamp offset;                     // rw
				ev_tstamp interval;                   // rw
				ev_tstamp function(ev_periodic *w,
					ev_tstamp now) reschedule_cb; // rw
			}
		}

		struct ev_signal
		{
			mixin EV_WATCHER_LIST!(ev_signal);
			int signum; // ro
		}

		struct ev_child
		{
			mixin EV_WATCHER_LIST!(ev_child);
			int pid;     // ro
			int rpid;    // rw, holds the received pid
			int rstatus; // rw, holds the exit status, use the
			             // macros from sys/wait.h
		}

		version (EV_STAT_ENABLE)
		{

			version (Windows) // alias _stati64 ev_statdata;
			{
				pragma (msg, "ev_stat not supported in windows "
						"because I don't know the "
						"layout of _stati64");
				static assert(0);
				// Maybe this should work?
				//static import stat = std.c.windows.stat;
				//alias stat.struct_stat ev_statdata;
			}
			else // It should be POSIX
			{
				static import stat = std.c.unix.unix;
				alias stat.struct_stat ev_statdata;
			}

			struct ev_stat
			{
				mixin EV_WATCHER_LIST!(ev_stat);

				ev_timer timer;     // private
				ev_tstamp interval; // ro
				const char *path;   // ro
				ev_statdata prev;   // ro
				ev_statdata attr;   // ro
				int wd; // wd for inotify, fd for kqueue
			}
		}

		version (EV_IDLE_ENABLE)
		{
			struct ev_idle
			{
				mixin EV_WATCHER!(ev_idle);
			}
		}

		struct ev_prepare
		{
			mixin EV_WATCHER!(ev_prepare);
		}

		struct ev_check
		{
			mixin EV_WATCHER!(ev_check);
		}

		version (EV_FORK_ENABLE)
		{
			struct ev_fork
			{
				mixin EV_WATCHER!(ev_fork);
			}
		}

		version (EV_EMBED_ENABLE)
		{
			struct ev_embed
			{
				mixin EV_WATCHER!(ev_embed);
				ev_loop_t* other;     // ro
				ev_io io;             // private
				ev_prepare prepare;   // private
				ev_check check;       // unused
				ev_timer timer;       // unused
				ev_periodic periodic; // unused
				ev_idle idle;         // unused
				ev_fork fork;         // unused
			}
		}
	}

	int ev_version_major();
	int ev_version_minor();

	uint ev_supported_backends();
	uint ev_recommended_backends();
	uint ev_embeddable_backends();

	ev_tstamp ev_time();
	void ev_sleep(ev_tstamp delay); // sleep for a while

	// Sets the allocation function to use, works like realloc.
	// It is used to allocate and free memory.
	// If it returns zero when memory needs to be allocated, the library
	// might abort
	// or take some potentially destructive action.
	// The default is your system realloc function.
	void ev_set_allocator(void* function(void* ptr, int size));

	// set the callback function to call on a
	// retryable syscall error
	// (such as failed select, poll, epoll_wait)
	void ev_set_syserr_cb(void* function(char* msg));

	extern ev_loop_t* ev_default_loop_ptr;

	ev_loop_t* ev_default_loop_init(uint flags);

	// create and destroy alternative loops that don't handle signals
	ev_loop_t* ev_loop_new(uint flags);
	void ev_loop_destroy(ev_loop_t*);
	void ev_loop_fork(ev_loop_t*);

	ev_tstamp ev_now(ev_loop_t*);
	void ev_default_destroy();
	void ev_default_fork();
	uint ev_backend(ev_loop_t*);
	uint ev_loop_count(ev_loop_t*);
	void ev_loop(ev_loop_t*, int flags);
	void ev_unloop(ev_loop_t*, how);
	void ev_set_io_collect_interval(ev_loop_t*, ev_tstamp interval);
	void ev_set_timeout_collect_interval(ev_loop_t*, ev_tstamp interval);
	void ev_ref(ev_loop_t*);
	void ev_unref(ev_loop_t*);
	void ev_once(ev_loop_t*, int fd, int events, ev_tstamp timeout,
			void function(int revents, void* arg), void* arg);

	void ev_feed_event(ev_loop_t*, void *w, int revents);
	void ev_feed_fd_event(ev_loop_t*, int fd, int revents);
	void ev_feed_signal_event (ev_loop_t*, int signum);
	void ev_invoke(ev_loop_t*, void *w, int revents);
	int  ev_clear_pending(ev_loop_t*, void *w);

	void ev_io_start(ev_loop_t*, ev_io *w);
	void ev_io_stop(ev_loop_t*, ev_io *w);

	void ev_timer_start(ev_loop_t*, ev_timer *w);
	void ev_timer_stop(ev_loop_t*, ev_timer *w);
	void ev_timer_again(ev_loop_t*, ev_timer *w);

	version (EV_PERIODIC_ENABLE)
	{
		void ev_periodic_start(ev_loop_t*, ev_periodic *w);
		void ev_periodic_stop(ev_loop_t*, ev_periodic *w);
		void ev_periodic_again(ev_loop_t*, ev_periodic *w);
	}

	void ev_signal_start(ev_loop_t*, ev_signal *w);
	void ev_signal_stop(ev_loop_t*, ev_signal *w);

	/* only supported in the default loop */
	void ev_child_start(ev_loop_t*, ev_child *w);
	void ev_child_stop(ev_loop_t*, ev_child *w);

	version (EV_STAT_ENABLE)
	{
		void ev_stat_start(ev_loop_t*, ev_stat *w);
		void ev_stat_stop(ev_loop_t*, ev_stat *w);
		void ev_stat_stat(ev_loop_t*, ev_stat *w);
	}

	version (EV_IDLE_ENABLE)
	{
		void ev_idle_start(ev_loop_t*, ev_idle *w);
		void ev_idle_stop(ev_loop_t*, ev_idle *w);
	}

	void ev_prepare_start(ev_loop_t*, ev_prepare *w);
	void ev_prepare_stop(ev_loop_t*, ev_prepare *w);

	void ev_check_start(ev_loop_t*, ev_check *w);
	void ev_check_stop(ev_loop_t*, ev_check *w);

	version (EV_FORK_ENABLE)
	{
		void ev_fork_start(ev_loop_t*, ev_fork *w);
		void ev_fork_stop(ev_loop_t*, ev_fork *w);
	}

	version (EV_EMBED_ENABLE)
	{
		// only supported when loop to be embedded is in fact embeddable
		void ev_embed_start(ev_loop_t*, ev_embed *w);
		void ev_embed_stop(ev_loop_t*, ev_embed *w);
		void ev_embed_sweep(ev_loop_t*, ev_embed *w);
	}

	bool ev_is_pending(TYPE)(TYPE* w)
	{
		return w.pending;
	}

	bool ev_is_active(TYPE)(TYPE* w)
	{
		return w.active;
	}

	int ev_priority(TYPE)(TYPE* w)
	{
		return w.priority;
	}

	void function(ev_loop_t*, TYPE*, int) ev_cb(TYPE)(TYPE* w)
	{
		return w.cb;
	}

	void ev_set_priority(TYPE)(TYPE* w, int pri)
	{
		w.priority = pri;
	}

	void ev_set_cb(TYPE)(TYPE* w,
			void function(ev_loop_t*, TYPE*, int) cb)
	{
		w.cb = cb;
	}

	void ev_init(TYPE)(TYPE* w,
			void function(ev_loop_t*, TYPE*, int) cb)
	{
		w.active = 0;
		w.pending = 0;
		w.priority = 0;
		ev_set_cb(w, cb);
	}

	void ev_io_set(ev_io* w, int fd, int events)
	{
		w.fd = fd;
		w.events = events | IOFDSET;
	}

	void ev_timer_set(ev_timer* w, ev_tstamp after, ev_tstamp repeat)
	{
		w.at = after;
		w.repeat = repeat;
	}

	void ev_periodic_set(ev_periodic* w, ev_tstamp ofs, ev_tstamp ival,
			ev_tstamp function(ev_periodic *w, ev_tstamp now) res)
	{
		w.offset = ofs;
		w.interval = ival;
		w.reschedule_cb = res;
	}

	void ev_signal_set(ev_signal* w, int signum)
	{
		w.signum = signum;
	}

	void ev_child_set(ev_child* w, int pid)
	{
		w.pid = pid;
	}

	void ev_stat_set(ev_stat* w, char* path, ev_tstamp interval)
	{
		w.path = path;
		w.interval = interval;
		w.wd = -2;
	}

	void ev_idle_set(ev_idle* w)
	{
	}

	void ev_prepare_set(ev_prepare* w)
	{
	}

	void ev_check_set(ev_check* w)
	{
	}

	void ev_embed_set(ev_embed* w, ev_loop_t* other)
	{
		w.other = other;
	}

	void ev_fork_set(ev_fork* w)
	{
	}

	void ev_io_init(ev_io* w, void function(ev_loop_t*, ev_io*, int) cb, int fd,
			int events)
	{
		ev_init(w, cb);
		ev_io_set(w, fd, events);
	}

	void ev_timer_init(ev_timer* w, void function(ev_loop_t*, ev_timer*, int) cb,
			ev_tstamp after, ev_tstamp repeat)
	{
		ev_init(w, cb);
		ev_timer_set(w, after, repeat);
	}

	void ev_periodic_init(ev_periodic* w,
			void function(ev_loop_t*, ev_periodic*, int) cb,
			ev_tstamp ofs, ev_tstamp ival,
			ev_tstamp function(ev_periodic *w, ev_tstamp now) res)
	{
		ev_init(w, cb);
		ev_periodic_set(w, ofs, ival, res);
	}

	void ev_signal_init(ev_signal* w, void function(ev_loop_t*, ev_signal*, int) cb,
			int signum)
	{
		ev_init(w, cb);
		ev_signal_set(w, signum);
	}

	void ev_child_init(ev_child* w, void function(ev_loop_t*, ev_child*, int) cb,
			int pid)
	{
		ev_init(w, cb);
		ev_child_set(w, pid);
	}

	void ev_stat_init(ev_stat* w, void function(ev_loop_t*, ev_stat*, int) cb,
			char* path, ev_tstamp interval)
	{
		ev_init(w, cb);
		ev_stat_set(w, path, interval);
	}

	void ev_idle_init(ev_idle* w, void function(ev_loop_t*, ev_idle*, int) cb)
	{
		ev_init(w, cb);
		ev_idle_set(w);
	}

	void ev_prepare_init(ev_prepare* w,
			void function(ev_loop_t*, ev_prepare*, int) cb)
	{
		ev_init(w, cb);
		ev_prepare_set(w);
	}

	void ev_check_init(ev_check* w, void function(ev_loop_t*, ev_check*, int) cb)
	{
		ev_init(w, cb);
		ev_check_set(w);
	}

	void ev_embed_init(ev_embed* w, void function(ev_loop_t*, ev_embed*, int) cb,
			ev_loop_t* other)
	{
		ev_init(w, cb);
		ev_embed_set(w, other);
	}

	void ev_fork_init(ev_fork* w, void function(ev_loop_t*, ev_fork*, int) cb)
	{
		ev_init(w, cb);
		ev_fork_set(w);
	}

	ev_loop_t* ev_default_loop(uint flags = AUTO)
	{
		if (!ev_default_loop_ptr)
			ev_default_loop_init(flags);
		return ev_default_loop_ptr;
	}

}

