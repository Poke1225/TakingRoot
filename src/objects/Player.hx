package objects;

import hxd.snd.Effect;
import h2d.filter.Shader;
import Shaders.Masking;
import h2d.SpriteBatch;
import h2d.RenderContext;
import utils.RotatedRect;
import hxd.Res;
import hxd.Math;
import hxd.App;
import haxe.Json;
import h2d.Tile;
import h2d.Bitmap;
import hxd.Key;
import h2d.col.Point;
import h2d.Object;

@:access(h2d.Bitmap)


typedef PlayerData = {
    characterName:String,
    health:Float,
    speed:Float,
    atk:Float,
    jumpForce:Float
}

enum PlayerDirection {
    LEFT;
    RIGHT;
}

class Attack extends Object {
    public var _name:String;
    public var texture:Bitmap;
    public var hitbox:RotatedRect;
    public var lifeSpan:Float;
    
    public function new() {
        super();
    }
}

class Player extends Object {

    public var characterName:String = "";
    public static var texture:Bitmap; 
    public var animation:AnimatedSprite;
    var data:PlayerData;
    var interp:hscript.Interp;
    var parser:hscript.Parser;

    // CHAR STATS
    public var health:Float = 1;
    public var charSpeed:Float = 5;
    public var atk:Float = 1;
    public var energy:Float = 100;

    public var isCpuMode:Bool = false;
    public var isAlive:Bool = true;
    public var player:Int = 1;
    public var inputs:Map<String, Int> = [];
    //PHYSICS
    public var hitbox(get, default):RotatedRect;
    public var direction:PlayerDirection = RIGHT;
    public var vel:Point = new Point();
    public var gravity:Float = 9.81;
    var jumpForce:Float = 1;
    public var jumpCount:Int = 2;
    public var onGround:Bool;
    public var isJumping:Bool;
    public var isDodging:Bool;
    public var isMoving:Bool;
    public var bulGrp:Array<Bullet> = [];
    public var bulBatch:SpriteBatch;
    public var damaged:Bool = false;
    public var invTime:Float = 1;
    public var dodgeTime:Float = 0.9;
    public var canShoot:Bool = true;
    public var shootTimer:Float = 0.3;
    public var slash:AnimatedSprite;
    public var canAttack:Bool = true;
    public var isAttacking:Bool;
    public var attackTimer:Float = 0.4;
    public var attacksGrp:Array<Attack> = [];
    public var currentAttack:Attack;

    //SOME EFFECTS
    var deadShader:Masking = new Masking();


    public function new(_name:String = "Fireman", player:Int) {
        super();
        characterName = _name;
        this.player = player;
        setInputs(player);
        data = Json.parse(Res.load("characters/"+characterName+"/data.json").entry.getText());
        charSpeed = data.speed;
        health = data.health;
        atk = data.atk;
        jumpForce = data.jumpForce;
        texture = new Bitmap(Tile.fromColor(0xFFFFFF, 50, 60), this);
        texture.alpha = 0.0;

        bulBatch = new SpriteBatch(null, null);
        bulBatch.hasUpdate = bulBatch.hasRotationScale = true;
       // texture.tile.setCenterRatio();
       // texture.scale(0.5);
       //animation = new AnimatedSprite(0, 0,)

        animation = new AnimatedSprite(0,0, Res.load("characters/"+characterName+"/images/"+characterName.toLowerCase()+".png").toTile(),
                                            "res/characters/"+characterName+"/images/"+characterName.toLowerCase()+".xml");
        
        addChild(animation);
        hitbox = new RotatedRect(getCenter().x, getCenter().y, 40, 60, 0);

     //   image = Res.load("characters/"+characterName+"/images/"+characterName.toLowerCase()+".png").toTile();

     //   needToCenter = true;
        animation.addAnimation("idle", "idle");
        animation.addAnimation("walk", "walk");
        animation.addAnimation("up", "up");
        animation.addAnimation("shoot", "shoot");

        animation.speed = 4;
      //  scale(2);

        animation.scale(1.88);

        slash = new AnimatedSprite(direction == LEFT ? texture.tile.width : 0, -10, "res/images/slash.xml");
        slash.image = Res.images.slash_png.toTile();
        slash.scale(2);
        slash.loop = false;
        slash.speed = 24;
        slash.addAnimation("slash", "slash");
        slash.alpha = 0.0001;

        animation.filter = new Shader(deadShader);

        startScript();
        executeFunc("onNew");
    }

    function setInputs(user:Int){
        inputs = UserControls.inputs[user-1];
    }

    function startScript() {
        //var bossNameFile = bossName.replace(' ', '').toLowerCase();
        if(FileSystem.exists("res/characters/"+characterName+"/scripts/moveset.hx")){
            var expr = sys.io.File.getContent("res/characters/"+characterName+"/scripts/moveset.hx");
            parser = new hscript.Parser();
            interp = new hscript.Interp();
            interp.variables.set("Character",this);
            interp.variables.set("Game",Game.inst);
            interp.variables.set("Bitmap",Bitmap);
            interp.variables.set("Std",Std);
            interp.variables.set("File",sys.io.File);
            interp.variables.set("FileSystem",FileSystem);
            interp.variables.set("Tile",Tile);
            interp.variables.set("Math",Math);
            interp.variables.set("Res",Res);
            interp.variables.set("Key",Key);
            interp.variables.set("Inputs",inputs);
            interp.variables.set("Timer",hxd.Timer);
            interp.variables.set("Random",Random);
            interp.variables.set("LEFT", PlayerDirection.LEFT);
            interp.variables.set("RIGHT", PlayerDirection.RIGHT);
           // interp.variables.set("Random",Character);
            interp.variables.set("onNew", function(){});
            interp.variables.set("onUpdate", function(){});
                var ast = parser.parseString(expr);
                interp.execute(ast);
        }
            
    }

    public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic
    {
        if (interp == null)
            return null;

        if (interp.variables.exists(funcName))
        {
            var func = interp.variables.get(funcName);
            if (args == null)
            {
                var result = null;
                try
                {
                    result = func();
                }
                catch (e)
                {
                    trace('$e');
                }
                return result;
            }
            else
            {
                var result = null;
                try
                {
                    result = Reflect.callMethod(null, func, args);
                }
                catch (e)
                {
                    trace('$e');
                }
                return result;
            }
        }
        return null;
    }

    public function getCenter():Point {
        return new Point(x+getBounds().width/2, y+getBounds().height/2);
    }

    public function addHitbox(_name:String, xp:Float, yp:Float, w:Int, h:Int, deg:Float, lifeSpan:Float = 1) {
        var att = new Attack();
        att._name = _name;
        att.hitbox = new RotatedRect(xp, yp, w, h, deg);
        att.hitbox.angle = deg;
        att.lifeSpan = lifeSpan;
        att.texture = new Bitmap(Tile.fromColor(0x00FF0000, w, h), att);
        att.texture.setPosition(att.hitbox.center.x, att.hitbox.center.y);
        att.texture.tile.setCenterRatio();
        att.texture.alpha = 0.0001;
        att.texture.rotation = Math.degToRad(deg);
         currentAttack = att;
        attacksGrp.push(att);
        Game.inst.gameObj.addChild(att);
        //Game.inst.gameObj.addChild(att.texture);

    }

    function updateAttack(dt:Float){
        if(Key.isPressed(inputs.get("Attack")) && canAttack && !damaged && !isDodging){
           // playAnimation("shoot");
           // loop = false;
            startSlashAnim();
           // isAttacking = true;
        }

        shootTimer -= dt;
        if(!isCpuMode && !damaged && Key.isPressed(inputs.get("Special")) && shootTimer <= 0.0 && !isDodging){
            shootBullet();
        }

    }

    public function shootBullet() {
        if(isAlive && !isAttacking && !Game.inst.battleFinished){
            animation.loop = false;
            animation.speed = 6;
            animation.playAnimation("shoot", direction == LEFT ? true : false);
            var bul = new Bullet();
            bul.t = Res.load("characters/"+characterName+"/images/bullet.png").toTile().center();
            bul.x = getCenter().x+(direction == LEFT ? -14 : 14);
            bul.y = getCenter().y-6;
            bul.hasParticles = true;
            bul.lifeSpan = 3;
            bul.speed = 7;
            bul.vel.x = direction == RIGHT ? 1 : -1;
            if(isCpuMode) bulBatch.adjustColor({hue: Math.degToRad(90)});
            bulBatch.add(bul);
            bulGrp.push(bul);
            var snd = Res.sounds.shoot.play();
            snd.addEffect(new hxd.snd.effect.Pitch(Random.float(0.8, 1.2)));
            shootTimer = 0.3;
        }
    }

    public function startSlashAnim(){
        if(isAlive && !Game.inst.battleFinished){
            slash.alpha = 1;
            slash.playAnimation("slash", direction == LEFT ? true : false);
            if(direction == RIGHT) addHitbox("Slash", getCenter().x + 50, getCenter().y - 5, 100, 40, 0, 0.16);
            else addHitbox("Slash",getCenter().x - 50, getCenter().y - 5, 100, 40, 0, 0.16);
            var snd = Res.sounds.slash.play();
            snd.addEffect(new hxd.snd.effect.Pitch(Random.float(0.8, 1.2)));
        }
    }

    public function movePlayer(dir:PlayerDirection, dt:Float){
        if(!isDodging && isAlive && !Game.inst.battleFinished){
            if(dir == RIGHT) {
                if(vel.x < charSpeed) vel.x += charSpeed*dt*60*0.75;
                isMoving = true;
            }
            else {
                if(vel.x > -charSpeed) vel.x -= charSpeed*dt*60*0.75;
                isMoving = true;
            }
        }
    }
    function updateMovement(dt:Float) {
        isMoving = false;
     //   vel.normalize();
       // direction = isCpuMode ? LEFT : RIGHT;

        if(onGround){
            jumpCount = 2;
        }

        if(!isCpuMode){
            if(Key.isPressed(inputs.get("Jump")) && (onGround || jumpCount > 0)){
                //vel.y = -jumpForce;
                //jumpCount--;
               // onGround = false;
                // if(vel.x > 0.0) vel.x += charSpeed*0.5;
                // else vel.x -= charSpeed*0.5;
            }
            if(Key.isDown(inputs.get("Jump"))){

            }

            if(!damaged && !isDodging){
                if(Key.isDown(inputs.get("Right")) && !Key.isDown(inputs.get("Left"))){
                    movePlayer(RIGHT, dt);
                }
                if(Key.isDown(inputs.get("Left")) && !Key.isDown(inputs.get("Right"))){
                    movePlayer(LEFT, dt);
                }

                if(Key.isPressed(inputs.get("Down"))){
                    isDodging = true;
                }
            }
        }

        if(Key.isDown(inputs.get("Right")) && Key.isDown(inputs.get("Left"))){
            //isMoving = false;
        }
        
        if(Game.inst.battleFinished == false || Game.inst.battleStarted == true){
            if (isMoving && animation.animName != "shoot" && animation.animName != "walk"){
                animation.loop = true;
                animation.speed = 4;
                animation.playAnimation("walk", direction == LEFT ? true : false);
            }
            if (!isMoving && animation.animName != "shoot" && animation.animName != "idle"){
                animation.loop = true;
                animation.speed = 4;
                animation.playAnimation("idle", direction == LEFT ? true : false);
            }

            if(animation.animName == "shoot"){
                if(animation.currentFrame > animation.animations.get("shoot").length-1){
                    if (isMoving && animation.animName != "walk"){
                        animation.loop = true;
                        animation.speed = 4;
                        animation.playAnimation("walk", direction == LEFT ? true : false);
                    }
                    if (!isMoving && animation.animName != "idle"){
                        animation.loop = true;
                        animation.speed = 4;
                        animation.playAnimation("idle", direction == LEFT ? true : false);
                    }
                }
            }
        }

        animation.setPosition(direction == LEFT ? texture.tile.width : 0, 0);


        if(vel.y < 40) vel.y += gravity*dt*2;
        vel.x /= 1.2;
        x+= vel.x*dt*60;
        y+= vel.y*dt*60;
    }

    var timer:Float = 0;
    public function flicker(mult:Float) {
        timer += mult;
        if(timer >= 1){
            animation.visible = !animation.visible;
            timer = 0;
        }
    }

    override function sync(ctx:RenderContext) {
        super.sync(ctx);
    }

    public function fixedUpdate(dt:Float) {
        
        if(isCpuMode){
            animation.adjustColor({hue: Math.degToRad(90)});
            slash.adjustColor({hue: Math.degToRad(90)});
        }
        if(health <= 0.0){
            health = 0;
            isAlive = false;
        }
        if(!isAlive){
            Game.inst.battleFinished = true;
            canAttack = false;
            shootTimer = 1000;
            isDodging = false;
            deadShader.time += dt;
        }
        updateMovement(dt);
        updateAttack(dt);
        slash.setPosition(x + vel.x*dt*60 + (direction == LEFT ? texture.tile.width : 0), y + vel.y*dt*60 -10);

        if(currentAttack != null){
            canAttack = false;
            isAttacking = true;
            currentAttack.hitbox.center.x += vel.x*dt*60;
            currentAttack.hitbox.center.y +=  vel.y*dt*60;
            currentAttack.texture.x += vel.x*dt*60;
            currentAttack.texture.y += vel.y*dt*60;
            currentAttack.lifeSpan -= dt;
            if(currentAttack.lifeSpan <= 0.0){
                currentAttack.hitbox = null;
                currentAttack.texture.remove();
                currentAttack.remove();
                attacksGrp.remove(currentAttack);
                currentAttack = null;
            }
        }
        else {
            isAttacking = false;
            canAttack = true;
        }

        for(att in attacksGrp){
          //  for(att in attacksGrp){
            if(currentAttack != att){
                att.hitbox = null;
                att.texture.remove();
                att.remove();
                attacksGrp.remove(att);
                att = null;
            }
           // trace(att.hitbox.center.toString());
        //}
            //if(att.hitbox.collidesWith(hitbox)) trace("fjklfsqdf");
           // att.setPosition(x, y);
        }

        if(damaged){
            flicker(0.5);
            invTime -= dt;
            if(invTime <= 0.0){
                damaged = false;
                animation.visible = true;
                invTime = Random.float(0.85, 1);
            }
        }

        if(isDodging){
            alpha = 0.5;
            dodgeTime -= dt;
            if(dodgeTime <= 0.0){
                alpha = 1;
                isDodging = false;
                dodgeTime = 0.9;
            }
        }
    }

    public function update(dt:Float) {
       // executeFunc("onUpdate");
    }

    override function syncPos() {
        super.syncPos();
    }

    function get_hitbox():RotatedRect {
        hitbox.center.set(getCenter().x, getCenter().y);
        hitbox.width = 40*scaleX;
        hitbox.height = 60*scaleY;
        return hitbox;
    }
}