package options;

import options.SideBar;
import options.OptionItem;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

//planned stuff, the note stuff will still be the same
//same with mobile controls and controls,
//the only thing that will change is the preferences
//becase its going to be harder to rewrite all of those

//main categories = graphics, gameplay, visuals and ui, audio, optimization, storage access and options personalization
class NewOptionsState extends MusicBeatState
{
    public static var menuBG:FlxSprite;
    public static var bgOverlay:FlxSprite;
    public static var sideBarItems:FlxTypedGroup<SideBarItem>;
    public static var grpOptions:FlxTypedGroup<OptionItem>;
    public static var contentSideBG:FlxSprite;
    public static var descText:FlxText;

    public static var categories = ["Graphics", "Gameplay", "Visuals and UI", "Audio", "Optimization", "Storage access", "Options personalization"];
    public static var options:Map<String, Array<Dynamic>> = new Map();

    public static var selectionState:String = "Choosing category";
    public static var curItem:Int = 0;
    public static var firstOpening:Bool = true;
    public static var curOption:Int = 0;

    override function create() 
    {
        //these look really confusing
        options.set('Graphics', [
            [
                ["Low quality"], 
                ["If checked, disables some background details,\ndecreases loading times and improves performance."],
                ["lowQuality"]
            ],
            [
                ["Anti-Aliasing"], 
                ["If unchecked, disables anti-aliasing, increases performance\nat the cost of the graphics not looking as smooth."],
                ["globalAntialiasing"]
            ],
            #if !html5
            [
                ['Framerate'], 
                ["Pretty self explanatory, isn't it?\nDefault value is 60."],
                ["framerate"]
            ],
            #end
        ]);

        options.set('Gameplay', [
            [
                ["Downscroll"], 
                ["If checked, notes go Down instead of Up, simple enough."],
                ["downScroll"]
            ],
            [
                ["Middlescroll"], 
                ["If checked, hides Opponent's notes and your notes get centered."],
                ["middleScroll"]
            ],
            [
                ["Ghost Tapping"], 
                ["If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit."],
                ["ghostTapping"]
            ],
            [
                ["Note Delay"], 
                ["Changes how late a note is spawned.\nUseful for preventing audio lag from wireless earphones."],
                ["noteOffset"]
            ],
            [
                ["Camera movement on note press"], 
                ['Moves the camera to the note direction'],
                ["cameraMovOnNoteP"]
            ]
        ]);

        options.set('Visuals and UI', [
            [
                ["FPS Counter"], 
                ["If unchecked, hides FPS Counter."],
                ["showFPS"]
            ],
            [
                ["Memory Counter"], 
                ["Displays a memory counter"],
                ["showMemory"]
            ],
            [
                ["Hide HUD"], 
                ["If checked, hides most HUD elements."],
                ["hideHud"]
            ],
            [
                ["Hide Song Length"], 
                ["If checked, the bar showing how much time is left\nwill be hidden."],
                ["hideTime"]
            ],
            [
                ["Flashing Lights"], 
                ["Uncheck this if you're sensitive to flashing lights!"],
                ["flashing"]
            ],
            [
                ["Camera Zooms"], 
                ["If unchecked, the camera won't zoom in on a beat hit."],
                ["camZooms"]
            ],
            [
                ["Icon Boping"], 
                ["If checked, icons bop"],
                ["iconBoping"]
            ]
        ]);

        options.set('Audio', [
            [
                ["Pause Music"], 
                ["What song do you prefer for the Pause Screen?"],
                ["pauseMusic"]
            ]
        ]);

        options.set('Optimization', [
            [
                ["Disable score tween"], 
                ['Disables score bop on sick'],
                ["optDisableScoreTween"]
            ],
            [
                ["Hide Health bar"], 
                ['Hides health bar and replaces it with a percentage'],
                ["optHideHealthBar"]
            ]
        ]);

        options.set('Storage access', [
            #if FEATURE_STORAGE_ACCESS
            [
                ["Chart priority"], 
                ["Change the chart scan priority when\nsearching charts"],
                ["chartScanPriority"]
            ]
            #elseif html5
            [
                ["Not compatible with JS targets"], 
                [""],
                [""]
            ]
            #elseif (sys && !FEATURE_STORAGE_ACCESS)
            [
                ["Feature disabled"], 
                [""],
                [""]
            ]
            #end
        ]);

        options.set('Options personalization', [
            [
                ["Music"], 
                ["What song do you prefer on this screen"],
                ["placeholder"]
            ],
            [
                ["Background Color"], 
                ["The background color, easy enough"],
                ["placeholder"]
            ]
        ]);

        Main.fpsVar.textColor = 0x000000;
        Main.memoryVar.textColor = 0x000000;

        menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = ClientPrefs.globalAntialiasing;
        add(menuBG);

        bgOverlay = new FlxSprite().makeGraphic(FlxG.width - 30, FlxG.height - 30, FlxColor.BLACK);
        bgOverlay.screenCenter();
        bgOverlay.alpha = 0.5;
        add(bgOverlay);

        add(new SideBar(Std.int(bgOverlay.height)));

        sideBarItems = new FlxTypedGroup();
        add(sideBarItems);

        contentSideBG = new FlxSprite().makeGraphic(Std.int(bgOverlay.width) - 345, Std.int(bgOverlay.height) - 16, FlxColor.WHITE);
        contentSideBG.screenCenter();
        contentSideBG.x += 160;
        contentSideBG.alpha = 0.7;
        add(contentSideBG);

        grpOptions = new FlxTypedGroup<OptionItem>();
        add(grpOptions);

        descText = new FlxText(Std.int(bgOverlay.width) - 345, Std.int(bgOverlay.height) - 16, 0, "placeholder", 20);
        descText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.BLACK, LEFT);
        add(descText);

        var curPos = 270;
        for(i in 0...categories.length)
        {
            var sideBarItem = new SideBarItem(categories[i], curPos - 50, i);
            sideBarItems.add(sideBarItem);
            curPos -= 50;
        }

        changeItem();
        generateOptions(categories[curItem]);

        #if android
        addVirtualPad(LEFT_FULL, A_B);
        #end

        super.create();
        firstOpening = false;
    }

    override function update(elapsed:Float)
    {
        if(selectionState == "Choosing category")
        {
            if(controls.BACK)
            {
                Main.fpsVar.textColor = 0xFFFFFF;
                Main.memoryVar.textColor = 0xFFFFFF;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new MainMenuState());
            }
            
            if(controls.UI_UP_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                changeItem(-1);
                generateOptions(categories[curItem]);
            }
            if(controls.UI_DOWN_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                changeItem(1);
                generateOptions(categories[curItem]);
            }

            if(controls.ACCEPT)
            {
                selectionState = "In category";
                sideBarItems.forEach(function(sideBarItem:SideBarItem)
                {
                    if(sideBarItem.ID == curItem)
                    {
                        FlxG.sound.play(Paths.sound('confirmMenu'));
                        sideBarItem.bg.color = FlxColor.GREEN;
                        changeOption();
                    }
                });
            }
        }

        if(selectionState == "In category")
        {
            if(controls.BACK)
            {
                selectionState = "Choosing category";
                sideBarItems.forEach(function(sideBarItem:SideBarItem)
                {
                    if(sideBarItem.ID == curItem)
                    {
                        FlxG.sound.play(Paths.sound('cancelMenu'));
                        curOption = 0;
                        sideBarItem.bg.color = FlxColor.GRAY;
                    }
                });

                grpOptions.forEach(function(optionItem:OptionItem)
                {
                    optionItem.bg.color = FlxColor.WHITE;
                });
            }

            if(controls.UI_UP_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                changeOption(-1);
            }
            if(controls.UI_DOWN_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                changeOption(1);
            }
        }

        super.update(elapsed);
    }

    function changeItem(change:Int = 0)
    {
        curItem += change;

        if(curItem >= categories.length)
            curItem = 0;
        if(curItem < 0)
            curItem = categories.length - 1;

        sideBarItems.forEach(function(sideBarItem:SideBarItem)
        {
            sideBarItem.bg.color = FlxColor.WHITE;

            if(sideBarItem.ID == curItem)
            {
                sideBarItem.bg.color = FlxColor.GRAY;
            }
        });
    }

    function generateOptions(category:String)
    {
        if(!firstOpening && grpOptions.length > 0)
        {
            grpOptions.clear();
        }
        var optionshit = options.get(category);
        var curPos = 300;
        for(i in 0...optionshit.length)
        {
            grpOptions.add(new OptionItem(optionshit[i][0].toString(), curPos, i, optionshit[i][2]));
            curPos -= 50;
        }
    }

    function changeOption(change:Int = 0)
    {
        curOption += change;

        if(curOption >= grpOptions.length)
            curOption = 0;
        if(curOption < 0)
            curOption = grpOptions.length - 1;

        grpOptions.forEach(function(optionItem:OptionItem)
        {
            optionItem.bg.color = FlxColor.WHITE;

            if(optionItem.ID == curOption)
            {
                optionItem.bg.color = FlxColor.GRAY;
            }
        });
    }
}