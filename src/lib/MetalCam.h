//
//  MetalCam.h
//  metalTextureTest
//
//  Created by Joseph Chow on 6/28/18.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <ARKit/ARKit.h>

#import "ARBodyTrackingBool.h"

#pragma once

NS_ASSUME_NONNULL_BEGIN
@protocol RenderDestinationProvider
@property (nonatomic, readonly, nullable) MTLRenderPassDescriptor *currentRenderPassDescriptor;
@property (nonatomic, readonly, nullable) id<MTLDrawable> currentDrawable;

@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic) MTLPixelFormat depthStencilPixelFormat;
@property (nonatomic) NSUInteger sampleCount;
@end

typedef struct {
    int                 cvPixelFormat;
    MTLPixelFormat      mtlFormat;
    GLuint              glInternalFormat;
    GLuint              glFormat;
    GLuint              glType;
} AAPLTextureFormatInfo;



@interface MetalCamView : MTKView {
    
    // Reference to the current session
    ARSession * _session;

    // maintains knowledge of the current orientation of the device
    UIInterfaceOrientation orientation;
    
    // Metal objects
    id <MTLTexture> _renderTarget;
    id <MTLCommandQueue> _commandQueue;
    id <MTLBuffer> _sharedUniformBuffer;
    id <MTLBuffer> _imagePlaneVertexBuffer;
    id <MTLBuffer> _scenePlaneVertexBuffer;
    id <MTLRenderPipelineState> _capturedImagePipelineState;
    id <MTLDepthStencilState> _capturedImageDepthState;
    
    // body extraction
    id<MTLTexture> alphaTexture;
    id<MTLTexture> dilatedDepthTexture;
    id<MTLTexture> sceneDepthTexture;

    
    CVMetalTextureRef _capturedImageTextureYRef;
    CVMetalTextureRef _capturedImageTextureCbCrRef;
    
    //! Combined camera image that gets rendered onto
    CVMetalTextureRef _cameraImage;
    
    id<MTLTexture> _cameraTexture;
    
    //! Shared camera texture that's used to hold a converted MetalTexture
    CVOpenGLESTextureRef openglTexture, alphaTextureMatteGLES, depthTextureMatteGLES, depthTextureGLES;
    
    // Captured image texture cache
    CVMetalTextureCacheRef _capturedImageTextureCache,_combinedCameraTextureCache;
    
    // Flag for viewport size changes
    BOOL _viewportSizeDidChange;
    
    // current viewport settings - using CGRect cause
    // it's needed to allow things to render correctly.
    CGRect _viewport;
    
    // stores formating info that allows interop between OpenGL / Metal
    AAPLTextureFormatInfo formatInfo;
    
    // ======= STUFF FOR MATTE ========= //
    ARMatteGenerator* matteDepthTexture;
    CVPixelBufferRef pixel_bufferAlphaMatte, pixel_bufferDepth, pixel_bufferDepthMatte;
    float *compositeVertexData;
    
    
    // ======= STUFF FOR OPENGL COMPATIBILITY ========= //
    CVOpenGLESTextureCacheRef _videoTextureCache;
    CVPixelBufferRef _sharedPixelBuffer;
    BOOL pixelBufferBuilt;
    BOOL openglMode;
}
@property(nonatomic,retain)dispatch_semaphore_t _inFlightSemaphore;
@property(nonatomic,retain)ARSession * session;


- (void) setupOpenGLCompatibility:(CVEAGLContext) eaglContext;
- (CVPixelBufferRef) getSharedPixelbuffer;
- (CVOpenGLESTextureRef) convertToOpenGLTexture:(CVPixelBufferRef) pixelBuffer _videoTextureCache:(CVOpenGLESTextureCacheRef)vidTextureCache;
// return types
- (CVOpenGLESTextureRef) getConvertedTexture;
- (CVOpenGLESTextureRef) getConvertedTextureMatteAlpha;
- (CVOpenGLESTextureRef) getConvertedTextureMatteDepth;
- (CVOpenGLESTextureRef) getConvertedTextureDepth;
- (CGAffineTransform) getAffineCameraTransform;



// Matte Texturing
- (void) _initMatteTexture;
- (void) _updateMatteTextures:(id<MTLCommandBuffer>) commandBuffer;

// convert
- (CVOpenGLESTextureRef) convertFromMTLToOpenGL:(id<MTLTexture>) texture  pixel_buffer:(CVPixelBufferRef)pixel_buffer _videoTextureCache:(CVOpenGLESTextureCacheRef)vidTextureCache;
- (CVOpenGLESTextureRef) convertFromPixelBufferToOpenGL:(CVPixelBufferRef)pixel_buffer _videoTextureCache:(CVOpenGLESTextureCacheRef)vidTextureCache;



- (void) _setupTextures;
- (void) _updateOpenGLTexture;
- (void) _drawCapturedImageWithCommandEncoder:(id<MTLRenderCommandEncoder>)renderEncoder;
- (void) _updateImagePlaneWithFrame;
- (void) _updateCameraImage;
- (void) update;
- (void) setViewport:(CGRect) _viewport;
- (void) loadMetal;

@end

// ========= Implement the renderer ========= //
namespace ofxARKit {
    namespace core {
        class MetalCamRenderer {
        protected:
            MetalCamView * _view;
            ARSession * session;
            CGRect viewport;
            CVEAGLContext context;
        public:
            MetalCamRenderer(){}
            ~MetalCamRenderer(){}
            
            MetalCamView* getView(){
                return _view;
            }
            
            CVOpenGLESTextureRef getTexture(){
                return [_view getConvertedTexture];
            }
            
//            CVOpenGLESTextureRef getTextureAlpha(){
//                return[_view getConvertedTextureAlpha];
//            }
            
            CVOpenGLESTextureRef getTextureDepth(){
                return[_view getConvertedTextureDepth];
            }
            
            void draw(){
                [_view draw];
            }
            
            void setViewport(int width,int height){
                viewport = CGRectMake(0,0,width,height);
                [_view setViewport:viewport];
            }
            
            void setup(ARSession * session, CGRect viewport, CVEAGLContext context){
                
                this->session = session;
                this->viewport = viewport;
                this->context = context;
                
                _view = [[MetalCamView alloc] initWithFrame:viewport device:MTLCreateSystemDefaultDevice()];
                _view.session = session;
                _view.framebufferOnly = NO;
                _view.paused = YES;
                _view.enableSetNeedsDisplay = NO;
                
                
                [_view loadMetal];
                [_view setupOpenGLCompatibility:context];
            }
        };
    
    }
}

NS_ASSUME_NONNULL_END
