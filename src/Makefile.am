plugindir=$(libdir)/x86_64-linux-gnu/gstreamer-1.0
plugin_LTLIBRARIES=libgst-videosrc.la

libgst_videosrc_la_VALASOURCES = Utils.vala Video.vala VideoSrc.vala \
	Uptobox.vala UptoboxSrc.vala \
	YoutubeSrc.vala Uri.vala Youtube.vala
	
libgst_videosrc_la_CFLAGS = $(PLUGINS_CFLAGS)
libgst_videosrc_la_LIBADD = $(PLUGINS_LIBS)
libgst_videosrc_la_LDFLAGS = -export-dynamic \
	-no-undefined \
	-avoid-version \
	-module
libgst_videosrc_la_LIBTOOLFLAGS = --tag=disable-static

TMPSOURCES = $(libgst_videosrc_la_VALASOURCES:.vala=.c)

libgst_videosrc_la_SOURCES = $(TMPSOURCES) fix.c

$(TMPSOURCES): plugin.stamp

plugin.stamp: $(libgst_videosrc_la_VALASOURCES)
	valac --enable-experimental --vapidir=$(srcdir)/vapis --pkg gstreamer-base-1.0 --pkg gxml-0.6 -C $(libgst_videosrc_la_VALASOURCES) -H videosrc.h

CLEANFILES = $(TMPSOURCES) *.h *.stamp
DISTCLEANFILES = $(CLEANFILES) *.in
