package states;

import flixel.util.FlxSort;

// For future use!!
class TestState extends MusicBeatState
{
	var roomGrp:FlxSpriteGroup;

	var clockText:FlxText;
	var box:FlxSprite;

	override public function create()
	{
		Paths.clearStoredMemory();

		// Test Code here !!
		var vcr:FlxText = new FlxText(0,0,0,"This is VCR OSD Mono",24);
		vcr.setFormat(Paths.font("vcr.ttf"),24);
		var neue:FlxText = new FlxText(0,32,0,"This is VCR OSD Mono *Neue*",24);
		neue.setFormat(Paths.font("vcrneue.ttf"),24);
		add(vcr);
		add(neue);

		FlxG.mouse.visible = true;
		super.create();
	}

	override public function update(elapsed:Float)
	{
		// Test Code here !!


		if (FlxG.mouse.pressed)
		{
			FlxG.camera.scroll.add(-FlxG.mouse.deltaScreenX, -FlxG.mouse.deltaScreenY);
		}
		FlxG.camera.zoom += FlxG.mouse.wheel * (FlxG.camera.zoom * elapsed);
		if (FlxG.keys.justPressed.R)
		{
			FlxG.camera.scroll.set(0, 0);
			FlxG.camera.zoom = 1;
		}

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}
