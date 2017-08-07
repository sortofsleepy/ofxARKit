precision highp float;

// this is the yyuv texture from ARKit
uniform sampler2D yMap;
uniform sampler2D uvMap;
varying vec2 vUv;


/**
     We want to take the camera input and properly convert to RGB. This was done with the help of
 GPUImage project
 https://github.com/BradLarson/GPUImage
 
 Specifically between these couple files
 https://github.com/BradLarson/GPUImage/blob/167b0389bc6e9dc4bb0121550f91d8d5d6412c53/framework/Source/GPUImageColorConversion.m
 https://github.com/BradLarson/GPUImage/blob/167b0389bc6e9dc4bb0121550f91d8d5d6412c53/framework/Source/GPUImageVideoCamera.m
 */
void main(){
 
    // flip uvs so image isn't inverted.
    vec2 textureCoordinate = vec2(vUv.s,1.0 - vUv.t);
    
    // Using BT.709 which is the standard for HDTV
    mat3 colorConversionMatrix = mat3(
                                      1.164,  1.164, 1.164,
                                      0.0, -0.213, 2.112,
                                      1.793, -0.533,   0.0
                                      );
    
    
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    yuv.x = texture2D(yMap, textureCoordinate).r - (16.0/255.0);
    yuv.yz = texture2D(uvMap, textureCoordinate).ra - vec2(0.5, 0.5);
  
    rgb = colorConversionMatrix * yuv;

    gl_FragColor = vec4(rgb,1.);
}


