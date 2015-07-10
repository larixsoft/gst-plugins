/* GStreamer
 *
 * Copyright (C) 2007 Rene Stadler <mail@renestadler.de>
 * Copyright (C) 2007 Sebastian Dröge <sebastian.droege@collabora.co.uk>
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "gstgio.h"
#include "gstgiosink.h"
#include "gstgiosrc.h"
#include "gstgiostreamsink.h"
#include "gstgiostreamsrc.h"

#include <string.h>

GST_DEBUG_CATEGORY_STATIC (gst_gio_debug);
#define GST_CAT_DEFAULT gst_gio_debug

/* @func_name: Name of the GIO function, for debugging messages.
 * @err: Error location.  *err may be NULL, but err must be non-NULL.
 * @ret: Flow return location.  May be NULL.  Is set to either #GST_FLOW_ERROR
 * or #GST_FLOW_FLUSHING.
 *
 * Returns: TRUE to indicate a handled error.  Error at given location err will
 * be freed and *err will be set to NULL.  A FALSE return indicates an unhandled
 * error: The err location is unchanged and guaranteed to be != NULL.  ret, if
 * given, is set to GST_FLOW_ERROR.
 */
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

GstFlowReturn
gst_gio_seek (gpointer element, GSeekable * stream, guint64 offset,
    GCancellable * cancel)
{
  gboolean success;
  GstFlowReturn ret;
  GError *err = NULL;

  GST_LOG_OBJECT (element, "seeking to offset %" G_GINT64_FORMAT, offset);

  success = g_seekable_seek (stream, offset, G_SEEK_SET, cancel, &err);

  if (success)
    ret = GST_FLOW_OK;
  else if (!gst_gio_error (element, "g_seekable_seek", &err, &ret)) {
    GST_ELEMENT_ERROR (element, RESOURCE, SEEK, (NULL),
        ("Could not seek: %s", err->message));
    g_clear_error (&err);
  }

  return ret;
}

void
gst_gio_uri_handler_do_init (GType type)
{
	
}

