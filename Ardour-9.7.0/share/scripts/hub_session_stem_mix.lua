-- Copyright (C) 2026 Hub contributors
-- This program is free software under the terms of the GNU General Public
-- License version 2 or later.

ardour {
	["type"] = "SessionInit",
	name = "Hub: Stem Mixing",
	description = [[A stereo stem-mixing layout with separate Drums, Percussion, Bass, Music, Effects, Lead Vocal, Backing Vocals, and Reference tracks. All tracks route to the stereo master bus.]]
}

function factory () return function ()
	local names = {
		"Drums", "Percussion", "Bass", "Music", "Effects",
		"Lead Vocal", "Backing Vocals", "Reference"
	}
	for _, name in ipairs (names) do
		Session:new_audio_track (
			2, 2, ARDOUR.RouteGroup(), 1, name,
			ARDOUR.PresentationInfo.max_order,
			ARDOUR.TrackMode.Normal, true)
	end
	Session:save_state ("")
end end
