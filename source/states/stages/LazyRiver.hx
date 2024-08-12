package states.stages;

import flixel.addons.display.FlxBackdrop;
import substates.GameOverSubstate;
import states.stages.objects.*;

class LazyRiver extends BaseStage
{
	// The original stage code for this was actually disgusting. I'm sorry but thats just the truth.
	override function create()
	{
		GameOverSubstate.loopSoundName = "lazyriver-gameover-loop";
		GameOverSubstate.endSoundName = 'lazyriver-gameover-end';

		var bg:BGSprite = new BGSprite('stages/lazyriver/MC_Sky', -830, -200, 0.1, 0.1);
		bg.scale.set(1, 1.1);
		add(bg);

		var mg2:BGSprite = new BGSprite("stages/lazyriver/MC_middleground2", 280, 75, 0.3, 0.3);
		mg2.velocity.set(-2,0); // I don't even think this works
		add(mg2);

		var mg:BGSprite = new BGSprite("stages/lazyriver/MC_middleground", 280, 75, 0.35, 0.35);
		mg.velocity.set(-4,0);
		add(mg);
		var clouds:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/MC_clouds"), X, 400, 0);
		clouds.scrollFactor.set(0.4, 0.4);
		clouds.velocity.set(-5, 0);
		clouds.antialiasing = ClientPrefs.data.antialiasing;
		clouds.y = -250;
		add(clouds);

		var rocks:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/mc_foreground_rocks"), X, -18);
		rocks.y = 240;
		rocks.scrollFactor.set(0.9, 0.9);
		rocks.velocity.set(-40, 0);
		rocks.antialiasing = ClientPrefs.data.antialiasing;
		add(rocks);

		var water:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/mc_foreground_water"), X, -18);
		water.y = 480;
		water.scrollFactor.set(1, 1);
		water.velocity.set(-40, 0);
		water.antialiasing = ClientPrefs.data.antialiasing;
		add(water);
	}

	override function createPost()
	{
		var waterRocks:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/mc_waterRocks"), X, -18);
		waterRocks.y = 720;
		waterRocks.scrollFactor.set(1.1, 1.1);
		waterRocks.velocity.set(-40, 0);
		waterRocks.antialiasing = ClientPrefs.data.antialiasing;
		add(waterRocks);
	}

	var sine:Float = 0;

	override function update(elapsed:Float)
	{
		sine = (sine + elapsed) % (Math.PI * 4);
		if (game.dad != null)
			game.dad.y = 100 - 170 + (Math.sin(sine) * 8);
	}
}
