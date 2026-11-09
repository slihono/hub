-- Copyright (C) 2026 Hub contributors
-- This program is free software under the terms of the GNU General Public
-- License version 2 or later.

ardour {
	["type"] = "SessionInit",
	name = "Hub: Live Band",
	description = [[A multitrack band recording layout with labeled mono inputs for drums, bass, guitars, keys, and vocals, plus a stereo Playback reference track. All tracks route to the stereo master bus.]]
}

function factory () return function ()
	local names = {
		"Kick", "Snare", "Hi-Hat", "Tom 1", "Tom 2", "Floor Tom",
		"Overhead L", "Overhead R", "Room", "Bass DI", "Guitar 1",
		"Guitar 2", "Keys L", "Keys R", "Lead Vocal", "Backing Vocal"
	}
	for _, name in ipairs (names) do
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
