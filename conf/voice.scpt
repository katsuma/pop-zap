tell application "iTunes"
  set added_track to add "$voice_file_path"
  play added_track with once
  delay 10
  pause
  set loc to (get location of added_track)
  delete added_track

  tell application "Finder"
    delete loc
  end tell
end tell