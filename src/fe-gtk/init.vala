using XchatFrontend;
using Posix;
using GLib;

/*
 * fe-gtk.c
 */

void fe_main () {
    Gtk.main();
}

void fe_cleanup () {}

void fe_exit () {
    Gtk.main_quit();
}

void vala_redraw_trans_xtexts () {
    var done_main = false;
    print("fu fu fu\n");
    foreach (Session* s in sess_list) {
        if (s->gui->xtext.transparent) {
            if (!s->gui->is_tab || !done_main)
                (s->gui->xtext).refresh(1);
            if (s->gui->is_tab)
                done_main = true;
        }
    }
}

void fe_new_window (Session* s, int focus) {
    bool tab = false;
    if (s->type == 3 /*SESS_DIALOG*/) {
        if(prefs.privmsgtab) tab = true;
    } else {
        if(prefs.tabchannels) tab = true;
    }
    mg_changui_new(s, null, tab, focus);
}

void fe_message (string msg, int flags) {
    var type = Gtk.MessageType.WARNING;

    if (0 != (flags & FeMsg.ERROR))
        type = Gtk.MessageType.ERROR;
    if (0 != (flags & FeMsg.INFO))
        type = Gtk.MessageType.INFO;

    var dialog = new Gtk.MessageDialog(parent_window, 0, type, Gtk.ButtonsType.OK, "%s", msg);
    if (0  != (flags & FeMsg.MARKUP))
        dialog.set_markup(msg);
    dialog.response.connect(()=>{dialog.destroy();});
    dialog.set_resizable(false);
    dialog.set_position(Gtk.WindowPosition.MOUSE);
    dialog.show();

    if (0 != (flags & FeMsg.WAIT))
        dialog.run();
}

uint vala_fe_input_add (int sok, int flags, IOFunc func) {
    // another miracle case, where dropping an argument works anyway,
    // because the compiler does dark magic.
    uint tag, type = 0;
    var channel = new IOChannel.unix_new(sok);
    // windows stuff
    //channel = g_io_channel_win32_new_fd (sok); // if fia_fd
    //channel = g_io_channel_win32_new_socket (sok);

    if (0 != (flags & Fia.READ))
        type |= IOCondition.IN | IOCondition.HUP | IOCondition.ERR;
    if (0 != (flags & Fia.WRITE))
        type |= IOCondition.OUT | IOCondition.ERR;
    if (0 != (flags & Fia.EX))
        type |= IOCondition.PRI;

    tag = channel.add_watch((IOCondition)type, func);
    return tag;
}

void fe_new_server (Server* serv) {
    serv->gui = new ServerGui();
}

void fe_notify_update (string? name) {
    if (null == name)
        notify_gui_update();
}

void fe_update_mode_entry (Session* s, Gtk.Entry? entry, char** text, string new_text) {
    // investigate into why I'm called two times every time

    if (!s->gui->is_tab || s == current_tab) {
        if (null != (s->gui->flag_wid[0])) /* channel mode buttons enabled? */
            entry.set_text(new_text);
    } else if (s->gui->is_tab) {
        // we should free *text here, but we don't because it won't be
        // necessary anymore when allocation will be in vala--
        *text = new_text.dup();
    }
}

void fe_update_channel_limit (Session* s) {
    // investigate into why I'm called two times every time
    var str = (s->limit).to_string();
    fe_update_mode_entry(s, s->gui->limit_entry, &s->res->limit_text, str);
    fe_set_title(s);
}

int fe_is_chanwindow (Server* serv) {
    if (null == serv->gui->chanlist_window)
        return 0;
    return 1;
}

int fe_is_banwindow (Session* s) {
    if (null == s->res->banlist_window)
        return 0;
    return 1;
}

static bool done_rc = false;
Gtk.Style create_input_style (Gtk.Style style) {
    int ColFg = 34; // it's a define
    int ColBg = 35;
    Pango.FontDescription fd;
    fd = Pango.FontDescription.from_string(prefs.font_normal);
    style.font_desc = fd;

    /* fall back */
    if (style.font_desc.get_size() == 0)
    {
        var buf = "Failed to open font:\n\n%s".printf(prefs.font_normal);
        fe_message(buf, FeMsg.ERROR);
        fd = Pango.FontDescription.from_string("sans 11");
        style.font_desc = fd;
    }

    if (0 != prefs.style_inputbox && !done_rc)
    {
        done_rc = true;
        var buf = cursor_color_rc.printf((colors[ColFg].red >> 8),
                                         (colors[ColFg].green >> 8),
                                         (colors[ColFg].blue >> 8));
        Gtk.rc_parse_string(buf);
    }

    style.bg[Gtk.StateType.NORMAL] = colors[ColFg];
    style.base[Gtk.StateType.NORMAL] = colors[ColBg];
    style.text[Gtk.StateType.NORMAL] = colors[ColFg];

    return style;
}

void fe_init () {
    palette_load ();
    key_init ();
    pixmaps_init ();

    channelwin_pix = pixmap_load_from_file (prefs.background);
    input_style = create_input_style (new Gtk.Style());
}

uint vala_fe_timeout_add (int interval, SourceFunc callback) {
    // magic from the other side. vala automatically adds a new parameter.
    return Timeout.add(interval, callback);
}

void fe_timeout_remove (int tag) {
    Source.remove(tag);
}

void fe_text_clear (Session* s, int lines) {
    (s->res->buffer).clear(lines);
}

void fe_close_window (Session* s) {
    if (s->gui->is_tab)
        mg_tab_close(s);
    else
        (s->gui->window).destroy();
}

void fe_progressbar_start (Session *s) {
    if (!s->gui->is_tab || current_tab == s)
    /* if it's the focused tab, create it for real! */
        mg_progressbar_create(s->gui);
    else
    /* otherwise just remember to create on when it gets focused */
        s->res->c_graph = true;
}

void fe_progressbar_end (Server* serv) {
    foreach (Session* s in sess_list) {
        if (s->server == serv) {
            if (null != s->gui->bar)
                mg_progressbar_destroy(s->gui);
            s->res->c_graph = false;
        }
    }
}

void fe_beep () {
    Gdk.beep();
}

void fe_update_channel_key (Session *s) {
    fe_update_mode_entry(s,s->gui->key_entry,&s->res->key_text,s->channelkey);
    fe_set_title(s);
}

void fe_input_remove (int tag) {
    Source.remove(tag);
}

void fe_print_text (Session* s, string text, time_t time) {
    PrintTextRaw(s->res->buffer, text, prefs.indent_nicks, time);
    if (!s->new_data && s != current_tab &&
        s->gui->is_tab && !s->nick_said && time == 0) {
        s->new_data = true;
        if (s->msg_said) fe_set_tab_color(s, 2);
        else fe_set_tab_color(s, 1);
    }
}

bool try_browser (string browser, string url) {
    var path = Environment.find_program_in_path(browser);
    if (null == path) return false;
    string[] argv = {path, url, null};
    xchat_execv(argv);
    return true;
}

void fe_open_url (string url) {
    Func test;
    test = (url) => {
        string u = (string)url;
        if (try_browser("xdg-open", u))
            return;
        if (try_browser("firefox", u))
            return;
    };
    if (url[0] != '/' && !url.contains(":")) {
        test("http://%s".printf(url));
    } else test(url);
}

void fe_set_topic (Session* s, string topic, string stripped_topic) {
    if (!s->gui->is_tab || s == current_tab) {
        (s->gui->topic_entry).set_text(stripped_topic);
        mg_set_topic_tip(s);
    } else {
        s->res->topic_text = stripped_topic.dup();
    }
}

void fe_set_hilight (Session* s) {
    if (s->gui->is_tab)
        fe_set_tab_color(s, 3); // set tab to blue

    if (prefs.input_flash_hilight)
        fe_flash_window(s); // taskbar flash
}

void fe_server_event (Server* serv, int type, int arg) {
    foreach (Session* s in sess_list) {
        if (s->server == serv && (current_tab == s || !s->gui->is_tab)) {
            SessionGui* gui = s->gui;

            switch (type) {
            case FeSe.CONNECTING:  /* connecting in progress */
            case FeSe.RECONDELAY:  /* reconnect delay begun */
                /* enable Disconnect item */
                (gui->menu_item[MenuId.DISCONNECT]).set_sensitive(true);
                break;
            case FeSe.CONNECT:
                /* enable Disconnect and Away menu items */
                (gui->menu_item[MenuId.AWAY]).set_sensitive(true);
                (gui->menu_item[MenuId.DISCONNECT]).set_sensitive(true);
                break;
            case FeSe.LOGGEDIN:    /* end of MOTD */
                (gui->menu_item[MenuId.JOIN]).set_sensitive(true);
                /* if number of auto-join channels is zero, open joind */
                if (arg == 0)
                    joind_open(serv);
                break;
            case FeSe.DISCONNECT:
                /* disable Disconnect and Away menu items */
                (gui->menu_item[MenuId.AWAY]).set_sensitive(false);
                (gui->menu_item[MenuId.DISCONNECT]).set_sensitive(false);
                (gui->menu_item[MenuId.JOIN]).set_sensitive(false);
                /* close the join-dialog, if one exists */
                joind_close(serv);
                break;
            }
        }
    }
}

void fe_set_lag (Server *serv, int lag) {
    int nowtim;

    if (lag == -1) {
        if (0 == serv->lag_sent)
            return;
        nowtim = make_ping_time();
        lag = (nowtim - (int)serv->lag_sent) / 100000;
    }

    var per = float.min(1.0f, lag/10.0f);

    var pref = (0 != serv->lag_sent) ? "+" : "";
    var lagtext = "%s%d.%ds".printf(pref, lag/10, lag%10);
    var lagtip = "Lag: %s%d.%d seconds".printf(pref, lag/10, lag%10);

    foreach (Session* s in sess_list) {
        if (s->server == serv) {
            s->res->lag_tip = lagtip;

            if (!s->gui->is_tab || current_tab == s) {
                if (null != s->gui->lagometer) {
                    (s->gui->lagometer).set_fraction(per);
                    add_tip((s->gui->lagometer).get_parent(), lagtip);
                }
                if (null != s->gui->laginfo)
                    (s->gui->laginfo).set_text(lagtext);
            } else {
                s->res->lag_value = per;
                s->res->lag_text = lagtext;
            }
        }
    }
}

void fe_set_throttle (Server* serv) {
    float per = float.min(1.0f, serv->sendq_len / 1024.0f);
    string tbuf = "";
    string tip = "";

    foreach (Session* s in sess_list) {
        if (s->server == serv) {
            tbuf = "%d bytes".printf(serv->sendq_len);
            tip = "Network send queue: %d bytes".printf(serv->sendq_len);
            s->res->queue_tip = tip;

            if (!s->gui->is_tab || current_tab == s) {
                if (null != s->gui->throttlemeter) {
                    (s->gui->throttlemeter).set_fraction(per);
                    add_tip((s->gui->throttlemeter).get_parent(), tip);
                }
                if (null != s->gui->throttleinfo)
                    (s->gui->throttleinfo).set_text(tbuf);
            } else {
                s->res->queue_value = per;
                s->res->queue_text = tbuf;
            }
        }
    }
}

void fe_set_inputbox_contents (Session* s, string text) {
    if (!s->gui->is_tab || s == current_tab) {
        (s->gui->input_box).set_text(text);
    } else {
        // again, we should free input_text
        s->res->input_text = text.dup();
    }
}

string fe_get_inputbox_contents (Session *s) {
    /* not the current tab */
    if (null != s->res->input_text)
        return s->res->input_text;

    /* current focused tab */
    return (s->gui->input_box).text;
}

int fe_get_inputbox_cursor (Session *s) {
    /* not the current tab (we don't remember the cursor pos) */
    if (null != s->res->input_text)
        return 0;

    /* current focused tab */
    return (s->gui->input_box).get_position();
}

void fe_set_inputbox_cursor (Session *s, int delta, int pos) {
    if (!s->gui->is_tab || s == current_tab) {
        if (0 != delta)
            pos += (s->gui->input_box).get_position();
        (s->gui->input_box).set_position(pos);
    } else {
        /* we don't support changing non-front tabs yet */
    }
}

void *fe_gui_info_ptr (Session *s, int info_type) {
    switch (info_type) {
    case 0: /* native window pointer (for plugins) */
        return s->gui->window;
    }
    return null;
}

int fe_gui_info (Session *s, int info_type) {
    switch (info_type) {
    case 0: /* window status */
        if (!(s->gui->window).get_visible())
            return 2;   /* hidden (iconified or systray) */
        if ((s->gui->window).is_active)
            return 1;   /* active/focused */
        return 0;       /* normal (no keyboard focus or behind a window) */
    }

    return -1;
}

void fe_ctrl_gui (Session *s, int action, int arg) {
    switch (action) {
    case FeGuiAction.HIDE:
        (s->gui->window).hide();
        break;
    case FeGuiAction.SHOW:
        (s->gui->window).show();
        (s->gui->window).present();
        break;
    case FeGuiAction.FOCUS:
        mg_bring_tofront_sess(s);
        break;
    case FeGuiAction.FLASH:
        fe_flash_window(s);
        break;
    case FeGuiAction.COLOR:
        fe_set_tab_color(s, arg);
        break;
    case FeGuiAction.ICONIFY:
        (s->gui->window).iconify();
        break;
    case FeGuiAction.MENU:
        menu_bar_toggle(); /* toggle menubar on/off */
        break;
    case FeGuiAction.ATTACH:
        mg_detach(s, arg); /* arg: 0=toggle 1=detach 2=attach */
        break;
    case FeGuiAction.APPLY:
        setup_apply_real(true, true);
        break;
    }
}

void dcc_saveas_cb (DCC *dcc, string? file) {
    if (is_dcc(dcc)) {
        if (dcc->dccstat == DccStat.QUEUED) {
            if (null != file)
                dcc_get_with_destfile(dcc, file);
            else if (dcc->resume_sent == 0)
                dcc_abort(dcc->serv->front_session, dcc);
        }
    }
}

// currently broken.
void __gtkutil_file_req (string title, void* cb, void* userdata,
                       string? filter, int flags)
{
    print("haloo.\n");
    Gtk.FileChooserDialog dialog;
    //extern char *get_xdir_fs (void);

    if (0 != (flags & Frf.WRITE)) {
        dialog = new Gtk.FileChooserDialog(title, null,
                                           Gtk.FileChooserAction.SAVE,
                                           Gtk.STOCK_CANCEL,
                                           Gtk.ResponseType.CANCEL,
                                           Gtk.STOCK_SAVE,
                                           Gtk.ResponseType.ACCEPT, null);

        if (null!=filter && 0!=filter[0]) {
            // filter becomes initial name when saving
            char temp[1024];
            path_part(filter, (string)temp, 1024);
            dialog.set_current_folder((string)temp);
            dialog.set_current_name(file_part(filter));
        }
        if (0 == (flags & Frf.NOASKOVERWRITE))
            dialog.set_do_overwrite_confirmation(true);
    }
    else
        dialog = new Gtk.FileChooserDialog(title, null,
                                           Gtk.FileChooserAction.OPEN,
                                           Gtk.STOCK_CANCEL,
                                           Gtk.ResponseType.CANCEL,
                                           Gtk.STOCK_OK,
                                           Gtk.ResponseType.ACCEPT, null);
    if (0 != (flags & Frf.MULTIPLE))
        dialog.set_select_multiple(true);
    if (0 != last_dir[0])
        dialog.set_current_folder(last_dir);
    if (0 != (flags & Frf.ADDFOLDER))
        dialog.add_shortcut_folder(get_xdir_fs());
    if (0 != (flags & Frf.CHOOSEFOLDER)) {
        dialog.set_action(Gtk.FileChooserAction.SELECT_FOLDER);
        dialog.set_current_folder(filter);
    } else if (null!=filter && 0!=(flags & Frf.FILTERISINITIAL)) {
            dialog.set_current_folder(filter);
    }

    var freq = new FileReq();
    freq.dialog = dialog;
    freq.flags = flags;
    freq.callback = cb;
    freq.userdata = userdata;

    dialog.response.connect(() => {gtkutil_file_req_response(freq);});
    dialog.destroy.connect(() => {gtkutil_file_req_destroy(freq);});
    dialog.show();
}


/*
 * maingui.c
 */

void mg_changui_new (Session* s, owned RestoreGui* res, bool tab, int focus) {
    bool first_run = false;
    SessionGui* gui;
    User* user = null;

    if (null == res)
        res = new RestoreGui();

    s->res = res;

    if (null == s->server->front_session)
        s->server->front_session = s;

    if (!is_channel(s->server, s->channel))
        user = userlist_find_global(s->server, s->channel);

    if (!tab) {
        gui = new SessionGui();
        gui->is_tab = false;
        s->gui = gui;
        mg_create_topwindow(s);
        fe_set_title(s);
        if (null!=user && null!=user->hostname)
            set_topic(s, user->hostname, user->hostname);
        return;
    }

    if (mg_gui == null) {
        first_run = true;
        gui = static_mg_gui_get();
        gui->is_tab = true;
        s->gui = gui;
        mg_create_tabwindow(s);
        mg_gui = gui;
        parent_window = gui->window;
    } else {
        s->gui = gui = mg_gui;
        gui->is_tab = true;
    }

    if (null!=user && null!=user->hostname)
        set_topic(s, user->hostname, user->hostname);

    mg_add_chan(s);

    if (first_run
        || (prefs.newtabstofront == FocusNew.ONLY_ASKED && 0 != focus)
        || prefs.newtabstofront == FocusNew.ALL )
        chan_focus(res->tab);
}


////////

void vala_log(string ss) {
    GLib.stdout.printf("%s\n", ss);
}
