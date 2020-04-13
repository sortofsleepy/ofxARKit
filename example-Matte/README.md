# About Example-Matte

![Screenshot of Hand Textured](handAsset.gif)

### Description

This example takes advantages of the [ARMatteGenerator](https://developer.apple.com/documentation/arkit/armattegenerator?language=objc) by using the 3 textures coming from the depth of the camera on iOS >= 13.0.

Find the file called `ARBodyTrackingBool.h` in `src/lib/` which defines if the  bodyTracking and uncomment line 9 & 10, in order for the shader vertexMatte and fragmentMatte in `Camera.h` to be used.

The shader processing the image inside ofCamera does the processing of the :
* [alpha texture](https://developer.apple.com/documentation/arkit/armattegenerator/3223424-generatemattefromframe?language=objc)
* [body depth texture](https://developer.apple.com/documentation/arkit/armattegenerator/3229913-generatedilateddepthfromframe?language=objc)
* [depth image](https://developer.apple.com/documentation/arkit/arframe/3152989-estimateddepthdata)

An Affine Transformation of the texture coordinate needs to be applied to get a match with the camera texture, which is done using the [CGAffineTransform](https://developer.apple.com/documentation/coregraphics/cgaffinetransform) to get the camera Transform. This is passed as 2 uniforms to the ofCamera shader.

Alternatively, the `ARProcessor` has the following methods to be used in the `ofApp` :
```
CVOpenGLESTextureRef getTextureMatteAlpha();
CVOpenGLESTextureRef getTextureMatteDepth();
CVOpenGLESTextureRef getTextureDepth();
ofMatrix3x3 getAffineTransform();
```

In order to use them correctly try coping the shader from `ofCamera.h` .
