#include <gst/gst.h>
#include <gio/gio.h>

#include "websrc.h"

#ifndef PACKAGE
#define PACKAGE "websrc"
#endif

#define GST_GIO_ERROR_MATCHES(err, code) g_error_matches (err, G_IO_ERROR, G_IO_ERROR_##code)

#define GST_GIO_STREAM_IS_SEEKABLE(stream) (G_IS_SEEKABLE (stream) && g_seekable_can_seek (G_SEEKABLE (stream)))

gboolean
gst_gio_error (gpointer element, const gchar * func_name, GError ** err,
    GstFlowReturn * ret)
{
  gboolean handled = TRUE;

  if (ret)
    *ret = GST_FLOW_ERROR;

  if (GST_GIO_ERROR_MATCHES (*err, CANCELLED)) {
    GST_DEBUG_OBJECT (element, "blocking I/O call cancelled (%s)", func_name);
    if (ret)
      *ret = GST_FLOW_FLUSHING;
  } else if (*err != NULL) {
    handled = FALSE;
  } else {
    GST_ELEMENT_ERROR (element, LIBRARY, FAILED, (NULL),
        ("%s call failed without error set", func_name));
  }

  if (handled)
    g_clear_error (err);

  return handled;
}


GstFlowReturn gst_gio_seek (gpointer element, GSeekable * stream, guint64 offset,
    GCancellable * cancel)
{
  gboolean success;
  GstFlowReturn ret;
  GError *err = NULL;

  GST_LOG_OBJECT (element, "seeking to offset %" G_GINT64_FORMAT, offset);

  success = g_seekable_seek (stream, offset, G_SEEK_SET, cancel, &err);

  if (success)
	return GST_FLOW_OK;
  return GST_FLOW_ERROR;
}

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

GstFlowReturn web_src_rcreate (GstWebSrc * src, guint64 offset, guint size,GstBuffer ** buf_return)
{
  GstBuffer *buf;
  GstFlowReturn ret = GST_FLOW_OK;

  g_return_val_if_fail (G_IS_INPUT_STREAM (src->stream), GST_FLOW_ERROR);

  /* If we have the requested part in our cache take a subbuffer of that,
   * otherwise fill the cache again with at least 4096 bytes from the
   * requested offset and return a subbuffer of that.
   *
   * We need caching because every read/seek operation will need to go
   * over DBus if our backend is GVfs and this is painfully slow. */
  if (src->cache && offset >= GST_BUFFER_OFFSET (src->cache) &&
      offset + size <= GST_BUFFER_OFFSET_END (src->cache)) {
    GST_DEBUG_OBJECT (src, "Creating subbuffer from cached buffer: offset %"
        G_GUINT64_FORMAT " length %u", offset, size);

    buf = gst_buffer_copy_region (src->cache, GST_BUFFER_COPY_ALL,
        offset - GST_BUFFER_OFFSET (src->cache), size);

    GST_BUFFER_OFFSET (buf) = offset;
    GST_BUFFER_OFFSET_END (buf) = offset + size;
  } else {
    guint cachesize = MAX (4096, size);
    GstMapInfo map;
    gssize read, streamread, res;
    guint64 readoffset;
    gboolean success, eos;
    GError *err = NULL;
    GstBuffer *newbuffer;
    GstMemory *mem;

    newbuffer = gst_buffer_new ();

    /* copy any overlapping data from the cached buffer */
    if (src->cache && offset >= GST_BUFFER_OFFSET (src->cache) &&
        offset <= GST_BUFFER_OFFSET_END (src->cache)) {
      read = GST_BUFFER_OFFSET_END (src->cache) - offset;
      GST_LOG_OBJECT (src,
          "Copying %" G_GSSIZE_FORMAT " bytes from cached buffer at %"
          G_GUINT64_FORMAT, read, offset - GST_BUFFER_OFFSET (src->cache));
      gst_buffer_copy_into (newbuffer, src->cache, GST_BUFFER_COPY_MEMORY,
          offset - GST_BUFFER_OFFSET (src->cache), read);
    } else {
      read = 0;
    }

    if (src->cache)
      gst_buffer_unref (src->cache);
    src->cache = newbuffer;

    readoffset = offset + read;
    GST_LOG_OBJECT (src,
        "Reading %u bytes from offset %" G_GUINT64_FORMAT, cachesize,
        readoffset);

    if (G_UNLIKELY (readoffset != src->position)) {
      if (!G_IS_SEEKABLE (src->stream))
        return GST_FLOW_NOT_SUPPORTED;

      GST_DEBUG_OBJECT (src, "Seeking to position %" G_GUINT64_FORMAT,
          readoffset);
      ret =
          gst_gio_seek (src, G_SEEKABLE (src->stream), readoffset, src->cancel);

      if (ret == GST_FLOW_OK)
        src->position = readoffset;
      else
        return ret;
    }

    /* GIO sometimes gives less bytes than requested although
     * it's not at the end of file. SMB for example only
     * supports reads up to 64k. So we loop here until we get at
     * at least the requested amount of bytes or a read returns
     * nothing. */
    mem = gst_allocator_alloc (NULL, cachesize, NULL);
    if (mem == NULL) {
      GST_ERROR_OBJECT (src, "Failed to allocate %u bytes", cachesize);
      return GST_FLOW_ERROR;
    }

    gst_memory_map (mem, &map, GST_MAP_WRITE);
    streamread = 0;
    while (size - read > 0 && (res =
            g_input_stream_read (G_INPUT_STREAM (src->stream),
                map.data + streamread, cachesize - streamread, src->cancel,
                &err)) > 0) {
      read += res;
      streamread += res;
      src->position += res;
    }
    gst_memory_unmap (mem, &map);
    gst_buffer_append_memory (src->cache, mem);

    success = (read >= 0);
    eos = (cachesize > 0 && read == 0);

    if (!success && !gst_gio_error (src, "g_input_stream_read", &err, &ret)) {
      GST_ELEMENT_ERROR (src, RESOURCE, READ, (NULL),
          ("Could not read from stream: %s", err->message));
      g_clear_error (&err);
    }

    if (success && !eos) {
      GST_BUFFER_OFFSET (src->cache) = offset;
      GST_BUFFER_OFFSET_END (src->cache) = offset + read;

      GST_DEBUG_OBJECT (src, "Read successful");
      GST_DEBUG_OBJECT (src, "Creating subbuffer from new "
          "cached buffer: offset %" G_GUINT64_FORMAT " length %u", offset,
          size);

      buf =
          gst_buffer_copy_region (src->cache, GST_BUFFER_COPY_ALL, 0, MIN (size,
              read));

      GST_BUFFER_OFFSET (buf) = offset;
      GST_BUFFER_OFFSET_END (buf) = offset + MIN (size, read);
    } else {
      GST_DEBUG_OBJECT (src, "Read not successful");
      gst_buffer_unref (src->cache);
      src->cache = NULL;
      buf = NULL;
    }

    if (eos)
      ret = GST_FLOW_EOS;
  }

  *buf_return = buf;

  return ret;
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
