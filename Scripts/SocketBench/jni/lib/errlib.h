#ifndef _ERRLIB_H
#define _ERRLIB_H

#ifdef	__cplusplus
extern "C" {
#endif

#include <stdarg.h>

extern int daemon_proc;

void err_msg (const char *fmt, ...);

void err_quit (const char *fmt, ...);

void err_ret (const char *fmt, ...);

void err_sys (const char *fmt, ...);

void err_dump (const char *fmt, ...);

#ifdef	__cplusplus
}
#endif

#endif
