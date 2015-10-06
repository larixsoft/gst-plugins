plugindir=$(libdir)/gstreamer-1.0
plugin_LTLIBRARIES=libgst-webvideo.la

libgst_webvideo_la_VALASOURCES = ../utils/Uri.vala ../utils/Utils.vala \
	WebVideoSrc.vala WebVideo.vala \
	services/Youtube.vala \
	services/Dailymotion.vala \
	services/Uptobox.vala

libgst_webvideo_la_CFLAGS = $(PLUGINS_CFLAGS)
libgst_webvideo_la_LIBADD = $(PLUGINS_LIBS)
libgst_webvideo_la_LDFLAGS = -export-dynamic \
	-no-undefined \
	-avoid-version \
	-module
libgst_webvideo_la_LIBTOOLFLAGS = --tag=disable-static

libgst_webvideo_la_TMPSOURCES = Uri.c Utils.c \
	WebVideoSrc.c WebVideo.c \
	services/Youtube.c \
	services/Dailymotion.c \
	services/Uptobox.c

libgst_webvideo_la_SOURCES = $(libgst_webvideo_la_TMPSOURCES) fix.c

Uri.c: plugin.stamp

plugin.stamp: $(libgst_webvideo_la_VALASOURCES)
	valac --enable-experimental --vapidir=$(srcdir)/../vapis --pkg gstreamer-base-1.0 --pkg json-glib-1.0 --pkg gxml-0.6 -C $(libgst_webvideo_la_VALASOURCES) -H webvideosrc.h

CLEANFILES = $(libgst_webvideo_la_TMPSOURCES) *.h *.stamp
DISTCLEANFILES = $(CLEANFILES) *.in
