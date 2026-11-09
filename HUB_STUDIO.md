# Hub Studio session starters

Hub builds on Ardour and adds four studio session starters to the
New Session template list:

- **Hub: Vocal Recording** — Lead Vocal, Double, Ad-libs, and Guide.
- **Hub: Podcast** — four mono microphone tracks and a stereo Playback track.
- **Hub: Live Band** — a labeled multitrack band layout and a stereo Playback
  track.
- **Hub: Stem Mixing** — stereo Drums, Percussion, Bass, Music, Effects, Lead
  Vocal, Backing Vocals, and Reference tracks.
- **Hub: 8D Spatial Mix** — mono source tracks for spatial movement, plus stereo
  FX Returns, Reference, and 8D Print tracks.

Each microphone or instrument input is a mono track routed to the stereo master
bus. Playback and stem tracks are stereo. The starters create tracks only:
they do not arm recording, choose an audio device, load plug-ins, or assume a
particular input numbering. Select the correct interface ports in Ardour after
creating a session, then arm only the tracks you intend to record.

These are Lua `SessionInit` scripts in `Ardour-9.7.0/share/scripts`. Ardour
discovers that script directory and lists session-init scripts as implicit
templates in the New Session dialog. Build and install Hub as usual; no extra
plugin or external service is required.

## 8D headphone mix workflow

The 8D starter creates a track layout; it does not apply an effect or automate
movement by itself. Ardour includes a surround master, 3D panner controls, and
binaural render controls. In the Mixer, enable **Surround Master** (shown as
**Atmos Surround Master** in Atmos builds), then use each source track's
surround panner to automate its position over time. Enable binaural rendering
for the sources intended to move, and monitor on headphones while checking the
stereo result. Keep lead vocal and bass centered unless the arrangement calls
for movement; automate ad-libs, percussion, synths, and transitions more freely.

Use **8D Print - Stereo** as a destination for a rendered stereo check or final
print, and keep **Reference - Stereo** unprocessed for comparison. A session
with moving panners is not by itself proof of binaural output: confirm the
surround master and binaural render settings in the built Ardour application
and listen to the exported stereo file on headphones.
