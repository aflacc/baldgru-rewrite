package states.stages;

import substates.GameOverSubstate;
import backend.BaseStage;
import states.stages.objects.*;

class Dealtastic extends BaseStage
{
	// the rush is starting, code is less rewritten and more just ported from the existing code..
	// I'm being rushed...
	// You don't rush perfection!
	var lyricsText:FlxText;
	var lyricsBack:FlxSprite;

	var dealionsGrp:FlxSpriteGroup;
	var dealionsActive:Array<Bool> = [];

	override function create()
	{
		GameOverSubstate.loopSoundName = "baldgru-gameover-loop";
		GameOverSubstate.endSoundName = 'baldgru-gameover-end';

		var suffix:String = "";

		if (ClientPrefs.data.summerMode){
			suffix = "-summer";
		}

		var sky:BGSprite = new BGSprite("stages/dealtastic"+suffix+"/DMsky", -350, -500, 0.1, 0.1);
		sky.scale.set(1.5, 1.5);
		add(sky);
		var shutters:BGSprite = new BGSprite("stages/dealtastic"+suffix+"/DMShutters", -380, -470, 0.5, 0.5);
		shutters.scale.set(0.8 * 1.5, 0.8 * 1.5);
		add(shutters);
		var stage:BGSprite = new BGSprite("stages/dealtastic"+suffix+"/DMStage", 0, 500, 1, 1);
		stage.scale.set(1, 1);
		add(stage);
		var borda:BGSprite = new BGSprite("stages/dealtastic"+suffix+"/borda", -610, 230, 1, 1, ["acrtion bubble"], true);
		borda.scale.set(1.5, 1.5);
		add(borda);
	}

	override function createPost()
	{
		game.boyfriendGroup.visible = false;
		game.gf.y += 600;
		if (ClientPrefs.data.distractions)
		{
			dealionsGrp = new FlxSpriteGroup();
			dealionsGrp.cameras = [game.camHUD];
			add(dealionsGrp);

			for (i in 1...5)
			{
				var dealion:FlxSprite = new FlxSprite();
				dealion.ID = i;
				dealion.frames = Paths.getSparrowAtlas("stages/dealtastic/dealion/dealion" + i);
				dealion.animation.addByPrefix("enter", "dealion" + i + " enter", 24, false);
				dealion.animation.addByPrefix("talk", "dealion" + i + " talk", 24, true);
				dealion.animation.addByPrefix("leave", "dealion" + i + " leave", 24, false);
				dealion.antialiasing = ClientPrefs.data.antialiasing;
				dealion.animation.play("talk", true);
				switch (i)
				{ // If you think about it switch cases are really just fancy if...elif... chains
					case 1:
						// floor left
						dealion.setPosition(106, 441);
					case 2:
						// floor right
						dealion.setPosition(822, 364);
					case 3:
						// wall
						dealion.setPosition(-48, 32);
					case 4:
						// get out of my face
						dealion.screenCenter();
						dealion.y += 54;
				}
				dealionsActive[i] = false;
				dealion.animation.play("leave");
				dealion.animation.finish(); // las t frame is invisible
				dealionsGrp.add(dealion);
			}
		}

		lyricsBack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		lyricsBack.visible = false;
		lyricsBack.alpha = 0.5;
		lyricsBack.cameras = [game.camHUD];
		add(lyricsBack);
		lyricsText = new FlxText(0, FlxG.height * 0.7, 0, "", 32);
		lyricsText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		lyricsText.borderSize = 1.25;
		lyricsText.screenCenter(X);
		lyricsText.cameras = [game.camHUD];
		add(lyricsText);
	}

	override function update(elapsed:Float)
	{
		if (ClientPrefs.data.distractions)
		{
			dealionsGrp.forEach(function(dealion:FlxSprite)
			{
				if (dealion.animation.curAnim.name == "enter" && dealion.animation.finished)
				{
					dealion.animation.play("talk", true);
					new FlxTimer().start(FlxG.random.float(2, 8), function(_)
					{
						dealion.animation.play("leave", true);
						dealionsActive[dealion.ID] = false;
						delayion += 8;
					});
				}
				if (dealion.animation.curAnim.name == "leave" && dealion.animation.finished)
				{
					dealion.visible = false;
				}
				else
				{
					dealion.visible = true;
				}
			});
		}
	}

	override function countdownTick(count:backend.BaseStage.Countdown, num:Int)
	{
		switch (count)
		{
			case THREE: // num 0
			case TWO: // num 1
			case ONE: // num 2
			case GO: // num 3
			case START: // num 4
		}
	}

	// Steps, Beats and Sections:
	//    curStep, curDecStep
	//    curBeat, curDecBeat
	//    curSection
	override function stepHit()
	{
		// Code here
	}

	var delayion:Int = 128;

	override function beatHit()
	{
		if (ClientPrefs.data.distractions)
		{
			if (delayion <= 0)
			{
				if (FlxG.random.bool(25))
				{ // this should allow for the chance for some *small* extra randomness
					var exclude = [for (i in 0...dealionsGrp.members.length) if (dealionsActive[i]) i];
					if (exclude.length != dealionsGrp.members.length)
					{
						var dee = FlxG.random.int(0, dealionsGrp.members.length - 1, exclude);
						dealionsActive[dee] = true;
						var thelion = dealionsGrp.members[dee];
						thelion.ID = dee;
						thelion.animation.play("enter");
						delayion += FlxG.random.int(3, 32);
					}
					else
					{
						trace("NO!!!");
						delayion += 4;
					}
				}
			}
			else
			{
				delayion--;
			}
		}
		// Code here
		switch (curBeat)
		{
			case 269:
				FlxTween.tween(game.gf, {y: game.gf.y -= 600}, 4);
		}
	}

	override function sectionHit()
	{
		// Code here
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if (paused)
		{
			// timer.active = true;
			// tween.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if (paused)
		{
			// timer.active = false;
			// tween.active = false;
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch (eventName)
		{
			case "Play Animation":
				game.boyfriendGroup.visible = true;
			case "Lyrics":
				lyricsBack.visible = (value1 != "");
				lyricsText.text = value1;
				lyricsText.applyMarkup(value1, [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "*")]);
				lyricsText.screenCenter(X);
				lyricsBack.scale.set(lyricsText.width + 16, lyricsText.height + 16);
				lyricsBack.setPosition(lyricsText.x + (lyricsText.width / 2), lyricsText.y + (lyricsText.height / 2));
		}
	}

	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch (event.event)
		{
			case "My Event":
				// precacheImage('myImage') //preloads images/myImage.png
				// precacheSound('mySound') //preloads sounds/mySound.ogg
				// precacheMusic('myMusic') //preloads music/myMusic.ogg
		}
	}

	override function eventPushedUnique(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events where its values affect what assets should be preloaded
		switch (event.event)
		{
			case "My Event":
				switch (event.value1)
				{
					// If value 1 is "blah blah", it will preload these assets:
					case 'blah blah':
						// precacheImage('myImageOne') //preloads images/myImageOne.png
						// precacheSound('mySoundOne') //preloads sounds/mySoundOne.ogg
						// precacheMusic('myMusicOne') //preloads music/myMusicOne.ogg

						// If value 1 is "coolswag", it will preload these assets:
					case 'coolswag':
						// precacheImage('myImageTwo') //preloads images/myImageTwo.png
						// precacheSound('mySoundTwo') //preloads sounds/mySoundTwo.ogg
						// precacheMusic('myMusicTwo') //preloads music/myMusicTwo.ogg

						// If value 1 is not "blah blah" or "coolswag", it will preload these assets:
					default:
						// precacheImage('myImageThree') //preloads images/myImageThree.png
						// precacheSound('mySoundThree') //preloads sounds/mySoundThree.ogg
						// precacheMusic('myMusicThree') //preloads music/myMusicThree.ogg
				}
		}
	}
}
