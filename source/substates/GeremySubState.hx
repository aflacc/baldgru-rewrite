package substates;

import flixel.addons.transition.FlxTransitionableState;
import backend.Song;
import objects.Character;

class GeremySubState extends MusicBeatSubstate
{
	var black:FlxSprite;
	var text:FlxText;
	var geremy:Character;

	var halt:FlxText;
	var geremyWarning:FlxText;
	var pressEnter:FlxText;
	public static var dumbass:Bool = false;
	public static var fleed:Bool = false;

	public function new(reset:Bool = false)
	{
		super();
		black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.alpha = 0;

		FlxG.sound.music.fadeOut(0.8, 0);

		geremy = new Character(280, FlxG.height + 64, "geremy", false);
		geremy.playAnim("halt", true);
		geremy.specialAnim = true;

		halt = new FlxText(0, -100, 0, "HALT!", 40);
		halt.setFormat("VCR OSD Mono", 40, FlxColor.RED, CENTER, OUTLINE, FlxColor.BLACK);
		halt.borderSize = 2;
		halt.y = -halt.height;
		halt.scale.set(1.5, 1.5);
		halt.screenCenter(X);
		halt.antialiasing = ClientPrefs.data.antialiasing;

		geremyWarning;
		geremyWarning = new FlxText(12, 64, FlxG.width - 128,
			"Master Guardian of the Freeplay Menu, Geremy, halts your advance.\nDefeat her in battle to gain access to the Freeplay Menu.\nYou CANNOT back out of this.",
			12);
		if (dumbass)
		{
			geremyWarning.text = "You wish to rematch? Only you have done this to yourself.\nDefeat her once more in battle to regain access to the Freeplay Menu.\nYou CANNOT stop this.";
		}
		if (fleed)
		{
			geremyWarning.text = "Where do you think you're going?\nGet back in there and finish what you've started.\nYou CANNOT back out of this.";
		}
		fleed = false;
		dumbass = false;

		geremyWarning.scrollFactor.set();
		geremyWarning.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		geremyWarning.screenCenter(X);
		geremyWarning.alpha = 0;

		pressEnter = new FlxText(0, FlxG.height - 96, 0, "Press ENTER to proceed.");
		pressEnter.alpha = 0;
		pressEnter.setFormat("VCR OSD Mono", 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pressEnter.screenCenter(X);
		add(black);
		add(geremy);
		add(halt);
		add(geremyWarning);
		add(pressEnter);

		FlxTween.tween(geremy, {y: FlxG.height - (geremy.height * 0.7)}, 1.2, {
			ease: FlxEase.quintOut
		});
		FlxTween.tween(halt, {y: 96}, 1.5, {
			ease: FlxEase.quintOut,
			onComplete: function(_)
			{
				FlxTween.tween(halt, {y: 16, "scale.x": 1, "scale.y": 1}, 1.2, {
					ease: FlxEase.quadInOut,
					startDelay: 1,
					onComplete: function(_)
					{
						FlxTween.tween(geremyWarning, {alpha: 1}, 0.85, {ease: FlxEase.quadIn});
						FlxTween.tween(pressEnter, {alpha: 1}, 0.5, {ease: FlxEase.quadIn, startDelay: 0.9});
					}
				});
			}
		});
		FlxTween.tween(black, {alpha: 0.8}, 0.7, {
			ease: FlxEase.quadInOut,
			onComplete: function(_)
			{
				FlxG.sound.play(Paths.sound('geremyAppear'), 0.4);

				FlxG.sound.playMusic(Paths.music('geremyTheme'), 0);
				FlxG.sound.music.fadeIn(3, 0, 0.6);
			}
		});
	}

	var challengeAccepted:Bool = false;

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && !challengeAccepted)
		{
			challengeAccepted = true;
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
			geremy.playAnim("enter", true);
			geremy.specialAnim = true;
			FlxTween.tween(black, {alpha: 0}, 0.5, {ease: FlxEase.quartIn});
			FlxTween.tween(halt, {y: -200, "scale.x": 0.5, "scale.y": 0.5}, 0.3, {ease: FlxEase.quartIn});
			FlxTween.tween(geremyWarning, {alpha: 0}, 0.6, {ease: FlxEase.quartIn});
			FlxTween.tween(pressEnter, {alpha: 0}, 0.2, {ease: FlxEase.quartIn});
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			new FlxTimer().start(1, function(_)
			{
				PlayState.SONG = Song.loadFromJson("yolked", "yolked");
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
		super.update(elapsed);
	}
}
