package objects;


import h2d.filter.Shader;
import h2d.filter.Group;
import h2d.col.Bounds;
import h2d.col.Point;
import h2d.col.RoundRect;
import sys.io.File;
import hxd.Res;
import h2d.Anim;
import h2d.Tile;
import h2d.Bitmap;

@:access(h2d.Tile)

class AnimatedSprite extends Anim {
    public var animation:Anim;
    public var animations:Map<String, Array<Tile>> = [];
    public var image:Tile;
    public var animName:String;
    var animOffsets:Map<String, Array<Float>> = [];
    
    var xml:Xml;
    var xmlDirectory:String;
	var needToCenter:Bool = false;
    public function new(x:Float, y:Float, ?image:Tile, ?xmlDirectory:String) {
        super();

        setPosition(x, y);

       // tile = Tile.fromColor(0xFF06E806, 1, 1, 0);

        this.image = image;
        this.xmlDirectory = xmlDirectory;

       // smooth = true;
       // filter1.smooth = true;
     //   animation = new Anim(null, 24, this);
        //smooth = true;
        speed = 24;
        //animation.filter = filter1;

        xml = Xml.parse(File.getContent(xmlDirectory)).firstElement();
    }

    var frameData:FrameData = {};
    var arrChild:Array<Array<Float>> = [];
    var childSubstr:String;
    var fullChildSubstr:String;
    var xmlName:String;
    //var adjustedDx:Float = 0;
    //var adjustedDy:Float = 0;
    public function addAnimation(name:String, nameFromXML:String, ?offset:Array<Int>, ?playAnimAfterAddition:Bool) {
        var anims:Array<Tile> = [];
        //trace(image.dx);
       // animOffsets = [];
        xmlName = nameFromXML;
        for (child in xml.elements()) {
            childSubstr = child.get("name").substring(0, child.get("name").length - 4);
            var size = new Bounds();
            frameData.x = Std.parseInt(child.get("x"));
			frameData.y = Std.parseInt(child.get("y"));
			frameData.width = Std.parseInt(child.get("width"));
			frameData.height = Std.parseInt(child.get("height"));
			if (child.exists("frameX"))
				frameData.frameX = -Std.parseInt(child.get("frameX"));
			if (child.exists("frameY"))
				frameData.frameY = -Std.parseInt(child.get("frameY"));
			if (child.exists("frameWidth"))
				frameData.frameWidth = Std.parseInt(child.get("frameWidth"));
			if (child.exists("frameHeight"))
				frameData.frameHeight = Std.parseInt(child.get("frameHeight"));
			frameData.name = (child.get("name"));

            size.x = frameData.frameX;
            size.y = frameData.frameY;
            size.width = frameData.frameWidth;
            size.height = frameData.frameHeight;
            animOffsets.set(frameData.name, [frameData.frameX, frameData.frameY]);
            if (childSubstr == nameFromXML) {
                var frame:Tile = image.sub( frameData.x, 
                                            frameData.y, 
                                            frameData.width, 
                                            frameData.height,
                                            frameData.frameX,
                                            frameData.frameY);
               // frame.grid(1, frameData.frameX, frameData.frameY);
               if(needToCenter) frame.setCenterRatio();
                if (offset != null) {
                    //addOffsetToAnimation(name, offset);
                }
              //  frame.dx -= (animOffsets.get(childSubstr+"0000") != null ? animOffsets.get(childSubstr+"0000")[0] : 0);
              //  frame.dy -= (animOffsets.get(childSubstr+"0000") != null ? animOffsets.get(childSubstr+"0000")[1] : 0);
                anims.push(frame);
            }
        }
        animations.set(name, anims);
        if (playAnimAfterAddition) {
            playAnimation(name);
        }
    }

    /**
     * FIXME: Offsets are *ever so slightly* incorrect
     */
    function addOffsetToAnimation(animationName:String, offset:Array<Int>) {
        for (frames in animations.get(animationName)) {
            //offset[0] -= Std.int(frameData.frameX);
            //offset[1] -= Std.int(frameData.frameY);
          //  if(childSubstr == xmlName){
               var adjustedDx = frames.dx;
               var adjustedDy = frames.dy;

                frames.dx +=  offset[0] - (animOffsets.get(childSubstr+"0000") != null ? animOffsets.get(childSubstr+"0000")[0] : 0);
                frames.dy +=  offset[1] - (animOffsets.get(childSubstr+"0000") != null ? animOffsets.get(childSubstr+"0000")[1] : 0);
                //break;
            //}
        }
    }

    public function playAnimation(name:String, flipX:Bool = false) {
        for (i in 0...animations.get(name).length) animations.get(name)[i].xFlip = flipX;
        play(animations.get(name));
        animName = name;
    }

    
}
typedef FrameData = {
        ?name:String,
        ?x:Float,
        ?y:Float,
        ?frameX:Float,
        ?frameY:Float,
        ?width:Int,
        ?height:Int,
        ?frameWidth:Int,
        ?frameHeight:Int
    }