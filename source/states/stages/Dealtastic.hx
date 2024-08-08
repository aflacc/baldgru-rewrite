package states.stages;

import substates.GameOverSubstate;
import backend.BaseStage;
import states.stages.objects.*;

class Dealtastic extends BaseStage
{
	// the rush is starting, code is less rewritten and more just ported from the existing code..
	// I'm being rushed...
	// You don't rush perfection!
	override function create()
	{
		GameOverSubstate.loopSoundName = "baldgru-gameover-loop";
		GameOverSubstate.endSoundName = 'baldgru-gameover-end';

		var sky:BGSprite = new BGSprite("stages/dealtastic/DMsky", -350, -500, 0.1, 0.1);
		sky.scale.set(1.5, 1.5);
		add(sky);
		var shutters:BGSprite = new BGSprite("stages/dealtastic/DMShutters", -380, -470, 0.5, 0.5);
		shutters.scale.set(0.8 * 1.5, 0.8 * 1.5);
		add(shutters);
		var stage:BGSprite = new BGSprite("stages/dealtastic/DMStage", 0, 500, 1, 1);
		stage.scale.set(1, 1);
		add(stage);
		var borda:BGSprite = new BGSprite("stages/dealtastic/borda", -610, 230, 1, 1, ["acrtion bubble"], true);
		borda.scale.set(1.5, 1.5);
		add(borda);
	}

	override function createPost()
	{
	}

	override function update(elapsed:Float)
	{
		// Code here
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

	override function beatHit()
	{
		// Code here
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
			case "My Event":
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
