package;

class Chroma extends h3d.shader.ScreenShader {

	static var SRC = {

		@param var texture:Sampler2D;
		@param var rOffset:Float;
		@param var gOffset:Float;
		@param var bOffset:Float;
		@param var ofs:Float = 0.2;
		@param var gOfs:Float = -0.0;

		function readColor(uv : Vec2, chromaticRate : Float) : Vec3 {

			// chromatic abberation
			var r = texture.get(uv + vec2(ofs/100, 0.0)).r;
			var g = texture.get(uv + vec2(gOfs/100, 0.0)).g;
			var b = texture.get(uv + vec2(-ofs/100, 0.0)).b;
			
			return vec3(r,g,b);
		}

		function fragment()
		{
			
			var col = vec4(1.0);	
			col.r = texture.get(input.uv + vec2(ofs/100, 0.0)).r;
			col.ga = texture.get(input.uv + vec2(gOfs/100, 0.0)).ga;
			col.b = texture.get(input.uv + vec2(-ofs/100, 0.0)).b;

			pixelColor = col;
		}
	}

}

class Masking extends h3d.shader.ScreenShader {

	static var SRC = {

		@param var texture:Sampler2D;
		@param var time:Float = 0;
		@param var speed:Float = 1;

		function fragment()
		{
			var color = texture.get(input.uv);
			if(time > input.uv.y){
				var gray = (color.r + color.g + color.b) / 3.0;
				color = vec4(gray, gray, gray, color.a);
			}
			if(time-1 > input.uv.y){
				color = vec4(0, 0, 0, 0);
			}

			output.color = color;
		}
	}

}

class OldTV extends h3d.shader.ScreenShader {

	static var SRC = {

		/**
		* Source: https://www.shadertoy.com/view/wllBDM
		*/
		@param var time = 1.0;
		@param var texture:Sampler2D;

		@param var scanSpeedAdd = 1.0;
		@param var lineCut = 0.01;
		@param var whiteIntensity = 0.45;
		@param var anaglyphIntensity = 0.5;

		// Anaglyph colors.
		var col_r:Vec3;
		var col_l:Vec3;

		function fragment() {
			col_r = vec3(0.0, 1.0, 1.0);
			col_l = vec3(1.0, 0.0, 0.0);
			// Normalized pixel coordinates (from 0 to 1).
			var uv = input.uv;
			var uv_right = vec2(uv.x + 0.01, uv.y + 0.01);
			var uv_left = vec2(uv.x - 0.01, uv.y - 0.01);

			// Black screen.
			var col = vec3(0.0);
			
			// Measure speed.
			var scanSpeed = (fract(time) * 2.5 / 40.0) * scanSpeedAdd;
			
			// Generate scanlines.
			var scanlines = vec3(1.0) * abs(cos((uv.y + scanSpeed) * 100.0)) - lineCut;
			
			// Generate anaglyph scanlines.
			var scanlines_right = col_r * abs(cos((uv_right.y + scanSpeed) * 100.0)) - lineCut;
			var scanlines_left = col_l * abs(cos((uv_left.y + scanSpeed) * 100.0)) - lineCut;
			
			col = smoothstep(0.1, 0.7, scanlines * whiteIntensity) + smoothstep(0.1, 0.7, scanlines_right * anaglyphIntensity) + smoothstep(0.1, 0.7, scanlines_left * anaglyphIntensity);
			
			var eyefishuv = (uv - 0.5) * 2.5;
			var deform = (1.0 - eyefishuv.y*eyefishuv.y) * 0.02 * eyefishuv.x;
			var texture1 = texture.get(vec2(uv.x - deform*0.5, uv.y));
			
			var bottomRight = pow(uv.x, uv.y * 100.0);
			var bottomLeft = pow(1.0 - uv.x, uv.y * 100.0);
			var topRight = pow(uv.x, (1.0 - uv.y) * 100.0);
			var topLeft = pow(uv.y, uv.x * 100.0);
			
			var screenForm = bottomRight + bottomLeft + topRight + topLeft;

			var col2 = 1.0-vec3(screenForm);

			pixelColor = texture1 + vec4((smoothstep(0.1, 0.9, col) * 0.1), 1.0);
			//pixelColor = vec4(pixelColor.rgb * col2, pixelColor.a);
		}
	}

}