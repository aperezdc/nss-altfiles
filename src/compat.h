/*
 * compat.h
 * Copyright (C) 2012 Adrian Perez <aperez@igalia.com>
 */

#ifndef __compat_h__
#define __compat_h__

#include <alloca.h>
#include <errno.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <strings.h>
#include <limits.h>

#define __set_errno(errval) \
    (errno = (errval))

#define __libc_lock_define_initialized(CLASS, lockvar) \
    CLASS pthread_mutex_t lockvar = PTHREAD_MUTEX_INITIALIZER;

#define __libc_lock_lock(lock) \
    pthread_mutex_lock (&(lock))

#define __libc_lock_unlock(lock) \
    pthread_mutex_unlock (&(lock))

#define __MAX_ALLOCA_CUTOFF 65536
#define __libc_use_alloca(bytes) \
    (bytes <= __MAX_ALLOCA_CUTOFF)

#define extend_alloca(buf, len, newlen) \
    alloca(((len) = (newlen)))

#define __strcasecmp(s1, s2) \
    strcasecmp(s1, s2)

#define __glibc_unlikely(cond) __builtin_expect ((cond), 0)
#define __glibc_likely(cond)   __builtin_expect ((cond), 1)

extern int __have_o_cloexec;

#ifndef ALTFILES_DATADIR
#define ALTFILES_DATADIR "/lib"
#endif /* !ALTFILES_DATADIR */

#ifndef ALTFILES_MODULE_NAME
#define ALTFILES_MODULE_NAME altfiles
#endif /* !ALTFILES_MODULE_NAME */

#define __ALTFILES_SYMBOL1(n,a)		_nss_ ## n ## a
#define __ALTFILES_SYMBOL2(n,a,b)	_nss_ ## n ## a ## b
#define _ALTFILES_SYMBOL1(n,a)    	__ALTFILES_SYMBOL1(n,a)
#define _ALTFILES_SYMBOL2(n,a,b)  	__ALTFILES_SYMBOL2(n,a,b)
#define ALTFILES_SYMBOL1(a)     _ALTFILES_SYMBOL1(ALTFILES_MODULE_NAME,a)
#define ALTFILES_SYMBOL2(a,b)   _ALTFILES_SYMBOL2(ALTFILES_MODULE_NAME,a,b)

#endif /* !__compat_h__ */

