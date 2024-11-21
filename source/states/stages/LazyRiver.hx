package states.stages;

import flixel.util.FlxSort;
import flixel.addons.display.FlxBackdrop;
import substates.GameOverSubstate;
import states.stages.objects.*;

class LazyRiver extends BaseStage
{
	// The original stage code for this was actually disgusting. I'm sorry but thats just the truth.
	// var passerby:FlxSprite;
	var passerbyGrp:FlxSpriteGroup; // Layering purposes

	// SUMMER!!!
	var lyricsText:FlxText;
	var lyricsBack:FlxSprite;

	override function create()
	{
		for (i in 0...passerbys.length)
		{
			activePasserbys[i] = false;
		}
		GameOverSubstate.loopSoundName = "lazyriver-gameover-loop";
		GameOverSubstate.endSoundName = 'lazyriver-gameover-end';

		var bg:BGSprite = new BGSprite('stages/lazyriver/MC_Sky', -830, -200, 0.1, 0.1);
		bg.scale.set(1, 1.1);
		add(bg);

		var mg2:BGSprite = new BGSprite("stages/lazyriver/MC_middleground2", 280, 75, 0.3, 0.3);
		mg2.velocity.set(-2, 0); // I don't even think this works
		add(mg2);

		var mg:BGSprite = new BGSprite("stages/lazyriver/MC_middleground", 280, 75, 0.35, 0.35);
		mg.velocity.set(-4, 0);
		add(mg);
		var clouds:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/MC_clouds"), X, 400, 0);
		clouds.scrollFactor.set(0.4, 0.4);
		clouds.velocity.set(-5, 0);
		clouds.antialiasing = ClientPrefs.data.antialiasing;
		clouds.y = -250;
		add(clouds);

		var rocks:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/mc_foreground_rocks"), X, -18);
		rocks.y = 280;
		rocks.scrollFactor.set(0.9, 0.9);
		rocks.velocity.set(-60, 0);
		rocks.antialiasing = ClientPrefs.data.antialiasing;
		add(rocks);

		var water:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/mc_foreground_water"), X, -18);
		water.y = 480;
		water.scrollFactor.set(1, 1);
		water.velocity.set(-60, 0);
		water.antialiasing = ClientPrefs.data.antialiasing;
		add(water);

		passerbyGrp = new FlxSpriteGroup();
		add(passerbyGrp);
	}

	override function createPost()
	{
		var waterRocks:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/mc_waterRocks"), X, -18);
		waterRocks.y = 900;
		waterRocks.scrollFactor.set(1.1, 1.1);
		waterRocks.velocity.set(-60, 0);
		waterRocks.antialiasing = ClientPrefs.data.antialiasing;
		add(waterRocks);

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

	var sine:Float = 0;
	var passerbySine:Float = 0;

	override function update(elapsed:Float)
	{
		passerbySine = passerbySine + elapsed;
		passerbyGrp.forEach(function(passerby:FlxSprite)
		{
			if (passerby != null)
			{
				// passerby.offset.set(0, Math.sin(passerbySine) * 4);
				// This will fix the weird floating visual where everyone matches
				passerby.offset.set(0, Math.sin(passerby.x / 50) * 4);
				if ((passerby.ID > 0 && passerby.x <= -500 - passerby.width) || (passerby.ID < 0 && passerby.x >= FlxG.width * 2))
				{
					trace("destroying");
					var eyedee = Math.abs(passerby.ID) - 1;
					activePasserbys[Std.int(eyedee)] = false;
					passerby.destroy();
					passerbyGrp.remove(passerby, true);
					timeoutBeats += 4; // just cuz sometimes it
				}
			}
		});

		sine = (sine + elapsed) % (Math.PI * 4);

		if (game.dad != null)
			game.dad.y = 100 - 170 + (Math.sin(sine) * 8);
	}

	var passerbys:Array<String> = ["baldgru", "beef", "harvester", "george", "aflac", "trav"];
	var activePasserbys:Array<Bool> = [];

	var timeoutBeats = 4;

	override function beatHit()
	{
		if (timeoutBeats <= 0)
		{
			var passerby = new FlxSprite();
			// I'm really good at naming variables..
			var active = [for (i in 0...passerbys.length) if (activePasserbys[i]) i];
			// butt = FlxG.random.getObject(passerbys, [for (i in 0...passerbys.length) activePasserbys[i] ? 1 : 0]);
			if (active.length != passerbys.length)
			{
				var butt = FlxG.random.int(0, passerbys.length - 1, active);

				if (!activePasserbys[butt])
				{
					var boob = passerbys[butt];
					// var boob = FlxG.random.getObject(passerbys, [for (i in 0...passerbys.length) activePasserbys[i] ? 1 : 0]);
					//	var boob = butt; // haha
					trace('boo! its the ' + boob); // funny
					passerby.frames = Paths.getSparrowAtlas("stages/lazyriver/passerbys/" + boob);
					passerby.animation.addByPrefix("loop", boob, 24, true);
					passerby.animation.play('loop', true);
					passerby.ID = butt + 1; // I hate the number 0
					activePasserbys[butt] = true;
					switch (boob)
					{
						case "baldgru" | "trav": // characters going up the river
							passerby.x = -700 - passerby.width;
							passerby.velocity.set(40, 0);
							passerby.ID *= -1;
						case "george": // characters going down the river (not just floating)
							passerby.x = FlxG.width * 2;
							passerby.velocity.set(-75, 0);
						// passerby.ID *= 1;
						default: // characters floating by (stationary)
							passerby.x = FlxG.width * 2;
							passerby.velocity.set(-60, 0);
							// passerby.ID = 0;
					}
					passerby.antialiasing = ClientPrefs.data.antialiasing;
					passerby.origin.set(passerby.width / 2, passerby.height);
					passerby.y = 400 + FlxG.random.int(0, 25);

					// offsets
					switch (boob)
					{
						case "beef":
							passerby.y += 0;
						case 'aflac':
							passerby.y -= 140;
						case 'trav':
							passerby.y -= 170;
						case 'george':
							passerby.y -= 210;
						case 'harvester':
							passerby.y -= 140;
					}
					passerbyGrp.add(passerby);

					// sort them vertically, this is I think the only code from the scrapped v2 code (v2 IS NOT CANCELLED) that im gonna use lol
					passerbyGrp.sort(FlxSort.byY, FlxSort.DESCENDING);
					timeoutBeats = FlxG.random.int(40, 64);

					trace([for (i in 0...passerbys.length) if (activePasserbys[i]) i]);
				}
				else
				{
					trace("cant spawn " + passerbys[butt] + "! it exists!");
				}
			}
			else
			{
				trace("STOPP FIGHTING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			}
		}
		else
		{
			timeoutBeats--;
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
