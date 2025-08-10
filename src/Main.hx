import hxd.Key;
import hxd.Window;
import hxd.snd.Manager;
import hxd.App;
import hxd.Res;

class Main extends App {
	public static var ME:Main;

	static function main() {
		Res.initEmbed();
		new Main();
	}

	override function init() {
		super.init();
		trace("Running first init");

		ME = this;
		//engine.fullScreen = true;

		setScene(new Menu());
	}

	override function update(dt:Float) {
		super.update(dt);
		for (scene in GameScene.scenesToUpdate) scene.update(dt);

		
		if(Key.isPressed(Key.F11) || (Key.isDown(Key.ALT) && Key.isPressed(Key.ENTER))){
			engine.fullScreen = !engine.fullScreen;
		}
		//for (object in GameScene.objectsToUpdate) object.update(dt);
	}

	override function onResize() {
		super.onResize();
		
		// Make sure windowInstance is up-to-date when resizing
		GameScene.windowInstance = Window.getInstance();
	}

	override function onContextLost() {
		trace("lost context");
		super.onContextLost();
	}

}
