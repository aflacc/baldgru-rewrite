package states.stages;

import objects.Note;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import backend.WeekData;
import states.FreeplayState.SongMetadata;
import objects.HealthIcon;
import openfl.filters.BlurFilter;
import flixel.system.FlxAssets.FlxShader;
import states.stages.objects.*;

// Stage thats like a fake freeplay menu
// I'm sorry
class FreeplayStage extends BaseStage
{
	var drain = 0.023;
	var freeplayGroup:FlxSpriteGroup;
	var rankStuff:Array<Float> = [
		1.0, // P
		0.9, // S
		0.85, // A
		0.80, // B
		0.75, // C
		0.6, // D
		0.3 // F
	];

	var songs:Array<SongMetadata> = [];

	var speaker:FlxSprite;

	var curSelected:Int = 0;

	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;

	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var tvBg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;
	var geremy:FlxSprite;
	var geremyPressTimer:Float = 0;

	var sketches:FlxSprite;
	var rankSprite:FlxSprite;

	// var scoreText:FlxText;
	var blur:BlurFilter;
	var bluramount:Float = 0;

	public static var whatShouldTheScoreSay:Float = 0;
	public static var whatShouldTheRankSay:Float = 0;

	var scroll:FlxBackdrop;

	override function create()
	{
		// var jackBlack:FlxSprite = new FlxSprite().loadGraphic(Paths.image("jackingoff"));
		// jackBlack.scrollFactor.set(0,0);
		// jackBlack.screenCenter(X);
		// add(jackBlack);
		// Paths.clearStoredMemory();
		// Paths.clearUnusedMemory();

		curSelected = FreeplayState.curSelected;

		Paths.clearStoredMemory();

		// persistentUpdate = true;
		// PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF5E596A); // .loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();
		scroll = new FlxBackdrop(Paths.image("freeplay/pattern"), XY, -100.5, 0);
		scroll.velocity.set(0, 20);
		scroll.alpha = 0.13;
		scroll.scale.set(1280 / 1920, 1280 / 1920);
		add(scroll);

		tvBg = new FlxSprite(-30, -322).loadGraphic(Paths.image('freeplay/song_tv-BG'));
		tvBg.scale.set(0.68, 0.692);
		tvBg.antialiasing = ClientPrefs.data.antialiasing;
		add(tvBg);
		// pattern offset is -51.5
		// :)

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(318, 320, songs[i].songName, true);
			songText.targetY = i;
			songText.changeX = false;
			grpSongs.add(songText);
			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.setScale(0.7, 0.7);

			songText.snapToPosition();
			songText.distancePerItem.set(0, 90);

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;
			icon.offset.set(20 + songText.width + 125, 25);
			icon.x -= songText.width;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		// scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		// scoreBG.alpha = 0.6;
		// add(scoreBG);

		// diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		// diffText.font = scoreText.font;
		// add(diffText);

		// add(scoreText);

		var scoreBGSprite = new FlxSprite(700, -20).loadGraphic(Paths.image("freeplay/highscore"));
		scoreBGSprite.scale.set(1280 / 1920, 1280 / 1920);
		scoreBGSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(scoreBGSprite);

		// var grayScoreText = new FlxText(scoreBGSprite.x + 48, scoreBGSprite.y + 119, 0, "000000000", 56);
		// grayScoreText.setFormat(Paths.font("ds-digib.ttf"), 56, FlxColor.GRAY, RIGHT);
		// add(grayScoreText);

		scoreText = new FlxText(858, 139, 0, Std.string(whatShouldTheScoreSay), 52);
		scoreText.setFormat(Paths.font("ds-digib.ttf"), 52, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 5;
		add(scoreText);

		rankSprite = new FlxSprite(1100, 100);
		rankSprite.frames = Paths.getSparrowAtlas("freeplay/ranks");
		rankSprite.animation.addByPrefix("rank", "rank", 0, false);
		rankSprite.animation.play("rank", true, false, 1);
		rankSprite.scale.set(1280 / 1920, 1280 / 1920);
		rankSprite.antialiasing = ClientPrefs.data.antialiasing;
		rankSprite.centerOrigin();
		add(rankSprite);

		FlxG.watch.add(scoreText, "x");
		FlxG.watch.add(scoreText, "y");

		var songTV = new FlxSprite(-30, -324).loadGraphic(Paths.image('freeplay/song_tv'));
		songTV.scale.set(0.68, 0.692);
		songTV.antialiasing = ClientPrefs.data.antialiasing;
		add(songTV);

		sketches = new FlxSprite(668, 107).loadGraphic(Paths.image('freeplay/portraits/placeholder'));
		sketches.antialiasing = ClientPrefs.data.antialiasing;
		sketches.scale.set(0.65, 0.65);
		add(sketches);

		var sketchTV = new FlxSprite(601, 40).loadGraphic(Paths.image('freeplay/sketch_tv'));
		sketchTV.scale.set(0.64, 0.64);
		sketchTV.antialiasing = ClientPrefs.data.antialiasing;
		add(sketchTV);

		// No! you're not supposed to be here! You are singing the song!
		geremy = new FlxSprite(-38, /*220*/ FlxG.height + 10);
		geremy.antialiasing = ClientPrefs.data.antialiasing;
		geremy.frames = Paths.getSparrowAtlas("freeplay/fpgerm");
		geremy.animation.addByPrefix("wait", "jeremy idle", 24, true);
		geremy.animation.addByPrefix("press", "jeremy press", 24, false);
		geremy.animation.play("wait", true);
		geremy.scale.set(0.85, 0.85);
		add(geremy);

		speaker = new FlxSprite(1109, 480);
		speaker.frames = Paths.getSparrowAtlas('freeplay/fp_speaker');
		speaker.animation.addByPrefix('Idle', 'speaker boppin', 24, false);
		speaker.animation.play('Idle');
		speaker.scale.set(0.7, 0.7);
		speaker.antialiasing = ClientPrefs.data.antialiasing;
		add(speaker);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);

		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if (curSelected >= songs.length)
			curSelected = 0;
		tvBg.color = songs[curSelected].color;
		intendedColor = tvBg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0;
		add(bottomBG);

		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		bottomText.scrollFactor.set();
		// add(bottomText);

		// player = new MusicPlayer(this);
		// add(player);

		changeSelection();
		refreshRank(whatShouldTheRankSay);
		updateTexts();
	}

	override function opponentNoteHit(note:Note)
	{
		if (game.health > 0.02)
		{
			game.health -= 0.0023;
		}
	}

	override function createPreHUD()
	{
		// FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK
		blur = new BlurFilter(0, 0);
		blur.quality = openfl.filters.BitmapFilterQuality.HIGH;
		PlayState.instance.camGame.filters = [blur];
		PlayState.instance.dadGroup.cameras = [game.camHUD];
		PlayState.instance.dad.setPosition(280, FlxG.height - (PlayState.instance.dad.height * 0.7));
	}

	override function createPost()
	{
		// Use this function to layer things above characters!
		PlayState.instance.timeBar.visible = false;
		PlayState.instance.timeTxt.visible = false;
	}

	override function beatHit()
	{
		// This looks a bit too strange in gameplay to use.
		// scroll.velocity.set(0, 120);
		// FlxTween.tween(scroll.velocity,{y: 20},Conductor.crochet / 1000, {ease: FlxEase.quadOut});
		speaker.animation.play("Idle", true);
		if (curBeat == 134)
		{
			FlxTween.num(5, 0, 0.75, {ease: FlxEase.quadOut}, function(nubmer)
			{
				bluramount = nubmer;
			});
			FlxTween.tween(game.dad, {y: FlxG.height + 20}, 0.9, {ease: FlxEase.quintIn});
			FlxTween.tween(geremy, {y: 220}, 1, {ease: FlxEase.quintInOut, startDelay: 0.4});
			FlxTween.tween(game.camHUD, {alpha: 0}, 0.5, {ease: FlxEase.quintInOut, startDelay: 0.8});

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
	}

	override function countdownTick(count:backend.BaseStage.Countdown, num:Int)
	{
		switch (count)
		{
			case THREE: // num 0
				FlxTween.num(0, 5, 0.75, {ease: FlxEase.quadOut}, function(nubmer)
				{
					bluramount = nubmer;
				});
				FlxTween.tween(game.camHUD, {alpha: 1}, 1.5);
			case TWO: // num 1
			case ONE: // num 2
			case GO: // num 3
			case START: // num 4
		}
	}

	override function update(elapsed:Float)
	{
		blur.blurX = bluramount;
		blur.blurY = bluramount;
		PlayState.isCameraOnForcedPos = true;
		PlayState.instance.camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
		PlayState.instance.camGame.scroll.set(0, 0);
		// Code here
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];

	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:Alphabet = grpSongs.members[i];
			item.visible = item.active = true;
			item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
			item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

			var icon:HealthIcon = iconArray[i];
			icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}

	function refreshRank(rate:Float):Int
	{
		for (i in 0...rankStuff.length)
		{
			if (rankStuff[i] <= rate)
			{
				if (rankSprite.animation.curAnim.curFrame != i || !rankSprite.visible)
				{
					rankSprite.scale.set(1280 / 1920 + 0.1, 1280 / 1920 + 0.1);
					rankSprite.angle = FlxG.random.int(-7, 7);
				}
				rankSprite.visible = true;
				rankSprite.animation.play("rank", true, false, i);
				return i;
			}
		}
		rankSprite.visible = false;
		return 6;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		// if (player.playingMusic)
		//	return;

		// _updateSongLastDifficulty();
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			// colorTween = FlxTween.color(tvBg, 1, tvBg.color, intendedColor, {
			//	onComplete: function(twn:FlxTween) {
			//		colorTween = null;
			//	}
			// });
		}

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;
		var path = Paths.image("freeplay/portraits/" + iconArray[curSelected].getCharacter());
		sketches.loadGraphic(path == null ? Paths.image("freeplay/portraits/placeholder") : path);
		// trace(Paths.image("freeplay/portraits/" + iconArray[curSelected].getCharacter()));

		for (item in grpSongs.members)
		{
			bullShit++;
			item.alpha = 0.6;
			if (item.targetY == curSelected)
				item.alpha = 1;
		}

		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();

		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if (savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if (lastDiff > -1)
			curDifficulty = lastDiff;
		else if (Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		// changeDiff();
		//	_updateSongLastDifficulty();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}
}
