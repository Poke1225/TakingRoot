package;

import slide.easing.Back;
import h2d.Scene;
import h3d.mat.Texture;
import h2d.RenderContext;
import hxd.snd.Channel;
import slide.easing.Quad;
import slide.easing.Bounce;
import slide.easing.Sine;
import slide.easing.Elastic;
import slide.Slide;
import objects.Particle;
import h2d.col.Point;
import h2d.Mask;
import h2d.col.Bounds;
import Shaders.Masking;
import Shaders.Chroma;
import h2d.filter.Shader;
import h2d.filter.Group;
import Shaders.OldTV;
import hxd.Math;
import h2d.Object;
import hxd.Res;
import h2d.Camera;
import h2d.filter.Glow;
import h2d.filter.Bloom;
import hxd.Timer;
import h2d.Tile;
import h2d.Bitmap;
import hxd.Key;
import h2d.SpriteBatch;
import objects.Player;


class Game extends GameScene {

    public static var inst:Game;

    //BG THINGS
    var sky:Bitmap;

    //CAMERAS
    var camGame:Camera;
    public var gameObj:Scene;
    var camZoom:Float = 1.2;

    // EFFECTS
    //var chroma:Chroma = new Chroma();

    //SOUNDS
    var battleSong:Channel;


    //GAMEPLAY
    //var player:Player;
    var playerGrp:Array<Player> = [];
    public var bulletBatch:SpriteBatch;
    var energyBar:h2d.Graphics;
    var energyFill:Bitmap;
    var energyBar2:h2d.Graphics;
    var energyFill2:Bitmap;

    public var battleStarted:Bool = false;
    public var battleFinished:Bool = false;
    var countdown:Float = 3;

    var superseed:Bitmap;
    var particlesBatch:SpriteBatch;
    public function new() {
        super();
        inst = this;

        battleSong = Res.sounds.battle.play();
        battleSong.pause = true;
        battleSong.loop = true;
        battleSong.position = 0;
        
        camZoom = 1;

        gameObj = new Scene();
        //gameObj.constraintSize(640, 480);
        //gameObj.scrollBounds = Bounds.fromValues(0,0, 640, 480);
        //gameObj.setPosition(320, 120);
        //gameObj.getBounds(gameObj, Bounds.fromValues(0,0, 1280, 720));
        add(gameObj, 0);


        var nightsky = new Bitmap(Res.images.nightsky.toTile(), gameObj);
        nightsky.setPosition(320, 120);

        var moon = new Bitmap(Res.images.moon.toTile(), gameObj);
        moon.setPosition(width*0.67, 140);
        moon.filter = new Glow(0xFFFFFF, 1, 36, 1, 1, true);

        var arena = new Bitmap(Res.images.arena.toTile(), gameObj);
        arena.x = 320;
        arena.y = 140;
        arena.alpha = 0.6;
        arena.blendMode = Add;

        particlesBatch = new SpriteBatch(null, gameObj);
        particlesBatch.hasUpdate = particlesBatch.hasRotationScale = true;

        superseed = new Bitmap(Res.images.superseed.toTile().center(), gameObj);
        superseed.setPosition(width/2, height/2);

       // gameObj.addBounds(this, Bounds.fromValues(320, 120, 640, 480), 0, 0, 640, 480);

        addCharacter("Piranha", width*0.35, height*0.6, 1, false, RIGHT);
        addCharacter("Piranha", width*0.65-50, height*0.6, 2, true, LEFT);
        for(char in playerGrp){
            gameObj.addChild(char.bulBatch);
            gameObj.addChild(char.slash);
        }

        bulletBatch = new SpriteBatch(null, null);
        bulletBatch.hasUpdate = bulletBatch.hasRotationScale = true;
        gameObj.addChild(bulletBatch);
        var glow = new Glow();
        glow.radius = 10;
        glow.color = 0xFFB300;
        glow.smoothColor = true;

        energyBar = new h2d.Graphics();
        energyBar.lineStyle(5, 0xFFFFFF);
        energyBar.drawRect(0,0, 30, 250);
        energyBar.endFill();
        energyBar.setPosition(width*0.04 + 320, height*0.45);
        gameObj.addChild(energyBar);

        energyFill = new Bitmap(Tile.fromColor(0xFFAA00, 25, 245), this);
        energyFill.tile.setCenterRatio(0,1);
        energyFill.alpha = 0.7;
        energyFill.setPosition(energyBar.x+2.5, energyBar.y+2.5+energyFill.tile.height);
        gameObj.addChild(energyFill);

        energyBar2 = new h2d.Graphics();
        energyBar2.lineStyle(5, 0xFFFFFF);
        energyBar2.drawRect(0,0, 30, 250);
        energyBar2.endFill();
        energyBar2.setPosition(width*0.96 - 30 - 320, height*0.45);
        gameObj.addChild(energyBar2);

        energyFill2 = new Bitmap(Tile.fromColor(0xFFAA00, 25, 245), this);
        energyFill2.tile.setCenterRatio(0,1);
        energyFill2.alpha = 0.7;
        energyFill2.setPosition(energyBar2.x+2.5, energyBar2.y+2.5+energyFill2.tile.height);
        gameObj.addChild(energyFill2);

        addGameShaders(gameObj);
      //  gameObj.filter.autoBounds = true;
        //gameObj.filter.boundsExtend = 100;
        //gameObj.filter.useScreenResolution = false;
    }

    function addCharacter(name:String, x:Float, y:Float, player:Int, bot:Bool, dir:PlayerDirection) {
        var char = new Player(name, player, bot);
        char.direction = dir;
        char.setPosition(x, y);
       // char.isCpuMode = bot;
        char.animation.blendMode = Add;
        char.slash.blendMode = Add;
        char.bulBatch.blendMode = Add;
        gameObj.addChild(char);
        playerGrp.push(char);
    }

    function spawnParticles(pos:Point, vel:Point, speed:Float = 1) {
        var p = new Particle(Res.images.seedparticle.toTile());
        p.x = pos.x;
        p.y = pos.y;
        p.rotation = Random.float(0, Math.PI);
        p.vel = vel;
        p.speed = speed;
        particlesBatch.add(p);
    }

    function distanceBetween(obj1:Dynamic, obj2:Dynamic) {
        var dx = Math.abs(obj1.x - obj2.x);
        var dy = Math.abs(obj1.y - obj2.y);
        return Math.sqrt(dx*dx + dy*dy);
    }


    var choice:Int = 0; // 0 is left, 1 is also left, 2 is right, 3 is attack
    var attackChoice:Int = 0; // 0 is slash, 1 is bullet
    var timeBeforeNewChoice:Float = 0.3;
    var choiceTaken:Bool = false;
    function updateBots(player:Player, dt:Float){
        for(player2 in playerGrp){
            if(player != player2 && player2.isAlive && battleStarted){
                if(distanceBetween(player, player2) < Random.float(120, 180)){
                    if(!choiceTaken){
                        choice = Random.int(0, 6);
                        switch (choice){
                            case 0 | 1:
                                if(player.x > player2.x && !player.damaged) player.movePlayer(LEFT, dt*2);
                                if(player.x < player2.x && !player.damaged) player.movePlayer(LEFT, dt*2);
                                timeBeforeNewChoice = Random.float(0.05, 0.4);
                            case 2:
                                if(player.x < player2.x && !player.damaged) player.movePlayer(RIGHT, dt);
                                if(player.x > player2.x && !player.damaged) player.movePlayer(LEFT, dt);
                                timeBeforeNewChoice = Random.float(0.05, 0.4);
                            case 3 | 4 | 5 | 6:
                                if(player.canAttack && (player.invTime <= 0.1 || !player.damaged) && !player.isDodging) player.startSlashAnim();
                                timeBeforeNewChoice = Random.float(0.05, 0.4);
                        }
                        choiceTaken = true;
                    }
                }
                else {
                    if(!choiceTaken){
                        choice = Random.int(0, 3);
                        timeBeforeNewChoice = Random.float(0.7, 1);
                        if(choice == 0) timeBeforeNewChoice = Random.float(0.7, 1.2);
                        choiceTaken = true;
                    }
                    switch (choice){
                            case 0 | 1:
                                if(player.x > player2.x) player.movePlayer(LEFT, dt);
                                else player.movePlayer(RIGHT, dt);
                            case 2:
                                if(player.x > player2.x) player.movePlayer(RIGHT, dt/2); // Slower movements
                                else player.movePlayer(LEFT, dt/2);
                            case 3:
                                if(player.shootTimer <= 0.0 && !player.damaged && !player.isAttacking) player.shootBullet();
                        }
                }

                for(bul in player2.bulGrp){
                    if(distanceBetween(bul, player) < Random.float(30, 100)){
                            var choice2 = Random.int(0, 3);
                            switch (choice2){
                                case 0:
                                    if(player.canAttack && !player.damaged && !player.isDodging) player.startSlashAnim();
                                   // timeBeforeNewChoice = Random.float(0.2, 0.7);
                                case 2:
                                    if(!player.damaged && !player.isDodging && !player.isAttacking) player.isDodging = true;
                                   // timeBeforeNewChoice = Random.float(0.2, 0.5);
                                case 3:
                                    if(!player.isDodging){
                                        if(bul.x < player.x) player.movePlayer(RIGHT, dt);
                                        else player.movePlayer(LEFT, dt);
                                    }
                                   // timeBeforeNewChoice = Random.float(0.3, 0.8);
                            }
                    }
                }

                if(choiceTaken){
                    if(player.onGround) timeBeforeNewChoice -= dt;
                    if(timeBeforeNewChoice <= 0.0){
                        choiceTaken = false;
                        timeBeforeNewChoice = Random.float(0.4, 1);
                    }
                }
            }
        }
    }

    override function sync(ctx:RenderContext) {
        super.sync(ctx);
        //gameObj.filter.autoBounds = false;
      //  gameObj.filter.getBounds(this, Bounds.fromValues(0,0, 10, 10), new Point(1, 1));
       // gameObj.clipBounds(ctx, Bounds.fromValues(0,0, 10, 10));
    }

     var doMute:Bool = false;
    var angle:Float = 0;
    var superAngle:Float = 0;
    override function fixedUpdate(dt:Float) {
        super.fixedUpdate(dt);
        superAngle += dt;
        countdown -= dt;
     //   @:privateAccess gameObj.getBounds().cli;
        //gameObj.getBounds(gameObj, Bounds.fromValues(320, 120, 640, 480)); 
        //gameObj.drawRec(ctx);
       // gameObj.clipBounds(ctx, Bounds.fromValues(320, 120, 640, 480));
       // gameObj.filter.getBounds(gameObj, Bounds.fromValues(320, 120, 640, 480), new Point(1, 1));
       // trace("gameObj.x :" + gameObj.x);
       if(!battleStarted){
            for(player in playerGrp) player.animation.playAnimation("up", player.direction == LEFT ? true : false);
       }
        if(countdown <= 0.0 && !battleStarted){
            Slide.tween(superseed).to({y: 70}, 0.6).ease(Back.easeIn).start().onComplete(function() {
                battleSong.pause = false;
                battleStarted = true;
            });
            countdown = 10000;
        }

        if(superAngle % Math.PI/4 == 0) superseed.rotation = superAngle;
        angle = Random.float(0, Math.PI*2);
        if(superseed.visible) spawnParticles(new Point(superseed.x, superseed.y), new Point(Math.cos(angle), Math.sin(angle)));

        for(player in playerGrp){
            player.fixedUpdate(dt);
            if(player.isCpuMode) updateBots(player, dt);
            player.x = Math.clamp(player.x, 320+45, 640+320-90);
            if(player.y >= height*0.62-(player.hitbox.height) + 60){
                player.y = height*0.62-(player.hitbox.height) + 60;
                player.vel.y = 0;
                player.onGround = true;
            }

            if(battleFinished){
                if(!playerGrp[0].isAlive && !doMute){
                    battleSong.fadeTo(0.01, 2.4, function() {
                        Slide.tween(deadShader).to({time : 2}, 1.2).start().onComplete(
                            function() {
                                changeScene(new Menu());
                            }
                        );
                    });
                    doMute = true;
                }
                if(player != null && player.isAlive && superseed != null && superseed.y == 70){
                    player.animation.playAnimation("up", player.direction == LEFT ? true : false);
                    Slide.tween(superseed).to({y: player.getCenter().y-20}, 3).ease(Quad.easeOut).start().onComplete(function() {
                       superseed.visible = false;
                       player.animation.playAnimation("idle", player.direction == LEFT ? true : false);
                    });
                    superseed.x = player.getCenter().x;
                }
                if(player != null && !superseed.visible){
                    player.animation.adjustColor({hue: superAngle});
                }
            }

            for(player2 in playerGrp){
                if(player != player2){
                    for(att in player.attacksGrp){
                        if(att.hitbox.collidesWith(player2.hitbox) && !player2.damaged && !player2.isDodging && player2.isAlive){
                                player2.health -= Random.int(4, 6);
                                player2.vel.y = -6;
                                if(player.x < player2.x) player2.vel.x += 8;
                                else player2.vel.x -= 8;
                                var snd = Res.sounds.hurt.play();
                                player2.damaged = true;
                        }
 
                    }

                    for(bul in player.bulGrp){
                        if(bul.x+bul.vel.x >= 640+320-10 || bul.x+bul.vel.x < 320+10){
                            bul.remove();
                            player.bulGrp.remove(bul);
                        }
                        if(bul.hitbox.collidesWith(player2.hitbox) && !player2.damaged && !player2.isDodging && player2.isAlive){
                            player2.health -= Random.int(3, 4);
                            player2.vel.x = 0;
                            player2.vel.y = -5;
                            if(player.x < player2.x) player2.vel.x += 4;
                            else player2.vel.x -= 4;
                            bul.remove();
                            player.bulGrp.remove(bul);
                            var snd = Res.sounds.hurt.play();
                            player2.damaged = true;
                        }

                        if(player2.currentAttack != null && bul.hitbox.collidesWith(player2.currentAttack.hitbox) && player2.isAttacking){
                            if(bul.x < player2.x) player2.vel.x += 3;
                            else player2.vel.x -= 3;
                            bul.remove();
                            player.bulGrp.remove(bul);
                        }
                        
                    }

                    if(player.hitbox.collidesWith(player2.hitbox) && player2.isAlive){
                            if(player.x < player2.x) player2.vel.x += 2;
                            else player2.vel.x -= 2;
                        }
                }
            }
        }

        camera.setScale(camZoom, camZoom);
        trace(playerGrp[0].vel.toString());
    }

    override function update(dt:Float) {
        super.update(dt);
        //trace(Main.ME.engine.drawCalls);

        energyFill.scaleY = playerGrp[0].health/100;
        energyFill2.scaleY = playerGrp[1].health/100;

        if(Key.isPressed(Key.ESCAPE)){
            battleSong.stop();
            changeScene(new Menu());
        }

        for(player in playerGrp){
            player.update(dt);
        }
    }
}