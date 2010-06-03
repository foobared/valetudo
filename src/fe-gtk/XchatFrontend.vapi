using GLib;

[CCode(cheader_filename = "../common/xchat.h,../common/fe.h,../common/util.h,../common/text.h,../common/cfgfiles.h,../common/xchatc.h,../common/plugin.h,gtkutil.h,maingui.h,textgui.h,pixmaps.h,joind.h,xtext.h,palette.h,menu.h,notifygui.h,textgui.h,fkeys.h,plugin-tray.h,urlgrab.h,fe-gtk.h", lower_case_cprefix = "", cprefix = "")]
namespace XchatFrontend {
    [CCode(type="struct session_gui", cname="struct session_gui")]
    public struct SessionGui {
        bool is_tab;
        XText xtext;
        Gtk.Entry topic_entry;
        Gtk.Entry limit_entry;
        Gtk.Entry key_entry;
        Gtk.Entry input_box;
        Gtk.Button[] flag_wid; /*NUM_FLAG_WIDS*/
        Gtk.Widget[] menu_item; /*MENU_ID_NUM*/
        Gtk.Window window;
        Gtk.Widget bar;
        Gtk.ProgressBar throttlemeter;
        Gtk.ProgressBar lagometer;
        Gtk.Label throttleinfo;
        Gtk.Label laginfo;
    }
    [Compact]
    [CCode(type="struct server_gui", cname="struct server_gui")]
    public class ServerGui {
        public ServerGui ();
        public Gtk.Window chanlist_window;
    }
    [Compact]
    [CCode(type="struct file_req", cname="struct file_req")]
    public class FileReq {
        public FileReq ();
        public Gtk.Dialog dialog;
        public int flags;
        public void* callback;
        public void* userdata;
    }
    [CCode(type="struct server", cname="struct server")]
    public struct Server {
        ServerGui* gui;
        int sendq_len;
        time_t lag_sent;
        Session* front_session;
    }
    [CCode(type="struct restore_gui", cname="struct restore_gui")]
    public struct RestoreGui {
        bool c_graph;
        string topic_text;
        char* limit_text; // leave char* or valac will complain
        char* key_text;
        string input_text;
        string queue_tip;
        string queue_text;
        float lag_value;
        string lag_text;
        string lag_tip;
        XText buffer;
        Gtk.Window banlist_window;
        float queue_value;
    }
    [CCode(type="struct session", cname="struct session")]
    public struct Session {
        Server* server;
        string channel;
        string channelkey;
        bool new_data;
        bool msg_said;
        bool nick_said;
        SessionGui* gui;
        RestoreGui* res;
        int type;
        int limit;
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
    [CCode(cname="struct DCC", type="struct DCC")]
    public struct DCC {
        Server* serv;
        int dccstat;
        int resume_sent;
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
        public void refresh(int do_trans);
        [CCode(cname="gtk_xtext_clear")]
        public void clear(int lines);
    }
    void fe_message(string s, int i);
    void mg_changui_new(Session* s, RestoreGui* res, int tab, int focus);
    void xchat_execv(char** argv);
    void mg_set_topic_tip(Session* s);
    Gtk.Window parent_window;
    [CCode(cprefix="FE_MSG_")]
    public enum FeMsg {
        WAIT=1, INFO=2, WARN=4, ERROR=8, MARKUP=16
    }
    [CCode(cprefix="FIA_")]
    public enum Fia { // frontend input add, methinks.
        READ=1, WRITE=2, EX=4, FD=8
    }
    [CCode(cprefix="FE_SE_")]
    public enum FeSe { // Frontend server
        CONNECT, LOGGEDIN, DISCONNECT, RECONDELAY, CONNECTING
    }
    [CCode(cprefix="MENU_ID_")]
    public enum MenuId {
        AWAY, MENUBAR, TOPICBAR, USERLIST, ULBUTTONS, MODEBUTTONS,
        LAYOUT_TABS, LAYOUT_TREE, DISCONNECT, RECONNECT, JOIN, USERMENU
    }
    [CCode(cprefix="FE_GUI_")]
    public enum FeGuiAction {
        HIDE, SHOW, FOCUS, FLASH, COLOR, ICONIFY, MENU, ATTACH, APPLY
    }
    [CCode(cprefix="STAT_")]
    public enum DccStat {
        QUEUED, ACTIVE, FAILED, DONE, CONNECTING, ABORTED
    }
    [CCode(cprefix="FRF_")]
    public enum Frf { // file request folder?
        WRITE=1, MULTIPLE=2, ADDFOLDER=4, CHOOSEFOLDER=8,
        FILTERISINITIAL=16, NOASKOVERWRITE=32
    }
    void fe_set_title(Session* s);
    void notify_gui_update();
    void mg_tab_close(Session* s);
    void mg_progressbar_create(SessionGui* sg);
    void mg_progressbar_destroy(SessionGui* sg);
    void mg_bring_tofront_sess(Session* s);
    void mg_detach(Session* s, int arg);
    void joind_open(Server* s);
    void joind_close(Server* s);
    void menu_bar_toggle();
    void setup_apply_real(bool a, bool b);
    void add_tip(Gtk.Widget w, string s);
    int make_ping_time();
    bool is_dcc(DCC* d);
    void dcc_abort(Session* s, DCC* d);
    void dcc_get_with_destfile(DCC* d, string file);
    void path_part(string file, string path, int pathlen);
    void gtkutil_file_req_response(FileReq f);
    void gtkutil_file_req_destroy(FileReq f);
    string get_xdir_fs();
    string file_part(string file);
    string last_dir;
}
