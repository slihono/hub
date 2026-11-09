-- Copyright (C) 2026 Hub contributors
-- This program is free software under the terms of the GNU General Public
-- License version 2 or later.

ardour {
	["type"] = "SessionInit",
	name = "Hub: Podcast",
	description = [[A spoken-word session with four mono microphone tracks and a stereo Playback track for music, calls, or references. All tracks route to the stereo master bus.]]
}

function factory () return function ()
	local microphones = { "Host 1", "Host 2", "Guest 1", "Guest 2" }
	for _, name in ipairs (microphones) do
		Session:new_audio_track (
			1, 2, ARDOUR.RouteGroup(), 1, name,
			ARDOUR.PresentationInfo.max_order,
			ARDOUR.TrackMode.Normal, true)
	end
	Session:new_audio_track (
		2, 2, ARDOUR.RouteGroup(), 1, "Playback",
		ARDOUR.PresentationInfo.max_order,
		ARDOUR.TrackMode.Normal, true)
	Session:save_state ("")
end end
