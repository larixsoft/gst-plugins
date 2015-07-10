#include <gst/gst.h>

#include "webvideosrc.h"

#ifndef PACKAGE
#define PACKAGE "webvideosrc"
#endif

static void web_video_src_interface_init (gpointer g_iface, gpointer iface_data) {
	GstURIHandlerInterface * iface = (GstURIHandlerInterface*)g_iface;
	iface->get_uri = web_video_src_get_uri;
	iface->set_uri = web_video_src_set_uri;
	iface->get_protocols = web_video_src_get_protocols;
	iface->get_type = web_video_src_get_type_uri;
}

GType web_video_src_real_type (void) {
	static volatile gsize type_id = 0;
	if (g_once_init_enter (&type_id)) {
		static const GInterfaceInfo gst_uri_handler_info = {
			web_video_src_interface_init,
			NULL,
			NULL
		};
		GType web_video_src_type_id = web_video_src_get_type();
		g_type_add_interface_static (web_video_src_type_id, gst_uri_handler_get_type (), &gst_uri_handler_info);
		g_once_init_leave (&type_id, web_video_src_type_id);
	}
	return type_id;
}

GST_PLUGIN_DEFINE (
    GST_VERSION_MAJOR,
    GST_VERSION_MINOR,
    webvideosrc,
    "Web video source element",
    web_video_src_init,
    "1.4",
    "LGPL",
    "MyPlugins",
    "https://github.com/inizan-yannick/gst-plugins"
)

