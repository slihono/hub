-- Copyright (C) 2026 Hub contributors
-- This program is free software under the terms of the GNU General Public
-- License version 2 or later.

ardour {
	["type"] = "SessionInit",
	name = "Hub: Vocal Recording",
	description = [[A ready-to-record vocal session with separate Lead, Double, Ad-libs, and Guide tracks. Each track is mono input and routes to the stereo master bus.]]
}

function factory () return function ()
	local names = { "Lead Vocal", "Double", "Ad-libs", "Guide" }
	for _, name in ipairs (names) do
		Session:new_audio_track (
			1, 2, ARDOUR.RouteGroup(), 1, name,
			ARDOUR.PresentationInfo.max_order,
			ARDOUR.TrackMode.Normal, true)
	end
	Session:save_state ("")
end end
