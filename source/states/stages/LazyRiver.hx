package states.stages;

import flixel.addons.display.FlxBackdrop;
import substates.GameOverSubstate;
import states.stages.objects.*;

class LazyRiver extends BaseStage
{
	// The original stage code for this was actually disgusting. I'm sorry but thats just the truth.
	var passerby:FlxSprite;
	var passerbyGrp:FlxSpriteGroup; // Layering purposes

	override function create()
	{
		GameOverSubstate.loopSoundName = "lazyriver-gameover-loop";
		GameOverSubstate.endSoundName = 'lazyriver-gameover-end';

		var bg:BGSprite = new BGSprite('stages/lazyriver/MC_Sky', -830, -200, 0.1, 0.1);
		bg.scale.set(1, 1.1);
		add(bg);

		var mg2:BGSprite = new BGSprite("stages/lazyriver/MC_middleground2", 280, 75, 0.3, 0.3);
		mg2.velocity.set(-2, 0); // I don't even think this works
		add(mg2);


		var mg:BGSprite = new BGSprite("stages/lazyriver/MC_middleground", 280, 75, 0.35, 0.35);
		mg.velocity.set(-4, 0);
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
		rocks.velocity.set(-60, 0);
		rocks.antialiasing = ClientPrefs.data.antialiasing;
		add(rocks);

		var water:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/mc_foreground_water"), X, -18);
		water.y = 480;
		water.scrollFactor.set(1, 1);
		water.velocity.set(-60, 0);
		water.antialiasing = ClientPrefs.data.antialiasing;
		add(water);

		passerbyGrp = new FlxSpriteGroup();
		add(passerbyGrp);
	}

	override function createPost()
	{
		var waterRocks:FlxBackdrop = new FlxBackdrop(Paths.image("stages/lazyriver/mc_waterRocks"), X, -18);
		waterRocks.y = 720;
		waterRocks.scrollFactor.set(1.1, 1.1);
		waterRocks.velocity.set(-60, 0);
		waterRocks.antialiasing = ClientPrefs.data.antialiasing;
		add(waterRocks);
	}

	var sine:Float = 0;
	var passerbySine:Float = 0;

	override function update(elapsed:Float)
	{
		passerbySine = passerbySine + elapsed;
		if (passerby != null)
		{
			passerby.offset.set(0, Math.sin(passerbySine) * 4);
			if ((passerby.ID == 0 && passerby.x <= -500 - passerby.width) || (passerby.ID == 1 && passerby.x >= FlxG.width * 2))
			{
				trace("destroying");
				passerby.destroy();
				passerby = null;
			}
		}
		sine = (sine + elapsed) % (Math.PI * 4);

		if (game.dad != null)
			game.dad.y = 100 - 170 + (Math.sin(sine) * 8);
	}

	var passerbys:Array<String> = ["baldgru", "beef","harvester"];

	override function beatHit()
	{
		// characters take forever to cross so 33% is fair
		// also, never thought i would write a "if thing IS null" LOL
		if (passerby == null && FlxG.random.bool(33))
		{
			passerby = new FlxSprite();
			// I'm really good at naming variables..
			var boob = FlxG.random.getObject(passerbys);
			trace('boo! its the ' + boob);// funny
			passerby.frames = Paths.getSparrowAtlas("stages/lazyriver/passerbys/" + boob);
			passerby.animation.addByPrefix("loop", boob, 24, true);
			passerby.animation.play('loop', true);
			switch (boob)
			{
				case "baldgru": // characters going up the river
					passerby.x = -700 - passerby.width;
					passerby.velocity.set(40, 0);
					passerby.ID = 1;
				case null: // characters going down the river (not just floating)
					passerby.x = FlxG.width * 2;
					passerby.velocity.set(-75, 0);
					passerby.ID = 0;
				default: // characters floating by (stationary)
					passerby.x = FlxG.width * 2;
					passerby.velocity.set(-60, 0);
					passerby.ID = 0;
			}
			passerby.antialiasing = ClientPrefs.data.antialiasing;
			passerby.origin.set(0, passerby.height);
			passerby.y = 400 + FlxG.random.int(0, 25);
			
			// offsets
			switch(boob) {
				case 'harvester':
					passerby.y -= 140;
			}
			passerbyGrp.add(passerby);
		}
	}
}
