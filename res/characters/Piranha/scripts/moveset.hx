function onNew() {
    trace("Hscript works !!");
}

var groundHitTimer = 0.4;
var doGroundHit = false;
function onUpdate() {
    if(Character.canAttack){
        if(Key.isPressed(Inputs.get("Attack")) && !doGroundHit){
            if(Character.onGround){
                if(Character.isMoving){
                    doRunAttack();
                }
                else {
                    doAttack();
                }
            }
            else {
                if(Character.isMoving){
                    doAirMoveAttack();
                }
                else {
                    doAirAttack();
                }
            }
        }

        if(Key.isPressed(Inputs.get("Special")) && !doGroundHit){
            if(Character.onGround){
                if(Character.isMoving){
                    doRunSpecial();
                }
                else {
                    doSpecial();
                }
            }
            else {
                if(Character.isMoving){
                    doAirMoveSpecial();
                }
                else {
                    doAirSpecial();
                }
            }
        }
    }
    //Character.vel.x = 3;

    if(Character.currentAttack != null && Character.currentAttack._name == "Spin"){
        Character.vel.y = 0;
    }

    if(doGroundHit){
        Character.canAttack = false;
        Character.vel.x = 0;
        groundHitTimer -= Timer.dt;
        if(groundHitTimer > 0.0){
            Character.vel.y -= 0.44;
        }
        else {
            Character.addHitbox("Fire Ground Punch",Character.getCenter().x, Character.getCenter().y + 20, 80, 25, 0, 0.1);
            Character.vel.y += 10;
        }

        if(Character.onGround) doGroundHit = false;
    }
}

function doRunAttack(){
    trace("Run Attack");
    Character.vel.x += Character.direction == RIGHT ? 12 : -12;
    if(Character.direction == RIGHT) Character.addHitbox("Rapid Tacle", Character.getCenter().x + 30, Character.getCenter().y + 20, 80, 25, 0, 0.3);
    else Character.addHitbox("Rapid Tacle",Character.getCenter().x - 30, Character.getCenter().y + 20, 80, 25, 0, 0.3);
}

function doAttack(){
    if(Key.isDown(Inputs.get("Down"))){
        trace("Down Attack");
        if(Character.direction == RIGHT) Character.addHitbox("Kick", Character.getCenter().x + 30, Character.getCenter().y + 20, 80, 25, 0, 0.2);
        else Character.addHitbox("Kick",Character.getCenter().x - 30, Character.getCenter().y + 20, 80, 25, 0, 0.3);
    }
    else {
        trace("Attack");
        if(Character.direction == RIGHT) Character.addHitbox("Punch",Character.getCenter().x + 30, Character.getCenter().y, 100, 20, 0, 0.15);
        else Character.addHitbox("Punch",Character.getCenter().x - 30, Character.getCenter().y, 100, 20, 0, 0.15);
    }
}

function doAirMoveAttack() {
    if(Key.isDown(Inputs.get("Down"))){
        Character.addHitbox("Down Kick",Character.getCenter().x, Character.getCenter().y+50, 100, 40, 0, 0.25);
    }
    else {
        if(Character.direction == RIGHT) trace("Air Right Attack");
        else trace("Air Left Attack");
    }
}

function doAirAttack() {
    if(Key.isDown(Inputs.get("Down"))){
        Character.addHitbox("Down Kick",Character.getCenter().x, Character.getCenter().y+50, 100, 40, 0, 0.25);
    }
    else {
        Character.addHitbox("Spin",Character.getCenter().x, Character.getCenter().y, 120, 40, 0, 0.4);
        trace("Air Attack");
    }
}

function doRunSpecial(){
    trace("Run Attack");
    Character.vel.x += Character.direction == RIGHT ? 12 : -12;
    if(Character.direction == RIGHT) Character.addHitbox("Rapid Tacle", Character.getCenter().x + 30, Character.getCenter().y + 20, 80, 25, 0, 0.3);
    else Character.addHitbox("Rapid Tacle",Character.getCenter().x - 30, Character.getCenter().y + 20, 80, 25, 0, 0.3);
}

function doSpecial(){
    if(Key.isDown(Inputs.get("Down"))){
        trace("Down Attack");
        if(Character.direction == RIGHT) Character.addHitbox("Kick", Character.getCenter().x + 30, Character.getCenter().y + 20, 80, 25, 0, 0.2);
        else Character.addHitbox("Kick",Character.getCenter().x - 30, Character.getCenter().y + 20, 80, 25, 0, 0.3);
    }
    else {
        trace("Attack");
        if(Character.direction == RIGHT) Character.addHitbox("Punch",Character.getCenter().x + 30, Character.getCenter().y, 100, 20, 0, 0.15);
        else Character.addHitbox("Punch",Character.getCenter().x - 30, Character.getCenter().y, 100, 20, 0, 0.15);
    }
}

function doAirMoveSpecial() {
    if(Key.isDown(Inputs.get("Down")) && !doGroundHit){
        groundHitTimer = 0.4;
        Character.vel.y = 0;
        doGroundHit = true;
    }
    else {
        if(Character.direction == RIGHT) trace("Air Right Attack");
        else trace("Air Left Attack");
    }
}

function doAirSpecial() {
    if(Key.isDown(Inputs.get("Down")) && !doGroundHit){
        groundHitTimer = 0.4;
        Character.vel.y = 0;
        doGroundHit = true;
    }
    else {
        Character.addHitbox("Spin",Character.getCenter().x, Character.getCenter().y, 120, 40, 0, 0.4);
        trace("Air Attack");
    }
}