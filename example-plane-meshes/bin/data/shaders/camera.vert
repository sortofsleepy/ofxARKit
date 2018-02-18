
// basic full screen shader
attribute vec2 position;
varying vec2 vUv;
uniform mat4 rotationMatrix;

const vec2 scale = vec2(0.5,0.5);
void main(){
    vUv = position.xy * scale + scale;

    //gl_Position = vec4(position,0.0,1.0);
    gl_Position = rotationMatrix * vec4(position,0.0,1.0);
}

