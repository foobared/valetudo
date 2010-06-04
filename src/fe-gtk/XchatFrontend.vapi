using GLib;

[CCode(cheader_filename = "../common/xchat.h,../common/fe.h,../common/util.h,../common/text.h,../common/cfgfiles.h,../common/xchatc.h,../common/plugin.h,gtkutil.h,maingui.h,textgui.h,pixmaps.h,joind.h,xtext.h,palette.h,menu.h,notifygui.h,textgui.h,fkeys.h,plugin-tray.h,urlgrab.h,fe-gtk.h,chanview.h", lower_case_cprefix = "", cprefix = "")]
namespace XchatFrontend {
    [CCode(type="struct session_gui", cname="struct session_gui")]
    public class SessionGui {
        public SessionGui ();
        public bool is_tab;
        public XText xtext;
        public Gtk.Entry topic_entry;
        public Gtk.Entry limit_entry;
        public Gtk.Entry key_entry;
        public Gtk.Entry input_box;
        public Gtk.Button[] flag_wid; /*NUM_FLAG_WIDS*/
        public Gtk.Widget[] menu_item; /*MENU_ID_NUM*/
        public Gtk.Window window;
        public Gtk.Widget bar;
        public Gtk.ProgressBar throttlemeter;
        public Gtk.ProgressBar lagometer;
        public Gtk.Label throttleinfo;
        public Gtk.Label laginfo;
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
    [Compact]
    [CCode(type="struct restore_gui", cname="struct restore_gui")]
    public class RestoreGui {
        public RestoreGui ();
        public bool c_graph;
        public string topic_text;
        public char* limit_text; // leave char* or valac will complain
        public char* key_text;
        public string input_text;
        public string queue_tip;
        public string queue_text;
        public float lag_value;
        public string lag_text;
        public string lag_tip;
        public XText buffer;
        public Gtk.Window banlist_window;
        public float queue_value;
        public Chan* tab;
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
        int newtabstofront;
    }
    [CCode(cname="struct DCC", type="struct DCC")]
    public struct DCC {
        Server* serv;
        int dccstat;
        int resume_sent;
    }
    [CCode(cname="struct _chan", type="struct _chan")]
    public struct Chan {
    }
    [Compact]
    [CCode(cname="struct User", type="struct User")]
    public struct User {
        //public User ();
        public string nick; // NICKLEN
        public string hostname;
        public string realname;
        public string servername;
        public time_t lasttalk;
        public int access;
        public string prefix; // 2
        public int op;
        public int hop;
        public int voice;
        public int me;
        public int away;
        public int selected;
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
    [CCode(cprefix="FOCUS_NEW_")]
    public enum FocusNew {
        NONE, ALL, ONLY_ASKED
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
    bool is_channel(Server* s, string chan);
    User* userlist_find_global(Server* s, string chan);
    void mg_create_topwindow(Session* s);
    void set_topic(Session* s, string h, string hh);
    SessionGui* mg_gui;
    SessionGui* static_mg_gui_get();
    void mg_create_tabwindow(Session* s);
    void mg_add_chan(Session* s);
    void chan_focus(Chan* tab);
}
