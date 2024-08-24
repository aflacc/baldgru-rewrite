---@diagnostic disable: undefined-global, lowercase-global
--Made my spectradev on discord
--Modified by Trav

-- {songName , {p1IconX,p1IconY} , {p2IconX,p2IconY} , {healthbarXdownscroll,healthbarYdownscroll} , {healthbarXupscroll,healthbarYupscroll} , {innerBarX,innerBarY} , framerate , flipped}
local BarData = {
    { 'Booyah', --song name
        { 0, 0 }, --p1 icon shit
        { 0, 0 }, --p2 icon shit
        { 0, 0 }, --healthcare downscroll shit
        { 0, 0 }, --same as above but upscroll
        { 0, 0 }, --inner bar shit
        24,    --framerate
        false  --if its flipped or not
    }
}
function onCreate()   --change values inside of here if youve changed the base healthbar
    if songName == "Jingle Bald" then
        close();
    end
    iconX1 = 400      --player 1 icon x offset
    iconY1 = -83      --player 1 icon y offset
    iconX2 = -550     --player 2 icon x offset
    iconY2 = -83      --player 2 icon y offset
    downscrollX = 0   --healthbar downscroll x offset
    downscrollY = -50 --healthbar downscroll y offset
    upscrollX = 0     --healthbar upscroll x offset
    upscrollY = -68   --healthbar upscroll y offset
    barScale = 0.65
    glowScale = 1
    innerBarX = 0  --sex
    innerBarY = -5 --you get it
    innerBarScaleX = 0.1
    innerBarScaleY = 0.1
    iconScale = 0.5
    fps = 24        --standard fnf framerate
    flipped = false --flipped healthbar
    setSettings()
end

--you shouldnt have to change anything below here
function onCreatePost()
    setProperty("timeBar.visible",false)
    setProperty("timeTxt.visible",false)
    if checkFileExists("images/customHealthbars/" .. string.lower(songName) .. "/player.png", false) then --better image detection! :3
        barImageDirectory = string.lower(songName) .. '/'
    else
        barImageDirectory = ""
    end
    --TV backgrounds

    makeLuaSprite("leftTvFill", "customHealthbars/left_tv_fill", 0.0, 0.0)
    scaleObject("leftTvFill", .7, .7)
    addLuaSprite("leftTvFill", false)
    setObjectCamera("leftTvFill", "camHUD")
    setProperty("leftTvFill.color", getColorFromHex(dadColor()))

    makeLuaSprite("rightTvFill", "customHealthbars/right_tv_fill", 0.0, 0.0)
    scaleObject("rightTvFill", .7, .7)
    addLuaSprite("rightTvFill", false)
    setObjectCamera("rightTvFill", "camHUD")
    setProperty("rightTvFill.color", getColorFromHex(bfColor()))

    makeLuaSprite("healthbarUnder", "customHealthbars/" .. barImageDirectory .. 'player', 0.0, 0.0) --healthbar bottom (player if not flipped)
    --scaleObject("healthbarUnder", innerBarScaleX, innerBarScaleY)
    addLuaSprite("healthbarUnder", false)
    setObjectCamera("healthbarUnder", "camHUD")
    setObjectOrder("healthbarUnder", getObjectOrder("healthbackground") + 1)
    setProperty("healthbarUnder.color", getColorFromHex("FF0000"))
    makeLuaSprite("healthbackground", "customHealthbars/" .. barImageDirectory .. 'healthbarBG', 0.0, 0.0) --BG
    scaleObject("healthbackground", barScale, barScale)
    addLuaSprite("healthbackground", false)
    setObjectCamera("healthbackground", "camHUD")
    --setObjectOrder("healthbackground", getObjectOrder("healthBar"))
    setProperty("healthBar.alpha", 0)

    makeLuaSprite("healthbarOver", "customHealthbars/" .. barImageDirectory .. 'opponent', 0.0, 0.0) --healthbar top (opponent if not flipped)
    --scaleObject("healthbarOver", innerBarScaleX, innerBarScaleY)
    addLuaSprite("healthbarOver", false)
    setObjectCamera("healthbarOver", "camHUD")
    setObjectOrder("healthbarOver", getObjectOrder("healthbarUnder") + 1)

    --glow
    setObjectOrder("iconP1", getObjectOrder("healthbackground"))
    setObjectOrder("iconP2", getObjectOrder("healthbackground"))

    if flipped then
        makeLuaSprite("flasher", "customHealthbars/" .. barImageDirectory .. 'opponent', 0.0, 0.0)
    else
        makeLuaSprite("flasher", "customHealthbars/" .. barImageDirectory .. 'player', 0.0, 0.0)
    end
    addLuaSprite("flasher", false)
    setObjectCamera("flasher", "camHUD")
    setObjectOrder("flasher", getObjectOrder("healthbarOver") + 0.5)
    setBlendMode("flasher", "screen")
    --setters time
    screenCenter("healthbackground", 'x')
    --setProperty("healthbackground.y", getProperty("healthbackground.y")-140)
    if downscroll then
        setProperty('healthbackground.y', 60)
        setRel('healthbackground.x', downscrollX)
        setRel('healthbackground.y', downscrollY)

        setRel('leftTvFill.x', 98)
        setRel('leftTvFill.y', 15)
        setRel('rightTvFill.x', 1048)
        setRel('rightTvFill.y', 15)
    else
        setProperty('healthbackground.y', 720 - 105)
        setRel('healthbackground.x', upscrollX)
        setRel('healthbackground.y', upscrollY)

        setRel('leftTvFill.x', 98)
        setRel('leftTvFill.y', 550)
        setRel('rightTvFill.x', 1048)
        setRel('rightTvFill.y', 550)
    end
    setProperty("healthbarUnder.x",
        getProperty("healthbackground.x") + getMid('healthbackground.width') - getMid('healthbarUnder.width') + innerBarX)
    setProperty("healthbarUnder.y",
        getProperty("healthbackground.y") + getMid('healthbackground.height') - getMid('healthbarUnder.height') +
        innerBarY)
    setProperty("healthbarOver.x", getProperty("healthbarUnder.x"))
    setProperty("healthbarOver.y", getProperty("healthbarUnder.y"))
    setProperty("flasher.x", getProperty("healthbarOver.x"))
    setProperty("flasher.y", getProperty("healthbarOver.y"))
    defaultWidth = getProperty("healthbarOver.width")
    if flipped then
        setProperty('iconP1.flipX', true)
        setProperty('iconP2.flipX', true)
        setFrame('healthbarOver', 'width', defaultWidth * (getHealth() / 2))
        setProperty("healthbarUnder.color", getColorFromHex(dadColor()))
        setProperty("healthbarOver.color", getColorFromHex(bfColor()))
    else
        setFrame('healthbarOver', 'width', defaultWidth - (defaultWidth * (getHealth() / 2)))
        setProperty("healthbarUnder.color", getColorFromHex(bfColor()))
        setProperty("healthbarOver.color", getColorFromHex(dadColor()))
    end
    originalP1height = getProperty("iconP1.height")
    originalP2height = getProperty("iconP2.height")
    setProperty("healthBar.visible", false)
end

local timeFunny = 10
function onUpdatePost(elapsed)
    --setProperty("iconP2.y", getProperty('healthbarOver.y')+(getProperty("iconP2.height")/10)-getMid(originalP2height)+iconY2)
    --setProperty("iconP1.y", getProperty('healthbarOver.y')+(getProperty("iconP1.height")/10)-getMid(originalP1height)+iconY1)
    if flipped then
        setProperty('flasher.color', getProperty("healthbarOver.color"))
        if getFrame('healthbarOver', 'width') > defaultWidth - 2 then
            setProperty("healthbarUnder.alpha", 0)
            setProperty("flasher.visible", true)
        else
            setProperty("healthbarUnder.alpha", 1)
            setProperty("flasher.visible", false)
        end

        --setProperty("iconP2.x", iconX2)
        --setProperty("iconP1.x", iconX1)
        --setProperty("iconP2.y", iconY2)
        --setProperty("iconP1.y", iconY1)

        --setProperty("iconP2.x", getProperty('healthbarOver.x')+getFrame('healthbarOver','width')+((getProperty("iconP2.width")/2)-100)+iconX2)
        --setProperty("iconP1.x", getProperty('healthbarOver.x')+getFrame('healthbarOver','width')-((getProperty("iconP1.width")/2)+60)+iconX1)

        if getFrame('healthbarOver', 'width') > (defaultWidth * (getHealth() / 2)) - 2 and getFrame('healthbarOver', 'width') < (defaultWidth * (getHealth() / 2)) + 2 then
        elseif getFrame('healthbarOver', 'width') > (defaultWidth * (getHealth() / 2)) then
            setFrame('healthbarOver', 'width',
                (getFrame('healthbarOver', 'width') - (getFrame('healthbarOver', 'width') - ((defaultWidth * (getHealth() / 2)))) / timeFunny))
        elseif getFrame('healthbarOver', 'width') < (defaultWidth * (getHealth() / 2)) then
            setFrame('healthbarOver', 'width',
                (getFrame('healthbarOver', 'width') + ((defaultWidth * (getHealth() / 2)) - getFrame('healthbarOver', 'width')) / timeFunny))
        end
    else
        setProperty('flasher.color', getProperty("healthbarUnder.color"))
        if getFrame('healthbarOver', 'width') < 2 then
            setProperty("healthbarOver.alpha", 0)
            setProperty("flasher.visible", true)
        else
            setProperty("healthbarOver.alpha", 1)
            setProperty("flasher.visible", false)
        end
        setProperty("iconP2.x", getProperty("healthbackground.x") + getMid('healthbackground.width') + iconX2)
        setProperty("iconP1.x", getProperty("healthbackground.x") + getMid('healthbackground.width') + iconX1)
        setProperty("iconP2.y", getProperty("healthbackground.y") + getMid('healthbackground.height') + iconY2)
        setProperty("iconP1.y", getProperty("healthbackground.y") + getMid('healthbackground.height') + iconY1)

        --setProperty("iconP2.x", getProperty('healthbarOver.x')+getFrame('healthbarOver','width')+((getProperty("iconP2.width")/2)-100)+iconX2)
        --setProperty("iconP1.x", getProperty('healthbarOver.x')+getFrame('healthbarOver','width')-((getProperty("iconP1.width")/2)+60)+iconX1)
        if getFrame('healthbarOver', 'width') > defaultWidth - (defaultWidth * (getHealth() / 2)) - 2 and getFrame('healthbarOver', 'width') < defaultWidth - (defaultWidth * (getHealth() / 2)) + 2 then
        elseif getFrame('healthbarOver', 'width') > defaultWidth - (defaultWidth * (getHealth() / 2)) then
            setFrame('healthbarOver', 'width',
                (getFrame('healthbarOver', 'width') - (getFrame('healthbarOver', 'width') - (defaultWidth - (defaultWidth * (getHealth() / 2)))) / timeFunny))
        elseif getFrame('healthbarOver', 'width') < defaultWidth - (defaultWidth * (getHealth() / 2)) then
            setFrame('healthbarOver', 'width',
                (getFrame('healthbarOver', 'width') + (defaultWidth - (defaultWidth * (getHealth() / 2)) - getFrame('healthbarOver', 'width')) / timeFunny))
        end
    end
end

function onBeatHit()
    if curBeat % 2 == 0 then -- note to myself: the % sign is essentialy like division but returns the remainder instead of the product -- Why do you need a comment for modulo, also mod is goated, thanks for using it
        setProperty("iconP1.angle", 5)
        setProperty("iconP2.angle", -5)
    else
        setProperty("iconP1.angle", -5)
        setProperty("iconP2.angle", 5)
    end
    for i = 1, 2 do
        doTweenAngle("return" .. i, "iconP" .. i, 0, 0.5 / playbackRate, "linear")
    end
    setProperty("flasher.alpha", 1)
    doTweenAlpha("returnFlash", "flasher", 0, 0.5 / playbackRate, "linear")
end

function onEvent(eventName, value1, value2)
    if eventName == 'Change Character' then
        if flipped then
            doTweenColor('changeColor1', 'healthbarUnder', dadColor(), 0.25, 'expoOut')
            doTweenColor('changeColor2', 'healthbarOver', bfColor(), 0.25, 'expoOut')
        else
            doTweenColor('changeColor1', 'healthbarUnder', bfColor(), 0.25, 'expoOut')
            doTweenColor('changeColor2', 'healthbarOver', dadColor(), 0.25, 'expoOut')
        end
    end
end

--helping functions--

function getFrame(tag, type)
    return getProperty(tag .. '._frame.frame.' .. type)
end

function setFrame(tag, type, value)
    setProperty(tag .. '._frame.frame.' .. type, value)
end

function getMid(tag)
    return getProperty(tag) / 2
end

function setRel(tag, value)
    setProperty(tag, getProperty(tag) + value)
end

function setSettings() --add more stuff to this if youve modified the script with more functions
    for i in pairs(BarData) do
        if BarData[i][1] == songName then
            iconX1 = BarData[i][2][1]
            iconY1 = BarData[i][2][2]
            iconX2 = BarData[i][3][1]
            iconY2 = BarData[i][3][2]
            downscrollX = BarData[i][4][1]
            downscrollY = BarData[i][4][2]
            upscrollX = BarData[i][5][1]
            upscrollY = BarData[i][5][1]
            innerBarX = BarData[i][6][1]
            innerBarY = BarData[i][6][2]
            fps = BarData[i][7]
            flipped = BarData[i][8]
        end
    end
end

function dadColor()
    return rgbToHex(getProperty('dad.healthColorArray'))
end

function bfColor()
    return rgbToHex(getProperty('boyfriend.healthColorArray'))
end

function rgbToHex(rgb) -- https://www.codegrepper.com/code-examples/lua/rgb+to+hex+lua
    return string.format('%02x%02x%02x', math.floor(rgb[1]), math.floor(rgb[2]), math.floor(rgb[3]))
end
