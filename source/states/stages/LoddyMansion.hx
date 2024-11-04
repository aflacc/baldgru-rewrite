package states.stages;

import objects.VideoSprite;
import states.stages.objects.*;

// Halloween song! yeah!
// (I am starting this the day before halloween.. oops)
// STAGE WILL ASSUME THE SONG IS BALDOWEEN. PROBABLY. I DONT THINK IM GONNA ADD A BILLION CHECKS

// WE ARE NO LONGER HAVING THIS BE PART OF THIS VERSION BECAUSE FUCK YOU VIDEO CRASH!
// We'll put out a new version that has this song in the future. Sorry
// This stage is now unused, and because of how little has gone into the stage specifically, I don't really mind
class LoddyMansion extends BaseStage
{

   // var startVideo:VideoSprite = null;

    // hopefully this'll load the video?? please???
    function boob() {
        trace("please load");
        /*startVideo = */PlayState.instance.startVideo("scaryIntro", true, false,false, false);
        startCountdown();
    }
	override function create()
	{
        // should load but not play it
        // Code here
        switch (songName.toLowerCase())
			{
				case "baldoween":
				    setStartCallback(boob.bind());
			}
	}

	override function createPost()
	{
        // Code here
	}

    override function onSongStart() {
        PlayState.instance.startVideo("scaryIntro", true, false,false, true);
    }

	override function update(elapsed:Float)
	{
        // Code here
	}

	override function stepHit()
	{
		// Code here
	}

	override function beatHit()
	{
		// Code here
	}
}
