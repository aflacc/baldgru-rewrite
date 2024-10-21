package states;

import backend.Highscore;
import haxe.Json;
import flixel.addons.display.FlxBackdrop;
/*#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1")
import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0")
import VideoHandler;
#else
import vlc.MP4Handler as VideoHandler;
#end
#end*/
using StringTools;

/**
 * extra extra extra extra extra extra extra extra extra extra
 * extra extra extra extra extra extra extra extra extra extra 
 * extra extra extra extra extra extra extra extra extra extra 
 * extra extra extra extra extra extra extra extra extra menu
 */
class ExtrasState extends MusicBeatState
{
	var descriptionText:FlxText;
	var nameText:FlxText;
	var arrowLeft:FlxSprite;
	var arrowRight:FlxSprite;
	var nameplate:FlxSprite;
	var image:FlxSprite;
	var imageGrp:FlxSpriteGroup; // layer

	var scrolldicator:FlxSprite; // its like "scroll indicator" if it was one word.... i'm funny, i swear!

	var allowScrolling:Bool = false;
	var scrollDist:Float = 0;

	var curSelected:Int = 0;

	var characterData:Array<Dynamic> = [];

	var entryLocked:Bool = false;
	var inspecting:Bool = false;

	var videoButton:FlxSprite;

	var previewBackground:FlxSprite;
	var previewImage:FlxSprite;

	var clickbox:FlxSprite;
	var videoing:Bool = false;

	#if VIDEOS_ALLOWED
	//var video:VideoHandler;
	#end

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF5E596A); // .loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		var scroll:FlxBackdrop = new FlxBackdrop(Paths.image("freeplay/pattern"), XY, -100.5, 0);
		scroll.velocity.set(0, 20);
		scroll.alpha = 0.13;
		scroll.scale.set(1280 / 1920, 1280 / 1920);
		add(scroll);

		var minionsBot:FlxBackdrop = new FlxBackdrop(Paths.image("extras/menuAssets/minions"), X);
		minionsBot.y = FlxG.height - minionsBot.height;
		minionsBot.velocity.set(30, 0);
		minionsBot.antialiasing = ClientPrefs.data.antialiasing;
		// add(minionsBot);

		var minionsTop:FlxBackdrop = new FlxBackdrop(Paths.image("extras/menuAssets/minions"), X);
		minionsTop.flipY = true;
		minionsTop.velocity.set(-30, 0);
		minionsTop.antialiasing = ClientPrefs.data.antialiasing;
		// add(minionsTop);

		var backBack:FlxSprite = new FlxSprite(50, 154).loadGraphic(Paths.image("extras/menuAssets/backback"));
		add(backBack);

		descriptionText = new FlxText(79, 197, 485, "my nuts. lol. You shouldn't be reading this.", 32);
		descriptionText.setFormat("Arial", 32, 0xFF232031);
		add(descriptionText);

		scrolldicator = new FlxSprite(61, 609).loadGraphic(Paths.image("extras/menuAssets/scrolldicator"));
		scrolldicator.antialiasing = ClientPrefs.data.antialiasing;
		add(scrolldicator);

		var back:FlxSprite = new FlxSprite(38, -20).loadGraphic(Paths.image("extras/menuAssets/back"));
		back.antialiasing = ClientPrefs.data.antialiasing;
		add(back);

		var tv:FlxSprite = new FlxSprite(684, 132).loadGraphic(Paths.image("extras/menuAssets/tv"));
		tv.antialiasing = ClientPrefs.data.antialiasing;
		add(tv);

		var descTitle:FlxText = new FlxText(99, 58, 451.15, "Description", 24);
		descTitle.setFormat(Paths.font("vcr.ttf"), 54, 0xFF232031, CENTER);
		add(descTitle);

		nameplate = new FlxSprite(750, 0);
		nameplate.frames = Paths.getSparrowAtlas("extras/menuAssets/name");
		nameplate.animation.addByPrefix("wa", "namebar change  instance 1", 24, false);
		nameplate.animation.play("wa", true);
		nameplate.antialiasing = ClientPrefs.data.antialiasing;
		add(nameplate);

		arrowLeft = new FlxSprite(660, 20);
		arrowLeft.frames = Paths.getSparrowAtlas("extras/menuAssets/arrow");
		arrowLeft.animation.addByPrefix("wa", "arrow press instance 1", 24, false);
		arrowLeft.animation.play("wa");
		arrowLeft.animation.finish(); // prevent the short moment of being able tosee the animation on menu open
		arrowLeft.antialiasing = ClientPrefs.data.antialiasing;
		add(arrowLeft);

		arrowRight = new FlxSprite(1180, 20);
		arrowRight.flipX = true;
		arrowRight.frames = Paths.getSparrowAtlas("extras/menuAssets/arrow");
		arrowRight.animation.addByPrefix("wa", "arrow press instance 1", 24, false);
		arrowRight.animation.play("wa");
		arrowRight.animation.finish(); // prevent the short moment of being able tosee the animation on menu open
		arrowRight.antialiasing = ClientPrefs.data.antialiasing;
		add(arrowRight);

		nameText = new FlxText(783.7, 54.4, 377.75, "my nuts", 46);
		nameText.setFormat(Paths.font("vcr.ttf"), 46, 0xFF232031, CENTER);

		nameText.alignment = CENTER;
		// nameText.wordWrap = false;
		add(nameText);

		imageGrp = new FlxSpriteGroup();
		add(imageGrp);

		image = new FlxSprite(983.2, 430);
		image.centerOrigin();
		image.x -= image.width / 2;
		image.y -= image.height / 2;
		imageGrp.add(image);

		videoButton = new FlxSprite(983.2, 430).loadGraphic(Paths.image("extras/menuAssets/video"));
		videoButton.centerOrigin();
		videoButton.x -= videoButton.width / 2;
		videoButton.y -= videoButton.height / 2;
		videoButton.alpha = 0.5;
		videoButton.visible = false;
		add(videoButton);

		previewBackground = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		previewBackground.alpha = 0;
		add(previewBackground);

		previewImage = new FlxSprite().loadGraphic(Paths.image("extras/characterstuff/brainless"));
		previewImage.screenCenter();
		add(previewImage);
		previewImage.alpha = 0;
		previewImage.antialiasing = ClientPrefs.data.antialiasing;

		clickbox = new FlxSprite(719, 168).makeGraphic(521, 519, FlxColor.BLUE);
		clickbox.alpha = 0.5;
        clickbox.visible = false;
		add(clickbox);

		refreshCharacterData();
		changeSelection();

		FlxG.sound.playMusic(Paths.music('baldIsle'), 0);
		FlxG.sound.music.fadeIn(3, 0, 0.7);

		#if VIDEOS_ALLOWED
		//video = new VideoHandler();
		#end

		super.create();
	}

	// should only need to be used once
	function refreshCharacterData()
	{
		var data = Paths.getTextFromFile('data/extras.json');
		var parsed = Json.parse(data);
		// trace(parsed);

		var tempArray:Array<Array<String>> = [];

		trace("doing");
		for (i in 0...parsed.characters.length)
		{
			var cur = parsed.characters[i];
			var temptemparrayarray:Array<String> = [];

			temptemparrayarray[0] = cur.name;
			temptemparrayarray[1] = cur.image;
			temptemparrayarray[3] = cur.unlock;
			temptemparrayarray[2] = (cur.description != null && cur.description != "") ? cur.description : "uh oh. no description provided...";
			temptemparrayarray[4] = (cur.scale != null) ? Std.string(cur.scale) : "1";
			temptemparrayarray[5] = cur.framerate; // cur.video
			temptemparrayarray[6] = (cur.zoom_scale == null) ? "0.25" : cur.zoom_scale;

			// trace(temptemparrayarray);
			tempArray.push(temptemparrayarray);
		}

		characterData = tempArray;
		// trace(characterData.length); this was messing me up. oops
		tempArray = null;

		trace("all done!");
	}

	function capitalize(str:String):String
	{
		// trace("a");
		var split1:Array<String> = str.split(" ");

		var newList:Array<String> = [];
		for (i in 0...split1.length)
		{
			var split2:Array<String> = split1[i].split("");
			split2[0] = split2[0].toUpperCase();
			newList.push(split2.join(""));
		}
		// trace("dsdasadss");
		var newString:String = newList.join(" ");
		trace(newString);

		return newString;
	}

	/*
		For V2, any expert coders out there want to tell me why this crashes
		public function startVideo(name:String)
		{
			trace("videoing!");
			inspecting = true;
			// inCutscene = true;
			//   videoPlaying = true;

			var filepath:String = Paths.video(name);
			#if sys
			if (!FileSystem.exists(filepath))
			#else
			if (!OpenFlAssets.exists(filepath))
			{
				FlxG.log.warn('Couldnt find video file: ' + name);
				inspecting = false;
				// startAndEnd();
				// videoPlaying = false;
				return;
			}
			#end
			#if VIDEOS_ALLOWED
			#if (hxCodec >= "3.0.0")
			// Recent versions
			trace("fuck?");
			video.play(filepath);
			video.onEndReached.add(function()
			{
				video.dispose();
				inspecting = false;
				// if (end)
				// startAndEnd();
				// videoPlaying = false;
				return;
			}, true);
			#else
			// Older versions
			video.playVideo(filepath);
			video.finishCallback = function()
			{
				inspecting = false;
				return;
			}
			#end
			#else
			FlxG.log.warn('Platform not supported!');
			inspecting = false;
			return;
			#end
		}
	 */
	// turns any string into question marks (includes spaces!)
	// ex: "my balls itch" => "?? ???? ????"
	// works roughly the same as capitalize as a base.
	// specifically ignoring "+" for loddy and pico
	function mysteryize(str:String):String
	{
		var split1:Array<String> = str.split(" ");

		var newList:Array<String> = [];
		for (i in 0...split1.length)
		{
			var split2:Array<String> = split1[i].split("");
			for (ii in 0...split2.length)
			{
				if (split2[ii] != "+")
					split2[ii] = "?";
			}
			newList.push(split2.join(""));
		}
		var newString:String = newList.join(" ");

		return newString;
	}

	function changeSelection(?change:Int = 0)
	{
		// "If only haxe did modulo the same way googles calculator did" I said to wizard, and he promptly showed me this.
		// Thank you wizard.
		// For context, if you type and negative number mod a number like say 10 it will return always a positive number and its cool
		curSelected = FlxMath.wrap(curSelected + change, 0, characterData.length - 1);
		descriptionText.y = 197;
		scrollDist = 0;
		allowScrolling = false;
		entryLocked = false;

		descriptionText.text = characterData[curSelected][2];
		descriptionText.applyMarkup(characterData[curSelected][2], [new FlxTextFormatMarkerPair(new FlxTextFormat(0x6404FF), "*")]);

		nameText.text = characterData[curSelected][0];
		nameplate.animation.play("wa", true);
		if (image != null)
		{
			image.destroy();
		}
		image = new FlxSprite(983.2, 430).loadGraphic(Paths.image("extras/characterstuff/" + characterData[curSelected][1]));
		if (characterData[curSelected][5] != null)
		{
			image.frames = Paths.getSparrowAtlas("extras/characterstuff/" + characterData[curSelected][1]);
			image.animation.addByPrefix("loop", "animation", Std.parseFloat(characterData[curSelected][5]), true);
			image.animation.play("loop");
		}
		image.centerOrigin();
		image.antialiasing = ClientPrefs.data.antialiasing;
		image.x -= image.width / 2;
		image.y -= image.height / 2;
		image.scale.set(Std.parseFloat(characterData[curSelected][4]), Std.parseFloat(characterData[curSelected][4]));
		imageGrp.add(image);

		// videoButton.visible = characterData[curSelected][5] != null;

		// beefs idea, a really good idea at that
		if (characterData[curSelected][0].toLowerCase() == "bald gru")
		{
			// If the window name rolls that 20% chance to be something that Isnt bald gru, display what that says here too.
			nameText.text = TitleState.chosenName;
			// descriptionText.text = characterData[curSelected][2].replace("Bald Gru", TitleState.chosenName); this doesnt work
		}

		if (characterData[curSelected][3] != null && characterData[curSelected][3] != "")
		{
			// trace(Highscore.getScore(characterData[curSelected][3], 0));
			var score:Int = Highscore.getScore(characterData[curSelected][3], 0);
			if (characterData[curSelected][3] == "ruther_setting")
			{
				score = ClientPrefs.data.ruther ? 1 : 0;
			}
			if (score == 0)
			{
				var lol = "Character entry is locked! Complete *" + capitalize(characterData[curSelected][3]).replace("-", " ") + "* to discover this entry!.";
				if (characterData[curSelected][3] == "ruther_setting")
				{
					lol = "Character entry is locked! Try looking for a *secret setting* first...";
				}
				if (FlxG.random.bool(5))
				{
					lol = "Human.. I remember youre *Locked Entries*...";
				}
				entryLocked = true;
				image.color = FlxColor.BLACK;
				image.alpha = 0.5;
				nameText.text = mysteryize(characterData[curSelected][0]);
				descriptionText.text = lol;
				descriptionText.applyMarkup(lol, [new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF0404), "*")]);
				videoButton.visible = false;
			}
		}

		if (descriptionText.y + descriptionText.height > 596)
		{
			allowScrolling = true;
		}

		Paths.clearUnusedMemory();
		trace(curSelected);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		previewBackground.alpha = FlxMath.lerp(previewBackground.alpha, inspecting ? 0.5 : 0, 9 * elapsed);
		previewImage.alpha = FlxMath.lerp(previewImage.alpha, inspecting ? 1 : 0, 24 * elapsed);
		var lrp = FlxMath.lerp(previewImage.scale.x,
			inspecting ? Std.parseFloat(characterData[curSelected][4]) + Std.parseFloat(characterData[curSelected][6]) : 0, 18 * elapsed);
		previewImage.scale.set(lrp, lrp);
		// previewImage.updateHitbox();
		if (!inspecting)
		{
			FlxG.sound.music.volume = FlxMath.lerp(FlxG.sound.music.volume, 1, 9 * elapsed);
			descriptionText.y = FlxMath.lerp(descriptionText.y, 197 - scrollDist, 9 * elapsed);

			if (controls.BACK)
			{
				MusicBeatState.switchState(new MainMenuState());
				FlxG.sound.playMusic(Paths.music(MainMenuState.nightCheck() ? 'nightTheme' : 'freakyMenu'));
			}

			if (controls.UI_LEFT_P)
			{
				changeSelection(-1);
				arrowLeft.animation.play("wa", true);
			}
			if (controls.UI_RIGHT_P)
			{
				changeSelection(1);
				arrowRight.animation.play("wa", true);
			}
			if (allowScrolling)
			{
				scrollDist += FlxG.mouse.wheel * -20;
				if (controls.UI_UP)
				{
					scrollDist -= 264 * elapsed;
				}
				if (controls.UI_DOWN)
				{
					scrollDist += 264 * elapsed;
				}
				scrollDist = FlxMath.bound(scrollDist, 0, -197 - 250 + descriptionText.height);
				// trace(scrollDist);
				// trace("and" + (-197 + descriptionText.height));
				scrolldicator.alpha = FlxMath.lerp(scrolldicator.alpha, scrollDist < 10 ? 1 : 0, 9 * elapsed);
			}
			else
			{
				scrolldicator.alpha = 0;
			}
			if (videoButton.visible)
			{
				if (FlxG.mouse.overlaps(videoButton))
				{
					videoButton.alpha = 0.85;
					videoButton.scale.set(1.1, 1.1);
					if (FlxG.mouse.justPressed)
					{
						FlxG.sound.music.volume = 0;
						inspecting = true;
						trace("v2 feature!! UH OH!!");
						// startVideo(characterData[curSelected][5]);
					}
				}
				else
				{
					videoButton.alpha = 0.5;
					videoButton.scale.set(1, 1);
				}
			}
			else
			{
				if (!entryLocked)
				{
					if (FlxG.mouse.overlaps(clickbox) && FlxG.mouse.justPressed && !videoButton.visible)
					{
						inspecting = true;
						previewImage.loadGraphic(Paths.image("extras/characterstuff/" + characterData[curSelected][1]));
						if (characterData[curSelected][5] != null)
						{
							previewImage.frames = Paths.getSparrowAtlas("extras/characterstuff/" + characterData[curSelected][1]);
							previewImage.animation.addByPrefix("loop", "animation", Std.parseFloat(characterData[curSelected][5]), true);
							previewImage.animation.play("loop");
							previewImage.animation.curAnim.curFrame = image.animation.curAnim.curFrame;
						}
						previewImage.screenCenter();
					}
				}
			}
		}
		else
		{
			if (inspecting)
			{
				if (FlxG.mouse.justPressed /*&& !FlxG.mouse.overlaps(previewImage)*/ || controls.BACK)
				{
					inspecting = false;
				}
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();
	}
}
