package states;

import lime.app.Application;
import backend.WeekData;
import backend.Highscore;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import shaders.ColorSwap;
import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	public static var updateVersion:String = '';

	public static var chosenName:String = "Bald Gru";

	override public function create():Void
	{
		// if (!initialized) {
		if (FlxG.random.bool(20)) // 20% chance to happen
		{
			var bald:Array<String> = [
				"Bald", "Balmed", "Bold", "Balled", "Bowled", "Mald", "Called", "Balbed", "Bulb", "Pulp", "Beef", "Bah", "Burp", "Tall", "Broken", "Bladder"
			];
			var gru:Array<String> = [
				"Gru", "Grew", "Glue", "Grue", "Blue", "Stew", "Shoe", "Poo", "Brew", "Starch Jello", "Goo", "New", "Few", "Gru Build", "Gangnam Style"
			];
			var chosenBald = FlxG.random.getObject(bald);
			var chosenGru = FlxG.random.getObject(gru);
			chosenName = '${chosenBald} ${chosenGru}';
			Application.current.window.title = 'Friday Night Funkin\': ${chosenBald} ${chosenGru}';
		}
		// }
		Paths.clearStoredMemory();

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		Highscore.load();

		if (!initialized)
		{
			// if (FlxG.save.data != null && FlxG.save.data.fullscreen)
			// {
			//	F//lxG.fullscreen = FlxG.save.data.fullscreen;
			// trace('LOADED FULLSCREEN SETTING!!');
			// }
			if (ClientPrefs.data.fullscreen)
			{
				FlxG.fullscreen = true;
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;

		if (FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
		{
			FlxG.sound.playMusic(Paths.music(MainMenuState.nightCheck() ? 'nightTheme' : 'freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);

			MusicBeatState.switchState(new MainMenuState());
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
