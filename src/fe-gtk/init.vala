using XchatFrontend;
using Posix;
using GLib;

void vala_redraw_trans_xtexts () {
    var done_main = false;
    print("fu fu fu\n");
    sess_list.foreach((sess) => {
        var s = (Session*)sess;
        if (s->gui->xtext.transparent) {
            if (!s->gui->is_tab || !done_main)
                (s->gui->xtext).refresh(1);
            if (s->gui->is_tab)
                done_main = true;
        }
    });
}

void fe_new_window (Session* s, int focus) {
    int tab = 0;
    if (s->type == 3 /*SESS_DIALOG*/) {
        if(prefs.privmsgtab) tab = 1;
    } else {
        if(prefs.tabchannels) tab = 1;
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

void fe_notify_update (string? name) {
    if (null == name)
        notify_gui_update();
}

void fe_update_mode_entry (Session* s, Gtk.Entry entry, char** text, string new_text) {
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
    sess_list.foreach((sess) => {
        var s = (Session*) sess;
        if (s->server == serv) {
            if (null != s->gui->bar)
                mg_progressbar_destroy(s->gui);
            s->res->c_graph = false;
        }
    });
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
    Pid pid;
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
    sess_list.foreach((sess) => {
        var s = (Session*) sess;
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
    });
}



////////

void vala_log(string ss) {
    GLib.stdout.printf("%s\n", ss);
}
