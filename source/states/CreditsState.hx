package states;

import flixel.util.FlxGradient;

class CreditsState extends MusicBeatState
{
	/* [ name, icon_path, desc, url, scream_path ] */
	// (url and or scream can be left blank or made null, for url make it just "")
	var credits:Array<Array<String>> = [
		[
			'BeefStarchJello',
			'beef',
			'Odd Day Director, Writer, Artistry for the bald, Charter, and Bald Gru & Sonic',
			'https://twitter.com/beefstarchjello',
			"baldiung moron"
		],
		[
			"BurritoBaptizer",
			"bb",
			'Even Day Director, Music of the Bald Variety, Voice of Geremy and Sonic Do Mau',
			'https://twitter.com/burritobaptizer',
			'burrito'
		],
		[
			"aflac",
			"aflac",
			"programmed all da things\ntrans rights         im sleepy",
			'https://twitter.com/aflaccck',
			"aflacscreamWAAAAHHH"
		],
		[
			'Scrumbo_',
			'scrumb',
			'Composering music\nNotably the "Jingle Bald" and the "Yolked',
			'https://twitter.com/scrumbo_',
			"scurmbo no!"
		],
		[
			'Izzys_Trying',
			'iz',
			'GameBanana Cover Art, Logo, & Album cover',
			'https://twitter.com/izzys_trying',
			'isdffsdfgsdhfdsgjydergfdrjterkreg'
		],
		[
			'Luigiman0',
			'luigiman',
			'Luigiman',
			'https://twitter.com/Iuigiman0',
			"luigermarn falls and Dies the Movie"
		],
		[
			'LodTheFraud',
			'lod',
			'Input, Assistance, Voice of Loddy',
			'https://twitter.com/LodtheFraud',
			null
		],
		[
			'Decoy',
			'decoy',
			'Voice of Carlito Doll',
			'https://twitter.com/Yoshinova_',
			null
		],
		[
			'Clo',
			'clover',
			'Charter for Lazy River',
			'https://twitter.com/Cloverderus',
			null
		],
		[
			'PhantomFear',
			'phantomfear',
			'Ending cutscene help',
			'https://twitter.com/PhantomFearOP',
			null
		],
		[
			'Crust',
			'crust',
			'Additional Art',
			'https://janitorcrust.newgrounds.com/',
			'i really like earthbund'
		],
		[
			'Daddy Dearest',
			'daddydearest',
			'Hi! I\'m Daddy Dearest! I play the role of Daddy Dearest in this FNF Mod! Hope you enjoy it, haha!     ',
			'https://twitter.com/DearestGamingYT',
			'daddy dearest dies to death'
		]
	];
	var curSelection:Int = 0;
	var cameraPoint:FlxPoint;
	var light:FlxSprite;
	var glow:FlxSprite;
	var conveyor:FlxSprite;
	var conveyorOffset:Float = 0;
	var iconsGrp:FlxSpriteGroup;
	var geremy:FlxSprite; // geremy please dont burn us alive geremy NO PLEASE AHHHHHHHHHHHHHHHHHHHH

	var signTitle:FlxText;
	var signDesc:FlxText;

	var allowControls:Bool = false;
	var allowFlickering:Bool = false;

	function useless(text:String):Void
	{
		// funny
	}

	override function create()
	{
		useless("This string can only be read through the source code OR through reading the .exe as a text file. Hello! Stop peeking into the file. Play. The MOD!!! - aflac");
		// ^ Why? Funny
		cameraPoint = new FlxPoint(FlxG.width / 2, -FlxG.height / 2); // strange behavior

		// DO STUFF HERE FIRST
		// OK

		var geremyRoom:FlxSprite = new FlxSprite().loadGraphic(Paths.image("credits/menuassets/geremyroomwall"));
		geremyRoom.antialiasing = ClientPrefs.data.antialiasing;
		geremyRoom.centerOrigin();
		geremyRoom.screenCenter();
		geremyRoom.y += 25;
		geremyRoom.x += 75;
		geremyRoom.scrollFactor.set(0.4, 0.4);

		geremy = new FlxSprite(410, -25);
		geremy.frames = Paths.getSparrowAtlas("credits/menuassets/geremy");

		// done this way bc offsets are BULLSHIT!!!
		geremy.animation.addByIndices("start", "germy", [0], "", 24, true);
		geremy.animation.addByIndices("enter", "germy", [for (i in 0...22) i], "", 24, false);
		geremy.animation.addByIndices("left", "germy", [for (i in 22...29) i], "", 24, false);
		geremy.animation.addByIndices("right", "germy", [for (i in 29...36) i], "", 24, false);
		geremy.antialiasing = ClientPrefs.data.antialiasing;
		geremy.scrollFactor.set(0.57, 0.57);
		geremy.animation.play("start", true);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("credits/menuassets/background"));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.centerOrigin();
		bg.screenCenter();
		bg.scrollFactor.set(0.6, 0.6);

		var incinerator:FlxSprite = new FlxSprite(89.3, 383.25).loadGraphic(Paths.image("credits/menuassets/incinerator"));

		incinerator.antialiasing = ClientPrefs.data.antialiasing;
		incinerator.centerOrigin();
		incinerator.screenCenter(Y);
		incinerator.x -= 200;
		incinerator.scrollFactor.set(0.7, 0.7);

		var sign:FlxSprite = new FlxSprite();
		sign.frames = Paths.getSparrowAtlas("credits/menuassets/sign");
		sign.animation.addByPrefix("down", "credit signs come down instance", 24, false);
		sign.scrollFactor.set(0.65, 0.65);
		sign.antialiasing = ClientPrefs.data.antialiasing;
		sign.screenCenter(X);
		sign.y -= 320;
		sign.visible = false; // It's slightly visible when the camera moves down so hide it to give the idea that its coming from higher up fast

		signTitle = new FlxText(0, 24, 576, "BeefStarchJello", 56);
		signTitle.setFormat(Paths.font("vcrneue.ttf"), 56, CENTER);
		signTitle.screenCenter(X);
		signTitle.visible = false;
		signTitle.antialiasing = ClientPrefs.data.antialiasing;
		signTitle.scrollFactor.set(0.65, 0.65);

		signDesc = new FlxText(0, 132, 967, "Odd Day Director, Artistry for the bald, Charter, and Bald Gru & Sonic VA", 38);
		signDesc.setFormat(Paths.font("vcr.ttf"), 38, CENTER);
		signDesc.screenCenter(X);
		signDesc.visible = false;
		signDesc.antialiasing = ClientPrefs.data.antialiasing; // Because text has antialiasing.. for osme reason
		signDesc.scrollFactor.set(0.65, 0.65);
		signDesc.wordWrap = true;
		signDesc.fieldHeight = 92;
		signDesc.alignment = FlxTextAlign.CENTER;

		conveyor = new FlxSprite(571, 553);
		conveyor.frames = Paths.getSparrowAtlas("credits/menuassets/conveyor_belt");
		conveyor.animation.addByPrefix("left", "conveyor move left instance 1", 24, false);
		// reminder to yell at beef to make a move right animation :3
		conveyor.scrollFactor.set(0.75, 0.75);
		conveyor.antialiasing = ClientPrefs.data.antialiasing;
		conveyor.animation.play("left", true);

		iconsGrp = new FlxSpriteGroup();
		iconsGrp.scrollFactor.set(0.75, 0.75);

		light = new FlxSprite().loadGraphic(Paths.image("credits/menuassets/light"));
		light.antialiasing = ClientPrefs.data.antialiasing;
		light.centerOrigin();
		light.screenCenter(Y);
		light.x -= 175;
		light.y += 65;
		light.scrollFactor.set(0.7, 0.7);
		light.blend = ADD;

		glow = new FlxSprite(-20, -300).loadGraphic(Paths.image("credits/menuassets/glow"));
		glow.scrollFactor.set(0.9, 0.5); // it's weird
		glow.antialiasing = ClientPrefs.data.antialiasing;
		glow.blend = ADD;

		// im a retard and i forgot to add this. thank you beef for reminding me. but like you didnt remind me
		// you just menntioned it and i was lije "What the fuck do you mean"
		var suicide:FlxSprite = new FlxSprite().loadGraphic(Paths.image("credits/menuassets/GOOGLE SEARCH HOW TO KILL MYSELF"));
		suicide.screenCenter();
		suicide.blend = MULTIPLY;
		suicide.x -= 16;
		suicide.y -= 40.7;
		suicide.antialiasing = ClientPrefs.data.antialiasing;

		add(geremyRoom);
		add(geremy);
		add(bg);
		add(sign);
		add(signTitle);
		add(signDesc);
		add(incinerator);
		add(conveyor);
		add(iconsGrp);
		add(light);
		add(glow);
		add(suicide);

		// Uh oh
		var ofs = 0;
		for (i in 0...credits.length)
		{
			var icon:FlxSprite = new FlxSprite(610 + (i * 256), 380);
			icon.frames = Paths.getSparrowAtlas("credits/icons/" + credits[i][1]);
			// icon.scale.set(0.45, 0.45);
			icon.animation.addByPrefix("loop", credits[i][1] + " icon", 24, true);
			icon.animation.play("loop", true);
			icon.flipX = false;
			icon.antialiasing = credits[i][1].endsWith("-pixel") ? false : ClientPrefs.data.antialiasing;
			iconsGrp.add(icon);
			icon.ID = i; // I think I'll make ID set to -1 when the icon has been thrown into the incinerator
			switch (credits[i][1])
			{
			}
			// ofs += 235;
		}
		super.create();
		// NOT AFTER
		var transGrad:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, 0x0]);
		transGrad.scrollFactor.set();
		transGrad.y = FlxG.height;
		var transBlack:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		transBlack.scrollFactor.set();
		add(transBlack);
		add(transGrad);

		FlxTween.tween(transBlack, {y: transBlack.y - FlxG.height * 2}, 1.5, {ease: FlxEase.quadOut});
		FlxTween.tween(transGrad, {y: transGrad.y - FlxG.height * 2}, 1.5, {ease: FlxEase.quadOut});
		FlxTween.tween(cameraPoint, {y: 0}, 2, {ease: FlxEase.quintOut});
		new FlxTimer().start(0.7, function(_)
		{
			geremy.animation.play("enter", true);
			new FlxTimer().start(0.6, function(_)
			{
				allowControls = true;
			});
		});
		new FlxTimer().start(1.2, function(_)
		{
			sign.visible = true; // I wrote this line and set visible to false am I retarded
			sign.animation.play("down", true);

			signTitle.alpha = 0;
			signTitle.visible = true;
			signDesc.alpha = 0;
			signDesc.visible = true;
			FlxTween.tween(signTitle, {alpha: 1}, 0.9, {ease: FlxEase.quadIn});
			FlxTween.tween(signDesc, {alpha: 1}, 1.1, {
				ease: FlxEase.quadIn,
				onComplete: function(_)
				{
					allowFlickering = true;
				}
			});
		});
		// AHHH
		FlxG.sound.playMusic(Paths.music('creditsTheme'), 0);
		FlxG.sound.music.fadeIn(6, 0, 0.7);
		FlxG.watch.add(geremy, "x", "gx");
		FlxG.watch.add(geremy, "y", "gy");
	}

	function changeSelection(change:Int = 0)
	{
		if (change >= 1
			&& iconsGrp.members[curSelection] != null
			&& iconsGrp.members[curSelection].ID != -1
			&& curSelection != credits.length)
		{
			// INTO THE PITS OF HELL!!!
			var fuck = iconsGrp.members[curSelection];
			fuck.ID = -1;
			fuck.velocity.set(-600, -150);
			fuck.acceleration.set(0, 450);
			fuck.angularVelocity = FlxG.random.int(280, 460);
			if (credits[curSelection][4] != null)
			{
				FlxG.sound.play(Paths.sound('credits/' + credits[curSelection][4]), 0.9);
			}
		}
		curSelection = Std.int(FlxMath.bound(curSelection + change, 0, credits.length));
		FlxTween.num(conveyorOffset, curSelection * 256, 0.3, {ease: change > 0 ? FlxEase.quintIn : FlxEase.quintOut}, function(num)
		{
			conveyorOffset = num;
		});

		signTitle.text = credits[curSelection] == null ? "" : credits[curSelection][0];
		signDesc.text = credits[curSelection] == null ? "" : credits[curSelection][2];
	}

	override function update(elapsed:Float)
	{
		// light flicker
		iconsGrp.forEach(function(icon:FlxSprite)
		{
			if (icon.ID == -1)
			{
				return;
			}
			icon.angle = FlxMath.lerp(icon.angle, icon.x - (610 + (icon.ID * 256) - conveyorOffset), 9 * elapsed);
			icon.x = 610 + (icon.ID * 256) - conveyorOffset;
			// trace(icon.ID + icon.x);
		});
		if (allowFlickering)
		{
			if (FlxG.random.bool(4))
			{
				signTitle.alpha = FlxG.random.float(0.8, 0.95);
			}
			if (FlxG.random.bool(4))
			{
				signDesc.alpha = FlxG.random.float(0.8, 0.95);
			}
		}
		if (FlxG.random.bool(5))
		{
			light.alpha = FlxG.random.float(0.8, 0.95);
		}
		else
		{
			light.alpha = 1;
		}
		if (FlxG.random.bool(2) && ClientPrefs.data.flashing)
		{
			glow.alpha = FlxG.random.float(0.5, 0.95);
		}
		else
		{
			glow.alpha = 1;
		}

		if (conveyor.animation.curAnim.finished && allowControls)
		{
			if (controls.UI_RIGHT_P)
			{
				if (curSelection != credits.length)
					conveyor.animation.play("left", true, false);
				geremy.animation.play("left", true);
				changeSelection(1);
			}
			else if (controls.UI_LEFT_P)
			{
				if (curSelection != 0)
					conveyor.animation.play("left", true, true);
				geremy.animation.play("right", true);
				changeSelection(-1);
			}
		}
		if (allowControls)
		{
			if (controls.ACCEPT)
			{
				if (curSelection != credits.length)
				{
					CoolUtil.browserLoad(credits[curSelection][3]);
				}
			}
		}

		FlxG.camera.scroll.set(FlxMath.lerp(FlxG.camera.scroll.x, cameraPoint.x + (FlxG.mouse.screenX - FlxG.width / 2) / 16 - FlxG.width / 2, 9 * elapsed),
			FlxMath.lerp(FlxG.camera.scroll.y, cameraPoint.y + (FlxG.mouse.screenY - FlxG.height / 2) / 24, 9 * elapsed));
		super.update(elapsed);

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music(MainMenuState.nightCheck() ? 'nightTheme' : 'freakyMenu'));
		}
	}
}
