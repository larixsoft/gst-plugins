AC_INIT([gst-plugins], [1.7.1], [inizan.yannick@gmail.com], gst-plugins])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([check-news dist-bzip2 subdir-objects])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_CONFIG_FILES([
Makefile
src/Makefile])

AM_PROG_AR
LT_INIT
AC_PROG_CC
AM_PROG_VALAC

AC_CHECK_PROG(HAVE_GJS, gjs, yes, no)

if test "x$HAVE_GJS" = "xno"; then
	AC_MSG_ERROR([gjs is required for YouTube])
fi

PKG_CHECK_MODULES(PLUGINS, gstreamer-base-1.0 json-glib-1.0 gxml-0.6 libsoup-2.4)

AC_OUTPUT
