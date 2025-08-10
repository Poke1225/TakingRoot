package;

import hxd.Key;

class UserControls {
    public static var inputs:Array<Map<String, Int>>;

    public static function initializeControls() {
        inputs = [];
        // For player 1
        var p1 = new Map<String, Int>();
        p1.set("Right", Key.RIGHT);
        p1.set("Left", Key.LEFT);
        p1.set("Up", Key.UP);
        p1.set("Down", Key.DOWN);
        p1.set("Jump", Key.Z);
        p1.set("Attack", Key.X);
        p1.set("Special", Key.C);
        p1.set("Parry", Key.A);

        // For player 2
        var p2 = new Map<String, Int>();
        p2.set("Right", Key.M);
        p2.set("Left", Key.K);
        p2.set("Up", Key.O);
        p2.set("Down", Key.L);
        p2.set("Jump", Key.O);
        p2.set("Attack", Key.U);
        p2.set("Special", Key.I);
        p2.set("Parry", Key.I);

        inputs.push(p1);
        inputs.push(p2);
    }
}