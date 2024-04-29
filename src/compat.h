/*
 * compat.h
 * Copyright (C) 2012 Adrian Perez <aperez@igalia.com>
 */

#pragma once

#include <alloca.h>
#include <errno.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <strings.h>
#include <limits.h>

#define off64_t off_t
#define __fseeko64 fseeko
#define __ftello64 ftello
#define __feof_unlocked feof_unlocked
#define __fgets_unlocked fgets_unlocked
#define __inet_network inet_network
#define __inet_pton inet_pton

static inline void
fseterr_unlocked(FILE *f)
{
    f->_flags |= _IO_ERR_SEEN;
}

#define _IO_flockfile flockfile
#define _IO_funlockfile funlockfile

#define IS_IN(_) 0

#define attribute_hidden __attribute__((visibility("hidden")))
#define libc_hidden_proto(fn)
#define libc_hidden_def(fn)

#define __set_errno(errval) \
    (errno = (errval))

#define __set_h_errno(errval) \
    (h_errno = (errval))

#define __libc_lock_define_initialized(CLASS, lockvar) \
    CLASS pthread_mutex_t lockvar = PTHREAD_MUTEX_INITIALIZER;

#define __libc_lock_init

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

#ifndef ALTFILES_DATADIR
#define ALTFILES_DATADIR "/lib"
#endif /* !ALTFILES_DATADIR */

#ifndef ALTFILES_MODULE_NAME
#define ALTFILES_MODULE_NAME altfiles
#endif /* !ALTFILES_MODULE_NAME */
