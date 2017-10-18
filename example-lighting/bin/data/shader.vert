attribute vec3 position;
attribute vec3 normal;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

varying vec3 normalInterp;
varying vec3 vertPos;
void main(){
	gl_Position = modelViewProjectionMatrix * vec4(position,1.);

	vec4 vertPos4 = modelViewMatrix * vec4(position,1.);
	vertPos = vec3(vertPos4) / vertPos4.w;
	normalInterp = normal;
}
