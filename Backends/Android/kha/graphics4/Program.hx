package kha.graphics4;

import android.opengl.GLES20;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class Program {
	private var program: Int;
	private var vertexShader: VertexShader;
	private var fragmentShader: FragmentShader;
	private var textures: Array<String>;
	private var textureValues: Array<Dynamic>;
	
	public function new() {
		program = GLES20.glCreateProgram();
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}
	
	public function setVertexShader(vertexShader: VertexShader): Void {
		this.vertexShader = vertexShader;
	}
	
	public function setFragmentShader(fragmentShader: FragmentShader): Void {
		this.fragmentShader = fragmentShader;
	}
	
	public function link(structure: VertexStructure): Void {
		compileShader(vertexShader);
		compileShader(fragmentShader);
		GLES20.glAttachShader(program, vertexShader.shader);
		GLES20.glAttachShader(program, fragmentShader.shader);
		
		var index = 0;
		for (element in structure.elements) {
			GLES20.glBindAttribLocation(program, index, element.name);
			++index;
		}
		
		GLES20.glLinkProgram(program);
		//if (!Sys.gl.getProgramParameter(program, Sys.gl.LINK_STATUS)) {
		//	throw "Could not link the shader program.";
		//}
	}
	
	public function set(): Void {
		GLES20.glUseProgram(program);
		for (index in 0...textureValues.length) {
			GLES20.glUniform1i(textureValues[index], index);
		}
	}
	
	private function compileShader(shader: Dynamic): Void {
		if (shader.shader != null) return;
		var s = GLES20.glCreateShader(shader.type);
		GLES20.glShaderSource(s, shader.source);
		GLES20.glCompileShader(s);
		//if (!Sys.gl.getShaderParameter(s, Sys.gl.COMPILE_STATUS)) {
		//	throw "Could not compile shader:\n" + Sys.gl.getShaderInfoLog(s);
		//}
		shader.shader = s;
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return new kha.android.graphics4.ConstantLocation(GLES20.glGetUniformLocation(program, name));
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var index = findTexture(name);
		if (index < 0) {
			var location = GLES20.glGetUniformLocation(program, name);
			index = textures.length;
			textureValues.push(location);
			textures.push(name);
		}
		return new kha.android.graphics4.TextureUnit(index);
	}
	
	private function findTexture(name: String): Int {
		for (index in 0...textures.length) {
			if (textures[index] == name) return index;
		}
		return -1;
	}
}