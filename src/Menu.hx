package;

import h2d.Scene;
import hxd.Res;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
import hxd.Key;

class Menu extends GameScene {

    var gameObj:Scene = new Scene();
    public function new() {
        super();

        var src = Res.sounds.powerup.play();
        src.mute = true;
      //  addConsole();
        add(gameObj, 0);
       // addGameShaders(gameObj);
    }

    override function fixedUpdate(dt:Float) {
        super.fixedUpdate(dt);
    }

    override function update(dt:Float) {
        super.update(dt);

        if(Key.isPressed(Key.Z) || Key.isPressed(Key.ENTER)){
            var src = Res.sounds.powerup.play();
            changeScene(new Instruction());
        }
    }
}