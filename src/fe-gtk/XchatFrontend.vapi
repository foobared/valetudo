[CCode(cheader_filename = "../common/xchat.h,../common/fe.h,../common/util.h,../common/text.h,../common/cfgfiles.h,../common/xchatc.h,../common/plugin.h,gtkutil.h,maingui.h,textgui.h,pixmaps.h,joind.h,xtext.h,palette.h,menu.h,notifygui.h,textgui.h,fkeys.h,plugin-tray.h,urlgrab.h,fe-gtk.h")]
namespace XchatFrontend {
    [CCode(type="struct session_gui", cname="struct session_gui")]
    public struct SessionGui {
        bool is_tab;
    }
    [CCode(type="struct restore_gui", cname="struct restore_gui")]
    public struct RestoreGui {
        void* buffer;
    }
    [CCode(type="struct session", cname="struct session")]
    public struct Session {
        string channel;
        bool new_data;
        bool msg_said;
        bool nick_said;
        SessionGui* gui;
        RestoreGui* res;
    }
    [CCode(type="struct xchatprefs", cname="struct xchatprefs")]
    public struct XchatPrefs {
        int indent_nicks;
        string background;
    }
    [CCode(type="struct session *", cname="current_tab")]
    Session current_tab;
    [CCode(cname="fe_set_tab_color")]
    void fe_set_tab_color(Session s, int i);
    [CCode(cname="PrintTextRaw")]
    void PrintTextRaw(void *xtbuf, string *text, int indent, time_t stamp);
    [CCode(cname="prefs")]
    XchatPrefs prefs;
    [CCode(cname="palette_load")]
    void palette_load();
    [CCode(cname="key_init")]
    void key_init();
    [CCode(cname="pixmaps_init")]
    void pixmaps_init();
    [CCode(cname="channelwin_pix")]
    Gdk.Pixmap channelwin_pix;
    [CCode(cname="input_style")]
    Gtk.Style input_style;
    [CCode(cname="pixmap_load_from_file")]
    Gdk.Pixmap pixmap_load_from_file(string fname);
    [CCode(cname="create_input_style")]
    // "owned" is an horrid kludge to be removed in the future.
    Gtk.Style create_input_style(owned Gtk.Style style);
}
