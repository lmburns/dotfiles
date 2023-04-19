" Vim syntax file
" Language:   conkyrc
" Author:     Ciaran McCreesh <ciaranm@gentoo.org>
" Version:    20060307
" Copyright:  Copyright (c) 2005 Ciaran McCreesh
" Licence:    You may redistribute this under the same terms as Vim itself
"

if exists("b:current_syntax")
	finish
endif

syn region ConkyrcComment start=/^\s*#/ end=/$/

syn keyword ConkyrcSetting alignment append_file background border_inner_margin border_outer_margin border_width colorN console_bar_fill console_bar_unfill console_graph_ticks cpu_avg_samples default_bar_height default_bar_width default_color default_gauge_height default_gauge_width default_graph_height default_graph_width default_outline_color default_shade_color detect_battery disable_auto_reload diskio_avg_samples display double_buffer draw_blended draw_borders draw_graph_borders draw_outline draw_shades extra_newline font fontN forced_redraw format_human_readable gap_x gap_y github_token hddtemp_host hddtemp_port http_port http_refresh if_up_strictness imap imlib_cache_flush_interval imlib_cache_size lua_mouse_hook lowercase lua_draw_hook_post lua_draw_hook_pre lua_load lua_shutdown_hook lua_startup_hook mail_spool max_port_monitor_connections max_text_width max_user_text maximum_width minimum_height minimum_width mpd_host mpd_password mpd_port music_player_interval mysql_db mysql_host mysql_password mysql_port mysql_user net_avg_samples no_buffers nvidia_display out_to_console out_to_http out_to_ncurses out_to_stderr out_to_wayland out_to_x override_utf8_locale overwrite_file own_window own_window_argb_value own_window_argb_visual own_window_class own_window_colour own_window_hints own_window_title own_window_transparent own_window_type pad_percents pop3 short_units show_graph_range show_graph_scale graph_gradient_mode stippled_borders store_graph_data_explicitly temperature_unit templateN text_buffer_size times_in_seconds top_cpu_separate top_name_verbose top_name_width total_run_times units_spacer update_interval update_interval_on_battery uppercase use_spacer use_xft xftalpha xinerama_head

syn keyword ConkyrcConstant
			\ above
			\ below
			\ bottom_left
			\ bottom_right
			\ bottom_middle
			\ desktop
			\ dock
			\ no
			\ none
			\ normal
			\ override
			\ skip_pager
			\ skip_taskbar
			\ sticky
			\ top_left
			\ top_right
			\ top_middle
			\ middle_left
			\ middle_right
			\ middle_middle
			\ undecorated
			\ yes

syn match ConkyrcNumber /\S\@<!\d\+\(\.\d\+\)\?\(\S\@!\|}\@=\)/
			\ nextgroup=ConkyrcNumber,ConkyrcColour skipwhite
syn match ConkyrcColour /\S\@<!#[a-fA-F0-9]\{6\}\(\S\@!\|}\@=\)/
			\ nextgroup=ConkyrcNumber,ConkyrcColour skipwhite

syn region ConkyrcText start=/^TEXT$/ end=/\%$/ contains=ConkyrcVar

syn region ConkyrcVar start=/\${/ end=/}/ contained contains=ConkyrcVarStuff
syn region ConkyrcVar start=/\$\w\@=/ end=/\W\@=\|$/ contained contains=ConkyrcVarName

syn match ConkyrcVarStuff /{\@<=/ms=s contained nextgroup=ConkyrcVarName

syn keyword ConkyrcVarName contained nextgroup=ConkyrcNumber,ConkyrcColour skipwhite acpiacadapter acpifan acpitemp addr addrs adt746xcpu adt746xfan alignc alignr apcupsd apcupsd_cable apcupsd_charge apcupsd_lastxfer apcupsd_linev apcupsd_load apcupsd_loadbar apcupsd_loadgauge apcupsd_loadgraph apcupsd_model apcupsd_name apcupsd_status apcupsd_temp apcupsd_timeleft apcupsd_upsmode apm_adapter apm_battery_life apm_battery_time audacious_bar audacious_bitrate audacious_channels audacious_filename audacious_frequency audacious_length audacious_length_seconds audacious_main_volume audacious_playlist_length audacious_playlist_position audacious_position audacious_position_seconds audacious_status audacious_title battery battery_bar battery_percent battery_power_draw battery_short battery_status battery_time blink buffers cached cat catp cmdline_to_pid cmus_aaa cmus_album cmus_artist cmus_curtime cmus_date cmus_file cmus_genre cmus_percent cmus_progress cmus_random cmus_repeat cmus_state cmus_timeleft cmus_title cmus_totaltime cmus_track color colorN combine conky_build_arch conky_build_date conky_version cpu cpubar cpugauge cpugovernor cpugraph curl desktop desktop_name desktop_number disk_protect diskio diskio_read diskio_write diskiograph diskiograph_read diskiograph_write distribution downspeed downspeedf downspeedgraph draft_mails else endif entropy_avail entropy_bar entropy_perc entropy_poolsize eval exec execbar execgauge execgraph execi execibar execigauge execigraph execp execpi flagged_mails font fontN format_time forwarded_mails free_bufcache freq freq2 freq_g fs_bar fs_bar_free fs_free fs_free_perc fs_size fs_type fs_used fs_used_perc gid_name github_notifications goto gw_iface gw_ip hddtemp head hr hwmon i2c i8k_ac_status i8k_bios i8k_buttons_status i8k_cpu_temp i8k_left_fan_rpm i8k_left_fan_status i8k_right_fan_rpm i8k_right_fan_status i8k_serial i8k_version ibm_brightness ibm_fan ibm_temps ibm_thinklight ibm_volume ical iconv_start iconv_stop if_empty if_existing if_gw if_match if_mixer_mute if_mounted if_mpd_playing if_pa_sink_muted if_running if_smapi_bat_installed if_up if_updatenr if_xmms2_connected iface image imap_messages imap_unseen intel_backlight ioscheduler irc journal kernel key_caps_lock key_num_lock key_scroll_lock keyboard_layout laptop_mode legacymem lines loadavg loadgraph lowercase lua lua_bar lua_gauge lua_graph lua_parse machine mails mboxscan mem memactive memavail membar memdirty memeasyfree memfree memgauge memgraph meminactive memlaundry memmax memperc memwired memwithbuffers memwithbuffersbar memwithbuffersgraph mixer mixerbar mixerl mixerlbar mixerr mixerrbar moc_album moc_artist moc_bitrate moc_curtime moc_file moc_rate moc_song moc_state moc_timeleft moc_title moc_totaltime monitor monitor_number mouse_speed mpd_album mpd_albumartist mpd_artist mpd_bar mpd_bitrate mpd_comment mpd_date mpd_elapsed mpd_file mpd_length mpd_name mpd_percent mpd_random mpd_repeat mpd_smart mpd_status mpd_title mpd_track mpd_vol mysql nameserver new_mails no_update nodename nodename_short nvidia nvidiabar nvidiagauge nvidiagraph offset outlinecolor pa_card_active_profile pa_card_name pa_sink_active_port_description pa_sink_active_port_name pa_sink_description pa_sink_volume pa_sink_volumebar password pb_battery pid_chroot pid_cmdline pid_cwd pid_egid pid_environ pid_environ_list pid_euid pid_exe pid_fsgid pid_fsuid pid_gid pid_nice pid_openfiles pid_parent pid_priority pid_read pid_sgid pid_state pid_state_short pid_stderr pid_stdin pid_stdout pid_suid pid_thread_list pid_threads pid_time pid_time_kernelmode pid_time_usermode pid_uid pid_vmdata pid_vmexe pid_vmhwm pid_vmlck pid_vmlib pid_vmpeak pid_vmpte pid_vmrss pid_vmsize pid_vmstk pid_write platform pop3_unseen pop3_used processes read_tcp read_udp replied_mails rss rstrip running_processes running_threads scroll seen_mails shadecolor shmem sip_status smapi smapi_bat_bar smapi_bat_perc smapi_bat_power smapi_bat_temp sony_fanspeed startcase stippled_hr stock swap swapbar swapfree swapmax swapperc sysctlbyname sysname tab tail tcp_ping tcp_portmon templateN texeci texecpi threads time to_bytes top top_io top_mem top_time totaldown totalup trashed_mails tztime uid_name unflagged_mails unforwarded_mails unreplied_mails unseen_mails updates uppercase upspeed upspeedf upspeedgraph uptime uptime_short user_names user_number user_terms user_time user_times utime v6addrs version voffset voltage_mv voltage_v wireless_ap wireless_bitrate wireless_channel wireless_essid wireless_freq wireless_link_bar wireless_link_qual wireless_link_qual_max wireless_link_qual_perc wireless_mode words xmms2_album xmms2_artist xmms2_bar xmms2_bitrate xmms2_comment xmms2_date xmms2_duration xmms2_elapsed xmms2_genre xmms2_id xmms2_percent xmms2_playlist xmms2_size xmms2_smart xmms2_status xmms2_timesplayed xmms2_title xmms2_tracknr xmms2_url

hi def link ConkyrcComment   Comment
hi def link ConkyrcSetting   Keyword
hi def link ConkyrcConstant  Constant
hi def link ConkyrcNumber    Number
hi def link ConkyrcColour    Special

hi def link ConkyrcText      String
hi def link ConkyrcVar       Identifier
hi def link ConkyrcVarName   Keyword

let b:current_syntax = "conkyrc"
