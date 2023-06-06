// Taken from Nick Nisi (https://github.com/nicknisi/dotfiles/blob/c9496e8c7c5d7638a7817cea0ec020207235db60/applescripts/tunes.js)

let output = "";
if (Application("Music").running()) {
  const track = Application("Music").currentTrack;
  const artist = track.artist();
  const title = track.name();
  output = `${title} - ${artist}`.substr(0, 50);
} else if (Application("Spotify").running()) {
  const track = Application("Spotify").currentTrack;
  const artist = track.artist();
  const title = track.name();
  output = `${title} - ${artist}`.substr(0, 50);
}

output;
