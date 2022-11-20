package osu;

using StringTools;

// comments might get removed in following commits
class BeatmapConverter
{
    private static var beatmap:Beatmap = new Beatmap();
    private static var fnfChart:Song.SwagSong = 
    {
        song: 'unknown',
        notes: [],
        events: [],
        bpm: 200,
        needsVoices: false,
        speed: 3,
        player1: "bf",
        player2: "bf",
        player3: null,
        gfVersion: "gf",
        stage: "stage",
        arrowSkin: "NOTE_assets",
        splashSkin: "noteSplashes",
        validScore: false
    };

    public static function convertBeatmap()
    {
        var testMapPath = Paths.getLibraryPath('beatmap1.osu', "osu!beatmaps");
		var map = CoolUtil.coolTextFile(testMapPath);

        beatmap.AUDIO_FILENAME = beatmap.getBeatmapOption(map, 'AudioFilename');
        setTitle(map);
        setArtist(map);
        beatmap.CREATOR = beatmap.getBeatmapOption(map, 'Creator');
        beatmap.DIFFICULTY = beatmap.getBeatmapOption(map, 'Version');

        var bgLine:Int = beatmap.findLine(map, '[Events]') + 1; // +1 is to skip [Events] line
        if (map[bgLine].startsWith("//"))
            bgLine++;

        // i dont actually know how the numbers here work but im just going to assume the first ones are coordinates and the other numbers are just scales
        beatmap.BACKGROUND = beatmap.makeArray(map[bgLine], ",");

        var breaksLine:Int = bgLine + 1; // + 1 bc we want to skip the bg stuff
        if (map[breaksLine].startsWith("//")) // again bruh
            breaksLine++;

        // dumb af sorry, will look into a different way 
        var breaksStr = beatmap.makeArray(map[breaksLine], ",");
        var breaksPars:Array<Int> = [];
        for (i in 0...breaksStr.length)
            breaksPars.push(Std.parseInt(breaksStr[i]));

        beatmap.BREAKS = breaksPars; // maybe its a float, but hopefully these numbers are in strum time or stmh

        // this would literally break the whole script for some reason lol
        /*if (Std.parseInt(beatmap.getBeatmapOption(map, "Mode")) != 3)
            return;

        if (Std.parseInt(beatmap.getBeatmapOption(map, "CircleSize")) != 4)
            return;*/

        // i dont understand how notes are converted lol

        #if js
        MainWorker.execute("Parse", [beatmap.findLine(map, '[HitObjects]') + 1, map.length - 1, map]);
        MainWorker.onMessageCB = (ret:Dynamic) -> 
        {
            // TODO: Move to worker maybe
            var sectNote:Int = 0;
            var curSection:Int = 0;

            for (i in 0...ret.data.length)
            {
                fnfChart.notes[curSection] = 
                {
                    typeOfSection: 0,
                    sectionBeats: 4,
                    sectionNotes: [],
                    mustHitSection: true,
                    gfSection: false,
                    altAnim: false,
                    changeBPM: false,
                    bpm: fnfChart.bpm
                };

                for (note in 0...ret.data.length)
                {
                    if (ret.data[note][0] <= ((curSection + 1) * (4 * (1000 * 60 / fnfChart.bpm)))
                        && ret.data[note][0] > ((curSection) * (4 * (1000 * 60 / fnfChart.bpm))))
                    {
                        fnfChart.notes[curSection].sectionNotes[sectNote] = ret.data[note];
                        sectNote++;
                    }
                }
                sectNote = 0;

                if (ret.data[Std.int(ret.data.length - 1)] == fnfChart.notes[curSection].sectionNotes[fnfChart.notes[curSection].sectionNotes.length - 1])
                    break;

                curSection++;
            }

            // finish setting up
            fnfChart.song = beatmap.TITLE;

            PlayState.SONG = fnfChart;
            PlayState.storyDifficulty = 2;
            CoolUtil.difficulties = CoolUtil.defaultDifficulties;
            PlayState.instSource = Paths.getLibraryPath(beatmap.AUDIO_FILENAME, "osu!beatmaps");

            LoadingState.loadAndSwitchState(new PlayState(), false);
        };
        #end
    }

    // lol
    private static function setTitle(map:Array<String>)
    {
        beatmap.TITLE = beatmap.getBeatmapOption(map, "Title");
        if (beatmap.TITLE == null)
            beatmap.TITLE = beatmap.getBeatmapOption(map, "TitleUnicode");
        if (beatmap.TITLE == null)
            beatmap.TITLE = "ConvertedBeatmap";
    }

    private static function setArtist(map:Array<String>)
    {
        beatmap.ARTIST = beatmap.getBeatmapOption(map, 'Artist');
        if (beatmap.ARTIST == null)
            beatmap.ARTIST = beatmap.getBeatmapOption(map, 'ArtistUnicode');
        if (beatmap.ARTIST == null)
            beatmap.ARTIST = "BeatmapConverter";
    }
}