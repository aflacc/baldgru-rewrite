package states;

import flixel.addons.transition.FlxTransitionableState;
import objects.Character;
import states.stages.FreeplayStage;
import substates.GeremySubState;
import flixel.addons.display.FlxBackdrop;
import backend.WeekData;
import backend.Highscore;
import backend.Song;
import objects.HealthIcon;
import objects.MusicPlayer;
import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import flixel.math.FlxMath;

class FreeplayState extends MusicBeatState
{
	var rankStuff:Array<Float> = [
		1.0, // P
		0.9, // S
		0.85, // A
		0.80, // B
		0.75, // C
		0.6, // D
		0.3 // F
	];

	// you just got.. yolked!
	var yolked:Bool = false;

	public static var resetYolked:Bool = false;

	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	var speaker:FlxSprite;

	public static var curSelected:Int = 0;

	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;

	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

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

	var player:MusicPlayer;
	var geremy:FlxSprite;
	var geremyPressTimer:Float = 0;

	var sketches:FlxSprite;
	var rankSprite:FlxSprite;

	// var scoreText:FlxText;

	override function create()
	{
		// Paths.clearStoredMemory();
		// Paths.clearUnusedMemory();

		Paths.clearStoredMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			if (weekIsLocked(WeekData.weeksList[i]))
				continue;

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
		var scroll:FlxBackdrop = new FlxBackdrop(Paths.image("freeplay/pattern"), XY, -100.5, 0);
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

		scoreText = new FlxText(858, 139, 0, "000000000", 52);
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

		geremy = new FlxSprite(-38, 220);
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
		updateTexts();

		super.create();
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;

	public static var vocals:FlxSound = null;

	var holdTime:Float = 0;

	override function beatHit()
	{
		speaker.animation.play("Idle", false);
		super.beatHit();
	}

	override function update(elapsed:Float)
	{
		if (Highscore.getScore("yolked", 0) <= 0 && !yolked)
		{
			persistentUpdate = false;
			yolked = true;
			destroyFreeplayVocals();
			FlxTween.tween(geremy, {y: FlxG.height + 10}, 0.2, {ease: FlxEase.quartIn});
			openSubState(new GeremySubState(resetYolked));
		}
		rankSprite.scale.set(FlxMath.lerp(rankSprite.scale.x, 1280 / 1920, 14 * elapsed), FlxMath.lerp(rankSprite.scale.y, 1280 / 1920, 14 * elapsed));
		rankSprite.angle = FlxMath.lerp(rankSprite.angle, 0, 9 * elapsed);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		tvBg.color = FlxColor.interpolate(tvBg.color, intendedColor, 5 * elapsed);

		if (controls.ACCEPT || controls.UI_DOWN_P || controls.UI_UP_P || controls.BACK || FlxG.mouse.wheel != 0)
		{
			geremyPressTimer = 1.4;
			geremy.animation.play("press", true);
			geremy.offset.set(5, -37);
		}
		geremyPressTimer = Math.max(geremyPressTimer - elapsed, 0);
		if (geremyPressTimer == 0 && geremy.animation.curAnim.name != "wait")
		{
			geremy.animation.play("wait", true);
			geremy.offset.set(0, 0);
		}
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

		//	if (!player.playingMusic)
		//	{
		scoreText.text = Std.string(lerpScore);
		// positionHighscore();

		if (songs.length > 1)
		{
			if (FlxG.keys.justPressed.HOME)
			{
				curSelected = 0;
				changeSelection();
				holdTime = 0;
			}
			else if (FlxG.keys.justPressed.END)
			{
				curSelected = songs.length - 1;
				changeSelection();
				holdTime = 0;
			}
			if (controls.UI_UP_P)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if (controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
			}
		}

		if (controls.UI_LEFT_P)
		{
			changeDiff(-1);
			_updateSongLastDifficulty();
		}
		else if (controls.UI_RIGHT_P)
		{
			changeDiff(1);
			_updateSongLastDifficulty();
		}
		// }

		if (controls.BACK)
		{
			/*if (player.playingMusic)
				{
					FlxG.sound.music.stop();
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
					instPlaying = -1;

					player.playingMusic = false;
					player.switchPlayMusic();

					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
				}
				else
				{ */

			persistentUpdate = false;
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			// }
		}

		if (FlxG.keys.justPressed.CONTROL /*&& !player.playingMusic*/)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if (controls.ACCEPT /*&& !player.playingMusic*/)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				if (ClientPrefs.data.summerMode) {
					if (songLowercase == "lazy-river") {
						PlayState.SONG = Song.loadFromJson('lazy-summer', 'lazy-summer');
					}
				}
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if (colorTween != null)
				{
					colorTween.cancel();
				}
			}
			catch (e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if (errorStr.startsWith('[file_contents,assets/data/'))
					errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length - 1); // Missing chart
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
			if (PlayState.SONG.song.toLowerCase() == "yolked")
			{
				var chargeremy = new Character(280, FlxG.height + 64, "geremy", false);
				chargeremy.playAnim("idle", true);
				add(chargeremy);
				FlxTween.tween(geremy, {y: FlxG.height + 10}, 0.2, {ease: FlxEase.quartIn});
				FlxTween.tween(chargeremy, {y: FlxG.height - (chargeremy.height * 0.8)}, 0.65, {
					ease: FlxEase.quintOut
				});

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				new FlxTimer().start(0.75, function(_)
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			}
			else
			{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;

			destroyFreeplayVocals();
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else if (controls.RESET /*&& !player.playingMusic*/)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateTexts(elapsed);
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
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

	function changeDiff(change:Int = 0)
	{
		// if (player.playingMusic)
		//	return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length - 1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		FreeplayStage.whatShouldTheScoreSay = intendedScore;

		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		refreshRank(intendedRating);
		FreeplayStage.whatShouldTheRankSay = intendedRating;
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty);
		// if (Difficulty.list.length > 1)
		//	diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		// else
		// diffText.text = lastDifficultyName.toUpperCase();

		// positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		// if (player.playingMusic)
		//	return;

		_updateSongLastDifficulty();
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

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		// scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		// scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		///diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		// diffText.x -= diffText.width / 2;
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

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if (this.folder == null)
			this.folder = '';
	}
}
