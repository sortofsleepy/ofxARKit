precision highp float;

// this is the yyuv texture from ARKit
uniform sampler2D yMap;
uniform sampler2D uvMap;
uniform sampler2D testImage;

uniform float testVal;
varying vec2 vUv;
uniform vec2 resolution;
uniform mat4 rotationMatrix;

varying float val;
void main(){
 
    // flip uvs so image isn't inverted.
    vec2 uv = vec2(vUv.s,1.0 - vUv.t);
    
    vec4 capturedImageTextureY = texture2D(yMap, uv);
    vec4 capturedImageTextureCbCr = texture2D(uvMap, uv);
    
    mat4 transform = mat4(
                          1.0000, 1.0000, 1.0000, 0.0000,
                          0.0000, -0.3441, 1.7720, 0.0000,
                          1.4020, -0.7141, 0.0000, 0.0000,
                          -0.7010, 0.5291, -0.8860, 1.0000
                          );
    
    
    vec4 ycbr = vec4(capturedImageTextureY.r,capturedImageTextureCbCr.rg,1.);
    
    gl_FragColor = ycbr * transform;
}


