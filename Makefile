# vim: filetype=make
# Adrian Perez, 2014-05-21
#

-include config.mk

LIBDIR ?= $(PREFIX)/lib

O := src/nss_altfiles/files-pwd.o \
     src/nss_altfiles/files-grp.o \
     src/nss_altfiles/files-hosts.o \
     src/nss_altfiles/files-network.o \
     src/nss_altfiles/files-proto.o \
     src/nss_altfiles/files-pwd.o \
     src/nss_altfiles/files-rpc.o \
     src/nss_altfiles/files-service.o \
     src/nss_altfiles/files-sgrp.o \
     src/nss_altfiles/files-spwd.o \
     src/nss_altfiles/files-have_o_cloexec.o \
     src/grp/fgetgrent_r.o \
     src/gshadow/sgetsgent_r.o \
     src/pwd/fgetpwent_r.o \
     src/shadow/sgetspent_r.o

CFLAGS   += $(EXTRA_CFLAGS) -pthread -fpic -std=gnu99 -Wall
LDFLAGS  += $(CFLAGS) -Wl,-soname,$T -Wl,-as-needed -lpthread
CPPFLAGS += -D_GNU_SOURCE

ifneq ($(strip $(DATADIR)),)
  CPPFLAGS += -DALTFILES_DATADIR='"$(DATADIR)"'
endif
ifneq ($(strip $(MODULE_NAME)),)
  CPPFLAGS += -DALTFILES_MODULE_NAME=$(MODULE_NAME)
  T := libnss_$(MODULE_NAME).so.2
else
  T := libnss_altfiles.so.2
endif

# Support getting the number of parallel jobs via Build-API
# Info: http://people.gnome.org/~walters/docs/build-api.txt
#
ifneq ($(strip $(BUILDAPI_JOBS)),)
  MAKEOPTS += -j$(BUILDAPI_JOBS)
endif

all: $T

$T: $O
	$(CC) -shared -o $@ $^ $(LDFLAGS)

$O: src/nss_altfiles/files-XXX.c src/nss_altfiles/files-parse.c src/compat.h
src/nss_altfiles/files-hosts.o: src/resolv/mapv4v6addr.h  src/resolv/res_hconf.h

clean:
	$(RM) $O $T

distclean: clean
	$(RM) config.mk

install: $T
	install -m 755 -d $(DESTDIR)$(LIBDIR)
	install -m 755 $T $(DESTDIR)$(LIBDIR)

export VERSION
dist:
	@ if test -n "$$VERSION" ; then V=$$VERSION ; \
		else V=$$(git tag | sed -e '/^v[0-9\.]*$$/s/^v//p' -e d | tail -1) ; fi ; \
		echo "nss-altfiles-$$V.tar.xz" ; \
		git archive --prefix=nss-altfiles-$$V/ v$$V | xz -9c > nss-altfiles-$$V.tar.xz

.PHONY: distclean install dist
