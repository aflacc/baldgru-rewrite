function onCreatePost()
	makeLuaSprite("SAD",(luaSpriteMakeGraphic),-1000,-640)
    makeGraphic("SAD", 2400,2400, '000000')
    setBlendMode("SAD", "multiply")
    setProperty('SAD.alpha', 0)
    addLuaSprite("SAD", true)
	setObjectOrder('SAD', 16)
end

function onUpdate(elapsed)
	-- The Actual Code --
	setProperty('dadGroup.x', getProperty('dadGroup.x') + 2 * math.cos(curDecBeat / 4 * math.pi) * elapsed * 10)
	setProperty('dadGroup.y', getProperty('dadGroup.y') + 1.25 * math.sin(curDecBeat / 4 * math.pi) * elapsed * 20)
	
	-- This Fixes The Camera Bug Issue --
	-- Change the true to false if you see this appearing on BF side and not the opponent Side --
	if mustHitSection == true then
		setProperty('camFollow.x', getProperty('camFollow.x'))
		setProperty('camFollow.y', getProperty('camFollow.y'))
	else
		setProperty('camFollow.x', getProperty('camFollow.x') + 2 * math.cos(curDecBeat / 4 * math.pi) * elapsed * 10)
		setProperty('camFollow.y', getProperty('camFollow.y') + 1.25 * math.sin(curDecBeat / 4 * math.pi) * elapsed * 20)
	end
end

function onBeatHit()
    if curBeat == 68 then
        doTweenAlpha('fogFade', 'fog', 0, 4);
    end

	if curBeat == 684 then
		doTweenAlpha("shimmy", "SAD", 1, 1.5, linear)
		setObjectOrder('dadGroup', 64)
		doTweenAlpha("shimmyBRUH!", "camHUD", 0, 1.5, linear)
	end
end