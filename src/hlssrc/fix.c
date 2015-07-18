#include <gst/gst.h>

#include "hlssrc.h"

#ifndef PACKAGE
#define PACKAGE "hlssrc"
#endif

static void hls_src_interface_init (gpointer g_iface, gpointer iface_data) {
	GstURIHandlerInterface * iface = (GstURIHandlerInterface*)g_iface;
	iface->get_uri = hls_src_get_uri;
	iface->set_uri = hls_src_set_uri;
	iface->get_protocols = hls_src_get_protocols;
	iface->get_type = hls_src_get_type_uri;
}

GType hls_src_real_type (void) {
	static volatile gsize type_id = 0;
	if (g_once_init_enter (&type_id)) {
		static const GInterfaceInfo gst_uri_handler_info = {
			hls_src_interface_init,
			NULL,
			NULL
		};
		GType hls_src_type_id = hls_src_get_type();
		g_type_add_interface_static (hls_src_type_id, gst_uri_handler_get_type (), &gst_uri_handler_info);
		g_once_init_leave (&type_id, hls_src_type_id);
	}
	return type_id;
}

GST_PLUGIN_DEFINE (
    GST_VERSION_MAJOR,
    GST_VERSION_MINOR,
	hlssrc,
    "HTTP Live Streaming source element",
    hls_src_init,
    "1.4",
    "LGPL",
    "MyPlugins",
    "https://github.com/inizan-yannick/gst-plugins"
)

