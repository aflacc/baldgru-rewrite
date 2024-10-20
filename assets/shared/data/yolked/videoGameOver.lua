playVideo = true;

function onGameOverStart()
	if not allowedEnd then
		if playVideo then --Video cutscene plays first
			startVideo('geremykills');
			playVideo = false;
			allowedEnd = true;
			return Function_Stop; --Prevents the song from starting naturally
		end
	end
	return Function_Continue; --Played video and dialogue, now the song can start normally
end