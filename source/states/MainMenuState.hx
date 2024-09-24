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
import openfl.Lib;

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

	//var summerEffect:SummerShader;

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

		// var everything:FlxSpriteGroup = new FlxSpriteGroup();
		if (ClientPrefs.data.summerMode && ClientPrefs.data.shaders)
		{
			// // uncomment this if u wanna give it a shot lmao
			// var summerTime:SummerTime = new SummerTime();
			// var summerShader:ShaderFilter = new ShaderFilter(summerTime.shader);
			
			// hudCamera.setFilters([summerShader]);
		}

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
		// if (summerEffect != null)
		// {
		// 	// time += elapsed;
		// 	// summerEffect.iTime = [time / 2];
		// 	///
		// 	///summerEffect.update(elapsed);
		// 	///FlxG.camera.filters = [new ShaderFilter(summerEffect.shader)];
		// }
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

class SummerTime
{
    public var shader:SummerShader = new SummerShader();
    public function new(){
        shader.iTime.value = [0];
        var w:Float = Lib.current.stage.stageWidth;
        var h:Float = Lib.current.stage.stageHeight;
        shader.iResolution.value = [w,h];

		// shader.waveAmplitude = 0.01;
		// shader.waveFrequency = 1;
		// shader.waveSpeed = 1;
    }
    public function update(elapsed:Float){
        shader.iTime.value[0] += elapsed;
        var w:Float = Lib.current.stage.stageWidth;
        var h:Float = Lib.current.stage.stageHeight;
        shader.iResolution.value = [w,h];
		trace("I ran lol");
    }
}

// Suicide 
class SummerShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float iTime;
		vec2 uv = openfl_TextureCoordv.xy;
		uniform vec2 iResolution = openfl_TextureSize;
		vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
		uniform vec4 iMouse;   
		#define texture flixel_texture2D
		#define iChannel0 bitmap
		#define iChannel1 bitmap
		#define iChannel2 bitmap
		#define fragColor gl_FragColor
		#define mainImage main

		const vec4 u_WaveStrengthX=vec4(94.15,94.66,0.1016,0.1015);
		const vec4 u_WaveStrengthY=vec4(92.54,96.33,0.10102,0.1025);
		vec2 dist(vec2 uv) { 
			float uTime = iTime * iMouse.x/iResolution.x;
			if(uTime==0.0) uTime=0.15*iTime;
			float noise = texture(iChannel1, uTime + uv).r;
			uv.y += (cos((uv.y + uTime * u_WaveStrengthY.y + u_WaveStrengthY.x * noise)) * u_WaveStrengthY.z) +
				(cos((uv.y + uTime) * 30.0) * u_WaveStrengthY.w);

			uv.x += (sin((uv.y + uTime * u_WaveStrengthX.y + u_WaveStrengthX.x * noise)) * u_WaveStrengthX.z) +
				(sin((uv.y + uTime) * 45.0) * u_WaveStrengthX.w);
			return uv;
		}
		void mainImage()
		{
			// Normalized pixel coordinates (from 0 to 1)
			vec2 uv = fragCoord/iResolution.xy;

			// Time varying pixel color
			vec4 col = texture(iChannel0,dist(uv));

			// Output to screen
			fragColor = col;
		}
	')
	public function new()
	{
		super();
	}
}
