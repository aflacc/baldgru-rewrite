package states.stages;

import substates.GameOverSubstate;
import states.stages.objects.*;

// GEN Z IS TRYING TO CANCEL SONIC DUMAU?
class Maudade extends BaseStage
{
	// mau-dah-gee
	var lyricsText:FlxText;
	var lyricsBack:FlxSprite;

	// this songs memory usage scares the fuck out of me BEEF WHAT THE FUCK WHY IS EVERYTHING SO MASSIVE

	override function create()
	{
		GameOverSubstate.loopSoundName = "maudade-gameover-loop";
		GameOverSubstate.endSoundName = 'maudade-gameover-end';

		var bg:BGSprite = new BGSprite('stages/maudade/SDsky', -560, -280, 0.1, 0.1);
		add(bg);
		var clouds:BGSprite = new BGSprite('stages/maudade/SDclouds', -340, -60, 0.15, 0.15);
		add(clouds);
		var ocean:BGSprite = new BGSprite('stages/maudade/SDOcean', -660, 250, 0.2, 0.1);
		add(ocean);
		var beach:BGSprite = new BGSprite('stages/maudade/SDbg2', -670, 270, 0.35, 0.15, ["Symbol 16"], true);
		add(beach);
		var islands:BGSprite = new BGSprite('stages/maudade/SDbg1', -670, 160, 0.2, 0.1, ["Symbol 11"], true);
		add(islands);
		var backFog:BGSprite = new BGSprite('stages/maudade/BackFog', -550, 80, 0.25, 0.15);
		backFog.alpha = 0.85;
		add(backFog);
		var mountain:BGSprite = new BGSprite('stages/maudade/SDmountain', 50, -120, 0.35, 0.15, ["Symbol 12"], true);
		add(mountain);
		var floor:BGSprite = new BGSprite('stages/maudade/SDfloor', -920, 845, 1, 0.8);
		floor.scale.set(1.25, 1.25);
		add(floor);
	}

	var introBlack:FlxSprite;
	var introBanner:FlxSprite;
	var introRio:FlxSprite;
	var introZone:FlxSprite;
	var introAct:FlxSprite;

	var fog:BGSprite;

	override function createPost()
	{
		fog = new BGSprite('stages/maudade/fog', -1200, 140, 1, 0.8, ["Symbol 1"], true);
		addBehindBF(fog);
		// Use this function to layer things above characters!
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

		introBlack = new FlxSprite(-100, -100).makeGraphic(FlxG.width + 200, FlxG.height + 200, FlxColor.BLACK);
		introBlack.screenCenter();
		introBlack.cameras = [game.camHUD];
		add(introBlack);

		introBanner = new FlxSprite(240, -800).loadGraphic(Paths.image("stages/maudade/sonicIntro/sonic3"));
		introBanner.scale.set(0.8, 0.8);
		introBanner.antialiasing = ClientPrefs.data.antialiasing;
		introBanner.cameras = [game.camHUD];
		add(introBanner);

		introRio = new FlxSprite(1280, 300).loadGraphic(Paths.image("stages/maudade/sonicIntro/rio_de_janeiro"));
		introRio.antialiasing = ClientPrefs.data.antialiasing;
		introRio.scale.set(0.7, 0.7);
		introRio.cameras = [game.camHUD];
		add(introRio);

		introZone = new FlxSprite(1662, 410).loadGraphic(Paths.image("stages/maudade/sonicIntro/zone"));
		introZone.antialiasing = ClientPrefs.data.antialiasing;
		introZone.scale.set(0.7, 0.7);
		introZone.cameras = [game.camHUD];
		add(introZone);

		introAct = new FlxSprite(1722, 520).loadGraphic(Paths.image("stages/maudade/sonicIntro/act1"));
		introAct.antialiasing = ClientPrefs.data.antialiasing;
		introAct.scale.set(0.7, 0.7);
		introAct.cameras = [game.camHUD];
		add(introAct);

		if (game.dad != null)
		{
		}
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
				// do this early so the intro card doesnt lag
				if (PlayState.deathCounter > 0)
				{
					PlayState.instance.triggerEvent("Change Character", "bf", "sonic_dumb", 0);
				}
			case TWO: // num 1
				FlxTween.tween(introBanner, {y: -120}, 0.25, {
					onComplete: function(_)
					{
						FlxTween.tween(introRio, {x: 480}, 0.25, {
							onComplete: function(_)
							{
								FlxTween.tween(introAct, {x: 922}, 0.25);
							}
						});
					}
				});
			case ONE: // num 2
			case GO: // num 3
				game.dad.idleSuffix = "-alt";
				game.dad.recalculateDanceIdle();
				game.dad.dance();
			case START: // num 4
				// new FlxTimer().start(Conductor.crochet * 0.001, function(_)
				// {
				FlxTween.tween(introBlack, {alpha: 0}, 0.5);
				FlxTween.tween(introBanner, {x: -800}, 0.2);
				FlxTween.tween(introRio, {x: 1280}, 0.2);
				FlxTween.tween(introZone, {x: 1662}, 0.2);
				FlxTween.tween(introAct, {x: 1722}, 0.2);
				// });
		}
	}

	override function stepHit()
	{
		switch (curStep)
		{
			case 54: // Throw up (if died once)
				if (PlayState.deathCounter > 0)
				{
					// This h.. doesnt work.. weird but like it works if i put the event back into the json so its all good!: )
					PlayState.instance.triggerEvent("Play Animation", "bf", "vomit", 4821.42857142857);
				}
		}
	}

	override function beatHit()
	{
		switch (curBeat)
		{
			case 70:
				FlxTween.tween(fog, {alpha: 0}, 2.5);
			case 28: // swithc to sonic (If died at least once)

				if (PlayState.deathCounter > 0)
				{
					PlayState.instance.triggerEvent("Change Character", "bf", "sonic", 10000);
				}
			case 684:
				var dead:FlxSprite = new FlxSprite().makeGraphic(FlxG.width + 800, FlxG.height + 800, FlxColor.BLACK);
				dead.screenCenter();
				dead.scrollFactor.set(0, 0);
				dead.alpha = 0;
				addBehindDad(dead);
				FlxTween.tween(dead, {alpha: 1}, Conductor.crochet * 0.002);
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch (eventName)
		{
			case "Lyrics":
				lyricsBack.visible = (value1 != "");
				lyricsText.text = value1;
                lyricsText.applyMarkup(value1,
                [
                    new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "*")
                ]
            );
				lyricsText.screenCenter(X);
				lyricsBack.scale.set(lyricsText.width + 16, lyricsText.height + 16);
				lyricsBack.setPosition(lyricsText.x + (lyricsText.width / 2), lyricsText.y + (lyricsText.height / 2));
		}
	}
}
