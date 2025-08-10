package objects;

import h2d.col.Bounds;
import utils.RotatedRect;
import h2d.SpriteBatch;
import h2d.Object;
import h2d.filter.Bloom;
import hxd.Math;
import h2d.col.Point;
import h2d.Tile;
import h2d.SpriteBatch.BatchElement;

class Bullet extends BatchElement {
    public var vel:Point = new Point();
    public var speed:Float = 1;
    public var name:String;
    public var lifeSpan:Float = 10;
    public var alive:Bool = true;
    public var hitbox(get, default):RotatedRect;

    public var hasParticles:Bool = false;
    public var particlesTimer:Float = 0.1;
    public var particlesGrp:Array<Bullet> = [];
    public var particlesBatch:SpriteBatch;
    public var object:Object;
    public function new() {
        super(t);
        t = Tile.fromColor(0x0000FF, 55, 12).center();
        particlesBatch = new SpriteBatch(null, Game.inst.gameObj);
        particlesBatch.hasRotationScale = particlesBatch.hasUpdate = true;
        hitbox = new RotatedRect(x, y, 10, 10);
    }

    override function update(dt:Float):Bool {
        vel.normalize();
        x += vel.x*speed;
        y += vel.y*speed;
       // rotation = Math.atan2(vel.y, vel.x);
        speed = Math.clamp(speed, -50, 50);

        lifeSpan -= dt;
        if(lifeSpan <= 0.0){
            alive = false;
            lifeSpan = 0;
        }

        if(hasParticles){
            particlesTimer -= dt;
        }

        for(i in particlesGrp){
            i.r = Math.lerp(i.r, 0.66, 0.15);
            i.rotation += dt*6;
            //i.vel.set(Math.lerp(i.vel.x, shootDir.x, 0.1), Math.lerp(i.vel.y, shootDir.y, 0.1));
           // i.vel.x = -vel.x;
            if(i.alpha > 0.0) i.alpha-=dt/i.lifeSpan;

        }

        return true;
    }

    public function doParticles(angle:Point) {
            var ang = Math.atan2(angle.y, angle.x);
            var b = new Bullet();
            b.t = Tile.fromColor(0xB3FF00, 10, 10).center();
            //b.name = name;
            b.speed = 0;
            b.lifeSpan = 0.2;
            b.vel.set(0, 0);
            b.x = x+Random.float(-20, 20)*Math.sin(ang);
            b.y = y+Random.float(-20, 20)*Math.cos(ang);
            particlesBatch.add(b);
            particlesGrp.push(b);
            particlesTimer = 0.01;
    }

    function get_hitbox():RotatedRect {
        hitbox.center.set(x, y);
        hitbox.width = 10;
        hitbox.height = 10;
        return hitbox;
    }
}