package states.editors;

import flixel.addons.display.FlxBackdrop;
import backend.WeekData;
import objects.Character;
import states.MainMenuState;
import states.FreeplayState;
import backend.Highscore;

class MasterEditorMenu extends MusicBeatSubstate
{
	var options:Array<String> = ['Test State', 'Chart Editor', 'Character Editor', "Freeplay", "Skip Story (dont)", "Skip Yolked (also dont)"];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var curSelected = 0;
	private var curDirectory = 0;
	private var directoryTxt:FlxText;

	override function create()
	{
		//FlxG.camera.bgColor = FlxColor.BLACK;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		//var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		//bg.scrollFactor.set();
		//bg.color = 0xFF353535;
		//add(bg);
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
		bg.scrollFactor.set();
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.45}, 0.5);
		add(bg);

		var cars:FlxBackdrop = new FlxBackdrop(Paths.image("ppcatarmy"));
		cars.alpha = 0;
		cars.velocity.set(-50, 10);
		cars.scale.set(4, 4);
		add(cars);
		
		// we love easter eggs
		FlxTween.tween(cars, {alpha: 0.05}, 10, {startDelay: 10});
		// Heavy traffic
		grpTexts = new FlxTypedGroup<Alphabet>();
		//grpTexts.
		add(grpTexts);


		for (i in 0...options.length)
		{
			var leText:Alphabet = new Alphabet(90, 320, options[i], true);
			leText.isMenuItem = true;
			leText.targetY = i;
			leText.scrollFactor.set();
			leText.distancePerItem = new FlxPoint(20, 60);
			grpTexts.add(leText);
			leText.snapToPosition();
		}

		#if MODS_ALLOWED
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		directoryTxt = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		directoryTxt.scrollFactor.set();
		//add(directoryTxt);

		for (folder in Mods.getModDirectories())
		{
			directories.push(folder);
		}

		var found:Int = directories.indexOf(Mods.currentModDirectory);
		if (found > -1)
			curDirectory = found;
		changeDirectory();
		#end
		changeSelection();

		///FlxG.mouse.visible = false;
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}
		#if MODS_ALLOWED
		if (controls.UI_LEFT_P)
		{
			changeDirectory(-1);
		}
		if (controls.UI_RIGHT_P)
		{
			changeDirectory(1);
		}
		#end

		if (controls.BACK)
		{
			// MusicBeatState.switchState(new MainMenuState());
			close();
		}

		if (controls.ACCEPT)
		{
			switch (options[curSelected])
			{
				case 'Skip Yolked (also dont)':
					Highscore.saveScore("yolked",1);
					MusicBeatState.switchState(new FreeplayState());
				case 'Skip Story (dont)':
					Highscore.saveScore("baldspicable",1);
					Highscore.saveScore("baldozer",1);
					Highscore.saveScore("dealtastic",1);
					MusicBeatState.switchState(new MainMenuState());
				case 'I dont care give me freeplay' | 'Freeplay':
					MusicBeatState.switchState(new FreeplayState());
				case 'Test State':
					MusicBeatState.switchState(new TestState());
				case 'Chart Editor': // felt it would be cool maybe
					LoadingState.loadAndSwitchState(new ChartingState(), false);
				case 'Character Editor':
					LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case 'Week Editor':
					MusicBeatState.switchState(new WeekEditorState());
				case 'Menu Character Editor':
					MusicBeatState.switchState(new MenuCharacterEditorState());
				case 'Dialogue Editor':
					LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
				case 'Dialogue Portrait Editor':
					LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
				case 'Note Splash Debug':
					MusicBeatState.switchState(new NoteSplashDebugState());
			}
			FlxG.sound.music.volume = 0;
			FreeplayState.destroyFreeplayVocals();
		}

		var bullShit:Int = 0;
		for (item in grpTexts.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;
	}

	#if MODS_ALLOWED
	function changeDirectory(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curDirectory += change;

		if (curDirectory < 0)
			curDirectory = directories.length - 1;
		if (curDirectory >= directories.length)
			curDirectory = 0;

		WeekData.setDirectoryFromWeek();
		if (directories[curDirectory] == null || directories[curDirectory].length < 1)
			directoryTxt.text = '< No Mod Directory Loaded >';
		else
		{
			Mods.currentModDirectory = directories[curDirectory];
			directoryTxt.text = '< Loaded Mod Directory: ' + Mods.currentModDirectory + ' >';
		}
		directoryTxt.text = directoryTxt.text.toUpperCase();
	}
	#end
}
