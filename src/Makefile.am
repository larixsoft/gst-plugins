plugindir=$(libdir)/gstreamer-1.0
plugin_LTLIBRARIES=libgst-websrc.la

libgst_websrc_la_VALASOURCES = Decryptor.vala Uri.vala Utils.vala WebSrc.vala WebVideo.vala \
	Youtube.vala WebVideoSrc.vala VimeoSrc.vala SoupInputStream.vala Dailymotion.vala
	
libgst_websrc_la_SOURCES = $(libgst_websrc_la_VALASOURCES:.vala=.c) fix.c

libgst_websrc_la_CFLAGS = $(PLUGINS_CFLAGS)
libgst_websrc_la_LIBADD = $(PLUGINS_LIBS)
libgst_websrc_la_LDFLAGS = -export-dynamic \
	-no-undefined \
	-avoid-version \
	-module
libgst_websrc_la_LIBTOOLFLAGS = --tag=disable-static

$(libgst_websrc_la_VALASOURCES:.vala=.c): plugin.stamp

plugin.stamp: $(libgst_websrc_la_VALASOURCES)
	valac --enable-experimental --vapidir=$(srcdir)/vapis --pkg libsoup-2.4 --pkg gstreamer-base-1.0 --pkg json-glib-1.0 --pkg gxml-0.6 -C $(libgst_websrc_la_VALASOURCES) -H websrc.h

CLEANFILES = $(libgst_websrc_la_VALASOURCES:.vala=.c) *.h *.stamp
DISTCLEANFILES = $(CLEANFILES) *.in
