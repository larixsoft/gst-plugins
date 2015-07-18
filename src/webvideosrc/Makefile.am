plugindir=$(libdir)/gstreamer-1.0
plugin_LTLIBRARIES=libgst-webvideo.la

libgst_webvideo_la_VALASOURCES = ../utils/Uri.vala ../utils/Utils.vala \
	WebVideoSrc.vala Video.vala Youtube.vala Dailymotion.vala

libgst_webvideo_la_CFLAGS = $(PLUGINS_CFLAGS)
libgst_webvideo_la_LIBADD = $(PLUGINS_LIBS)
libgst_webvideo_la_LDFLAGS = -export-dynamic \
	-no-undefined \
	-avoid-version \
	-module
libgst_webvideo_la_LIBTOOLFLAGS = --tag=disable-static

libgst_webvideo_la_SOURCES = Uri.c Utils.c \
	WebVideoSrc.c Video.c Youtube.c Dailymotion.c \
	fix.c

Uri.c: plugin.stamp

plugin.stamp: $(libgst_webvideo_la_VALASOURCES)
	valac --enable-experimental --vapidir=$(srcdir)/../vapis --pkg gstreamer-base-1.0 --pkg mee-json-1.0 --pkg gxml-0.6 -C $(libgst_webvideo_la_VALASOURCES) -H webvideosrc.h

CLEANFILES = Uri.c Utils.c WebVideoSrc.c Video.c Youtube.c Dailymotion.c *.h *.stamp
DISTCLEANFILES = $(CLEANFILES) *.in
