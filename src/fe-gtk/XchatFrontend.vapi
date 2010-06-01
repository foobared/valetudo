using GLib;

[CCode(cheader_filename = "../common/xchat.h,../common/fe.h,../common/util.h,../common/text.h,../common/cfgfiles.h,../common/xchatc.h,../common/plugin.h,gtkutil.h,maingui.h,textgui.h,pixmaps.h,joind.h,xtext.h,palette.h,menu.h,notifygui.h,textgui.h,fkeys.h,plugin-tray.h,urlgrab.h,fe-gtk.h")]
namespace XchatFrontend {
    [CCode(type="struct session_gui", cname="struct session_gui")]
    public struct SessionGui {
        bool is_tab;
        XText xtext;
        Gtk.Entry topic_entry;
    }
    [CCode(type="struct restore_gui", cname="struct restore_gui")]
    public struct RestoreGui {
        string topic_text;
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
        int type;
    }
    [CCode(type="struct xchatprefs", cname="struct xchatprefs")]
    public struct XchatPrefs {
        int indent_nicks;
        string background;
        bool privmsgtab;
        bool tabchannels;
        string font_normal;
        int style_inputbox;
        bool input_flash_hilight;
    }
    [CCode(type="struct session *", cname="current_tab")]
    Session* current_tab;
    [CCode(cname="fe_set_tab_color")]
    void fe_set_tab_color(Session* s, int i);
    [CCode(cname="fe_flash_window")]
    void fe_flash_window(Session* s);
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
    [CCode(cname="cursor_color_rc")]
    string cursor_color_rc;
    [CCode(cname="colors")]
    Gdk.Color[] colors;
    [CCode(cname="sess_list")]
    SList<Session*> sess_list;
    [CCode(cname="pixmap_load_from_file")]
    Gdk.Pixmap pixmap_load_from_file(string fname);
    [CCode(cname="create_input_style")]
    // "owned" is an horrid kludge to be removed in the future.
    Gtk.Style create_input_style(owned Gtk.Style style);
    [CCode(cname="struct _GtkXText")]
    public class XText {
        public bool transparent;

        [CCode(cname="gtk_xtext_refresh")]
        public void refresh (int do_trans);
    }
    [CCode(cname="fe_message")]
    void fe_message(string s, int i);
    [CCode(cname="mg_changui_new")]
    void mg_changui_new(Session* s, RestoreGui* res, int tab, int focus);
    [CCode(cname="xchat_execv")]
    void xchat_execv(char** argv);
    [CCode(cname="mg_set_topic_tip")]
    void mg_set_topic_tip(Session* s);
}
