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


/*

    Reminder note that OpenGL is planned for deprecation at some point. 
    https://www.anandtech.com/show/12894/apple-deprecates-opengl-across-all-oses

    Shifting any texture information getters to return "void *" for more flexible handling of things.
*/
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
    id <MTLRenderPipelineState> _capturedImagePipelineState;
    id <MTLDepthStencilState> _capturedImageDepthState;
    
    CVMetalTextureRef _capturedImageTextureYRef;
    CVMetalTextureRef _capturedImageTextureCbCrRef;
    
    //! Combined camera image that gets rendered onto
    CVMetalTextureRef _cameraImage;
    
    id<MTLTexture> _cameraTexture;
    
    //! Shared camera texture that's used to hold a converted MetalTexture
    CVOpenGLESTextureRef openglTexture;
    
    // Captured image texture cache
    CVMetalTextureCacheRef _capturedImageTextureCache,_combinedCameraTextureCache;
    
    // Flag for viewport size changes
    BOOL _viewportSizeDidChange;
    
    // current viewport settings - using CGRect cause
    // it's needed to allow things to render correctly.
    CGRect _viewport;
    
    // stores formating info that allows interop between OpenGL / Metal
    AAPLTextureFormatInfo formatInfo;
    
    // ======= STUFF FOR OPENGL COMPATIBILITY ========= //
    CVOpenGLESTextureCacheRef _videoTextureCache;
    CVPixelBufferRef _sharedPixelBuffer;
    BOOL pixelBufferBuilt;
    MTLRegion captureRegion;
    BOOL openglMode;
    
    // ===== OCCLUSION RELATED ======= //
    
    // pre-processor defs can be used it seems
    // https://stackoverflow.com/questions/25290547/checking-ios-version-through-preprocessor
#ifdef __IPHONE_13_0
    ARMatteGenerator matteGenerator;
    
    // textures used to calculate depth information
    MTLTexture alphaTexture;
    MTLTexture dilatedDepthTexture;
    
#endif
}
@property(nonatomic,retain)dispatch_semaphore_t _inFlightSemaphore;
@property(nonatomic,retain)ARSession * session;

- (void) setupOpenGLCompatibility:(CVEAGLContext) eaglContext;
- (CVPixelBufferRef) getSharedPixelbuffer;
- (CVOpenGLESTextureRef) convertToOpenGLTexture:(CVPixelBufferRef) pixelBuffer;
- (CVOpenGLESTextureRef) getConvertedTexture;
- (void) _setupTextures;
- (void) _updateOpenGLTexture;
- (void) _drawCapturedImageWithCommandEncoder:(id<MTLRenderCommandEncoder>)renderEncoder;
- (void) _updateImagePlaneWithFrame;
- (void) _updateCameraImage;
- (void) update;
- (void) setViewport:(CGRect) _viewport;
- (void) loadMetal;

#ifdef __IPHONE_13_0
- (void) loadMatteGenerator;
- (void) updateMatteTextures(id<MTLCommandBuffer>)commandBuffer;
- (void*) getDepthTextureData;
- (void*) getAlphaTextureData;
#endif

@end

// ========= Implement the renderer ========= //
namespace ofxARKit { namespace core {
    
        class MetalCamRenderer {
        protected:
            MetalCamView * _view;
            ARSession * session;
            CGRect viewport;
            CVEAGLContext context;
        public:
            MetalCamRenderer() = default;

            // TODO probably should tear stuff down but seems to be fine for now. 
            ~MetalCamRenderer() = default;
            
            //! Returns a reference to the Metal view object that handles the camera input.
            MetalCamView* getView(){
                return _view;
            }
            
            //! Returns the OpenGL texture id for the camera 
            //! TODO convert to something more oF friendly.
            CVOpenGLESTextureRef getTexture(){
                return [_view getConvertedTexture];
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
