-- Copyright (C) 2026 Hub contributors
-- This program is free software under the terms of the GNU General Public
-- License version 2 or later.

ardour {
	["type"] = "SessionInit",
	name = "Hub: 8D Spatial Mix",
	description = [[A spatial-mix layout for binaural headphone production. Create the surround master and enable binaural rendering in Ardour before automating 3D movement.]]
}

function factory () return function ()
	local mono_tracks = {
		"Lead Vocal - Center",
		"Lead Vocal - Orbit",
		"Backing Vocal - Orbit",
		"Ad-libs - Orbit",
		"Drums - Front",
		"Percussion - Orbit",
		"Bass - Center",
		"Synths - Orbit",
		"Atmosphere - Height",
		"Transitions - Orbit",
	}

	for _, name in ipairs (mono_tracks) do
		Session:new_audio_track (
			1, 2, ARDOUR.RouteGroup(), 1, name,
			ARDOUR.PresentationInfo.max_order,
			ARDOUR.TrackMode.Normal, true)
	end

	local stereo_tracks = { "FX Returns - Stereo", "Reference - Stereo", "8D Print - Stereo" }
	for _, name in ipairs (stereo_tracks) do
		Session:new_audio_track (
			2, 2, ARDOUR.RouteGroup(), 1, name,
			ARDOUR.PresentationInfo.max_order,
			ARDOUR.TrackMode.Normal, true)
	end

	Session:save_state ("")
end end
