#include <gst/gst.h>
#include <gio/gio.h>

#include "websrc.h"

#ifndef PACKAGE
#define PACKAGE "websrc"
#endif

gboolean gst_web_video_src_set_uri (GstURIHandler * handler, const gchar * uri, GError ** error) {
	GstElement *element = GST_ELEMENT (handler);
	g_return_val_if_fail (GST_IS_ELEMENT (element), FALSE);
	if (!video_web_video_uri_is_valid (uri)) {
		g_set_error (error, GST_URI_ERROR, GST_URI_ERROR_BAD_URI, "URI not supported");
		return FALSE;
	}
	if (GST_STATE (element) == GST_STATE_PLAYING || GST_STATE (element) == GST_STATE_PAUSED) {
		g_set_error (error, GST_URI_ERROR, GST_URI_ERROR_BAD_STATE,
			"Changing the 'location' property while the element is running is not supported");
		return FALSE;
	}
	gst_web_video_src_set_location ((GstWebVideoSrc*)handler, uri);
	return TRUE;
}

gboolean gst_vimeo_src_set_uri (GstURIHandler * handler, const gchar * uri, GError ** error) {
	GstElement *element = GST_ELEMENT (handler);
	g_return_val_if_fail (GST_IS_ELEMENT (element), FALSE);
	if (!gst_vimeo_src_uri_is_valid (uri)) {
		g_set_error (error, GST_URI_ERROR, GST_URI_ERROR_BAD_URI, "URI not supported");
		return FALSE;
	}
	if (GST_STATE (element) == GST_STATE_PLAYING || GST_STATE (element) == GST_STATE_PAUSED) {
		g_set_error (error, GST_URI_ERROR, GST_URI_ERROR_BAD_STATE,
			"Changing the 'location' property while the element is running is not supported");
		return FALSE;
	}
	gst_vimeo_src_set_location ((GstVimeoSrc*)handler, uri);
	return TRUE;
}

static void gst_web_video_src_interface_init (gpointer g_iface, gpointer iface_data) {
	GstURIHandlerInterface * iface = (GstURIHandlerInterface*)g_iface;
	iface->get_uri = gst_web_video_src_get_uri;
	iface->set_uri = gst_web_video_src_set_uri;
	iface->get_protocols = gst_web_video_src_get_protocols;
	iface->get_type = gst_web_video_src_get_type_uri;
}

static void gst_vimeo_src_interface_init (gpointer g_iface, gpointer iface_data) {
	GstURIHandlerInterface * iface = (GstURIHandlerInterface*)g_iface;
	iface->get_uri = gst_vimeo_src_get_uri;
	iface->set_uri = gst_vimeo_src_set_uri;
	iface->get_protocols = gst_vimeo_src_get_protocols;
	iface->get_type = gst_vimeo_src_get_type_uri;
}

GType gst_web_video_src_real_type (void) {
	static volatile gsize type_id = 0;
	if (g_once_init_enter (&type_id)) {
		static const GInterfaceInfo gst_uri_handler_info = {
			gst_web_video_src_interface_init,
			NULL,
			NULL
		};
		GType gst_web_video_src_type_id = gst_web_video_src_get_type();
		g_type_add_interface_static (gst_web_video_src_type_id, gst_uri_handler_get_type (), &gst_uri_handler_info);
		g_once_init_leave (&type_id, gst_web_video_src_type_id);
	}
	return type_id;
}

GType gst_vimeo_src_real_type (void) {
	static volatile gsize type_id = 0;
	if (g_once_init_enter (&type_id)) {
		static const GInterfaceInfo gst_uri_handler_info = {
			gst_vimeo_src_interface_init,
			NULL,
			NULL
		};
		GType gst_vimeo_src_type_id = gst_vimeo_src_get_type();
		g_type_add_interface_static (gst_vimeo_src_type_id, gst_uri_handler_get_type (), &gst_uri_handler_info);
		g_once_init_leave (&type_id, gst_vimeo_src_type_id);
	}
	return type_id;
}

GST_PLUGIN_DEFINE (
    GST_VERSION_MAJOR,
    GST_VERSION_MINOR,
    websrc,
    "Web source elements",
    gst_web_src_init,
    "1.7.1",
    "LGPL",
    "MyPlugins",
    "https://github.com/inizan-yannick/gst-plugins"
)
