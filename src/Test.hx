package;

import hxd.Key;
import Shaders.Outline;
import h2d.filter.Shader;
import hxd.Res;
import h2d.Bitmap;

class Test extends GameScene {
    var shader:Outline = new Outline();
    public function new() {
        super();

        var bg = new Bitmap(Res.images.nightsky.toTile().center(), this);
        bg.scale(2);
        bg.setPosition(width*0.5, height*0.5);

       // var seed = new Bitmap(Res.characters.Piranha.images.piranha_1.toTile().center(), this);
       // seed.setPosition(width*0.5, height*0.5);
       // seed.scale(2);
        //seed.filter = new Shader(shader);
       // seed.filter.useScreenResolution = true;
        var char = new objects.Player("Piranha", 1);
        char.direction = RIGHT;
        char.setPosition(width*0.5, height*0.5);
       // char.animation.blendMode = Add;
       char.filter = new Shader(shader);
       char.filter.useScreenResolution = true;
       char.animation.playAnimation("idle");
        addChild(char);
       // char.isCpuMode = bot;
       // char.slash.blendMode = Add;
       // char.bulBatch.blendMode = Add;
      // filter = new Shader(shader);
    }

    override function update(dt:Float) {
        super.update(dt);
        shader.time += dt;
        if(Key.isPressed(Key.ESCAPE)){
            changeScene(new Test());
        }
    }
}