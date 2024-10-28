---@diagnostic disable: undefined-global, lowercase-global
overlayResize = 0.55

function setFrame(tag,type,value)
    setProperty(tag..'._frame.frame.'..type,value)
end
function onCreate()
    if songName == "Jingle Bald" then
        close();
    end
    if (string.lower(songName) == "yolked") then
        close()
    end
end
function onCreatePost()
    if songName == "Jingle Bald" then
        close();
    end
    
    if (string.lower(songName) == "yolked") then
        close()
    end
    makeLuaSprite("timeBar", "customHealthbars/timeBar/time_background", 0.0, 0.0)
    setObjectCamera("timeBar", "camHUD")
    scaleObject("timeBar", overlayResize, overlayResize)
    screenCenter("timeBar", 'x')
    setProperty("timeBar.x", getProperty("timeBar.x")-6.5)
    setProperty("timeBar.y", getProperty("timeBar.y")+18.5)
    addLuaSprite("timeBar")

    defaultWidth = getProperty("timeBar.width")

    makeLuaSprite("timeBarFill", "customHealthbars/timeBar/time_barWhite", 0.0, 0.0)
    setObjectCamera("timeBarFill", "camHUD")
    scaleObject("timeBarFill", overlayResize, overlayResize)
    screenCenter("timeBarFill", 'x')
    setProperty("timeBarFill.x", getProperty("timeBar.x"))
    setProperty("timeBarFill.y", getProperty("timeBar.y"))
    addLuaSprite("timeBarFill")

    makeLuaText("timeText", 'BITCH', screenWidth, 0, 550)
    setTextAlignment("timeText", 'center')
    setTextSize("timeText", 40)
    screenCenter("timeText", 'x')
    setProperty("timeText.x", getProperty("timeText.x") - 6.5)
    setProperty("timeText.y", getProperty("timeText.y") - 528)
    setTextBorder("timeText", 3, '2d3541')
    addLuaText("timeText")
    setObjectOrder('timeText', 20, false);

    makeLuaSprite("timeBarOverlay", "customHealthbars/timeBar/time_bar", 0.0, 0.0)
    setObjectCamera("timeBarOverlay", "camHUD")
    scaleObject("timeBarOverlay", overlayResize, overlayResize)
    screenCenter("timeBarOverlay", 'x')
    setProperty("timeBarOverlay.x", getProperty("timeBarOverlay.x") + 5)
    setProperty("timeBarOverlay.y", getProperty("timeBarOverlay.y") - 10)
    addLuaSprite("timeBarOverlay")
end

function onUpdate()
    setFrame("timeBarFill", "width", defaultWidth * getProperty('songPercent') *1.81)
    setTextString("timeText", getProperty("timeTxt.text"))
end