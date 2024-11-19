package states.stages;

//
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxGradient;
import substates.GameOverSubstate;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import states.stages.Loddy.LoddyStage;
import backend.BaseStage;
import backend.BaseStage.Countdown;
import states.stages.objects.*;

class BaldGlue extends BaseStage
{
	// the loddy! :)
	// Learn to collapse lines btw
	var voicelines:Array<String> = [
		"Bald gru is the BEST game you've never played! Or, the darkest game you\ncan't play. Big wins.",
		"When life gives you freaking combustible lemons, you SQUIRT 'em right\nback into life's eyes!",
		"According to a poll, most minons' favorite game is.. Upper Bro Wonder 2!",
		"If you were to take off my headphones, my head would look freaking AWESOME,\nlet me tell you that much. It would look so cool, so, it wouldn't look chafed.",
		"Don't forget to charge dat chromebook.",
		"chuddy... flavored.. mush..",
		"Chuddy flavored mush.",
		"Did you know, that the actual reason why this mod was made in the first\nplace, was becaus- wait, fuck, I gotta finish my DeltaMath. Ok, be right back.",
		"Did you know Bald Gru is just a mech? Check the FLA file for more.",
		"I'm kinda freaking like black ops 3 guy, because when holy chunguses rain,\nI buy!",
		"There was a parody of bald gru's debut movie, indescribable you, named\n'despicable me!'",
		"I loved playing Jungle Queen & Electrician as a kid. In fact, it's the\nmost popular outdoor activity among minons!",
		"Did you know bald gru was once a minon himself?",
		"Despite popular belief, the artist of this mod is actually made out of\nmiracle mayo and jumbo juice.",
		"Despite popular belief, the artist of this mod is actually made out of\nmiracle mayo and jumbo josh- Juice. Shit.",
		"Hello Neigheigheigheigheigh-bor! That's if Hello Neighbor was a horse.",
		"Nefaro once tried making a commentary channel, but nobody watched him\nbecause his microphone was always covered in phlegm.",
		"If you pray hard enough you can beat any song.",
		"*Incoherent* I'm sorry, I had something stuck in my throat.",
		"Bald Gru tried getting the world record for most three pointers in 1\n minute, but he got disqualified.. because his hoop had no rim!",
		"WHO won?! WHO'S next?! YOU decide!"
	];
	var voicelines_summer:Array<String> = [
		"Shirts up for jesus!",
		"Chuddy flavored popsicle.",
		"I was part of a competitive popsicle eating team once. I got kicked out after i got too into it and started licking the ref",
		"you ever get so thirsty you drink out of your local water tower",
		"did i ever tell you about the time me and my buddy keith went to the nearby lagoon and disguised as the wildlife? we got hit by a few bullets but let’s just say.. heh… we got the scares…",
		"If you type \"winter\" during a song, you get a special winter mode! try it out!",
		"phew it’s hot in here, if only the trusty winter mode could cool me down, which you can activate by typing in \"winter\" during a song!",
		"Hooah! Anybody else getting a liiiiiittle TOO hot here? I say we should then, quote unquote, \"Take off all our clothes!\" Who's with me?!",
		"who up summering they mode? and by mode let’s just say i’m summering my mode…",
		"Bald gru's tumor is nearing its final stage as we speak, and he needs your credit card number, and the three digits on the back to pay for his iconic surgery!",
		"Bald gru needs your help, quick! fan him with your mouse cursor!",
		"click the loddy! click the loddy!! ahahahahahahaha!!! (whimsy laughter)",
		"I would say a hilarious quip here, but my bae is calling. and by bae, lets just say. my pico",
		"man if only we were in a winter special song!",
	];
	var special_lines:Array<String> = ["Muahahahahaha.. Winter mode: ACTIVATED!"];

	var winterKeys:Array<FlxKey> = [FlxKey.W, FlxKey.I, FlxKey.N, FlxKey.T, FlxKey.E, FlxKey.R];
	var winterStage:Int = 0;
	var loddy:FlxSprite;
	var loddyTalking:Bool = false;
	var loddyBuffer:Float = 16; // How many beats *have* to pass before loddy can speak, Prevents it from being randomly spammed
	var loddio:FlxSound; // loddy audio I'm so funny
	var dialogBG:FlxSprite;
	var loddyDialog:FlxText;

	var object:FlxSprite;

	var crowd1:BGSprite;
	var crowd2:BGSprite;
	var crowd3:FlxSprite;

	var alarm:FlxSprite;

	var gandolfo:BGSprite;
	var explosion:BGSprite;
	var coolasFuckGradient:FlxSprite;
	var imreallystupid:FlxSprite;

	override function create()
	{
		GameOverSubstate.loopSoundName = "baldgru-gameover-loop";
		GameOverSubstate.endSoundName = 'baldgru-gameover-end';

		var farBg:FlxSprite = new FlxSprite(-630,-330).loadGraphic(Paths.image("stages/baldGlue/farthest background"));
		farBg.scrollFactor.set(0.0, 0.0);
		farBg.scale.set(0.85,0.85);
		farBg.antialiasing = ClientPrefs.data.antialiasing;

		var fartherBg:FlxSprite = new FlxSprite(-630,-530).loadGraphic(Paths.image("stages/baldGlue/farther background"));
		fartherBg.scrollFactor.set(0.15, 0.15);
		fartherBg.scale.set(0.85,0.85);
		fartherBg.antialiasing = ClientPrefs.data.antialiasing;

		var bg:FlxSprite = new FlxSprite(-660,-430).loadGraphic(Paths.image("stages/baldGlue/background"));
		bg.scrollFactor.set(0.3, 0.3);
		bg.scale.set(0.85,0.85);
		bg.antialiasing = ClientPrefs.data.antialiasing;

		var minionsFront = new FlxSprite(-520,770);
		minionsFront.frames = Paths.getSparrowAtlas("stages/baldGlue/bf_foreground_crowd");
		minionsFront.antialiasing = ClientPrefs.data.antialiasing;
		minionsFront.animation.addByPrefix("idle", "front crowd1 instance 1", 24, true);
		minionsFront.animation.play("idle", true);
		minionsFront.scale.set(1.2,1.2);

		alarm = new FlxSprite(-480, -180);
		alarm.frames = Paths.getSparrowAtlas("stages/baldGlue/alarm");
		alarm.scrollFactor.set(0.4, 0.4);
		alarm.animation.addByIndices("norm", "alarm goin off", [0, 0], "", 24, true); // cheating the system i think
		alarm.animation.addByPrefix("alarm", "alarm goin off", 24, true);
		alarm.scale.set(1.15, 1.15);
		alarm.animation.play("norm", true);
		add(alarm);

		//var pipe:FlxSprite = new FlxSprite(-175, 490).loadGraphic(Paths.image("stages/baldGlue/bg_pipe"));
		//pipe.antialiasing = ClientPrefs.data.antialiasing;
		//pipe.scrollFactor.set(0.4, 0.4);
		//pipe.scale.set(1.2, 1);

		/*
			makeLuaSprite("gandolfo","bigstage/gandolfo",300,700)
			setLuaSpriteScrollFactor('gandolfo', 0.9, 0.9)
			addLuaSprite("gandolfo",false)
			setObjectOrder("gandolfo",4)

			makeAnimatedLuaSprite("explody","bigstage/kablooey",-350,-300)
			addAnimationByPrefix("explody","play","explos instance",24,false)
			setProperty("explody.visible", false)
			setLuaSpriteScrollFactor('explody', 0.9, 0.9)
			addLuaSprite("explody",false)
			setObjectOrder("explody",5)
		 */
		if (PlayState.SONG.song.toLowerCase() == "baldozer")
		{
			gandolfo = new BGSprite("stages/baldGlue/gandolfo", 300, 700, 0.9, 0.9);

			explosion = new BGSprite("stages/baldGlue/kablooey", -350, -300, 0.9, 0.9, ["explos instance"]);
			// explosion.animation.addByPrefix("play", "explos instance", 24, false);
			explosion.visible = false;
		}
		var platform:FlxSprite = new FlxSprite(-340,670).loadGraphic(Paths.image("stages/baldGlue/BGstage"));
		platform.antialiasing = ClientPrefs.data.antialiasing;
		platform.scrollFactor.set(1, 1);
		platform.scale.set(1.2, 1.2);

		crowd1 = new BGSprite("stages/baldGlue/BGbackcrowd", -500,500, 0.4, 0.3, ["front"], false);
		crowd1.dance();

		crowd2 = new BGSprite("stages/baldGlue/BGfront_crowd", -700,490, 0.7, 0.4, ["front"], false);
		crowd2.dance();


		crowd3 = new FlxSprite(-499,280);
		crowd3.antialiasing = ClientPrefs.data.antialiasing;
		crowd3.frames = Paths.getSparrowAtlas("stages/baldGlue/BGfront_minons");
		crowd3.animation.addByPrefix("idle", "crowd instance 1", 24, false, false);
		crowd3.animation.play("idle");
		crowd3.scrollFactor.set(1.2, 1);
		crowd3.scale.set(1.8,1.8);

		//var gruOverlay:BGSprite = new BGSprite('stages/baldGlue/baldoverlay', -430, -100, 0, 0);
		//gruOverlay.blend = OVERLAY;
		//gruOverlay.scale.set(1.1, 1.1);

		add(farBg);
		add(fartherBg);
		add(bg);
		add(crowd1);
		add(crowd2);
		if (PlayState.SONG.song.toLowerCase() == "baldozer")
		{
			add(explosion);
			add(gandolfo);
		}
		add(platform);

		add(minionsFront);

		object = crowd1;

		

		if (isStoryMode && ClientPrefs.data.cutscenes)
		{
			switch (songName)
			{
				case "baldspicable":
					// if(!seenCutscene) PlayState.instance.startVideo("cough");
					if (!seenCutscene)
						setStartCallback(videoCutscene.bind('BaldGruIntro'));
			}
		}
	}

	override function countdownTick(count:backend.BaseStage.Countdown, num:Int)
	{
		switch (count)
		{
			case THREE: // num 0
				if (PlayState.SONG.song.toLowerCase() == "baldspicable")
				{
					game.boyfriend.playAnim("deadasfuck", true);
					game.boyfriend.specialAnim = true; // FUCK
					game.gf.playAnim("awesome", true);
					game.gf.specialAnim = true; // FUCK 2
				}
			case TWO: // num 1
			case ONE: // num 2
			case GO: // num 3
			case START: // num 4
		}
	}

	override function createPost()
	{
		if (PlayState.SONG.song.toLowerCase() == "baldspicable")
			{
				game.boyfriend.playAnim("deadasfuck", true);
				game.boyfriend.specialAnim = true; // FUCK
				game.gf.playAnim("awesome", true);
				game.gf.specialAnim = true; // FUCK 2
			}
		add(crowd3);

		// Use this function to layer things above characters!

		// dialog bg doesn't want to cooperate. Not going to use it
		// dialogBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		// dialogBG.cameras = [game.camHUD];
		// dialogBG.alpha = 0.5;
		// add(dialogBG);

		// Bald Gru should have a dedicated gangnam style button
		var gruDarkness = new BGSprite('stages/baldGlue/darkness', -970,-1180, 1, 1);
		gruDarkness.blend = MULTIPLY;
		gruDarkness.scale.set(1, 1);
		gruDarkness.scrollFactor.set(1, 0.5);
		gruDarkness.alpha = 0.8;
		add(gruDarkness);
		var gruLighting = new BGSprite('stages/baldGlue/bal_gru_lighting', -420,-310, 1, 1);
		gruLighting.blend = ADD;
		gruLighting.scale.set(1, 1);
		gruLighting.scrollFactor.set(1, 0.5);
		add(gruLighting);

		loddy = new FlxSprite(-300, 280);
		loddy.frames = Paths.getSparrowAtlas("stages/baldGlue/loddy");
		loddy.antialiasing = ClientPrefs.data.antialiasing;
		loddy.animation.addByIndices("enter", "loddy full", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
		loddy.animation.addByIndices("leave", "loddy full", [23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35], "", 24, false);
		loddy.animation.addByIndices("speak", "loddy full", [14, 15, 16, 17, 18, 19, 20, 21, 22], "", 24, true);
		loddy.cameras = [game.camHUD];
		loddy.animation.play("leave", true);
		loddy.animation.finish();
		add(loddy);

		

		loddyDialog = new FlxText(128, FlxG.height * 0.7, FlxG.width - 128, "I know this one; the Indescribable Yes!", 30);
		loddyDialog.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		loddyDialog.borderSize = 2;
		loddyDialog.cameras = [game.camHUD];
		loddyDialog.fieldWidth = Math.min(FlxG.width - 256, loddyDialog.width);
		loddyDialog.screenCenter(X);
		loddyDialog.updateHitbox();
		add(loddyDialog);

		loddyDialog.alpha = 0;

		loddio = new FlxSound();
		loddio.volume = 3.5;
		FlxG.sound.list.add(loddio);

		/*		
			makeLuaSprite("gradient","bigstage/gradient",0,-720 * 2)
			setObjectCamera("gradient","camOther")
			addLuaSprite("gradient",true)
			scaleObject("gradient",1280,1)
			setObjectOrder('gruOverlay', 1112, false)
		 */
		coolasFuckGradient = FlxGradient.createGradientFlxSprite(1, 720, [FlxColor.BLACK, 0x0]);
		coolasFuckGradient.scale.set(FlxG.width, 1);
		coolasFuckGradient.cameras = [game.camOther];
		coolasFuckGradient.y = -720;
		coolasFuckGradient.screenCenter(X);
		add(coolasFuckGradient);

		imreallystupid = new FlxSprite(0, -720 * 2).makeGraphic(1280, 720, FlxColor.BLACK);
		imreallystupid.cameras = [game.camOther];
		add(imreallystupid);
		// dialogBG.x = loddyDialog.x - 8;
		// dialogBG.y = loddyDialog.y - 8;
		// dialogBG.scale.set(loddyDialog.width + 16, loddyDialog.height + 16);
	}

	var stop:Bool = false;

	override function update(elapsed:Float)
	{
		// Code here

		if (ClientPrefs.data.summerMode)
		{
			if (FlxG.keys.checkStatus(winterKeys[winterStage], FlxInputState.JUST_PRESSED) && (winterStage < 4 || !loddyTalking))
			{
				trace("TYPED " + winterKeys[winterStage]);
				winterStage++;
				if (winterKeys[winterStage] == ClientPrefs.keyBinds["reset"][0])
				{
					stop = true;
					PlayState.instance.canReset = false;
				}
				else
				{
					if (stop)
					{
						stop = false;
						PlayState.instance.canReset = false;
					}
				}
				if (winterStage == winterKeys.length)
				{
					loddyTalking = true;
					loddyDialog.text = "Muahahahahaha.. Winter mode: ACTIVATED!";
					loddy.animation.play("enter", true);
					loddio.loadEmbedded(Paths.sound("loddy/winterActivate"));
					loddio.onComplete = function()
					{
						loddy.animation.play("leave", true);

						FlxTween.tween(loddyDialog, {alpha: 0}, 0.5);
						new FlxTimer().start(0.75, function(_)
						{
							loddyBuffer = FlxG.random.int(16, 20);
							loddyTalking = false;
						});
					}
					new FlxTimer().start(0.25, function(tmr)
					{
						loddy.animation.play("speak", true);
						loddio.play();

						FlxTween.tween(loddyDialog, {alpha: 1}, 0.25);
					});
				}
			}
		}

		#if debug
		debugShit();
		#end

		loddy.visible = !(loddy.animation.curAnim.name == "leave" && loddy.animation.finished);
	}

	override function beatHit()
	{
		// Code here
		if (curBeat % 4 == 0)
			crowd1.dance();
		if (curBeat % 2 == 0)
		{
			crowd2.dance();
			crowd3.animation.play("idle");
		}

		// Baldozer loddy shits
		if (PlayState.SONG.song.toLowerCase() == "baldozer")
		{
			if (ClientPrefs.data.distractions)
			{
				loddyBuffer = Math.max(0, loddyBuffer - 1);
				if (loddyBuffer == 0 && !loddyTalking && FlxG.random.bool(5))
				{
					var chosen = FlxG.random.int(0, (ClientPrefs.data.summerMode ? voicelines_summer : voicelines).length - 1);
					trace(chosen);
					loddyTalking = true;
					loddyDialog.text = (ClientPrefs.data.summerMode ? voicelines_summer : voicelines)[chosen];
					loddy.animation.play("enter", true);
					loddio.loadEmbedded(Paths.sound("loddy/" + (ClientPrefs.data.summerMode ? "summer" : "regular") + "/" + chosen));
					loddio.pitch = ClientPrefs.getGameplaySetting("songspeed");
					loddio.onComplete = function()
					{
						loddy.animation.play("leave", true);

						FlxTween.tween(loddyDialog, {alpha: 0}, 0.5);
						new FlxTimer().start(0.75, function(_)
						{
							loddyBuffer = FlxG.random.int(16, 20);
							loddyTalking = false;
						});
					}
					new FlxTimer().start(0.25, function(tmr)
					{
						loddy.animation.play("speak", true);
						loddio.play();

						FlxTween.tween(loddyDialog, {alpha: 1}, 0.25);
					});
				}
			}

			/*
				if curBeat == 456 then -- 456
					doTweenY("hello","gandolfo",0,crochet*0.006,"quintOut")
					setProperty("explody.visible",true)
					playAnim("explody","play",true)
					doTweenAlpha("byebyehud","camHUD",0,crochet*0.004,"quadInOut")
				end
				if curBeat == 464 then
					setProperty("isCameraOnForcedPos",true)
					doTweenY("goodbye","gandolfo",-4000,crochet*0.026,"sineIn")
				end
				if curBeat == 480 then
					doTweenY("whee","camFollow",getProperty("camFollow.y") - 1600,crochet*0.016,"sineIn")
					doTweenY("fade","gradient",0,crochet*0.010,"sineIn")
					
				end
			 */
			switch (curBeat)
			{
				case 456: // 456
					FlxTween.tween(gandolfo, {y: 0}, Conductor.crochet * 0.006, {ease: FlxEase.quintOut});
					FlxTween.tween(game.camHUD, {alpha: 0}, Conductor.crochet * 0.004, {ease: FlxEase.quadInOut});
					explosion.visible = true;
					explosion.dance();
				// explosion.animation.play("play", true);
				case 464: // 464
					PlayState.isCameraOnForcedPos = true;
					PlayState.instance.camFollow.x += 200;
					FlxTween.tween(gandolfo, {y: -4000}, Conductor.crochet * 0.026, {ease: FlxEase.sineIn});
				case 480: // 480
					FlxTween.tween(coolasFuckGradient, {y: 720}, Conductor.crochet * 0.010, {ease: FlxEase.sineIn});
					FlxTween.tween(imreallystupid, {y: 0}, Conductor.crochet * 0.010, {ease: FlxEase.sineIn});
					FlxTween.tween(PlayState.instance.camFollow, {y: PlayState.instance.camFollow.y - 1600}, Conductor.crochet * 0.016, {ease: FlxEase.sineIn});
			}
		}
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if (paused)
		{
			loddio.resume();
			// timer.active = true;
			// tween.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if (paused)
		{
			loddio.pause();
			// timer.active = false;
			// tween.active = false;
		}
	}

	// delayed hxvlc porting for several days because my dumbass didnt notice this was a FUCKING FUNCTION
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

		if (isStoryMode)
		{
			switch (songName)
			{
				default:
					trace('cd!');
					startCountdown();
					// case 'darnell':
					// darnellCutscene();
			}
		}
	}

	function debugShit()
		{
			var holdShift = FlxG.keys.pressed.SHIFT;
			var holdCtrl = FlxG.keys.pressed.CONTROL;
			var holdAlt = FlxG.keys.pressed.ALT;
			var multiplier = 1;
			if (holdShift)
				multiplier = 10;
	
			if (holdCtrl)
				multiplier = 100;
	
			if (FlxG.keys.justPressed.J)
			{
				object.x -= (1 * multiplier);
				trace(object.x, object.y);
			}
			if (FlxG.keys.justPressed.I)
			{
				object.y -= (1 * multiplier);
				trace(object.x, object.y);
			}
			if (FlxG.keys.justPressed.F1){
				endSong();
			}
			if (FlxG.keys.justPressed.SEMICOLON)
			{
				trace("------------------------------------");
				trace("X: " + object.x);
				trace("Y: " + object.y);
				trace("SCALE X: " + object.scale.x);
				trace("SCALE Y: " + object.scale.y);
				trace("------------------------------------");
			}
			if (FlxG.keys.justPressed.K)
			{
				object.y += (1 * multiplier);
				trace(object.x, object.y);
			}
			if (FlxG.keys.justPressed.L)
			{
				object.x += (1 * multiplier);
				trace(object.x, object.y);
			}
			if (FlxG.keys.justPressed.U)
			{
				object.scale.x -= (0.1 * multiplier);
			}
			if (FlxG.keys.justPressed.Y)
			{
				object.scale.x += (0.1 * multiplier);
			}
			if (FlxG.keys.justPressed.O)
			{
				object.scale.y -= (0.1 * multiplier);
			}
			if (FlxG.keys.justPressed.P)
			{
				object.scale.y += (0.1 * multiplier);
			}
			if (FlxG.keys.justPressed.Z)
			{
				object.angle -= (0.1 * multiplier);
			}
			if (FlxG.keys.justPressed.X)
			{
				object.angle += (0.1 * multiplier);
			}
			if (FlxG.keys.justPressed.PAGEUP)
			{
				PlayState.instance.defaultCamZoom += 0.1;
			}
			if (FlxG.keys.justPressed.PAGEDOWN)
			{
				PlayState.instance.defaultCamZoom -= 0.1;
			}
		}
}
