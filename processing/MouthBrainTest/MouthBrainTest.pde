import processing.video.*;
import processing.net.*;

Movie movie;
BrainLink brainLink;

void setup() {
  size(128,128,P2D);

  brainLink = new BrainLink(this);
  
  movie = new Movie(this,"test.mov");
  movie.loop();

  noStroke();
  
  frameRate(10);
}

void draw() {
  image(movie, 0, 0, width, height);
  
  loadPixels();
  for(int i=0; i<pixels.length; i++) {
    // Turn into shades of gray and adjust brightness
    pixels[i] = color(constrain(floor(sin(brightness(pixels[i])/256.0*HALF_PI)*255),0,255));
  }
  updatePixels();

  brainLink.sendData();
}



