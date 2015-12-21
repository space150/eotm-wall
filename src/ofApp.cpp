#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
	ofBackground(0,0,0);
	ofSetVerticalSync(true);
	frameByframe = false;
    
    serial.listDevices();
    vector <ofSerialDeviceInfo> deviceList = serial.getDeviceList();
    
    int baud = 57600;
    //serial.setup(0, 57600);
    serial.setup("/dev/tty.usbmodem1421", baud);
    
    memset(bytesReadString, 0, 4);
    
    currentEotmMovie = 0;
    
    ofVideoPlayer eotmMovie;
    eotmMovie.load("movies/red.mp4");
    eotmMovie.setLoopState(OF_LOOP_NONE);
    eotmMovie.play();
    eotmMovies.push_back(eotmMovie);
    
    ofVideoPlayer eotmMovie2;
    eotmMovie2.load("movies/green.mp4");
    eotmMovie2.setLoopState(OF_LOOP_NONE);
    eotmMovies.push_back(eotmMovie2);
    
    ofVideoPlayer eotmMovie3;
    eotmMovie3.load("movies/blue.mp4");
    eotmMovie3.setLoopState(OF_LOOP_NONE);
    eotmMovies.push_back(eotmMovie3);
    
    eotmMovies[0].setPosition(0.0f);
    
    ofSeedRandom();
}

//--------------------------------------------------------------
void ofApp::update(){
    
    nTimesRead = 0;
    nBytesRead = 0;
    int nRead  = 0;  // a temp variable to keep count per read
    
    unsigned char bytesReturned[3];
    
    memset(bytesReadString, 0, 4);
    memset(bytesReturned, 0, 3);
    
    while( (nRead = serial.readBytes( bytesReturned, 3)) > 0){
        nTimesRead++;
        nBytesRead = nRead;
    };
    
    memcpy(bytesReadString, bytesReturned, 3);
    
    bSendSerialMessage = false;
    readTime = ofGetElapsedTimef();
    
    if (ofToString(bytesReadString) == "1")
        selectRandomMovie();
    
    for ( int i = 0; i < eotmMovies.size(); i++ )
        eotmMovies[i].update();
}

//--------------------------------------------------------------
void ofApp::draw()
{

    eotmMovies[currentEotmMovie].draw(0,0);

}

void ofApp::selectRandomMovie()
{
    ofLog(ofLogLevel::OF_LOG_ERROR, "Selecting random movie to play!");
    currentEotmMovie = ofRandom(0, 2);
    eotmMovies[currentEotmMovie].firstFrame();
    eotmMovies[currentEotmMovie].play();
}

//--------------------------------------------------------------
void ofApp::keyPressed  (int key){
    switch(key){
        case 'f':
            frameByframe=!frameByframe;
            eotmMovies[currentEotmMovie].setPaused(frameByframe);
        break;
        case OF_KEY_LEFT:
            eotmMovies[currentEotmMovie].previousFrame();
        break;
        case OF_KEY_RIGHT:
            eotmMovies[currentEotmMovie].nextFrame();
        break;
        case '0':
            eotmMovies[currentEotmMovie].firstFrame();
        break;
        case 'r':
            selectRandomMovie();
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
        eotmMovies[currentEotmMovie].setSpeed(speed);
	}
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
	if(!frameByframe){
        int width = ofGetWidth();
        float pct = (float)x / (float)width;
        eotmMovies[currentEotmMovie].setPosition(pct);
	}
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
	if(!frameByframe){
        eotmMovies[currentEotmMovie].setPaused(true);
	}
}


//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){
	if(!frameByframe){
        eotmMovies[currentEotmMovie].setPaused(false);
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
