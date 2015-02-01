# Choose copy destination
do shell script "ls /Volumes/"
set _Result to the paragraphs of result
set theVolumeTemp to (choose from list _Result with prompt "Choose Volume:" without empty selection allowed)
if theVolumeTemp is false then return
set theVolume to theVolumeTemp

tell application "iTunes"
	
	with timeout of 300 seconds
		
		activate
		
		set listOfAlbumNames to {}
		set itunesLibrary to a reference to (get view of front window)
		set totalNumberOfTracks to (count of every track in itunesLibrary)
		
	end timeout
	
end tell

set progress total steps to totalNumberOfTracks

repeat with i from 1 to totalNumberOfTracks
	tell application "iTunes"
		set currentTrack to (a reference to track i of itunesLibrary)
		
		set currentAlbumName to (currentTrack's album as string)
		set currentAlbumArtist to (currentTrack's album artist as string)
		set currentTrackName to (currentTrack's name as string)
	end tell
	
	# Need an album name, otherwise we can't create a folder
	if currentAlbumName is not "" then
		
		tell application "iTunes"
			# Revert to track artist if album artist not set
			if currentAlbumArtist is "" then
				set currentAlbumArtist to (currentTrack's artist as string)
			end if
			
			set displayName to (currentAlbumName & " - " & currentAlbumArtist)
			try
				set fileLocation to (currentTrack's location as string)
			on error errorMessage
				set fileLocation to ""
			end try
		end tell
		
		if fileLocation is not "" then
			set displayName to (replaceText(":", "-", displayName) as string)
			set destinationAlbumDirectory to ((theVolume & ":" & displayName) as string)
			
			set progress description to ("Processing track " & currentTrackName & " - " & displayName)
			
			tell application "Finder"
				try
					make new folder at theVolume with properties {name:displayName}
				end try
				
				try
					duplicate file fileLocation to folder destinationAlbumDirectory without replacing
				end try
			end tell
		end if
		
	end if
	
	set progress completed steps to i
end repeat

display dialog "Successfully copied albums" default button "OK"

on replaceText(find, replace, subject)
	set prevTIDs to text item delimiters of AppleScript
	set text item delimiters of AppleScript to find
	set subject to text items of subject
	
	set text item delimiters of AppleScript to replace
	set subject to "" & subject
	set text item delimiters of AppleScript to prevTIDs
	
	return subject
end replaceText
