using GLib;

[CCode(cheader_filename = "../common/xchat.h,../common/fe.h,../common/util.h,../common/text.h,../common/cfgfiles.h,../common/xchatc.h,../common/plugin.h,gtkutil.h,maingui.h,textgui.h,pixmaps.h,joind.h,xtext.h,palette.h,menu.h,notifygui.h,textgui.h,fkeys.h,plugin-tray.h,urlgrab.h,fe-gtk.h", lower_case_cprefix = "", cprefix = "")]
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
    [CCode(type="struct session *")]
    Session* current_tab;
    void fe_set_tab_color(Session* s, int i);
    void fe_flash_window(Session* s);
    void PrintTextRaw(void *xtbuf, string *text, int indent, time_t stamp);
    XchatPrefs prefs;
    void palette_load();
    void key_init();
    void pixmaps_init();
    Gdk.Pixmap channelwin_pix;
    Gtk.Style input_style;
    string cursor_color_rc;
    Gdk.Color[] colors;
    SList<Session*> sess_list;
    Gdk.Pixmap pixmap_load_from_file(string fname);
    // "owned" is an horrid kludge to be removed in the future.
    Gtk.Style create_input_style(owned Gtk.Style style);
    [CCode(cname="struct _GtkXText")]
    public class XText {
        public bool transparent;

        [CCode(cname="gtk_xtext_refresh")]
        public void refresh (int do_trans);
    }
    void fe_message(string s, int i);
    void mg_changui_new(Session* s, RestoreGui* res, int tab, int focus);
    void xchat_execv(char** argv);
    void mg_set_topic_tip(Session* s);
}
