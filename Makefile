# GCC makefile for Ipol.im library image input-output
# Pascal Getreuer
# May 4, 2012

LIBIPOLN=libipoliio.so
LIBIPOLV=0
LIBIPOLD=20220720
##
# The following three statements determine the build configuration.
# For handling different image formats, the program can be linked with
# the libjpeg, libpng, and libtiff libraries.  For each library, set
# the flags needed for linking.  To disable use of a library, comment
# its statement.  You can disable all three (BMP is always supported).
LDLIBJPEG=-ljpeg
LDLIBPNG=-lpng
LDLIBTIFF=-ltiff

##
# Standard make settings
SHELL=/bin/sh
CFLAGS=-O3 -ansi -pedantic -Wall -Wextra -Isrc
LDFLAGS=
LDLIBS=-lm $(LDLIBJPEG) $(LDLIBPNG) $(LDLIBTIFF)

ifneq ($(shell uname -m), i386)
    CFLAGS += -fPIC
endif

##
# These statements add compiler flags to define USE_LIBJPEG, etc.,
# depending on which libraries have been specified above.
ifneq ($(LDLIBJPEG),)
	CJPEG=-DUSE_LIBJPEG
endif
ifneq ($(LDLIBPNG),)
	CPNG=-DUSE_LIBPNG
endif
ifneq ($(LDLIBTIFF),)
	CTIFF=-DUSE_LIBTIFF
endif

ALLCFLAGS=$(CFLAGS) $(CJPEG) $(CPNG) $(CTIFF)

LIBIPOL_SOURCES=basic.c imageio.c

ARCHIVENAME=$(LIBIPOLN)_$(shell date -u +%Y%m%d)
SOURCES=src/basic.c src/basic.h src/imageio.c src/imageio.h LICENSE Makefile
# LIBIPOL_OBJECTS=$(LIBIPOL_SOURCES:.c=.o)
LIBIPOL_OBJECTS=src/basic.o src/imageio.o
.SUFFIXES: .c .o
.PHONY: all clean rebuild dist dist-zip

all: $(LIBIPOLN).$(LIBIPOLV)

$(LIBIPOLN).$(LIBIPOLV): $(LIBIPOL_OBJECTS)
	$(CC) -shared -Wl,-soname,$@ $(LDFLAGS) -o $@ $^ $(LDLIBS) -s
	chmod -v 644 $@
	mv $@ $@.$(LIBIPOLD)
	ln -s $@.$(LIBIPOLD) $@
	ln -s $@ $(LIBIPOLN)

.c.o:
	$(CC) -c $(ALLCFLAGS) $< -o $@

clean:
	-$(RM) $(LIBIPOL_OBJECTS) $(LIBIPOLN)*

rebuild: clean all
dist: $(SOURCES)
	-rm -rf $(ARCHIVENAME)
	mkdir $(ARCHIVENAME)
	ln $(SOURCES) $(ARCHIVENAME)
	tar vchzf $(ARCHIVENAME).tgz $(ARCHIVENAME)
	-rm -rf $(ARCHIVENAME)

dist-zip: $(SOURCES)
	-rm -rf $(ARCHIVENAME)
	mkdir $(ARCHIVENAME)
	ln $(SOURCES) $(ARCHIVENAME)
	-rm -f $(ARCHIVENAME).zip
	zip -r9 $(ARCHIVENAME).zip $(ARCHIVENAME)/*
	-rm -rf $(ARCHIVENAME)
