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
    }
    [CCode(type="struct session *", cname="current_tab")]
    Session current_tab;
    [CCode(cname="fe_set_tab_color")]
    void fe_set_tab_color(Session s, int i);
    [CCode(cname="PrintTextRaw")]
    void PrintTextRaw(void *xtbuf, string *text, int indent, time_t stamp);
    [CCode(cname="prefs")]
    XchatPrefs prefs;
}
