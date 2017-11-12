//
//  UI.h
//  bulletplane
//
//  Created by Joseph Chow on 11/1/17.
//

#ifndef UI_h
#define UI_h

#include "ofMesh.h"
class Button {
    
    ofColor color = ofColor(100,100,100);
    std::function<void(void)> onClick;
    int width,height;
    int x,y;
    
public:
    
    bool onButton = false;
    
    Button(int x=0,int y=0,int width=100,int height=100){
        this->width = width;
        this->height = height;
        this->x = 0;
        this->y = 0;
    }
    
    void setOnClickHandler(std::function<void(void)> clickHandler){
        onClick = clickHandler;
    }
    
    void flipOnButtonFlag(){
        onButton = !onButton;
    }
    
    bool isOnButton(){
        return onButton;
    }
    
    void draw(){
        ofPushMatrix();
        
        ofSetColor(color);
        ofDrawPlane(x,y,width,height);
        ofPopMatrix();
    }
    
    void onPress(int x, int y){
        float centerX = this->x + width / 2;
        float centerY = this->y + height / 2;
        float minX = centerX - width / 2;
        float minY = centerY - height / 2;
        float maxX = centerX + width / 2;
        float maxY = centerY + height / 2;
        
        if(x > minX && x < maxX && y > minY && y < maxY){
            
            if(onClick){
                onClick();
            }
            onButton = true;
        }else{
            onButton = false;
        }
        
        
    }
};
#endif /* UI_h */

