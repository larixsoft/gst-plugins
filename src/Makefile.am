plugindir=$(libdir)/x86_64-linux-gnu/gstreamer-1.0
plugin_LTLIBRARIES=libgst-webvideo.la

libgst_webvideo_la_VALASOURCES = WebVideoSrc.vala Uri.vala Utils.vala Video.vala \
	Youtube.vala Dailymotion.vala

libgst_webvideo_la_CFLAGS = $(PLUGINS_CFLAGS)
libgst_webvideo_la_LIBADD = $(PLUGINS_LIBS)
libgst_webvideo_la_LDFLAGS = -export-dynamic \
	-no-undefined \
	-avoid-version \
	-module
libgst_webvideo_la_LIBTOOLFLAGS = --tag=disable-static

TMPSOURCES = $(libgst_webvideo_la_VALASOURCES:.vala=.c)

libgst_webvideo_la_SOURCES = $(TMPSOURCES) \
	gio/gstgio.c gio/gstgiobasesrc.c gio/gstgiosrc.c \
	fix.c

$(TMPSOURCES): plugin.stamp

plugin.stamp: $(libgst_webvideo_la_VALASOURCES)
	valac --enable-experimental --vapidir=$(srcdir)/vapis --pkg gstgio --pkg mee-json-1.0 --pkg gxml-0.6 -C $(libgst_webvideo_la_VALASOURCES) -H webvideosrc.h

CLEANFILES = $(TMPSOURCES) *.h *.stamp
DISTCLEANFILES = $(CLEANFILES) *.in
