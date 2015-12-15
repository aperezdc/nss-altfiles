/*
 * main.c
 * Copyright (C) 2015 Adrian Perez <aperez@igalia.com>
 *
 * Distributed under terms of the MIT license.
 */

#include "compat.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define XSTRINGIZE(y) #y
#define STRINGIZE(x)  XSTRINGIZE(x)

static int
usage (const char *prgname)
{
    fprintf (stderr, "Usage: %s [datadir | modulename]\n", prgname);
    return EXIT_FAILURE;
}

int
main (int argc, const char *argv[])
{
    if (argc > 2) return usage (argv[0]);

    if (argc == 1 || strcmp (argv[1], "datadir") == 0) {
        printf ("%s\n", ALTFILES_DATADIR);
    } else if (strcmp (argv[1], "modulename") == 0) {
        printf ("%s\n", STRINGIZE (ALTFILES_MODULE_NAME));
    } else {
        return usage (argv[0]);
    }
    return EXIT_SUCCESS;
}
