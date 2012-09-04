# vim: filetype=make
# Adrian Perez, 2012-08-29 13:09
#

-include config.mk

O := files-pwd.o \
     files-grp.o \
     files-have_o_cloexec.o

CFLAGS   += $(EXTRA_CFLAGS)   -pthread -fpic
LDFLAGS  += $(EXTRA_CXXFLAGS) -pthread -fpic -lpthread -Wl,-soname,$T
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
	gcc -shared -o $@ $^ $(LDFLAGS)

files-grp.o files-pwd.o: files-XXX.c files-parse.c compat.h

clean:
	$(RM) $O $T

distclean: clean
	$(RM) config.mk

install: $T
	install -m 755 -d $(DESTDIR)$(PREFIX)/lib
	install -m 755 $T $(DESTDIR)$(PREFIX)/lib

export VERSION
dist:
	@ if test -n "$$VERSION" ; then V=$$VERSION ; \
		else V=$$(git tag | sed -e '/^v[0-9\.]*$$/s/^v//p' -e d | tail -1) ; fi ; \
		echo "nss-altfiles-$$V.tar.xz" ; \
		git archive --prefix=nss-altfiles-$$V/ v$$V | xz -9c > nss-altfiles-$$V.tar.xz

.PHONY: distclean install dist
