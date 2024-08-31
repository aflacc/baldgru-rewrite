package states;

import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;
import shaders.WiggleEffect;
import flixel.FlxSubState;
import backend.Highscore;
import backend.Song;
import backend.WeekData;
import flixel.addons.text.FlxTextField;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import flixel.util.FlxGradient;

class MainMenuState extends MusicBeatState
{
	public static var initialized:Bool = false;
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC

	public var baldGruVersion:String = '1.84LD'; // This is not used for Discord RPC
	public var curSelected:Int = -1;

	var curSprite:FlxSprite = null;

	#if debug
	var debugDrag:FlxSprite;
	var debugStartDrag:FlxPoint;
	var debugEndDrag:FlxPoint;
	var debugDragging:Bool = false;
	var debugText:FlxText;
	#end

	var resetBG:FlxSprite;
	var holdUp:FlxText;
	var resetText:FlxText;

	// stores offset information
	var menuStuff:Map<String, Map<String, Array<Int>>> = [
		"story_mode" => [
			"clickbox" => [157, 1667, 224, 172],
			"position" => [-5, 500],
			"unselected" => [0, 0],
			"hover" => [0, 0],
			"select" => [3, 0]
		],
		"freeplay" => [
			"clickbox" => [159, 1849, 279, 269],
			"position" => [-187, 660],
			"unselected" => [0, 0],
			"hover" => [0, 0],
			"select" => [9, 0],
			"broken" => [0, 0]
		],
		"extras" => [
			"clickbox" => [935, 1752, 234, 171],
			"position" => [850, 600],
			"unselected" => [0, 0],
			"hover" => [1, 0],
			"select" => [42, 0]
		],
		"settings" => [
			"clickbox" => [912, 1940, 251, 195],
			"position" => [806, 758],
			"unselected" => [0, 0],
			"hover" => [0, 0],
			"select" => [38, 0]
		], // 876
		"credits" => [
			"clickbox" => [611, 1908, 207, 200],
			"position" => [545, 724],
			"unselected" => [0, 0],
			"hover" => [0, 0],
			"select" => [37, 0]
		] // 625
	];

	var menuOrder:Array<String> = ["story_mode", "freeplay", "credits", "extras", "settings"];
	var menuClickBoxes:FlxSpriteGroup;
	var freeplayEnabled:Bool = false; // todo: add a check to see if player has completed the story week
	var menuSprites:Array<FlxSprite> = [];
	var magenta:FlxSprite;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	private var hudCamera:FlxCamera;
	var cameraPoint:FlxPoint;
	var followPoint:FlxObject;
	var camFollow:FlxObject;

	var isNight:Bool = false;
	var baldWeek:Array<WeekData> = [];
	var time:Float;

	var summerEffect:SummerShader;

	public static function nightCheck():Bool
	{
		var curHour = Date.now().getHours();
		return (curHour <= 5 || curHour >= 19);
	}

	override function create()
	{
		Paths.clearStoredMemory();

		isNight = nightCheck();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music(MainMenuState.nightCheck() ? 'nightTheme' : 'freakyMenu'), 0);
		}

		WeekData.reloadWeekFiles(false);
		// var everything:FlxSpriteGroup = new FlxSpriteGroup();
		if (ClientPrefs.data.summerMode && ClientPrefs.data.shaders)
		{
			// summerEffect = new SummerShader();

			//	summerEffect = new WiggleEffect();
			//	//summerEffect.effectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
			//	summerEffect.waveAmplitude = 0.01;
			//	summerEffect.waveFrequency = 1;
			//	summerEffect.waveSpeed = 1;
			// FlxG.camera.filters = [new ShaderFilter(summerEffect)];
		}

		// add(everything);
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		persistentUpdate = persistentDraw = true;
		// camGame = new FlxCamera();
		// camAchievement = new FlxCamera();
		// camAchievement.bgColor.alpha = 0;
		// FlxG.cameras.reset(camGame);
		// FlxG.cameras.add(camAchievement, false);
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);

		var baldFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[0]);
		baldWeek.push(baldFile);
		WeekData.setDirectoryFromWeek(baldFile);
		Difficulty.loadFromWeek();

		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;
		FlxG.cameras.add(hudCamera, false);

		var sky:FlxSprite = new FlxSprite().loadGraphic(Paths.image(isNight ? 'mainmenu/sky' : 'mainmenu/summer_sky'));
		sky.scale.set(0.75, 0.75);
		sky.scrollFactor.set(0.1, 0.1);
		sky.screenCenter(X);
		sky.y -= isNight ? 200 : 300;
		sky.antialiasing = ClientPrefs.data.antialiasing;
		add(sky);

		var stars:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/stars'));
		stars.scale.set(0.75, 0.75);
		stars.scrollFactor.set(0.05, 0.05);
		stars.screenCenter(X);
		stars.y -= 200;
		stars.antialiasing = ClientPrefs.data.antialiasing;
		add(stars);
		if (!isNight)
		{
			stars.destroy(); // Lol
		}
		// var stars:FlxSprite = new FlxSprite().loadG
		var moon:FlxSprite = new FlxSprite().loadGraphic(Paths.image(isNight ? 'mainmenu/moon' : 'mainmenu/summer_sun'));
		moon.scale.set(0.7, 0.7);
		moon.scrollFactor.set(0.3, 0.26);
		moon.screenCenter(X);
		if (!isNight)
		{
			moon.y -= 400;
		}
		moon.antialiasing = ClientPrefs.data.antialiasing;
		moon.y -= 60;
		add(moon);
		var clouds:FlxSprite = new FlxSprite().loadGraphic(Paths.image(isNight ? "mainmenu/clouds" : "mainmenu/summer_clouds"));
		clouds.scale.set(0.7, 0.7);
		clouds.scrollFactor.set(0.5, 0.5);
		clouds.screenCenter(X);
		clouds.y += FlxG.height * 1.05;
		clouds.x += FlxG.width / 4;
		clouds.antialiasing = ClientPrefs.data.antialiasing;
		// add(clouds);
		var clouds:FlxBackdrop = new FlxBackdrop(Paths.image(isNight ? "mainmenu/clouds" : "mainmenu/summer_clouds"), X, 420);
		clouds.scale.set(0.7, 0.7);
		clouds.scrollFactor.set(0.5, 0.5);
		clouds.screenCenter(X);
		clouds.y += FlxG.height * 1.05;
		clouds.x += FlxG.width / 4;
		clouds.velocity.set(-10, 0);
		clouds.antialiasing = ClientPrefs.data.antialiasing;
		add(clouds);
		var farback:FlxSprite = new FlxSprite().loadGraphic(Paths.image(isNight ? "mainmenu/far_out" : "mainmenu/summer_far_out"));
		farback.scale.set(0.7, 0.7);
		farback.scrollFactor.set(0.7, 0.7);
		farback.screenCenter(X);
		farback.y = FlxG.height * 2.7 - farback.height;
		farback.antialiasing = ClientPrefs.data.antialiasing;
		add(farback);
		var stage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(isNight ? "mainmenu/stage" : "mainmenu/summer_stage"));
		stage.scale.set(0.7, 0.7);
		stage.scrollFactor.set(1, 1);
		stage.screenCenter(X);
		stage.y = FlxG.height * 3.4 - stage.height;
		stage.antialiasing = ClientPrefs.data.antialiasing;
		add(stage);

		// var wooglyboogly:FlxSprite = new FlxSprite(-600).loadGraphic(Paths.image("testasset"));
		// add(wooglyboogly);
		// wiggleShader = new WiggleEffect();
		//// wiggleShader.effectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
		// wiggleShader.waveAmplitude = 0.1;
		// wiggleShader.waveFrequency = 4;
		// wiggleShader.waveSpeed = 1;
		// wooglyboogly.shader = wiggleShader.shader;

		// the!!!! i know this!! yay!! wahoo
		super.create();

		for (index => key in menuOrder)
		{
			var value = menuStuff[key];
			trace(key + value);
			if (value != null)
			{
				var tv:FlxSprite = new FlxSprite(value["position"][0], value["position"][1] + (FlxG.height * 1.5));
				tv.frames = Paths.getSparrowAtlas("mainmenu/tv_" + key);
				tv.ID = index;
				for (key2 => value2 in value)
				{
					// trace((key2 != "position" && key2 != "clickbox") + key2);
					if (key2 != "position" && key2 != "clickbox")
					{
						tv.animation.addByPrefix(key2, '${key} ${key2}', 24, key2 != "select");
					}
				}
				if (key == "freeplay")
				{
					// What the fuck why do you only work after checking freeplay
					trace("week score: " + Highscore.getWeekScore("story", 0));
					trace("dealtastic: " + Highscore.getScore("dealtastic", 0));
					// dealtastic is the last song codes fucking buggy asf
					if (Highscore.getWeekScore("story", 0) > 0 || Highscore.getScore("dealtastic", 0) > 0)
					{
						tv.animation.play("unselected", true);
					}
					else
					{
						tv.animation.play("broken", true);
					}
				}
				else
				{
					tv.animation.play("unselected", true);
				}
				tv.scale.set(1280 / 1920, 1280 / 1920);
				tv.antialiasing = ClientPrefs.data.antialiasing;
				add(tv);
				menuSprites.push(tv);
			}
			else
			{
				trace("skipping " + key + " because it is null...");
			}
		}
		if (!isNight)
		{
			var overlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image("mainmenu/summer_glow"));
			overlay.scale.set(0.7, 0.7);
			overlay.scrollFactor.set(0, 0);
			overlay.screenCenter(X);
			// stage.y = FlxG.height * 3.4 - stage.height;
			overlay.antialiasing = ClientPrefs.data.antialiasing;
			add(overlay);
		}

		cameraPoint = new FlxPoint(moon.x + moon.width / 2, FlxG.height);
		FlxG.camera.zoom = 1.5;
		FlxG.camera.scroll.set(cameraPoint.x, cameraPoint.y);
		if (!initialized)
		{
			trace("Fuck");
			cameraPoint = new FlxPoint(moon.x + moon.width / 2, FlxG.height);
			FlxG.camera.zoom = 1.5;
			FlxG.camera.scroll.set(cameraPoint.x, cameraPoint.y);
			trace(FlxG.camera.zoom);
			new FlxTimer().start(2, function(_)
			{
				FlxTween.tween(cameraPoint, {"y": FlxG.height * 2}, 5, {ease: FlxEase.sineInOut});
				FlxTween.tween(FlxG.camera, {"zoom": 1}, 6, {
					ease: FlxEase.sineInOut,
					startDelay: 0.5,
					onComplete: function(_)
					{
						trace(FlxG.camera.zoom);
					}
				});
				FlxTween.tween(moon, {"y": moon.y + 25}, 5, {ease: FlxEase.sineInOut}); // what da fuck
			});
		}
		else
		{
			cameraPoint = new FlxPoint(moon.x + moon.width / 2, FlxG.height * 2);
			FlxG.camera.zoom = 1;
			FlxG.camera.scroll.set(cameraPoint.x, cameraPoint.y);
			moon.y += 25;
		}
		var versionShit:FlxText = new FlxText(5, FlxG.height
			- 5, 0,
			"FNF "
			+ Application.current.meta.get('version')
			+ "\nPsych "
			+ psychEngineVersion
			+ "\nBald Gru v"
			+ baldGruVersion
			+ (isNight ? "\nGoodnight!" : ""),
			12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.NONE, FlxColor.BLACK);
		versionShit.setFormat("_sans", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.NONE, FlxColor.BLACK);
		versionShit.alpha = 0;
		versionShit.y -= versionShit.height;
		new FlxTimer().start(7, function(_)
		{
			FlxTween.tween(versionShit, {alpha: 0.5}, 1, {ease: FlxEase.sineInOut});
		});
		add(versionShit);
		initialized = true;
		FlxG.mouse.visible = true;
		var sprite = new FlxSprite().loadGraphic(Paths.image('bald gru cursor')); // 'alt cursor'
		FlxG.mouse.load(sprite.pixels);

		menuClickBoxes = new FlxSpriteGroup();
		add(menuClickBoxes);
		menuClickBoxes.visible = false;

		for (i in 0...menuOrder.length)
		{
			var value = menuOrder[i];
			var clickbox:FlxSprite = new FlxSprite(menuStuff[value]["clickbox"][0],
				menuStuff[value]["clickbox"][1]).makeGraphic(menuStuff[value]["clickbox"][2], menuStuff[value]["clickbox"][3], FlxColor.BROWN);
			clickbox.alpha = 0.75;
			clickbox.ID = i;

			trace("Creating Clickbox for " + value);
			trace('x${clickbox.x}, y${clickbox.y}, w${clickbox.width}, h${clickbox.height}');
			menuClickBoxes.add(clickbox);
		}

		#if debug
		FlxG.watch.addMouse();
		debugDrag = new FlxSprite().makeGraphic(1, 1, FlxColor.MAGENTA);
		debugDrag.alpha = 0.5;
		debugDrag.visible = false;
		add(debugDrag);
		debugEndDrag = new FlxPoint();
		#end

		resetBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// resetBG.cameras = [hudCamera];
		resetBG.alpha = 0.5;
		resetBG.scrollFactor.set(0, 0);
		resetBG.visible = false;
		add(resetBG);
		holdUp = new FlxText(0, 180, FlxG.width * 0.6, "!!! HOLD ON !!!");
		holdUp.setFormat("VCR OSD Mono", 28, FlxColor.RED, CENTER, OUTLINE, FlxColor.BLACK);
		holdUp.borderSize = 2;
		holdUp.screenCenter(X);
		holdUp.scrollFactor.set(0, 0);
		holdUp.visible = false;
		add(holdUp);

		resetText = new FlxText(0, 0, FlxG.width * 0.6,
			"Are you sure you want to clear your story progress?\n\n(This will lock freeplay say your final goodbyes to it!!!!)\n\nPress CONFIRM to.. confirm\nPress BACK to cancel");
		resetText.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		resetText.borderSize = 2;
		resetText.screenCenter();
		// resetText.cameras = [hudCamera];
		resetText.scrollFactor.set(0, 0);
		resetText.visible = false;
		add(resetText);

		FlxG.camera.scroll.set(cameraPoint.x
			+ (FlxG.mouse.screenX - FlxG.width / 2) / 16
			- FlxG.width / 2,
			cameraPoint.y
			+ (FlxG.mouse.screenY - FlxG.height / 2) / 24);
		// FlxG.camera.follow(camFollow, null, 9);
	}

	override function openSubState(SubState:FlxSubState)
	{
		// persistentUpdate = false;
		selectedSomethin = true;
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		// persistentUpdate = true;
		selectedSomethin = false;
		super.closeSubState();
	}

	var selectedSomethin:Bool = false;
	var testmouse:Bool = false;

	var popup:Bool = false;

	override function update(elapsed:Float)
	{
		if (summerEffect != null)
		{
			// time += elapsed;
			// summerEffect.iTime = [time / 2];
			///
			///summerEffect.update(elapsed);
			///FlxG.camera.filters = [new ShaderFilter(summerEffect.shader)];
		}
		holdUp.offset.set(FlxG.random.int(-1, 1) * 1, FlxG.random.int(-1, 1) * 0.5);
		// FlxG.camera.scroll.set(cameraPoint.x,cameraPoint.y);
		if (controls.RESET)
		{
			resetBG.visible = true;
			resetText.visible = true;
			holdUp.visible = true;
			selectedSomethin = true;
			popup = true;
		}
		if (controls.BACK && popup)
		{
			resetBG.visible = false;
			resetText.visible = false;
			holdUp.visible = false;
			popup = false;
			selectedSomethin = false;
		}
		else if (controls.ACCEPT && popup)
		{
			Highscore.resetWeek("story", 0);
			Highscore.resetSong("baldspicable");
			Highscore.resetSong("baldozer");
			Highscore.resetSong("dealtastic");

			// menuSprites[menuOrder.indexOf("freeplay")].animation.play("broken",true);
			MusicBeatState.switchState(new MainMenuState()); // Just refresh the thing
			initialized = false;

			resetBG.visible = false;
			resetText.visible = false;
			holdUp.visible = false;
			popup = false;
			selectedSomethin = false;
		}
		if (FlxG.keys.justPressed.F7)
		{
			testmouse = !testmouse;
			var sprite = new FlxSprite().loadGraphic(Paths.image(testmouse ? 'alt cursor' : 'bald gru cursor')); // 'alt cursor'
			FlxG.mouse.load(sprite.pixels);
		}
		if (!selectedSomethin)
		{
			var hoveringsomething = false;
			menuClickBoxes.forEach(function(clickbox:FlxSprite)
			{
				if (FlxG.mouse.overlaps(clickbox) && menuSprites[clickbox.ID].animation.curAnim.name != "broken")
				{
					if (curSprite != null && curSelected != clickbox.ID)
					{
						if (curSprite.animation.curAnim.name != "unselected")
						{
							curSprite.animation.play("unselected", true);
							var offset = menuStuff[menuOrder[curSelected]]["unselected"];
							curSprite.offset.set(offset[0], offset[1]);
						}
					}
					curSelected = clickbox.ID;
					curSprite = menuSprites[clickbox.ID];

					if (menuSprites[clickbox.ID].animation.curAnim.name != "hover")
					{
						// trace(menuSprites[clickbox.ID].animation.curAnim.name);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						menuSprites[clickbox.ID].animation.play("hover", true);
						var offset = menuStuff[menuOrder[clickbox.ID]]["hover"];
						menuSprites[clickbox.ID].offset.set(offset[0], offset[1]);
					}
					hoveringsomething = true;
				}
			});
			if (hoveringsomething == false)
			{
				curSelected = -1;
				if (curSprite != null)
				{
					curSprite.animation.play("unselected", true);
					var offset = menuStuff[menuOrder[curSprite.ID]]["unselected"];
					curSprite.offset.set(offset[0], offset[1]);
				}
			}
		}
		if (FlxG.keys.justPressed.F3)
		{
			menuClickBoxes.visible = !menuClickBoxes.visible;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		FlxG.camera.scroll.set(FlxMath.lerp(FlxG.camera.scroll.x, cameraPoint.x + (FlxG.mouse.screenX - FlxG.width / 2) / 16 - FlxG.width / 2, 9 * elapsed),
			FlxMath.lerp(FlxG.camera.scroll.y, cameraPoint.y + (FlxG.mouse.screenY - FlxG.height / 2) / 24, 9 * elapsed));

		if (FlxG.sound.music.volume < 0.8 && !selectedSomethin)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}
		if (!selectedSomethin)
		{
			if (curSelected != -1 && FlxG.mouse.justPressed)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
				menuSprites[curSelected].animation.play("select", true);
				var offset = menuStuff[menuOrder[curSelected]]["select"];
				menuSprites[curSelected].offset.set(offset[0], offset[1]);
				new FlxTimer().start(1, function(_)
				{
					switch (menuOrder[curSelected])
					{
						case "freeplay":
							MusicBeatState.switchState(new FreeplayState());
						case "credits":
							FlxG.sound.music.fadeOut(1);
							new FlxTimer().start(0.3, function(_)
							{
								// This MAY be ass
								var gradientTop:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0x0, FlxColor.BLACK]);
								gradientTop.scrollFactor.set(0, 0);
								gradientTop.setPosition(0, FlxG.height);
								var gradientBot:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
								gradientBot.scrollFactor.set(0, 0);
								gradientBot.setPosition(0, 2 * FlxG.height);
								add(gradientBot);
								add(gradientTop);
								FlxTween.tween(gradientTop, {y: -FlxG.height}, 1.1, {ease: FlxEase.quadIn});
								FlxTween.tween(gradientBot, {y: 0}, 1.1, {ease: FlxEase.quadIn});
								FlxTween.tween(cameraPoint, {y: FlxG.height * 2.5}, 1.5, {
									ease: FlxEase.quadIn,
									onComplete: function(_)
									{
										FlxTransitionableState.skipNextTransIn = true;
										FlxTransitionableState.skipNextTransOut = true;
										MusicBeatState.switchState(new CreditsState());
									}
								});
							});
						case "settings":
							MusicBeatState.switchState(new OptionsState());
						case "extras":
							FlxG.sound.music.fadeOut(0.3);

							MusicBeatState.switchState(new ExtrasState());

						// openSubState(new MasterEditorMenu());
						// MusicBeatState.switchState(new MasterEditorMenu());
						case "story_mode":
							selectedSomethin = true;
							var baldArray:Array<String> = ["Baldspicable", "Baldozer", "Dealtastic"];

							PlayState.storyPlaylist = baldArray;
							PlayState.isStoryMode = true;
							//	selectedWeek = true;

							PlayState.storyWeek = 0;
							PlayState.storyDifficulty = 0;
							// Difficulty.loadFromWeek();

							PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
							PlayState.campaignScore = 0;
							PlayState.campaignMisses = 0;
							LoadingState.loadAndSwitchState(new PlayState(), true);
							FreeplayState.destroyFreeplayVocals();
						default:
							trace("what The SHIT");
							selectedSomethin = false;
					}
				});
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				// selectedSomethin = true;
				openSubState(new MasterEditorMenu());
				// MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		#if debug
		if (FlxG.mouse.justPressed)
		{
			debugDrag.x = FlxG.mouse.x;
			debugDrag.y = FlxG.mouse.y;
			debugDrag.visible = true;
			debugStartDrag = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
			debugDragging = true;
		}
		if (debugDragging)
		{
			debugEndDrag.set(FlxG.mouse.x, FlxG.mouse.y);
		}

		if (debugStartDrag != null)
		{
			debugDrag.scale.set(debugEndDrag.x - debugStartDrag.x, debugEndDrag.y - debugStartDrag.y);
			debugDrag.x = debugStartDrag.x;
			debugDrag.y = debugStartDrag.y;
			debugDrag.origin.set(0, 0);
		}
		if (FlxG.mouse.justReleased)
		{
			debugDragging = false;
		}

		if (FlxG.mouse.justReleased || FlxG.mouse.justPressedMiddle)
		{
			trace('NEW CLICKBOX: FROM: ${debugStartDrag.x}, ${debugStartDrag.y} TO: ${debugEndDrag.x}, ${debugEndDrag.y}');
		}

		if (debugStartDrag != null)
		{
			if (FlxG.keys.justPressed.W)
				debugStartDrag.y -= 1;
			if (FlxG.keys.justPressed.A)
				debugStartDrag.x -= 1;
			if (FlxG.keys.justPressed.S)
				debugStartDrag.y += 1;
			if (FlxG.keys.justPressed.D)
				debugStartDrag.x += 1;
		}
		if (debugEndDrag != null)
		{
			if (FlxG.keys.justPressed.UP)
				debugEndDrag.y -= 1;
			if (FlxG.keys.justPressed.LEFT)
				debugEndDrag.x -= 1;
			if (FlxG.keys.justPressed.DOWN)
				debugEndDrag.y += 1;
			if (FlxG.keys.justPressed.RIGHT)
				debugEndDrag.x += 1;
		}

		if (FlxG.mouse.justPressedRight)
		{
			debugDrag.visible = false;
		}
		#end
		super.update(elapsed);
	}

	override function beatHit()
	{
		// FlxG.camera.zoom += 0.015;
		super.beatHit();
	}
}

class SummerShader extends FlxShader
{
	@:glFragmentHeader('
		#pragma header
		uniform float iTime = 0.0;
		vec2 uv = openfl_TextureCoordv.xy;
		vec2 iResolution = openfl_TextureSize;
		vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
		uniform vec4      iMouse;   
		#define texture flixel_texture2D
		#define iChannel0 bitmap
		#define iChannel1 bitmap
		#define iChannel2 bitmap
		#define fragColor gl_FragColor
		#define mainImage main
	')
	@:glFragmentSource('
		vec3 rgb2hsv(vec3 c)
		{
		    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
		    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

		    float d = q.x - min(q.w, q.y);
		    float e = 1.0e-10;
		    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		vec3 hsv2rgb(vec3 c)
		{
		    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}

		float rand(vec2 n) {
		    return fract(sin(cos(dot(n, vec2(12.9898,12.1414)))) * 83758.5453);
		}

		float noise(vec2 n) {
		    const vec2 d = vec2(0.0, 1.0);
		    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
		    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
		}

		float fbm(vec2 n) {
		    float total = 0.0, amplitude = 1.0;
		    for (int i = 0; i <5; i++) {
		        total += noise(n) * amplitude;
		        n += n*1.7;
		        amplitude *= 0.47;
		    }
		    return total;
		}
		void mainImage() {
    		const vec3 c1 = vec3(0.5, 0.0, 0.1);
    		const vec3 c2 = vec3(0.9, 0.1, 0.0);
    		const vec3 c3 = vec3(0.2, 0.1, 0.7);
    		const vec3 c4 = vec3(1.0, 0.9, 0.1);
    		const vec3 c5 = vec3(0.1);
    		const vec3 c6 = vec3(0.9);

    		vec2 speed = vec2(1.2, 0.1);
    		float shift = 1.327+sin(iTime*2.0)/2.4;
    		float alpha = 1.0;

    		//change the constant term for all kinds of cool distance versions,
    		//make plus/minus to switch between 
    		//ground fire and fire rain!
			float dist = 3.5-sin(iTime*0.4)/1.89;

    		vec2 p = fragCoord.xy * dist / iResolution.xx;
    		p.x -= iTime/1.1;
    		float q = fbm(p - iTime * 0.01+1.0*sin(iTime)/10.0);
    		float qb = fbm(p - iTime * 0.002+0.1*cos(iTime)/5.0);
    		float q2 = fbm(p - iTime * 0.44 - 5.0*cos(iTime)/7.0) - 6.0;
    		float q3 = fbm(p - iTime * 0.9 - 10.0*cos(iTime)/30.0)-4.0;
    		float q4 = fbm(p - iTime * 2.0 - 20.0*sin(iTime)/20.0)+2.0;
    		q = (q + qb - .4 * q2 -2.0*q3  + .6*q4)/3.8;
    		vec2 r = vec2(fbm(p + q /2.0 + iTime * speed.x - p.x - p.y), fbm(p + q - iTime * speed.y));
    		vec3 c = mix(c1, c2, fbm(p + r)) + mix(c3, c4, r.x) - mix(c5, c6, r.y);
    		vec3 color = vec3(c * cos(shift * fragCoord.y / iResolution.y));
    		color += .05;
    		color.r *= .8;
    		vec3 hsv = rgb2hsv(color);
    		hsv.y *= hsv.z  * 1.1;
    		hsv.z *= hsv.y * 1.13;
    		hsv.y = (2.2-hsv.z*.9)*1.20;
    		color = hsv2rgb(hsv);
    		vec4 camColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    		fragColor = camColor * 0.5 + vec4(color.x, color.y, color.z, alpha) * 0.5;
		}
	')
	public function new()
	{
		super();
	}
}
