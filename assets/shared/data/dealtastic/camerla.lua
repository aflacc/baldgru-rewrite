function onSectionHit()
	if curSection >= 17 then
	if not mustHitSection then
		doTweenZoom('camz','camGame',1.5,1,'sineInOut')
		setProperty('defaultCamZoom',1.5)
	else
		doTweenZoom('cambf','camGame',0.85,1,'sineInOut')
		setProperty('defaultCamZoom',0.85)
	end
	elseif curSection == 17 then
		doTweenAlpha('camHUD', 1, 0.65, 'linear')
	end
end