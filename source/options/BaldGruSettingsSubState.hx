package options;

import backend.Highscore;

class BaldGruSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Mod Settings';
		rpcTitle = 'Bald Gru Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('Summer Mode',
			'swlurp slurp mmmmmmm popsiclkle,,,,,,, yum' + (Highscore.getScore("yolked", 0) > 0 ? "\nConsider checking out Lazy river!" : ""), 'summerMode',
			'bool');
		option.onChange = function()
		{
			if (ClientPrefs.data.summerMode)
				FlxG.sound.play(Paths.sound('settings/summer'), 0.9);
		};
		addOption(option);

		var option:Option = new Option('Distractions', 'If unchecked, distractions are hidden/disabled', 'distractions', 'bool');
		option.onChange = function()
		{
			if (ClientPrefs.data.distractions)
				FlxG.sound.play(Paths.sound('settings/distractions'), 0.9);
		};
		addOption(option);

		var option:Option = new Option('Cutscenes', 'If checked, cutscenes will in fact play.', 'cutscenes', 'bool');
		option.onChange = function()
		{
			if (!ClientPrefs.data.cutscenes)
				FlxG.sound.play(Paths.sound('settings/booooriiiing'), 1.6);
		};
		addOption(option);
		if (FlxG.random.bool(10) || ClientPrefs.data.crust)
		{
			var option:Option = new Option('Crust holding 18 pencils', 'If checked, Crust holds up 18 pencils to you.', 'crust', 'bool');
			option.onChange = function()
			{
				if (ClientPrefs.data.crust)
					FlxG.sound.play(Paths.sound('settings/pencils'), 1.6);
			};
			addOption(option);
		}

		if (FlxG.random.bool(20) || ClientPrefs.data.ruther)
		{
			var option:Option = new Option('Ruther', 'Enables Ruther.', 'ruther', 'bool');
			option.onChange = function()
			{
				if (ClientPrefs.data.ruther)
					FlxG.sound.play(Paths.sound('settings/ruther'), 0.9);
			};
			addOption(option);
		}
		super();
	}
}
