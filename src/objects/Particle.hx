package objects;

import h2d.Bitmap;
import h2d.col.Point;
import h2d.Tile;
import h2d.SpriteBatch.BatchElement;

class Particle extends BatchElement {
    public var vel:Point = new Point();
    public var speed:Float = 1;
    public var lifeSpan:Float = 0.6;
    public function new(t:Tile) {
        super(t);
        if(t != null) t.setCenterRatio();
    }

    override function update(dt:Float):Bool {
        vel.normalize();
        x+= vel.x*speed*dt*60;
        y+= vel.y*speed*dt*60;
        lifeSpan -= dt;
        if(lifeSpan <= 0.0){
            remove();
        }
        return true;
    }
}