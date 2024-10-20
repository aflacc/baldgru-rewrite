playVideo = true;

function onEndSong()
	if not allowedEnd and isStoryMode then
		if playVideo then --Video cutscene plays first
			startVideo('outtro'); --Play video file from "videos/" folder
			playVideo = false;
			allowedEnd = true;
			return Function_Stop; --Prevents the song from starting naturally
		end
	end
	return Function_Continue; --Played video and dialogue, now the song can start normally
end