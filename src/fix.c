#include <gst/gst.h>

#include "videosrc.h"

#ifndef PACKAGE
#define PACKAGE "videosrc"
#endif

GType uptobox_src_real_type (void);
GType youtube_src_real_type (void);

static void uptobox_src_interface_init (gpointer g_iface, gpointer iface_data) {
	GstURIHandlerInterface * iface = (GstURIHandlerInterface*)g_iface;
	iface->get_uri = uptobox_src_get_uri;
	iface->set_uri = uptobox_src_set_uri;
	iface->get_protocols = uptobox_src_get_protocols;
	iface->get_type = uptobox_src_get_type_uri;
}

static void youtube_src_interface_init (gpointer g_iface, gpointer iface_data) {
	GstURIHandlerInterface * iface = (GstURIHandlerInterface*)g_iface;
	iface->get_uri = youtube_src_get_uri;
	iface->set_uri = youtube_src_set_uri;
	iface->get_protocols = youtube_src_get_protocols;
	iface->get_type = youtube_src_get_type_uri;
}

GType uptobox_src_real_type (void) {
	static volatile gsize uptobox_src_type_id_volatile = 0;
	if (g_once_init_enter (&uptobox_src_type_id_volatile)) {
		static const GInterfaceInfo gst_uri_handler_info = {
			uptobox_src_interface_init,
			NULL,
			NULL
		};
		g_type_add_interface_static (uptobox_src_get_type(), gst_uri_handler_get_type (), &gst_uri_handler_info);
		g_once_init_leave (&uptobox_src_type_id_volatile, uptobox_src_get_type());
	}
	return uptobox_src_type_id_volatile;
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
    videosrc,
    "Youtube source element",
    video_init,
    "1.4",
    "LGPL",
    "MyPlugins",
    "https://github.com/inizan-yannick/gst-plugins"
)

