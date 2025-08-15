package;

import hxd.Res;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
import hxd.Key;

class Instruction extends GameScene {

    var gameObj:Object = new Object();
    var instruct:Int = 0;
    var m1:Bitmap;
    var m2:Bitmap;
    public function new() {
        super();

      //  addConsole();
        add(gameObj, 0);
        addGameShaders(gameObj);

        m2 = new Bitmap(Res.images.instruction2.toTile(), gameObj);
        m2.setPosition(320, 120);
        m1 = new Bitmap(Res.images.instruction.toTile(), gameObj);
        m1.setPosition(320, 120);

    }

    override function fixedUpdate(dt:Float) {
        super.fixedUpdate(dt);
    }

    override function update(dt:Float) {
        super.update(dt);

        if(Key.isPressed(Key.Z) || Key.isPressed(Key.ENTER)){
            var snd = Res.sounds.powerup.play();
            if(instruct == 0) m1.remove();
            if(instruct == 1) m2.remove();
            instruct++;
            if(instruct > 1) changeScene(new Game());
        }
    }
}