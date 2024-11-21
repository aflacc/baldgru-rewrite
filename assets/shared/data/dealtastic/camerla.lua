function onSectionHit()
	if curSection >= 17 then
	if not mustHitSection then
		doTweenZoom('camz','camGame',1,1,'sineInOut')
		setProperty('defaultCamZoom',1)
	else
		doTweenZoom('cambf','camGame',0.85,1,'sineInOut')
		setProperty('defaultCamZoom',0.85)
	end
end
end