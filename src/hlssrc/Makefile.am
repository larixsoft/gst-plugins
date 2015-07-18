plugindir=$(libdir)/gstreamer-1.0
plugin_LTLIBRARIES=libgst-hlssrc.la

libgst_hlssrc_la_VALASOURCES = ../utils/Uri.vala ../utils/Utils.vala \
	HlsSrc.vala M3U8.vala

libgst_hlssrc_la_CFLAGS = $(PLUGINS_CFLAGS) $(SOUP_CFLAGS)
libgst_hlssrc_la_LIBADD = $(PLUGINS_LIBS) $(SOUP_LIBS)
libgst_hlssrc_la_LDFLAGS = -export-dynamic \
	-no-undefined \
	-avoid-version \
	-module
libgst_hlssrc_la_LIBTOOLFLAGS = --tag=disable-static

libgst_hlssrc_la_SOURCES = Uri.c Utils.c \
	HlsSrc.c \
	fix.c

$(libgst_hlssrc_la_SOURCES): plugin.stamp

plugin.stamp: $(libgst_hlssrc_la_VALASOURCES)
	valac --enable-experimental --vapidir=$(srcdir)/../vapis --pkg libsoup-2.4 --pkg gstreamer-base-1.0 --pkg gxml-0.6 -C $(libgst_hlssrc_la_VALASOURCES) -H hlssrc.h

CLEANFILES = Uri.c Utils.c HlsSrc.c *.h *.stamp
DISTCLEANFILES = $(CLEANFILES) *.in
