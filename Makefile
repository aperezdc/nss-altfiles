# vim: filetype=make
# Adrian Perez, 2014-05-21
#

-include config.mk

LIBDIR ?= $(PREFIX)/lib

# By default, only pwd/grp are handled
HANDLE_pwd ?= 1
HANDLE_grp ?= 1

# Choose object depending on the HANDLE_foo variables
O := $(if $(HANDLE_rpc),     src/nss_altfiles/files-rpc.o)  \
     $(if $(HANDLE_proto),   src/nss_altfiles/files-proto.o) \
     $(if $(HANDLE_hosts),   src/nss_altfiles/files-hosts.o)  \
     $(if $(HANDLE_network), src/nss_altfiles/files-network.o) \
     $(if $(HANDLE_service), src/nss_altfiles/files-service.o)  \
     $(if $(HANDLE_pwd),     src/nss_altfiles/files-pwd.o  src/pwd/fgetpwent_r.o)  \
     $(if $(HANDLE_grp),     src/nss_altfiles/files-grp.o  src/grp/fgetgrent_r.o)   \
     $(if $(HANDLE_spwd),    src/nss_altfiles/files-spwd.o src/shadow/sgetspent_r.o) \
     $(if $(HANDLE_sgrp),    src/nss_altfiles/files-sgrp.o src/gshadow/sgetsgent_r.o) \
     src/nss_altfiles/files-have_o_cloexec.o

CFLAGS   += $(EXTRA_CFLAGS) -pthread -fpic -std=gnu99 -Wall
LDFLAGS  += $(CFLAGS) -Wl,-soname,$T -Wl,-as-needed -lpthread
CPPFLAGS += -D_GNU_SOURCE

ifneq ($(strip $(DATADIR)),)
  CPPFLAGS += -DALTFILES_DATADIR='"$(strip $(DATADIR))"'
endif
ifneq ($(strip $(MODULE_NAME)),)
  CPPFLAGS += -DALTFILES_MODULE_NAME=$(strip $(MODULE_NAME))
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

all: $T nss-altfiles-config

$T: $O
	$(CC) -shared -o $@ $^ $(LDFLAGS)

$O: src/nss_altfiles/files-XXX.c src/nss_altfiles/files-parse.c src/compat.h
src/nss_altfiles/files-hosts.o: src/resolv/mapv4v6addr.h  src/resolv/res_hconf.h

nss-altfiles-config: src/main.o
	$(CC) -o $@ $^ $(LDFLAGS)

clean:
	find src -name '*.o' -delete
	$(RM) $T nss-altfiles-config

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
