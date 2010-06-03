/* X-Chat
 * Copyright (C) 1998 Peter Zelezny.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include "fe-gtk.h"

#include <gtk/gtkmain.h>
#include <gtk/gtkentry.h>
#include <gtk/gtkprogressbar.h>
#include <gtk/gtkbox.h>
#include <gtk/gtklabel.h>
#include <gtk/gtktogglebutton.h>
#include <gtk/gtkmessagedialog.h>
#include <gtk/gtkversion.h>

#include "../common/xchat.h"
#include "../common/fe.h"
#include "../common/util.h"
#include "../common/text.h"
#include "../common/cfgfiles.h"
#include "../common/xchatc.h"
#include "../common/plugin.h"
#include "gtkutil.h"
#include "maingui.h"
#include "pixmaps.h"
#include "joind.h"
#include "xtext.h"
#include "palette.h"
#include "menu.h"
#include "notifygui.h"
#include "textgui.h"
#include "fkeys.h"
#include "plugin-tray.h"
#include "urlgrab.h"

#ifdef USE_XLIB
#include <gdk/gdkx.h>
#include <gtk/gtkinvisible.h>
#endif

#ifdef USE_GTKSPELL
#include <gtk/gtktextview.h>
#endif

#ifdef WIN32
#include <windows.h>
#endif

GdkPixmap *channelwin_pix;


/* === command-line parameter parsing : requires glib 2.6 === */

static char *arg_cfgdir = NULL;
static gint arg_show_autoload = 0;
static gint arg_show_config = 0;
static gint arg_show_version = 0;

static const GOptionEntry gopt_entries[] = 
{
 {"no-auto",	'a', 0, G_OPTION_ARG_NONE,	&arg_dont_autoconnect, N_("Don't auto connect to servers"), NULL},
 {"cfgdir",	'd', 0, G_OPTION_ARG_STRING,	&arg_cfgdir, N_("Use a different config directory"), "PATH"},
 {"no-plugins",	'n', 0, G_OPTION_ARG_NONE,	&arg_skip_plugins, N_("Don't auto load any plugins"), NULL},
 {"plugindir",	'p', 0, G_OPTION_ARG_NONE,	&arg_show_autoload, N_("Show plugin auto-load directory"), NULL},
 {"configdir",	'u', 0, G_OPTION_ARG_NONE,	&arg_show_config, N_("Show user config directory"), NULL},
 {"url",	 0,  0, G_OPTION_ARG_STRING,	&arg_url, N_("Open an irc://server:port/channel URL"), "URL"},
#ifndef WIN32	/* uses DBUS */
 {"command",	'c', 0, G_OPTION_ARG_STRING,	&arg_command, N_("Execute command:"), "COMMAND"},
 {"existing",	'e', 0, G_OPTION_ARG_NONE,	&arg_existing, N_("Open URL or execute command in an existing XChat"), NULL},
#endif
 {"version",	'v', 0, G_OPTION_ARG_NONE,	&arg_show_version, N_("Show version information"), NULL},
 {NULL}
};

int
fe_args (int argc, char *argv[])
{
	GError *error = NULL;
	GOptionContext *context;

	context = g_option_context_new (NULL);
	g_option_context_add_main_entries (context, gopt_entries, GETTEXT_PACKAGE);
	g_option_context_add_group (context, gtk_get_option_group (FALSE));
	g_option_context_parse (context, &argc, &argv, &error);

	if (error)
	{
		if (error->message)
			printf ("%s\n", error->message);
		return 1;
	}

	g_option_context_free (context);

	if (arg_show_version)
	{
		printf (PACKAGE_TARNAME" "PACKAGE_VERSION"\n");
		return 0;
	}

	if (arg_show_autoload)
	{
		printf ("%s\n", XCHATLIBDIR"/plugins");
		return 0;
	}

	if (arg_show_config)
	{
		printf ("%s\n", get_xdir_fs ());
		return 0;
	}

	if (arg_cfgdir)	/* we want filesystem encoding */
	{
		xdir_fs = strdup (arg_cfgdir);
		if (xdir_fs[strlen (xdir_fs) - 1] == '/')
			xdir_fs[strlen (xdir_fs) - 1] = 0;
		g_free (arg_cfgdir);
	}

	gtk_init (&argc, &argv);

	gdk_window_set_events (gdk_get_default_root_window (), GDK_PROPERTY_CHANGE_MASK);
	return -1;
}

char *cursor_color_rc =
	"style \"xc-ib-st\""
	"{"
		"GtkEntry::cursor-color=\"#%02x%02x%02x\""
	"}"
	"widget \"*.xchat-inputbox\" style : application \"xc-ib-st\"";

int fe_timeout_add (int interval, void *callback, void *userdata)
{
	// for some obscure reason it works. but you should investigate into 
	// not dropping userdata.
	return vala_fe_timeout_add(interval, callback, userdata);
}
int fe_input_add (int sok, int flags, void *func, void *data) {
	// same stuff as above
	vala_fe_input_add(sok, flags, func, data);
}

void
fe_new_server (struct server *serv)
{
	// this stuff is difficult to port in vala
	serv->gui = malloc (sizeof (struct server_gui));
	memset (serv->gui, 0, sizeof (struct server_gui));
}

void fe_idle_add (void *func, void *data){g_idle_add (func, data);}

static int
lastlog_regex_cmp (char *a, regex_t *reg)
{
	return !regexec (reg, a, 1, NULL, REG_NOTBOL);
}

void
fe_lastlog (session *sess, session *lastlog_sess, char *sstr, gboolean regexp)
{
	// convert into using glib regexps.
	// also maybe the whole function is of dubious utility
	regex_t reg;

	if (gtk_xtext_is_empty (sess->res->buffer))
	{
		PrintText (lastlog_sess, _("Search buffer is empty.\n"));
		return;
	}

	if (!regexp)
	{
		gtk_xtext_lastlog (lastlog_sess->res->buffer, sess->res->buffer,
								 (void *) nocasestrstr, sstr);
		return;
	}

	if (regcomp (&reg, sstr, REG_ICASE | REG_EXTENDED | REG_NOSUB) == 0)
	{
		gtk_xtext_lastlog (lastlog_sess->res->buffer, sess->res->buffer,
								 (void *) lastlog_regex_cmp, &reg);
		regfree (&reg);
	}
}

extern void dcc_saveas_cb(struct DCC *, const char*);

void
fe_confirm (const char *message, void (*yesproc)(void *), void (*noproc)(void *), void *ud)
{
	/* warning, assuming fe_confirm is used by DCC only! */
	struct DCC *dcc = ud;

	if (dcc->file)
		gtkutil_file_req (message, dcc_saveas_cb, ud, dcc->file,
								FRF_WRITE|FRF_FILTERISINITIAL|FRF_NOASKOVERWRITE);
}

void
fe_get_file (const char *title, char *initial,
				 void (*callback) (void *userdata, char *file), void *userdata,
				 int flags)
				
{
	/* OK: Call callback once per file, then once more with file=NULL. */
	/* CANCEL: Call callback once with file=NULL. */
	gtkutil_file_req (title, callback, userdata, initial, flags | FRF_FILTERISINITIAL);
}
