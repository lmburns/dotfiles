-- Control 1.0.9
-- https://github.com/oe-d/control
-- See control.conf for settings and key binds

options = require 'mp.options'
u = require 'mp.utils'

o = {
    audio_devices = "'auto'",
    audio_device = 0,
    osc_paused = false,
    play_on_load = 'auto',
    pause_minimized = 'no',
    play_restored = false,
    show_info = 'yes',
    info_duration = 1000,
    show_volume = true,
    step_method = 'seek',
    step_delay = -1,
    step_rate = 0,
    step_mute = 'auto',
    htp_speed = 2.5,
    htp_keep_dir = false,
    end_rewind = 'no',
    end_exit_fs = false,
    audio_symbol='🔊 ',
    audio_muted_symbol='🔈 ',
    image_symbol='🖼 ',
    music_symbol='🎵 ',
    video_symbol='🎞 '
}

function init()
    options.read_options(o, 'control')
    audio:create_user_list()
    if o.audio_device > 0 then audio:set(o.audio_device, get('volume')) end
    if o.step_delay == -1 then o.step_delay = get('input-ar-delay') end
    if o.step_rate == -1 then o.step_rate = get('input-ar-rate') end
    if o.end_rewind == 'file' then mp.set_property('keep-open', 'always') end
    if o.show_info == 'start' then
        o.show_info = 'yes'
        osd:toggle()
    end
    osd.default_msg = function()
        if media.type == 'image' then
            return o.image_symbol
        elseif media.type == 'audio' then
            return o.music_symbol
        elseif media.type == 'video' then
            return o.video_symbol..media.playback.frame..' / '..media.frames..' ('..media.playback.progress..'%)\n'
                ..format(media.playback.time)..'\n'
                ..round(fps.fps, 3)..' fps ('..round(media.playback.speed, 2)..'x)'
        else
            return ''
        end
    end
    osd.msg_timer:kill()
    osd.osd_timer:kill()
    step.delay_timer:kill()
    step.delay_timer.timeout = o.step_delay / 1000
    step.hwdec_timer:kill()
    mp.register_event('file-loaded', function()
        media:on_load()
        media.playback.on_load()
    end)
    mp.observe_property('window-minimized', 'bool', function(_, v) media.playback:on_minimize(v) end)
    mp.observe_property('estimated-vf-fps', 'number', function(_, v) fps:on_est_fps(v) end)
    mp.observe_property('pause', 'bool', function(_, v)
        media.playback.paused = v
        osc:on_pause(v)
        step:on_pause(v)
    end)
    mp.observe_property('playback-time', 'number', function(_, v)
        media.playback:on_tick(v)
        if media.type == 'video' then fps:on_tick() end
        if osd.show then osd:set(nil, o.info_duration / 1000) end
    end)
    mp.observe_property('play-dir', 'string', function(_, v) step:on_dir(v) end)
    mp.observe_property('speed', 'number', function(_, v)
        media.playback.speed = v
        if media.type == 'video' then fps:on_speed() end
        if o.show_info == 'yes' then osd:set(nil, o.info_duration / 1000) end
    end)
    mp.observe_property('eof-reached', 'bool', function(_, v)
        media.playback:on_eof(v)
        fullscreen.on_eof(v)
    end)
    mp.register_script_message('list-audio-devices', function() audio:msg_handler('list') end)
    mp.register_script_message('set-audio-device', function(...) audio:msg_handler('cycle', ...) end)
    mp.register_script_message('cycle-audio-devices', function(...) audio:msg_handler('cycle', ...) end)
    mp.add_key_binding(nil, 'toggle-info', function() osd:toggle() end)
    mp.add_key_binding(nil, 'cycle-pause', function() media.playback:pause() end)
    mp.add_key_binding(nil, 'cycle-fullscreen', function(e) fullscreen:key_handler(e) end, {complex = true})
    mp.add_key_binding(nil, 'step', function(e) step:key_handler(e, 'forward') end, {complex = true})
    mp.add_key_binding(nil, 'step-back', function(e) step:key_handler(e, 'backward') end, {complex = true})
    mp.add_key_binding(nil, 'htp', function(e) step:key_handler(e, 'forward', true) end, {complex = true})
    mp.add_key_binding(nil, 'htp-back', function(e) step:key_handler(e, 'backward', true) end, {complex = true})
end

function case_insensitive(str)
    str = str:gsub('%a', function(char)
        return ('[%s%s]'):format(char:lower(), char:upper())
    end)
    return str
end

function split(string, pattern)
    local t = {}
    for i in string:gmatch(pattern) do
        table.insert(t, i)
    end
    return t
end

function round(number, decimals)
    decimals = decimals or 0
    return math.floor(number * 10 ^ decimals + 0.5) / 10 ^ decimals
end

function format(time)
    time = time or 0
    local h = time / 3600
    local m = time % 3600 / 60
    local s = time % 60
    return ('%02d:%02d:%06.03f'):format(h, m, s)
end

function get(property)
    return mp.get_property_native(property)
end

media = {
    frames = 0,
    duration = 0,
    type = nil,
    get_type = function(self)
        local tracks = get('track-list/count')
        for i = 0, tracks - 1 do
            if get('track-list/'..i..'/type') ~= 'video' then goto next end
            if get('track-list/'..i..'/albumart') then self.type = 'audio'
            elseif not get('container-fps') then self.type = 'video'
            elseif self.frames == 1 or (not self.duration or self.duration == 0) then self.type = 'image'
            else self.type = 'video' end
            do return self.type end
            ::next::
        end
        if tracks > 0 then self.type = 'audio' end
        return self.type
    end,
    on_load = function(self)
        self.frames = get('estimated-frame-count')
        self.duration = get('duration')
        self:get_type()
    end,
    playback = {
        frame = 0,
        time = 0,
        progress = 0,
        speed = 0,
        paused = false,
        eof = false,
        prev_pause = false,
        prev_sync = nil,
        play = function(dir, speed)
            mp.command('no-osd set play-dir '..dir)
            mp.command('no-osd set speed '..speed)
            if not step.played_backward or (step.played_backward and (not step.prev_hwdec or step.prev_hwdec == 'no')) then
                mp.commandv('seek', 0, 'relative+exact')
            end
            mp.command('set pause no')
            step.played_backward = dir == 'backward'
        end,
        pause = function(self)
            if self.eof then self.rewind()
            else mp.command('cycle pause') end
        end,
        rewind = function(playlist_pos, pause)
            if playlist_pos then mp.set_property('playlist-pos-1', math.min(playlist_pos, get('playlist-count'))) end
            mp.add_timeout(0.01, function()
                mp.commandv('seek', 0, 'absolute')
                mp.command('set pause '..(pause and 'yes' or 'no'))
            end)
        end,
        on_load = function()
            if o.play_on_load ~= 'auto' then mp.command('set pause '..(o.play_on_load == 'yes' and 'no' or 'yes')) end
        end,
        on_tick = function(self, time)
            self.time = math.max(time or 0, 0)
            if media.type == 'video' then
                if media.frames > 0 then
                    self.frame = math.min(round(media.frames * self.time / media.duration) + 1, media.frames)
                    self.eof = media.frames - self.frame <= 1
                    self.progress = math.floor((self.frame - (self.eof and 0 or 1)) / media.frames * 100)
                else
                    self.frame = 0
                    self.progress = self.eof and 100 or math.floor(self.time / (media.duration or 0) * 100)
                end
            end
        end,
        on_minimize = function(self, minimized)
            if o.pause_minimized == 'yes' or o.pause_minimized == media:get_type() then
                if minimized then
                    self.prev_pause = media.playback.paused
                    mp.command('set pause yes')
                elseif o.play_restored then
                    if not self.prev_pause then mp.command('set pause no') end
                    self.prev_pause = false
                end
            elseif not get('d3d11-flip') or not get('angle-flip') then
                if minimized then
                    local sync = get('video-sync')
                    if sync ~= 'audio' then
                        self.prev_sync = sync
                        mp.command('no-osd set video-sync audio')
                    end
                else
                    if self.prev_sync then mp.command('no-osd set video-sync '..self.prev_sync) end
                    self.prev_sync = nil
                end
            end
        end,
        on_eof = function(self, eof)
            self.eof = eof
            if o.end_rewind ~= 'no' and eof and not step.played then self.rewind(tonumber(o.end_rewind), true) end
        end
    }
}

audio = {
    osd = true,
    user_list = {},
    prev_list = '',
    i = 0,
    valid = true,
    create_user_list = function(self)
        local user_list = split(o.audio_devices, '"([^"]+)"')
        if #user_list == 0 then user_list = split(o.audio_devices, "'([^']+)'") end
        local list = self:get()
        for i, v in ipairs(user_list) do
            table.insert(self.user_list, {})
            for j, _ in ipairs(list) do
                if list[j].description:find(case_insensitive(v)) then
                    self.user_list[i] = list[j]
                    break
                end
            end
        end
    end,
    get = function(self, index)
        local list = index and self.user_list or get('audio-device-list')
        if (index and (index < 1 or index > #list or not list[index].description)) then
            self.valid = false
            list[1].name = 'Invalid device index ('..index..')'
            list[1].description = list[1].name
            index = 1
        end
        return index and list[index] or list
    end,
    set = function(self, index, vol)
        self.valid = true
        local name = self:get(index).name
        if self.valid then
            mp.command('no-osd set audio-device '..name)
            mp.command('no-osd set volume '..vol)
        end
    end,
    list = function(self, list, duration)
        if not self.osd then return end
        local msg = ''
        for i, v in ipairs(list) do
            local symbol = ''
            local vol = ''
            if v.name == get('audio-device') then
                symbol = (get('mute') or get('volume') == 0) and o.audio_muted_symbol or o.audio_symbol
                if o.show_volume then vol = '('..get('volume')..') ' end
            end
            msg = msg..symbol..vol..v.description..'\n'
        end
        osd:set(msg, duration)
    end,
    cycle = function(self, list)
        for _, v in ipairs(self.user_list) do
            if v.name == get('audio-device') then v.volume = get('volume') end
        end
        self.i = u.to_string(list) ~= self.prev_list and 1 or (self.i == #list and 1 or self.i + 1)
        self.prev_list = u.to_string(list)
        local index = 0
        local vol = 0
        for i, v in ipairs(list) do
            local components = split(v, '%d+')
            if i == self.i then
                index = tonumber(components[1])
                vol = tonumber(components[2]) or self.user_list[index].volume or get('volume')
            end
            list[i] = self:get(tonumber(components[1]))
        end
        self:set(index, vol)
        self:list(list, 2)
    end,
    msg_handler = function(self, cmd, ...)
        if cmd == 'list' then
            self.osd = true
            self:list(self:get(), 4)
        elseif cmd == 'cycle' then
            local args = {...}
            if args[1] == 'no-osd' then
                table.remove(args, 1)
                self.osd = false
            else
                self.osd = true
            end
            self:cycle(args)
        end
    end
}

osc = {
    overlay = mp.create_osd_overlay('ass-events'),
    on_pause = function(self, pause)
        if not o.osc_paused then return end
        if pause then
            mp.command('script-message osc-visibility always no-osd')
            mp.add_timeout(0.05, function()
		        self.overlay:update()
		        self.overlay:remove()
	        end)
        else
            mp.command('script-message osc-visibility auto no-osd')
        end
    end
}

fps = {
    interval = 0.5,
    est_fps = get('container-fps') or 0,
    identical_count = 0,
    different_count = 0,
    fps = 0,
    prev_time = 0,
    prev_pos = 0,
    prev_drops = 0,
    prev_vop_dur = 0,
    vop_dur = 0,
    frames = 0,
    drop_delta = 0,
    get_fps = function(self)
        local time = mp.get_time()
        local vop = self.drop_delta > 0 and get('vo-passes') or {fresh = {}}
        for _, v in ipairs(vop.fresh) do self.vop_dur = self.vop_dur + v.last end
        if self.vop_dur ~= self.prev_vop_dur then self.frames = self.frames + 1 end
        self.prev_vop_dur = self.vop_dur
        self.vop_dur = 0
        local time_delta = time - self.prev_time
        if time_delta < self.interval then return end
        local speed = media.playback.speed
        local pos_delta = math.abs(media.playback.time - self.prev_pos)
        local drops = get('frame-drop-count') or 0
        self.drop_delta = drops - self.prev_drops
        local mult = self.interval / time_delta
        local function hot_mess(p_speed)
            return self.drop_delta > 0 and
                self.frames * mult < self.est_fps * p_speed / math.max(self.est_fps / 30, 1) * self.interval * 0.95 and
                round(self.frames * mult, 2) or
                self.est_fps * speed
        end
        local fps = speed > 1 and
            (self.drop_delta > 0 and
            (pos_delta * mult > 2 or pos_delta * mult / self.interval > speed * 0.95 and self.frames * mult > 18 * self.interval) and
            round(self.est_fps * pos_delta * mult / self.interval, 2) or
            hot_mess(1)) or
            hot_mess(speed)
        if fps > 1 then self.fps = fps end
        self.prev_time = time
        self.prev_pos = media.playback.time
        self.prev_drops = drops
        self.frames = 0
    end,
    on_est_fps = function(self, fps)
        if fps and fps > 0 then self.est_fps = fps end
    end,
    on_tick = function(self)
        if osd.show then self:get_fps() end
    end,
    on_speed = function(self)
        self.fps = self.est_fps * media.playback.speed
    end
}

osd = {
    default_msg = nil,
    msg = '',
    show = false,
    toggled = false,
    osd_timer = mp.add_timeout(1e8, function() mp.set_property('osd-msg1', '') end),
    msg_timer = mp.add_timeout(1e8, function() osd.msg = osd.default_msg() end),
    set = function(self, msg, duration)
        if msg or not self.toggled or (self.toggled and self.osd_timer.timeout ~= 1e8) then
            self.osd_timer:kill()
            self.osd_timer.timeout = self.toggled and 1e8 or duration
            self.osd_timer:resume()
            mp.set_property('osd-level', 1)
        end
        if msg then
            self.msg = msg
            self.msg_timer:kill()
            self.msg_timer.timeout = duration
            self.msg_timer:resume()
            mp.add_timeout(0.1, function() mp.set_property('osd-msg1', self.msg) end)
        elseif not self.msg_timer:is_enabled() then
            self.msg = self.default_msg()
            mp.set_property('osd-msg1', self.msg)
        else
            mp.set_property('osd-msg1', self.msg)
        end
    end,
    toggle = function(self)
        self.toggled = not self.toggled
        self.show = self.toggled
        self:set(nil, 0)
    end
}

fullscreen = {
    time_window = 0.5,
    prev_time = 0,
    clicks = 0,
    x = 0,
    cycle = function(self, e)
        if self.clicks == 2 and mp.get_time() - self.prev_time < self.time_window then
            if (e == 'down' and get('fs')) or (e == 'up' and not get('fs')) then
                mp.command('cycle fullscreen')
                self.clicks = 0
            end
        end
    end,
    on_click = function(self)
        if mp.get_time() - self.prev_time > self.time_window then self.clicks = 0 end
        if self.clicks == 1 and mp.get_time() - self.prev_time < self.time_window and math.abs(mp.get_mouse_pos() - self.x) < 5 then
            self.clicks = 2
        else
            self.x = mp.get_mouse_pos()
            self.clicks = 1
        end
        self.prev_time = mp.get_time()
    end,
    on_eof = function(eof)
        if o.end_exit_fs and eof and not step.played then mp.command('set fullscreen no') end
    end,
    key_handler = function(self, e)
        if e.key_name == 'MBTN_LEFT_DBL' then
            osd:set('Bind to MBTN_LEFT. Not MBTN_LEFT_DBL.', 4)
        elseif e.event == 'press' then
            osd:set('Received a key press event.\n'
                ..'Key down/up events are required.\n'
                ..'Make sure nothing else is bound to the key.', 4)
        elseif e.event == 'down' then
            self:on_click()
            self:cycle(e.event)
        elseif e.event == 'up' then
            self:cycle(e.event)
        end
    end
}

step = {
    e_msg = false,
    direction = nil,
    prev_hwdec = nil,
    dir_frame = 0,
    paused = false,
    muted = false,
    prev_speed = 1,
    prev_pos = 0,
    play_speed = 1,
    stepped = false,
    played = false,
    played_backward = false,
    delay_timer = mp.add_timeout(1e8, function() step:play() end),
    hwdec_timer = mp.add_periodic_timer(1 / 60, function()
        if get('play-dir') == 'forward' and not media.playback.paused and get('estimated-frame-number') ~= step.dir_frame then
            mp.command('no-osd set hwdec '..step.prev_hwdec)
            step.hwdec_timer:kill()
            step.prev_hwdec = nil
        end
    end),
    on_dir = function(self, dir)
        if dir == 'forward' and self.prev_hwdec then
            self.dir_frame = get('estimated-frame-number')
            self.hwdec_timer:resume()
        end
    end,
    on_pause = function(self, pause)
        if not pause and self.stepped then
            if (o.step_mute == 'auto' and not self.muted) or (o.step_mute == 'hold' and not self.muted and not self.played) then
                mp.command('no-osd set mute no')
            end
            mp.commandv('seek', 0, 'relative+exact')
            self.stepped = false
        end
    end,
    play = function(self)
        self.played = true
        if o.step_mute == 'auto' and not self.muted then mp.command('no-osd set mute no')
        elseif o.step_mute == 'hold' then mp.command('no-osd set mute yes') end
        if self.direction == 'backward' then mp.command('no-osd set hwdec no') end
        media.playback.play(self.direction, self.play_speed)
    end,
    start = function(self, dir, htp)
        self.direction = dir
        self.prev_hwdec = self.prev_hwdec or get('hwdec')
        self.paused = media.playback.paused
        if not self.stepped then self.muted = get('mute') end
        self.prev_speed = media.playback.speed
        self.prev_pos = media.playback.time
        if o.show_info == 'yes' then osd.show = true end
        if htp then
            self.play_speed = o.htp_speed
            self:play()
        else
            self.play_speed = o.step_rate == 0 and 1 or o.step_rate / fps.est_fps
            self.delay_timer:resume()
            if not self.paused then mp.command('set pause yes') end
            if dir == 'forward' and o.step_method == 'step' then
                if o.step_mute ~= 'no' then mp.command('no-osd set mute yes') end
                mp.command('frame-step')
                self.stepped = true
            elseif (dir == 'backward' and get('time-pos') > 0) or (dir == 'forward' and get('time-pos') < get('duration')) then
                mp.commandv('seek', (dir == 'forward' and 1 or -1) / fps.est_fps, 'relative+exact')
            end
        end
    end,
    stop = function(self, dir, htp)
        self.delay_timer:kill()
        if dir == 'backward' and get('estimated-frame-number') > 0 and not self.played and media.playback.time == self.prev_pos then
            mp.command('frame-back-step')
            print('Backward seek failed. Reverted to backstep.')
        end
        if not htp or not o.htp_keep_dir then mp.command('no-osd set play-dir forward') end
        media.playback.speed = self.prev_speed
        mp.command('no-osd set speed '..media.playback.speed)
        if o.step_mute ~= 'no' and (not self.muted and not (o.step_mute ~= 'no' and self.stepped)) then
            mp.command('no-osd set mute no')
        end
        if (htp and self.paused) or (not htp and ((o.step_method == 'step' and not self.played) or self.played)) then
            mp.command('set pause yes')
        end
        if self.played and not media.playback.eof then mp.commandv('seek', 0, 'relative+exact') end
        self.played = false
        if not osd.toggled then osd.show = false end
    end,
    on_press = function(self, dir, htp)
        local msg = 'Received a key press event.\n'
            ..(htp and 'Key down/up events are required.\n'
            or 'Only single frame steps will work.\n')
            ..'Make sure nothing else is bound to the key.'
        if htp then
            osd:set(msg, 4)
            return
        else
            if not self.e_msg then
                print(msg)
                self.e_msg = true
            end
            self:start(dir, false)
            mp.add_timeout(0.1, function() self:stop(dir, false) end)
        end
    end,
    key_handler = function(self, e, dir, htp)
        if media.type ~= 'video' then return
        elseif e.event == 'press' then self:on_press(dir, htp)
        elseif e.event == 'down' then self:start(dir, htp)
        elseif e.event == 'up' then self:stop(dir, htp) end
    end
}

init()
