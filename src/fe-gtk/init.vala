using XchatFrontend;

void vala_fe_print_text(Session s, string text, time_t time) {
	PrintTextRaw(s.res->buffer, text, prefs.indent_nicks, time);
	if (!s.new_data && s != current_tab &&
        s.gui->is_tab && !s.nick_said && time == 0) {
		s.new_data = true;
		if (s.msg_said) fe_set_tab_color(s, 2);
		else fe_set_tab_color(s, 1);
	}
}

void vala_log(string ss) {
    stdout.printf("%s\n", ss);
}
