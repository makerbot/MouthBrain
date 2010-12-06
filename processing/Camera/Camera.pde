import processing.video.*;

Capture capture;
BrainLink brainLink;

void setup() {
  size(160, 160);
  println(Capture.list());
  capture = new Capture(this, 213, 160);
  brainLink = new BrainLink(this);
  frameRate(2);
}

void draw() {
  if (capture.available()) {
    capture.read();
    image(capture, -27, 0);
    loadPixels();
    for(int i=0; i<pixels.length; i++) {
      // Turn into shades of gray and adjust brightness
      pixels[i] = color(constrain(floor(sin(brightness(pixels[i])/256.0*HALF_PI)*255),0,255));
    }
    updatePixels();
    
    brainLink.sendData();
  }
}

