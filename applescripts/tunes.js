let output = "";
if (Application("Music").running()) {
  try {
    const track = Application("Music").currentTrack;
    const artist = track.artist();
    const title = track.name();
    output = `${title} - ${artist}`.substr(0, 50);
  } catch (e) {
    // Handle case where track info can't be accessed
  }
}

output;
