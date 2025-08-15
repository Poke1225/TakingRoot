package;

import hxd.WaitEvent;
import hxd.Res;
import sys.thread.Thread;
import h2d.Object;
import hxd.Math;
import h2d.Tile;
import h2d.Bitmap;

class Loading extends GameScene {
    var images = ["arena", "instruction", "instruction2", "moon", "nightsky", "seedparticle", "superseed", "slash"];
    var sounds = ["battle", "hurt", "powerup", "shoot", "slash"];
    var progress:Float = 0;
    var max = 10;
    var progressBar:Bitmap;
    var gameObj:Object = new Object();
    var finished:Bool = false;
    public function new() {
        super();
        add(gameObj, 0);
        addGameShaders(gameObj);
        progressBar = new Bitmap(Tile.fromColor(0xFFFFFF, 640, 30), gameObj);
        progressBar.setPosition(320, 300);


       // Thread.create(() ->{
            for (i in images){
                Res.load("images/"+i+".png").toTile();
                progress += 1;
            }
            for (i in sounds){
                Res.load("sounds/"+i+".ogg").toSound();
                trace("Cached " + i + ".ogg");
                progress += 1;
            }

            finished = true;
        //});
    }

    var waitEvent:WaitEvent = new WaitEvent();
    override function update(dt:Float) {
        super.update(dt);
        waitEvent.update(dt);
        var lerpTarget:Float = 640.0 * (progress / max);
		progressBar.scaleX = Math.lerp(progressBar.scaleX, lerpTarget, dt * 5);
        if(finished){
            waitEvent.wait(1, function() {
                changeScene(new Menu());
            });
        }
    }
}