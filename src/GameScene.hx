package ;

import h2d.col.Point;
import h2d.col.Bounds;
import Shaders.Masking;
import slide.Slide;
import Shaders.Chroma;
import Shaders.OldTV;
import h2d.filter.Shader;
import h2d.filter.Group;
import hxd.Res;
import h2d.Camera;
import hxd.res.DefaultFont;
import h2d.Text;
import hxd.SceneEvents.InteractiveScene;
import h2d.Scene;
import h2d.Tile;
import h2d.Bitmap;
import hxd.Window;
import h2d.Object;
import hxd.snd.Channel;

enum Axis {
	X;
	Y;
	XY;
}

enum Style {
	IN;
	OUT;
}

/**
 * `Scene` class with extra functionality. Extend this instead of `Scene`.
 * Also contains helper functions
 */
class GameScene extends Scene {
	/**
	 * Array of objects the game should update.
	 * Updating is done in `Main`.
	 */
	//public static var objectsToUpdate:Array<FNFObject> = [];

	/**
	 * Array of MusicBeatStates the game has to update.
	 * Updating is done in `Main`.
	 */
	public static var scenesToUpdate:Array<GameScene> = [];

	

	/**
	 * Song the Conductor should use to calculate songPosition.
	 */

	public static var windowInstance:Window = Window.getInstance();
	var flashSprite:Bitmap;
	var transitionSprite:Bitmap;

	var camUI:Camera;
	var oldTv:OldTV = new OldTV();
	var chroma:Chroma = new Chroma();
	var deadShader:Masking = new Masking();
	var camConsole:Camera;

	var topLayerCamera:Camera = new Camera();
    var fps:Text;

	public function new() {
		super();

		scaleMode = LetterBox(1280, 720);

		camera.layerVisible = (layer) -> layer == 0;
		camUI = new Camera(this);
        camUI.setAnchor(0.5, 0.5);
        camUI.setPosition(width/2, height/2);

        camUI.layerVisible = (layer) -> layer == 1;

		camConsole = new Camera(this);
        camConsole.setAnchor(0.5, 0.5);
        camConsole.setPosition(width/2, height/2);

        camConsole.layerVisible = (layer) -> layer == 2;

		UserControls.initializeControls();

		flashSprite = new Bitmap(Tile.fromColor(0xFFFFFFFF, window.width, window.height, 1));
		transitionSprite = new Bitmap(Tile.fromColor(0xFF000000, window.width, -window.height - 500, 1));

		//topLayerCamera.layerVisible = (layer) -> layer == Layers.layerTop;


		//window.resize(1280, 720);
		camera.setAnchor(0.5, 0.5);
		camera.setPosition(width/2, height/2);
		fps = new Text(DefaultFont.get());
        fps.scale(2);
       // add(fps, 1);

		addConsole();
		
		trace("Opened new scene.");
	}

	function addConsole() {
		var console = new Bitmap(Res.images.console.toTile());
		console.smooth = true;
        add(console, 2);
	}

	function addGameShaders(object:Object){
		 for(i in 0...2){
           // var t = new Bitmap(Tile.fromColor(0x00FF0000), object);
            //if(i > 0) t.setPosition(320+640, 120+480);
            //else t.setPosition(319, 119);
        }
		object.filter = new Group([new Shader(oldTv), new Shader(chroma), new Shader(deadShader)]);
		object.filter.useScreenResolution = true;
		object.filter.autoBounds = false;
		//object.getBounds(object, Bounds.fromValues(320, 120, 640, 480));
		//object.filter.getBounds(object, Bounds.fromValues(320, 120, 640, 480), new Point(1, 1));
	}

	var fixedDt:Float = 1/60;
	var acc:Float = 0.0;
	public function fixedUpdate(dt:Float) {
		oldTv.time += dt;
		Slide.step(dt);	
	}

	public function update(dt:Float) {
		fps.text = "FPS: " + (Main.ME.engine.fps) + 
				"\nMEMORY: " + Std.int(Main.ME.engine.mem.stats().textureMemory / 1048576) + "MBs" + 
				"\nDrawCalls: " + Main.ME.engine.drawCalls;
		
		acc += dt;
		while (acc >= fixedDt){
			fixedUpdate(fixedDt);
			acc -= fixedDt;
		}
	}

	override function onAdd() {
		super.onAdd();

//        defaultSmooth = true;

		scenesToUpdate.push(this);
		//addCamera(topLayerCamera, Layers.layerTop);
	}

	/**
	 * Set an objects position to the center of the screen.
	 * @param object Object to target
	 * @param axis Axis on which to 
	 */
	function screenCenter(object:Object, axis:Axis = XY) {
		if (axis == X) {
			object.x = (window.width - object.getSize().width) / 2;
		}
		else if (axis == Y)
			object.y = (window.height - object.getSize().height) / 2;
		else {
			object.x = (window.width - object.getSize().width) / 2;
			object.y = (window.height - object.getSize().height) / 2;
		}
	}

	/**
	 * Change the current scene. Automatically disposes of the assets of the last scene.
	 * Also removes all the objects in `objectsToUpdate` and removes `this` instance from `scenesToUpdate`
	 * @param scene Which scene to transition to. (new PlayState());
	 * @param transition Should do transition animation? (Unused)
	 * @param dispose Dipose of the scene?
	 */
	public function changeScene(scene:InteractiveScene, transition:Bool = false, dispose:Bool = true) {
			Main.ME.setScene(scene, true);
			dispose ? GameScene.scenesToUpdate.remove(this) : trace("Did not dispose scene.");
	}
}