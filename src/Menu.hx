package;

import hxd.Res;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
import hxd.Key;

class Menu extends GameScene {

    var gameObj:Object = new Object();
    public function new() {
        super();

      //  addConsole();
        add(gameObj, 0);
         for(i in 0...2){
            var t = new Bitmap(Tile.fromColor(0x00FF0000), gameObj);
            if(i > 0) t.setPosition(320+640*(i), 120+480*(i));
            else t.setPosition(319, 119);
        }
        addGameShaders(gameObj);
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