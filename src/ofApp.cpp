#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
	ofBackground(0,0,0);
	ofSetVerticalSync(true);
	frameByframe = false;
    
    serial.listDevices();
    vector <ofSerialDeviceInfo> deviceList = serial.getDeviceList();
    
    int baud = 57600;
    serial.setup(0, 57600);
    //serial.setup("/dev/ttyUSB0", baud);
    
    memset(bytesReadString, 0, 4);
    
}

//--------------------------------------------------------------
void ofApp::update(){
    memset(bytesReadString, 0, 4);
    eotmMovie.update();
}

//--------------------------------------------------------------
void ofApp::draw(){

    eotmMovie.draw(0,0);

}

//--------------------------------------------------------------
void ofApp::keyPressed  (int key){
    switch(key){
        case 'f':
            frameByframe=!frameByframe;
            eotmMovie.setPaused(frameByframe);
        break;
        case OF_KEY_LEFT:
            eotmMovie.previousFrame();
        break;
        case OF_KEY_RIGHT:
            eotmMovie.nextFrame();
        break;
        case '0':
            eotmMovie.firstFrame();
        break;
        case 'r':
            eotmMovie.load("movies/red.mp4");
            eotmMovie.setLoopState(OF_LOOP_NORMAL);
            eotmMovie.play();
        break;
        case 'g':
            eotmMovie.load("movies/green.mp4");
            eotmMovie.setLoopState(OF_LOOP_NORMAL);
            eotmMovie.play();
        break;
        case 'b':
            eotmMovie.load("movies/blue.mp4");
            eotmMovie.setLoopState(OF_LOOP_NORMAL);
            eotmMovie.play();
        break;
    }
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){
	if(!frameByframe){
        int width = ofGetWidth();
        float pct = (float)x / (float)width;
        float speed = (2 * pct - 1) * 5.0f;
        eotmMovie.setSpeed(speed);
	}
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
	if(!frameByframe){
        int width = ofGetWidth();
        float pct = (float)x / (float)width;
        eotmMovie.setPosition(pct);
	}
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
	if(!frameByframe){
        eotmMovie.setPaused(true);
	}
}


//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){
	if(!frameByframe){
        eotmMovie.setPaused(false);
	}
}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
