/**
 * Getting Started with Capture.
 * 
 * Reading and displaying an image from an attached Capture device. 
 */

import processing.video.*;

BrainLink brainLink;
Capture cam;

void setup() {
  size(320, 320);

  brainLink = new BrainLink(this);

  // If no device is specified, will just use the default.
  cam = new Capture(this, 320, 240);

  // To use another device (i.e. if the default device causes an error),  
  // list all available capture devices to the console to find your camera.
  //String[] devices = Capture.list();
  //println(devices);

  // Change devices[0] to the proper index for your camera.
  //cam = new Capture(this, width, height, devices[0]);

  // Opens the settings page for this capture device.
  //cam.settings();

  frameRate(5);
}


void draw() {
  background(127);
  if (cam.available() == true) {
    cam.read();
    set(0, 40, cam);
    filter(GRAY);
    filter(POSTERIZE, 4);
    filter(INVERT);
    brainLink.sendData();
  }
} 

