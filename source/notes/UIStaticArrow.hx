package notes;

import flixel.FlxSprite;

// from forever engine legacy, modified
class UIStaticArrow extends FlxSprite
{
    private var colorSwap:ColorSwap;
    public var downScroll:Bool = false;
    public var sustainReduce:Bool = true;
    public var texture(default, set):String = null;

    public var arrowType:Int = 0;
    public var initialX:Int;
    public var initialY:Int;

    public var setAlpha:Float = 0.8;
    public var resetAnim:Float = 0;
    public var direction:Float = 90;

    public function new(x:Float, y:Float, arrowType:Int = 0)
    {
        colorSwap = new ColorSwap();
        shader = colorSwap.shader;

        this.arrowType = arrowType;
        super(x, y);

        var skin:String = "NOTE_assets";
        if (PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;
        if (Paths.getSparrowAtlas(skin) == null)
            skin = "NOTE_assets";
        texture = skin;

        scrollFactor.set();
    }

    override function update(elapsed:Float)
    {
        if (resetAnim > 0)
        {
            resetAnim -= elapsed;
            if (resetAnim <= 0)
            {
                playAnim('static');
                resetAnim = 0;
            }
        }

        if (animation.curAnim.name == "confirm" && !PlayState.isPixelStage)
            centerOrigin();

        super.update(elapsed);
    }

    private function set_texture(value:String):String
    {
        if (texture != value)
        {
            texture = value;
            reloadNote();
        }
        return value;
    }

    public function reloadNote()
    {
        var lastAnim:String = null;
        if (animation.curAnim != null)
            lastAnim = animation.curAnim.name;

        if (PlayState.isPixelStage)
        {
            loadGraphic(Paths.image('pixelUI/$texture'), true, 17, 17);

            animation.add('static', [arrowType]);
            animation.add('pressed', [4 + arrowType, 8 + arrowType], 12, false);
            animation.add('confirm', [12 + arrowType, 16 + arrowType], 24, false);

            setGraphicSize(Std.int(width * PlayState.daPixelZoom));
            antialiasing = false;
        }
        else
        {
            var stringSect:String = getArrowFromNum(arrowType);

            frames = Paths.getSparrowAtlas(texture);
            animation.addByPrefix('static', 'arrow${stringSect.toUpperCase()}');
            animation.addByPrefix('pressed', '$stringSect press', 24, false);
            animation.addByPrefix('confirm', '$stringSect confirm', 24, false);

            antialiasing = ClientPrefs.globalAntialiasing;
            setGraphicSize(Std.int(width * 0.7));
        }

        updateHitbox();

        if (lastAnim != null)
            playAnim(lastAnim, true);
    }

    // % 4 should be % keyAmount or stmh
    public function playAnim(AnimName:String, Force:Bool = false)
    {
        if (AnimName == "confirm")
        {
            colorSwap.hue = ClientPrefs.arrowHSV[arrowType % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[arrowType % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[arrowType % 4][2] / 100;
            alpha = 1;

            if (!PlayState.isPixelStage)
                centerOrigin();
        }
        else
        {
            colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
            alpha = setAlpha;
        }

        animation.play(AnimName, Force);
        centerOffsets();
        centerOrigin();
    }

    public static function getArrowFromNum(num:Int)
    {
        var stringSex:String = "";
        switch (num)
        {
            case 0: stringSex = "left";
            case 1: stringSex = "down";
            case 2: stringSex = "up";
            case 3: stringSex = "right";
        }
        return stringSex;
    }

    public static function getColorFromNum(num:Int)
    {
        var stringSex:String = "";
        switch (num)
        {
            case 0: stringSex = "purple";
            case 1: stringSex = "blue";
            case 2: stringSex = "green";
            case 3: stringSex = "red";
        }
        return stringSex;
    }
}