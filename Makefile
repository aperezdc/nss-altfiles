# vim: filetype=make
# Adrian Perez, 2014-05-21
#

comma := ,

-include config.mk

ifeq ($(strip $(HANDLE_ALL)),)
HANDLE_ALL := grp pwd
endif

ifeq ($(strip $(MODULE_NAME)),)
MODULE_NAME := altfiles
endif

LIBDIR ?= $(PREFIX)/lib

# By default, only pwd/grp are handled
define def-handle
HANDLE_$1 := 1
endef

$(foreach I,$(HANDLE_ALL),$(eval $(call def-handle,$I)))

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
     src/nss_altfiles/nss_fgetent_r.o \
     src/nss_altfiles/nss_files_data.o \
     src/nss_altfiles/nss_files_fopen.o \
     src/nss_altfiles/nss_parse_line_result.o \
     src/nss_altfiles/nss_readline.o

CFLAGS   += $(EXTRA_CFLAGS) -pthread -fpic -std=gnu11 -Wall
LDFLAGS  += $(CFLAGS) -Wl,--as-needed
CPPFLAGS += -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 \
            -DALTFILES_MODULE_NAME=$(strip $(MODULE_NAME))

ifneq ($(strip $(DATADIR)),)
CPPFLAGS += -DALTFILES_DATADIR='"$(strip $(DATADIR))"'
endif

T := libnss_$(MODULE_NAME).so.2

# Support getting the number of parallel jobs via Build-API
# Info: http://people.gnome.org/~walters/docs/build-api.txt
#
ifneq ($(strip $(BUILDAPI_JOBS)),)
  MAKEOPTS += -j$(BUILDAPI_JOBS)
endif

all: $T nss-altfiles-config

symbols.map: gen-symmap Makefile
	./gen-symmap $(MODULE_NAME) $(HANDLE_ALL) > $@
symbols.ver: gen-symver Makefile
	./gen-symver $(MODULE_NAME) > $@

$T: LDFLAGS += -Wl,-soname,$T -lpthread
$T: $O symbols.map symbols.ver
	$(CC) -shared -o $@ $O $(LDFLAGS) -Wl,--version-script,symbols.ver symbols.map

$O: src/nss_altfiles/files-XXX.c src/nss_altfiles/files-parse.c src/compat.h
src/nss_altfiles/files-hosts.o: src/resolv/mapv4v6addr.h  src/resolv/res_hconf.h

nss-altfiles-config: src/main.o
	$(CC) -o $@ $^ $(LDFLAGS)

clean:
	$(RM) $O src/main.o
	$(RM) $T nss-altfiles-config
	$(RM) symbols.map symbols.ver

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
