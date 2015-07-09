#include <gst/gst.h>

#include "youtubesrc.h"

#ifndef PACKAGE
#define PACKAGE "youtubesrc"
#endif

static void youtube_src_interface_init (gpointer g_iface, gpointer iface_data) {
	GstURIHandlerInterface * iface = (GstURIHandlerInterface*)g_iface;
	iface->get_uri = youtube_src_get_uri;
	iface->set_uri = youtube_src_set_uri;
	iface->get_protocols = youtube_src_get_protocols;
	iface->get_type = youtube_src_get_type_uri;
}

GType youtube_src_real_type (void) {
	static volatile gsize youtube_src_type_id__volatile = 0;
	if (g_once_init_enter (&youtube_src_type_id__volatile)) {
		static const GInterfaceInfo gst_uri_handler_info = {
			youtube_src_interface_init,
			NULL,
			NULL
		};
		GType youtube_src_type_id = youtube_src_get_type();
		g_type_add_interface_static (youtube_src_type_id, gst_uri_handler_get_type (), &gst_uri_handler_info);
		g_once_init_leave (&youtube_src_type_id__volatile, youtube_src_type_id);
	}
	return youtube_src_type_id__volatile;
}

/* gstreamer looks for this structure to register myfilters
 *
 * exchange the string 'Template myfilter' with your myfilter description
 */
GST_PLUGIN_DEFINE (
    GST_VERSION_MAJOR,
    GST_VERSION_MINOR,
    youtubesrc,
    "Youtube source element",
    youtube_src_init,
    "1.4",
    "LGPL",
    "MyPlugins",
    "https://github.com/inizan-yannick/gst-plugins"
)

