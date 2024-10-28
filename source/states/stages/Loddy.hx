package states.stages;

import states.stages.objects.*;
import objects.Note;
import flixel.ui.FlxBar;
import objects.Character;
import objects.HealthIcon;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import backend.ClientPrefs;
import backend.MusicBeatState;
// import flixel.ui.FlxBar; // it has sub stuff i need.
// import flixel.ui.FlxBarFillDirection; // it has sub stuff i need.
import Math;
import flixel.math.FlxRect;

// AAHHH!!
// import flixel.util.FlxStringUtil;
using StringTools;

class LoddyStage extends BaseStage
{
	// hi im aflac and i love hx files. theyre so awesome.
	var lodcon:HealthIcon;

	var displHealth:Float = 1.0;

	var hBar:FlxBar;

	var snog:FlxBackdrop;
	var snog2:FlxBackdrop;
	var snogSine:Float = 0;

	var sky:FlxSprite;
	var colorTweenDidntWorkOops:FlxSprite;

	var leftHealth:FlxSprite;
	var rightHealth:FlxSprite;
	var barWidth:Float;
	var healthBar:FlxSprite;
	var heart:FlxSprite;
	var heartbeatCooldown:Float = 0;

	var bg:FlxSprite;
	var bg1:FlxSprite; // im dumb
	var cold:FlxSprite;

	override function create()
	{
		// triggered when the hscript file is started, some variables weren't created yet

		sky = new FlxSprite().makeGraphic(1280, 720, 0xFF7CCCEC);
		sky.scrollFactor.set(0, 0);
		add(sky);

		colorTweenDidntWorkOops = new FlxSprite().makeGraphic(1280, 720, 0xFFE7EBEC);
		colorTweenDidntWorkOops.alpha = 0;
		colorTweenDidntWorkOops.scrollFactor.set(0, 0);
		add(colorTweenDidntWorkOops);

		// clouds has no references after being added, so it's just created here.
		var clouds:FlxBackdrop = new FlxBackdrop(Paths.image("stages/loddy/clouddys"));
		clouds.y += 30;
		clouds.velocity.set(-10, 0);
		clouds.scrollFactor.set(0.2, 0.8);
		add(clouds);

		bg = new FlxSprite().loadGraphic(Paths.image("stages/loddy/floddrest"));
		// addBehindDad(bg); // hate you game

		var dabeeg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("stages/loddy/trees"));
		dabeeg.y -= 350;
		dabeeg.x -= 100;
		dabeeg.scrollFactor.set(0.5, 0.5);
		add(dabeeg);
		var dabeeg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("stages/loddy/bench"));
		dabeeg.y += 175;
		dabeeg.scrollFactor.set(0.8, 0.8);
		add(dabeeg);
		var dabeeg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("stages/loddy/foreground"));
		dabeeg.scrollFactor.set(1, 1);
		add(dabeeg);

		bg1 = new FlxSprite().loadGraphic(Paths.image("stages/loddy/floddrest"));
		bg1.frames = Paths.getSparrowAtlas("stages/loddy/inside");
		bg1.animation.addByPrefix("loop", "bg fireplace instance", 24, true);
		bg1.animation.play("loop");
		// bg1.visible = false;
		add(bg1); // hate you game

		healthBar = new FlxSprite();
		healthBar.frames = Paths.getSparrowAtlas("stages/loddy/heartbar");
		healthBar.animation.addByPrefix("t", "Symbol 8 instance", 0, true);
		healthBar.cameras = [game.camHUD];
		healthBar.screenCenter(X);
		healthBar.y = ClientPrefs.data.downScroll ? 40 : FlxG.height - healthBar.height - 10;

		leftHealth = new FlxSprite().loadGraphic(Paths.image("stages/loddy/heartbar_half"));
		barWidth = leftHealth.width;
		leftHealth.setPosition(60, healthBar.y + 10);
		leftHealth.clipRect = new FlxRect(0, 0, Std.int(barWidth / 4), Std.int(leftHealth.height));
		leftHealth.cameras = [game.camHUD];

		rightHealth = new FlxSprite().loadGraphic(Paths.image("stages/loddy/heartbar_half"));
		rightHealth.flipX = true;
		rightHealth.setPosition(FlxG.width - rightHealth.width - 60, healthBar.y + 10);
		rightHealth.clipRect = new FlxRect(0, 0, Std.int(leftHealth.width / 4), Std.int(leftHealth.height));
		rightHealth.cameras = [game.camHUD];

		add(leftHealth);
		add(rightHealth);
		add(healthBar);

		heart = new FlxSprite();
		heart.frames = Paths.getSparrowAtlas("stages/loddy/healtheart");
		heart.animation.addByPrefix("beat", "heart beating instance", 24, false);
		heart.animation.play("beat");
		heart.cameras = [game.camHUD];
		heart.screenCenter(X);
		heart.centerOrigin();
		heart.y = healthBar.y - heart.height / 2;
		add(heart);

		lodcon = new HealthIcon("loddy", false);
		lodcon.cameras = [game.camHUD];
		add(lodcon);

		cold = new FlxSprite().loadGraphic(Paths.image("stages/loddy/iceyy"));
		cold.cameras = [game.camHUD];
		cold.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		cold.screenCenter();
		cold.alpha = 0;

		add(cold);

		PlayState.instance.gfGroup.visible = false;

		//if (isStoryMode)
		//	{
				switch (songName.replace(" ","-"))
				{
					case "jingle-bald":
						// if(!seenCutscene) PlayState.instance.startVideo("cough");
						if (!seenCutscene)
							setStartCallback(videoCutscene.bind('lovewins'));
				}
		//	}
	}

	function placeFollow(x, y)
	{
		game.camFollow.x = game.dad.x + game.dad.cameraPosition[0] - 150 + x + (FlxG.width / 2);
		game.camFollow.y = game.dad.y + game.dad.cameraPosition[1] + y + (FlxG.height / 2);
	}

	override function createPost()
	{
		PlayState.isCameraOnForcedPos = true;
		leftHealth.color = FlxColor.fromRGB(game.dad.healthColorArray[0], game.dad.healthColorArray[1], game.dad.healthColorArray[2]);

		rightHealth.color = FlxColor.fromRGB(PlayState.instance.boyfriend.healthColorArray[0], PlayState.instance.boyfriend.healthColorArray[1],
			PlayState.instance.boyfriend.healthColorArray[2]);

		game.camGame.scroll.set(game.dad.x + game.dad.cameraPosition[0] - 150, game.dad.y + game.dad.cameraPosition[1]);
		// end of "create"
		PlayState.instance.healthBar.visible = false;
		PlayState.instance.iconP1.visible = false;
		PlayState.instance.iconP2.visible = false;
		PlayState.instance.boyfriend.cameras = [game.camHUD];
		PlayState.instance.boyfriend.x = 50;
		PlayState.instance.boyfriend.y = 50;

		game.iconP1.y -= 0;
		game.iconP2.y -= 0;

		snog = new FlxBackdrop(Paths.image("stages/loddy/snog"));
		snog.velocity.set(-25, 50);
		snog.alpha = 0;
		add(snog);
		snog2 = new FlxBackdrop(Paths.image("stages/loddy/snog"));
		snog2.x += 400;
		snog2.y += 382;
		snog2.velocity.set(-35, 40);
		snog2.alpha = 0;
		snog2.cameras = [game.camHUD];
		add(snog2);
	}

	// Gameplay/Song interactions
	function onSectionHit()
	{
		// triggered after it goes to the next section
	}

	function doCutscene(num:Int, howlong:Float)
	{
		var cutsc:FlxSprite = new FlxSprite().loadGraphic(Paths.image(switch (num)
		{
			case 1: "stages/loddy/imliterallycrying/loddy_moment";
			case 2: "stages/loddy/imliterallycrying/loddy_moment2";
			default: "stages/loddy/imliterallycrying/loddy_momentback";
		}));
		cutsc.cameras = [game.camOther];
		cutsc.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		cutsc.updateHitbox();
		// if (curBeat == 197)
		//    {
		cutsc.alpha = 0;
		FlxTween.tween(cutsc, {alpha: 1}, howlong);
		//    }
		add(cutsc);
	}

	override function beatHit()
	{
		// triggered 4 times per section
		if (PlayState.SONG.song == "Jingle Bald")
		{
			if (curBeat > 68)
			{
				bg1.visible = false;
			}
			switch (curBeat)
			{
				case 64:
					game.camZooming = false;
				case 68:
					if (ClientPrefs.data.flashing)
					{
						PlayState.instance.camGame.flash(FlxColor.WHITE, 1.5, null, true);
					}
					FlxTween.tween(cold, {alpha: 1}, 6);
					bg1.visible = false;
					placeFollow(0, 0);
					game.camGame.scroll.set(5, 10);
				case 132:
					// snog.velocity.set(-50,100);
					FlxTween.tween(snog, {alpha: 1}, 2);
					FlxTween.tween(colorTweenDidntWorkOops, {alpha: 1}, 2);
				// FlxTween.color(sky,2.0,0xFF7CCCEC,0xFF37EBEC);
				case 164:
					FlxTween.tween(snog2, {alpha: 0.7}, 4);
				case 197:
					doCutscene(0, 3);
				case 214:
					doCutscene(1, 1);
				case 222:
					doCutscene(2, 1);

				case 228:
					var fadetoblackbutnotactuallyafadeiliedtoyou:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height), 0xFF000000);
					fadetoblackbutnotactuallyafadeiliedtoyou.cameras = [game.camOther];
					add(fadetoblackbutnotactuallyafadeiliedtoyou);
			}
			if (curBeat >= 69)
			{
				game.camGame.zoom += curBeat % 2 == 0 ? 0.04 : 0.06;
				game.camHUD.zoom += curBeat % 2 == 0 ? 0.01 : 0.02;
			}
		}
	}

	override function stepHit()
	{
		// triggered 16 times per section
	}

	override function update(elapsed:Float)
	{
		snogSine = (snogSine + elapsed) % 90;
		// trace("he"); // snog.velocity.set(FlxMath.lerp(snog.velocity.x,-25,20*elapsed),FlxMath.lerp(snog.velocity.y,50,20*elapsed));
		snog.velocity.set(-25 + (Math.sin(snogSine) * 4), 50);
		displHealth = FlxMath.lerp(displHealth, game.health, 9 * elapsed);
		PlayState.instance.boyfriend.angle = FlxMath.lerp(PlayState.instance.boyfriend.angle, 0, 9 * elapsed);

		// actually horrible way to do it but the code was for some reason not letting me just edit the .width
		// leftHealth.clipRect.width = Std.int(barWidth * (1 - (health / 2)));
		leftHealth.clipRect = new FlxRect(0, 0, Std.int(barWidth * (displHealth / 2)), Std.int(leftHealth.height));
		rightHealth.clipRect = new FlxRect(0, 0, Std.int(barWidth * (displHealth / 2)), Std.int(leftHealth.height));
		if (PlayState.instance.boyfriend.animation.curAnim.name == "idle")
		{
			placeFollow(0, 0);
		}
		game.camFollow.x = FlxMath.lerp(game.camFollow.x, game.dad.x + game.dad.cameraPosition[0] - 150 + (FlxG.width / 2), 6 * elapsed);
		game.camFollow.y = FlxMath.lerp(game.camFollow.y, game.dad.y + game.dad.cameraPosition[1] + (FlxG.height / 2), 6 * elapsed);
		if (heart != null)
		{
			if (heartbeatCooldown > 0)
			{
				heartbeatCooldown -= 12 * (elapsed * displHealth);
			}
			if (heartbeatCooldown <= 0)
			{
				heartbeatCooldown = 24;
				heart.animation.play("beat", true);
			}
			// heart.animation.curAnim.frameRate = 24 * (displHealth / 2);
			// start of "update", some variables weren't updated yet
		}
	}

	override function updatePost(elapsed:Float)
	{
		if (PlayState.instance.boyfriend != null)
		{
			rightHealth.color = PlayState.instance.boyfriend.animation.curAnim.name.endsWith("miss") == true ? 0xFF998da2 : FlxColor.fromRGB(PlayState.instance.boyfriend.healthColorArray[0],
				PlayState.instance.boyfriend.healthColorArray[1],
				PlayState.instance.boyfriend.healthColorArray[2]);
		}
		// end of "update"
		PlayState.instance.boyfriend.setPosition(FlxG.width - PlayState.instance.boyfriend.width - 100 - ((healthBar.width / 3) * (displHealth / 2)),
			game.iconP1.y - 25);
		lodcon.setPosition(lodcon.width + 140 + ((healthBar.width / 3) * ((displHealth - 1) / 2)), game.iconP2.y - 15);
		lodcon.animation.curAnim.curFrame = (PlayState.instance.healthBar.percent > 80) ? 1 : 0; // game.iconP2.animation.curAnim.curFrame;
		// PlayState.instance.boyfriend.setPosition(healthBar.x + (healthBar.width / 2 ) + 100 + (healthBar.width * 0.6) - ((healthBar.width * 1.2) * (displHealth / 4)) - PlayState.instance.boyfriend.width - 20,game.iconP1.y - 10);
		PlayState.instance.boyfriend.scale.set(game.iconP1.scale.x / 1.75, game.iconP1.scale.y / 1.75);
		lodcon.scale.set(game.iconP2.scale.x, game.iconP2.scale.y);
	}

	override function goodNoteHit(note:Note)
	{
		switch (note.noteData)
		{
			case 0:
				placeFollow(-20, 0);
			case 1:
				placeFollow(0, 30);
			case 2:
				placeFollow(0, -30);
			case 3:
				placeFollow(20, 0);
		}
		// Function called when you hit a note (***after*** note hit calculations)
	}

	override function noteMiss(note:Note)
	{
		// Called after the note miss calculations
		// Player missed a note by letting it go offscreen
		PlayState.instance.boyfriend.angle = FlxG.random.int(-10, 10);
		switch (note.noteData)
		{
			case 0:
				placeFollow(-10, 0);
			case 1:
				placeFollow(0, 15);
			case 2:
				placeFollow(0, -15);
			case 3:
				placeFollow(10, 0);
		}
	}

	var videoEnded:Bool = false;

	function videoCutscene(?videoName:String = null)
	{
		game.inCutscene = true;
		if (!videoEnded && videoName != null)
		{
			#if VIDEOS_ALLOWED
			game.startVideo(videoName);
			game.videoCutscene.finishCallback = game.videoCutscene.onSkip = function()
			{
				trace('wagooga');
				videoEnded = true;
				game.videoCutscene = null;
				videoCutscene();
			};
			#else // Make a timer to prevent it from crashing due to sprites not being ready yet.
			new FlxTimer().start(0.0, function(tmr:FlxTimer)
			{
				videoEnded = true;
				videoCutscene(videoName);
			});
			#end
			return;
		}

		//if (isStoryMode)
		//{
			switch (songName)
			{
				default:
					trace('cd!');
					startCountdown();
					// case 'darnell':
					// darnellCutscene();
			}
		//}
	}
}
