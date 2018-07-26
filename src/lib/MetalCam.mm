//
//  MetalCam.m
//  metalTextureTest
//
//  Created by Joseph Chow on 6/28/18.
//

#import <simd/simd.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <MetalKit/MetalKit.h>
#import "MetalCam.h"
#include "ofMain.h"

#define GL_UNSIGNED_INT_8_8_8_8_REV 0x8367

// Include header shared between C code here, which executes Metal API commands, and .metal files
#import "ShaderTypes.h"

// The max number of command buffers in flight
static const NSUInteger kMaxBuffersInFlight = 3;
static const float kImagePlaneVertexData[16] = {
    -1.0, -1.0,  0.0, 1.0,
    1.0, -1.0,  1.0, 1.0,
    -1.0,  1.0,  0.0, 0.0,
    1.0,  1.0,  1.0, 0.0,
};


// Table of equivalent formats across CoreVideo, Metal, and OpenGL
static const AAPLTextureFormatInfo AAPLInteropFormatTable[] =
{
    // Core Video Pixel Format,               Metal Pixel Format,            GL internalformat, GL format,   GL type
    { kCVPixelFormatType_32BGRA,              MTLPixelFormatBGRA8Unorm,      GL_RGBA,           GL_BGRA_EXT, GL_UNSIGNED_INT_8_8_8_8_REV },
    { kCVPixelFormatType_32BGRA,              MTLPixelFormatBGRA8Unorm_sRGB, GL_RGBA,           GL_BGRA_EXT, GL_UNSIGNED_INT_8_8_8_8_REV },
};

static NSDictionary* cvBufferProperties = @{
                                             (__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @YES,
                                             (__bridge NSString*)kCVPixelBufferMetalCompatibilityKey : @YES,
                                             };

static const NSUInteger AAPLNumInteropFormats = sizeof(AAPLInteropFormatTable) / sizeof(AAPLTextureFormatInfo);

// ============ METAL CAM VIEW IMPLEMENTATION ============== //

@implementation MetalCamView

-(void)drawRect:(CGRect)rect{
    if(!self.currentDrawable && !self.currentRenderPassDescriptor){
        NSLog(@"unable to render");
        return;
    }
   
    // adjust image based on current frame
    [self _updateImagePlaneWithFrame];
    
    // update the camera image.
    [self update];
    
   
}

- (void) setViewport:(CGRect) _viewport{
    self->_viewport = _viewport;
}
- (void) update {
    
    if (!_session) {
        return;
    }
    
    // if viewport hasn't been set to something other than 0, try to set the viewport
    // values to be 0,0,<auto calcualted width>, <auto calculated height>
    _viewport = [[UIScreen mainScreen] bounds];
    
    // set the current orientation
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // Wait to ensure only kMaxBuffersInFlight are getting proccessed by any stage in the Metal
    //   pipeline (App, Metal, Drivers, GPU, etc)
    dispatch_semaphore_wait(self._inFlightSemaphore, DISPATCH_TIME_FOREVER);
    
    // Create a new command buffer for each renderpass to the current drawable
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    // Add completion hander which signal _inFlightSemaphore when Metal and the GPU has fully
    //   finished proccssing the commands we're encoding this frame.  This indicates when the
    //   dynamic buffers, that we're writing to this frame, will no longer be needed by Metal
    //   and the GPU.
    __block dispatch_semaphore_t block_sema = self._inFlightSemaphore;
    // Retain our CVMetalTextureRefs for the duration of the rendering cycle. The MTLTextures
    //   we use from the CVMetalTextureRefs are not valid unless their parent CVMetalTextureRefs
    //   are retained. Since we may release our CVMetalTextureRef ivars during the rendering
    //   cycle, we must retain them separately here.
    CVBufferRef capturedImageTextureYRef = CVBufferRetain(_capturedImageTextureYRef);
    CVBufferRef capturedImageTextureCbCrRef = CVBufferRetain(_capturedImageTextureCbCrRef);
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        dispatch_semaphore_signal(block_sema);
        CVBufferRelease(capturedImageTextureYRef);
        CVBufferRelease(capturedImageTextureCbCrRef);
    }];
    
    // update camera image
    [self _updateCameraImage];
    
    // Obtain a renderPassDescriptor generated from the view's drawable textures
    MTLRenderPassDescriptor* renderPassDescriptor = self.currentRenderPassDescriptor;
    
    // If we've gotten a renderPassDescriptor we can render to the drawable, otherwise we'll skip
    //   any rendering this frame because we have no drawable to draw to
    if (renderPassDescriptor != nil) {
        //NSLog(@"Got render pass descriptor - we can render!");
        // Create a render command encoder so we can render into something
        id <MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        
        // DRAW PRIMATIVE
        
        [self _drawCapturedImageWithCommandEncoder:renderEncoder];
        
        // We're done encoding commands
        [renderEncoder endEncoding];
    }else{
        NSLog(@"Error - do not have render pass descriptor");
    }
   
   
    //update shared OpenGL pixelbuffer
    // if running in openFrameworks
    if(openglMode){
        [self _updateSharedPixelbuffer];
    }
   
    
    // Schedule a present once the framebuffer is complete using the current drawable
    [commandBuffer presentDrawable:self.currentDrawable];
    
    // Finalize rendering here & push the command buffer to the GPU
    [commandBuffer commit];

}


- (void)_drawCapturedImageWithCommandEncoder:(id<MTLRenderCommandEncoder>)renderEncoder{
    if (_capturedImageTextureYRef == nil || _capturedImageTextureCbCrRef == nil) {
        //NSLog(@"Have not obtained image");
        return;
    }
    
    // Push a debug group allowing us to identify render commands in the GPU Frame Capture tool
    [renderEncoder pushDebugGroup:@"DrawCapturedImage"];
    
    // Set render command encoder state
    [renderEncoder setCullMode:MTLCullModeNone];
    [renderEncoder setRenderPipelineState:_capturedImagePipelineState];
    [renderEncoder setDepthStencilState:_capturedImageDepthState];
    
    // Set mesh's vertex buffers
    [renderEncoder setVertexBuffer:_imagePlaneVertexBuffer offset:0 atIndex:kBufferIndexMeshPositions];
    
    // Set any textures read/sampled from our render pipeline
    [renderEncoder setFragmentTexture:CVMetalTextureGetTexture(_capturedImageTextureYRef) atIndex:kTextureIndexY];
    [renderEncoder setFragmentTexture:CVMetalTextureGetTexture(_capturedImageTextureCbCrRef) atIndex:kTextureIndexCbCr];
    
    // Draw each submesh of our mesh
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    
    [renderEncoder popDebugGroup];

}


- (CVMetalTextureRef)_createTextureFromPixelBuffer:(CVPixelBufferRef)pixelBuffer pixelFormat:(MTLPixelFormat)pixelFormat planeIndex:(NSInteger)planeIndex {
    
    const size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex);
    const size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex);
    
    CVMetalTextureRef mtlTextureRef = nil;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, _capturedImageTextureCache, pixelBuffer, NULL, pixelFormat, width, height, planeIndex, &mtlTextureRef);
    if (status != kCVReturnSuccess) {
        CVBufferRelease(mtlTextureRef);
        mtlTextureRef = nil;
        NSLog(@"Issue cureating texture from pixel buffer");
    }
    
    return mtlTextureRef;
}

- (void) _updateImagePlaneWithFrame{
    
    if(_session.currentFrame != nil){
        
        // Update the texture coordinates of our image plane to aspect fill the viewport
        CGAffineTransform displayToCameraTransform = CGAffineTransformInvert([_session.currentFrame displayTransformForOrientation:orientation viewportSize:_viewport.size]);
        
        
        // TODO - example code is fine but here I have to cast? :/
        float *vertexData = (float*)[_imagePlaneVertexBuffer contents];
        
        for (NSInteger index = 0; index < 4; index++) {
            NSInteger textureCoordIndex = 4 * index + 2;
            CGPoint textureCoord = CGPointMake(kImagePlaneVertexData[textureCoordIndex], kImagePlaneVertexData[textureCoordIndex + 1]);
            CGPoint transformedCoord = CGPointApplyAffineTransform(textureCoord, displayToCameraTransform);
            vertexData[textureCoordIndex] = transformedCoord.x;
            vertexData[textureCoordIndex + 1] = transformedCoord.y;
        }
    }
    
    
}

- (void) _updateCameraImage {
    
   
    if(_session.currentFrame){
        // Create two textures (Y and CbCr) from the provided frame's captured image
        CVPixelBufferRef pixelBuffer = _session.currentFrame.capturedImage;
        
        CVBufferRelease(_capturedImageTextureYRef);
        CVBufferRelease(_capturedImageTextureCbCrRef);
        _capturedImageTextureYRef = [self _createTextureFromPixelBuffer:pixelBuffer pixelFormat:MTLPixelFormatR8Unorm planeIndex:0];
        _capturedImageTextureCbCrRef = [self _createTextureFromPixelBuffer:pixelBuffer pixelFormat:MTLPixelFormatRG8Unorm planeIndex:1];
        
    }
    
}
- (void) loadMetal {
    self._inFlightSemaphore = dispatch_semaphore_create(kMaxBuffersInFlight);
    
    self.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    self.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    self.sampleCount = 1;
    
    for(int i = 0; i < AAPLNumInteropFormats; i++) {
        if(self.colorPixelFormat == AAPLInteropFormatTable[i].mtlFormat) {
            formatInfo = AAPLInteropFormatTable[i];
         
        }
    }
    
    // Create a vertex buffer with our image plane vertex data.
    _imagePlaneVertexBuffer = [self.device newBufferWithBytes:&kImagePlaneVertexData length:sizeof(kImagePlaneVertexData) options:MTLResourceCPUCacheModeDefaultCache];
    
    _imagePlaneVertexBuffer.label = @"ImagePlaneVertexBuffer";
    
    // Load all the shader files with a metal file extension in the project
    // NOTE - this line will throw an exception if you don't have a .metal file as part of your compiled sources.
    id <MTLLibrary> defaultLibrary = [self.device newDefaultLibrary];
    
    id <MTLFunction> capturedImageVertexFunction = [defaultLibrary newFunctionWithName:@"capturedImageVertexTransform"];
    id <MTLFunction> capturedImageFragmentFunction = [defaultLibrary newFunctionWithName:@"capturedImageFragmentShader"];
    
    // Create a vertex descriptor for our image plane vertex buffer
    MTLVertexDescriptor *imagePlaneVertexDescriptor = [[MTLVertexDescriptor alloc] init];
    
    // build camera image plane
    // Positions.
    imagePlaneVertexDescriptor.attributes[kVertexAttributePosition].format = MTLVertexFormatFloat2;
    imagePlaneVertexDescriptor.attributes[kVertexAttributePosition].offset = 0;
    imagePlaneVertexDescriptor.attributes[kVertexAttributePosition].bufferIndex = kBufferIndexMeshPositions;
    
    // Texture coordinates.
    imagePlaneVertexDescriptor.attributes[kVertexAttributeTexcoord].format = MTLVertexFormatFloat2;
    imagePlaneVertexDescriptor.attributes[kVertexAttributeTexcoord].offset = 8;
    imagePlaneVertexDescriptor.attributes[kVertexAttributeTexcoord].bufferIndex = kBufferIndexMeshPositions;
    
    // Position Buffer Layout
    imagePlaneVertexDescriptor.layouts[kBufferIndexMeshPositions].stride = 16;
    imagePlaneVertexDescriptor.layouts[kBufferIndexMeshPositions].stepRate = 1;
    imagePlaneVertexDescriptor.layouts[kBufferIndexMeshPositions].stepFunction = MTLVertexStepFunctionPerVertex;
    
    
    // Create a pipeline state for rendering the captured image
    MTLRenderPipelineDescriptor *capturedImagePipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    capturedImagePipelineStateDescriptor.label = @"MyCapturedImagePipeline";
    capturedImagePipelineStateDescriptor.sampleCount = self.sampleCount;
    capturedImagePipelineStateDescriptor.vertexFunction = capturedImageVertexFunction;
    capturedImagePipelineStateDescriptor.fragmentFunction = capturedImageFragmentFunction;
    capturedImagePipelineStateDescriptor.vertexDescriptor = imagePlaneVertexDescriptor;
    capturedImagePipelineStateDescriptor.colorAttachments[0].pixelFormat = self.colorPixelFormat;
    capturedImagePipelineStateDescriptor.depthAttachmentPixelFormat = self.depthStencilPixelFormat;
    capturedImagePipelineStateDescriptor.stencilAttachmentPixelFormat = self.depthStencilPixelFormat;
    
    NSError *error = nil;
    _capturedImagePipelineState = [self.device newRenderPipelineStateWithDescriptor:capturedImagePipelineStateDescriptor error:&error];
    if (!_capturedImagePipelineState) {
        NSLog(@"Failed to created captured image pipeline state, error %@", error);
    }
    // do stencil setup
    // TODO this might not be needed in this case.
    MTLDepthStencilDescriptor *capturedImageDepthStateDescriptor = [[MTLDepthStencilDescriptor alloc] init];
    capturedImageDepthStateDescriptor.depthCompareFunction = MTLCompareFunctionAlways;
    capturedImageDepthStateDescriptor.depthWriteEnabled = NO;
    _capturedImageDepthState = [self.device newDepthStencilStateWithDescriptor:capturedImageDepthStateDescriptor];
    
    // initialize image cache
    CVMetalTextureCacheCreate(NULL, NULL, self.device, NULL, &_capturedImageTextureCache);
    
    // Create the command queue
    _commandQueue = [self.device newCommandQueue];
    
    // by default - there is no OpenGL compatibility so set pixel buffer flag to YES to
    // stop initialization.
    pixelBufferBuilt = YES;
    
}

// =========== OPENGL COMPATIBILTY =========== //


- (CVOpenGLESTextureRef) getConvertedTexture{
    return openglTexture;
}
- (void) _updateSharedPixelbuffer {
    
    auto width = 0;
    auto height = 0;
    
    
    
    
    
    if(self.currentDrawable && _session.currentFrame.capturedImage){
        
        /**
            TODO values are currently a bit fudged. Probably need to figure out better solution
         
            Figuring out the pixelBuffer size to get an accurate representation from the Metal frame.
            For some reason - default image is really zoomed in compared to when using the MTKView on it's own.
            Making the sharedPixelBuffer size to be larger fixes the issue, the problem now is coming up
            with an accurate value.
         
            Multiplying the bounds of the screen by the scale doesn't work oddly enough, it results in an
            error during OpenGL texture creation due to the resulting height being larger than the max texture size of 4096.
         
            Multiplying the bounds by 2 seems to do the trick though it's unclear if it's accurate or not at the moment.
         
            Testing results. Note all values are divided by 2
            1. when using scale - width is 1620 and height is 2880
         
            2. when using nativeScale - 1408 and height is 2504
         
            3. no scaling(note values are multiplied by 2 here) - Width is 2160 and height is 3840
         
            Taking
            <full frame width * scale> - <native width> and <full frame height * scale> - <native height> seems
            to be the best solution.
         */
        
        
        
        // Still zoomed in here - also need to flip width/height otherwise it looks like there's distortion
        //width = CVPixelBufferGetHeight(_session.currentFrame.capturedImage);
        //height = CVPixelBufferGetWidth(_session.currentFrame.capturedImage);
        
        // note that imageResolution is returned in a way as if the camera were in landscape mode so you may need to reverse values. Also note that this is not updated automatically, so probably gonna stick with native bounds of screen.
        //CGSize bounds = _session.configuration.videoFormat.imageResolution;
        
        CGRect screenBounds = [[UIScreen mainScreen] nativeBounds];
        auto scale = [[UIScreen mainScreen] nativeScale];
        
        CGSize fullFrame = CGSizeMake(screenBounds.size.width * scale, screenBounds.size.height * scale);
       
        width = fullFrame.width - screenBounds.size.width;
        height = fullFrame.height - screenBounds.size.height;
       
        //NSLog(@"Width is %i and height is %i",width,height);
        
        // TODO if orientation changes, set pixelBufferBuilt to NO so we can get the correct scaling.
        // If the pixel buffer hasn't been built yet - build it.
        // Note that this needs to be in an if statement because otherwise you run out of memory, previous buffer contents aren't overwritten for some reason even though we're pointing to the same pixel buffer.
        // Also setting the pixel buffer width / height to match the drawable doesn't work for some reason. Too large?
        
        if(pixelBufferBuilt == NO){
            // setup the shared pixel buffer so we can send this to OpenGL
            CVReturn cvret = CVPixelBufferCreate(kCFAllocatorDefault,
                                                 width,height,
                                                 formatInfo.cvPixelFormat,
                                                 (__bridge CFDictionaryRef)cvBufferProperties,
                                                 &_sharedPixelBuffer);
            
            if(cvret != kCVReturnSuccess)
            {
                assert(!"Failed to create shared opengl pixel buffer");
            }else{
                // NSLog(@"Width %f, height is %f",self.currentDrawable.layer.drawableSize.width,self.currentDrawable.layer.drawableSize.height);
            }
            
            pixelBufferBuilt = YES;
        }
        
        CVPixelBufferLockBaseAddress(_sharedPixelBuffer, 0);
        // set the region we want to capture in the Metal frame
        auto region = MTLRegionMake2D(0, 0, width, height);
        
        // set the bytes per row
        NSInteger bytesPerRow = CVPixelBufferGetBytesPerRow(_sharedPixelBuffer);
        
        // grab texture data from Metal
        [self.currentDrawable.texture getBytes:CVPixelBufferGetBaseAddress(_sharedPixelBuffer) bytesPerRow:bytesPerRow fromRegion:region mipmapLevel:0];
        
        // convert shared pixel buffer into an OpenGL texture
        openglTexture = [self convertToOpenGLTexture:_sharedPixelBuffer];
        
        // correct wrapping and filtering
        glBindTexture(CVOpenGLESTextureGetTarget(openglTexture), CVOpenGLESTextureGetName(openglTexture));
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glBindTexture(CVOpenGLESTextureGetTarget(openglTexture), 0);
        
        CVPixelBufferUnlockBaseAddress(_sharedPixelBuffer, 0);
        
    }
    

}
- (void) setupOpenGLCompatibility:(CVEAGLContext) eaglContext{
    // initialize video texture cache
    CVReturn err = CVOpenGLESTextureCacheCreate(
                                                kCFAllocatorDefault,
                                                nil,
                                                eaglContext,
                                                nil,
                                                &_videoTextureCache);
    if (err){
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
    }
    
    openglMode = YES;
    pixelBufferBuilt = NO;
    zoomFactor = 2.0;
}

- (CVPixelBufferRef) getSharedPixelbuffer{
    return _sharedPixelBuffer;
}
- (CVOpenGLESTextureRef) convertToOpenGLTexture:(CVPixelBufferRef) pixelBuffer{
    CVOpenGLESTextureRef texture = NULL;
    
    CVPixelBufferLockBaseAddress(_sharedPixelBuffer, 0);
    
    CVReturn err = noErr;
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       _sharedPixelBuffer,
                                                       nil,
                                                       GL_TEXTURE_2D,
                                                       formatInfo.glInternalFormat,
                                                       CVPixelBufferGetWidth(_sharedPixelBuffer),
                                                       CVPixelBufferGetHeight(_sharedPixelBuffer),
                                                       formatInfo.glFormat,
                                                       formatInfo.glType,
                                                       0,
                                                       &texture);
    
    if (err != kCVReturnSuccess) {
        CVBufferRelease(texture);

        //NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        if(err == kCVReturnInvalidPixelFormat){
            NSLog(@"Invalid pixel format");
        }
        
        if(err == kCVReturnInvalidPixelBufferAttributes){
            NSLog(@"Invalid pixel buffer attributes");
        }
        
        if(err == kCVReturnInvalidSize){
            NSLog(@"invalid size");
        }
        
        if(err == kCVReturnPixelBufferNotOpenGLCompatible){
            NSLog(@"not opengl compatible");
        }
        
    }
    
    // clear texture cache
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    CVPixelBufferUnlockBaseAddress(_sharedPixelBuffer, 0);
    
    return texture;
    
}
@end




