---@diagnostic disable: undefined-global, lowercase-global

--script by yumii (hehe#6969) 
------options

local color = "FFFFFF" --color of the text in hex
local title = "markiflier"
local composer = "trav" --composers name
local artist = "beefstarchjello" --composers name
local charter = "trav" --composers name
local icon = "keoiki" --image for icon (image must be in credits/ICON and image size must be atleast 150x150 or else it will look ugly)
local card = "conbi" --image for card bg/heading (image needs to be 400x50px and it should be in headings/CARDheading.)

------end of options

function onCreatePost()

  makeAnimatedLuaSprite('cTV', 'ingametv', -230, -75)
  addAnimationByPrefix('cTV', 'play', 'credit ingame', 24, false)
  setProperty('cTV.scale.y', .6)
  setProperty('cTV.scale.x', .6);
  setObjectCamera('cTV', 'camHUD')
  setProperty('cTV.alpha', 0)
  addLuaSprite('cTV', true)

  makeLuaSprite('iconComp', 'creditStuff/'..composer..'-title', 5, 130)
  setProperty('iconComp.scale.y', 0.65)
  setProperty('iconComp.scale.x', 0.65);
  setObjectCamera('iconComp', 'camHUD')
  setProperty('iconComp.alpha', 0)
  addLuaSprite('iconComp', true)

  makeLuaText('composerText', title..' By:',0,-5,0)
  setTextSize('composerText', 24)
  setProperty('composerText.y', 150)
  setProperty('composerText.x', 30)
  setProperty('composerText.alpha', 0)
  setTextColor('composerText',''..color..'');
  addLuaText('composerText', true)

  makeLuaSprite('iconArt', 'creditStuff/'..artist..'-title', 5, 130)
  setProperty('iconArt.scale.y', 0.65)
  setProperty('iconArt.scale.x', 0.65);
  setObjectCamera('iconArt', 'camHUD')
  setProperty('iconArt.alpha', 0)
  addLuaSprite('iconArt', true)

  makeLuaText('artistText', 'Artist:',-60,-5,0)
  setTextSize('artistText', 24)
  setProperty('artistText.y', 150)
  setProperty('artistText.x', 30)
  setProperty('artistText.alpha', 0)
  setTextColor('artistText',''..color..'');
  addLuaText('artistText', true)

  makeLuaSprite('iconChart', 'creditStuff/'..charter..'-title', 5, 130)
  setProperty('iconChart.scale.y', 0.65)
  setProperty('iconChart.scale.x', 0.65);
  setObjectCamera('iconChart', 'camHUD')
  setProperty('iconChart.alpha', 0)
  addLuaSprite('iconChart', true)

  makeLuaText('charterText', 'Charter:',-60,-5,0)
  setTextSize('charterText', 24)
  setProperty('charterText.y', 150)
  setProperty('charterText.x', 30)
  setProperty('charterText.alpha', 0)
  setTextColor('charterText',''..color..'');
  addLuaText('charterText', true)

  runTimer('TvLoad', 1)

  function onTimerCompleted(tag)
      if tag == "TvLoad" then
        doTweenAlpha('things3', 'cTV', 1, .3, 'linear');
        objectPlayAnimation('cTV', 'play', true)
        runTimer('Composer', .5)
      end

      if tag == "Composer" then
        doTweenAlpha('things1', 'composerText', 1, .5, 'linear');
        doTweenAlpha('things2', 'iconComp', 1, .5, 'linear');
        runTimer('Artist', 1.8)
      end

      if tag == "Artist" then
        doTweenAlpha('things3', 'composerText', 0, .2, 'linear');
        doTweenAlpha('things4', 'iconComp', 0, .2, 'linear');

        doTweenAlpha('things1', 'artistText', 1, .5, 'linear');
        doTweenAlpha('things2', 'iconArt', 1, .5, 'linear');
        runTimer('Charter', 1.8)
      end

      if tag == "Charter" then
        doTweenAlpha('things3', 'artistText', 0, .2, 'linear');
        doTweenAlpha('things4', 'iconArt', 0, .2, 'linear');

        doTweenAlpha('things1', 'charterText', 1, .5, 'linear');
        doTweenAlpha('things2', 'iconChart', 1, .5, 'linear');
        runTimer('End', 1.3)
      end

      if tag == "End" then
        doTweenAlpha('things3', 'charterText', 0, .2, 'linear');
        doTweenAlpha('things4', 'iconChart', 0, .2, 'linear');
        runTimer('FadeOut', 0.35)
      end

      if tag == "FadeOut" then
        doTweenAlpha('things3', 'cTV', 0, .1, 'linear');
      end
  end


end