plugindir=$(libdir)/x86_64-linux-gnu/gstreamer-1.0
plugin_LTLIBRARIES=libgstyoutube.la

libgstyoutube_la_VALASOURCES = YoutubeSrc.vala Uri.vala Youtube.vala Utils.vala
libgstyoutube_la_CFLAGS = $(PLUGINS_CFLAGS)
libgstyoutube_la_LIBADD = $(PLUGINS_LIBS)
libgstyoutube_la_LDFLAGS = -export-dynamic \
	-no-undefined \
	-avoid-version \
	-module
libgstyoutube_la_LIBTOOLFLAGS = --tag=disable-static

libgstyoutube_la_SOURCES = $(libgstyoutube_la_VALASOURCES:.vala=.c) fix.c

YoutubeSrc.c: plugin.stamp

plugin.stamp: $(libgstyoutube_la_VALASOURCES)
	valac --enable-experimental --vapidir=$(srcdir)/vapis --pkg gstreamer-base-1.0 --pkg gxml-0.6 -C $(libgstyoutube_la_VALASOURCES) -H youtubesrc.h

CLEANFILES = *.c *.stamp
DISTCLEANFILES = $(CLEANFILES) *.in
