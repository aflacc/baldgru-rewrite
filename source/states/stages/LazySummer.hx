package states.stages;

import substates.GameOverSubstate;
import flixel.addons.display.FlxBackdrop;
import states.stages.objects.*;

// Lazy River Stage with summer mode
class LazySummer extends BaseStage
{
	// If you're moving your stage from PlayState to a stage file,
	// you might have to rename some variables if they're missing, for example: camZooming -> game.camZooming
	// SUMMER!!!
	var lyricsText:FlxText;
	var lyricsBack:FlxSprite;

	override function create()
	{
		
		GameOverSubstate.loopSoundName = "lazyriver-gameover-loop";
		GameOverSubstate.endSoundName = 'lazyriver-gameover-end';
		
		var bg:BGSprite = new BGSprite('stages/lazyriver/MC_Sky', -830, -200, 0.1, 0.1);
		bg.scale.set(1, 1.1);
		add(bg);

		var mg2:BGSprite = new BGSprite("stages/lazyriver/MC_middleground2", 280, 75, 0.3, 0.3);
		// mg2.velocity.set(-2, 0); // I don't even think this works
		add(mg2);

		var mg:BGSprite = new BGSprite("stages/lazyriver/MC_middleground", 280, 75, 0.35, 0.35);
		// mg.velocity.set(-4, 0);
		add(mg);
		var clouds:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/MC_clouds"), X, 400, 0);
		clouds.scrollFactor.set(0.4, 0.4);
		clouds.velocity.set(-8, 0);
		//clouds can have a little bit of scroll
		clouds.antialiasing = ClientPrefs.data.antialiasing;
		clouds.y = -250;
		add(clouds);

		var rocks:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/mc_foreground_rocks"), X, -18);
		rocks.y = 240;
		// rocks.scrollFactor.set(0.9, 0.9);
		rocks.antialiasing = ClientPrefs.data.antialiasing;
		add(rocks);

		var wow:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/drained"), X, -28);
		wow.y = 443;
		wow.antialiasing = ClientPrefs.data.antialiasing;
		add(wow);
		var gfDead:FlxSprite = new FlxSprite(886,1015);
		gfDead.scale.set(1.4,1.4);
		gfDead.frames = Paths.getSparrowAtlas("stages/lazyriver/deflated");
		gfDead.animation.addByPrefix("loop","gf idle copy",24,true);
		gfDead.animation.play("loop");
		gfDead.antialiasing = ClientPrefs.data.antialiasing;
		add(gfDead);

		var martello:FlxSprite = new FlxSprite(-300,120);
		martello.frames = Paths.getSparrowAtlas("stages/lazyriver/martello");
		martello.animation.addByPrefix("fire","Symbol 18 instance 1",24,true);
		martello.animation.play("fire");
		martello.antialiasing = ClientPrefs.data.antialiasing;
		martello.scale.set(1.5,1.5); // Why
		add(martello);
		
	}

	override function createPost()
	{


		game.camGame.zoom = 2;
		defaultCamZoom = 1.2;
		PlayState.instance.camZooming = true;
		game.dadGroup.visible = false;
		game.gfGroup.visible = false;
		
		game.dad.y += 100;
		game.boyfriendCameraOffset[1] -= 100;

		game.dadGroup.x -= 200;
		game.boyfriend.y += 300; // camera purposes!

		PlayState.instance.moveCamera(false); // i think this will reposition the camera correctly?

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

	override function beatHit() {
		if (PlayState.SONG.notes[curSection].mustHitSection) {
			defaultCamZoom = curBeat > 42 ? 0.8 : 1.2;
		} else {
			defaultCamZoom = 0.65;
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch (eventName)
		{
			case "Lyrics":
				lyricsBack.visible = true;
				if (value1 == "")
				{
					FlxTween.tween(lyricsText, {alpha: 0}, 1.5);
					FlxTween.tween(lyricsBack, {alpha: 0}, 1.5);
				}
				else
				{
					FlxTween.cancelTweensOf(lyricsText);
					FlxTween.cancelTweensOf(lyricsBack);
					lyricsText.alpha = 1;
					lyricsBack.alpha = 0.5;
					lyricsText.text = value1;
					lyricsText.applyMarkup(value1, [new FlxTextFormatMarkerPair(new FlxTextFormat(0x1CA4FF), "*")]);
					lyricsText.screenCenter(X);
					lyricsBack.scale.set(lyricsText.width + 16, lyricsText.height + 16);
					lyricsBack.setPosition(lyricsText.x + (lyricsText.width / 2), lyricsText.y + (lyricsText.height / 2));
				}
		}
	}
}
