import processing.video.*;
import processing.net.*;

Client CLIENT;
char[] BUFFER = new char[514];

void setup() {
  size(16,16,P2D);

  CLIENT = new Client(this, "127.0.0.1", 6683);
  frameRate(0);

  draw();
}

void draw() {
  background(255);
  loadPixels();
  for (int i=0; i < pixels.length; i++) {
    pixels[i] = color((int) random(0, 255));
  }
  updatePixels();
  sendData();
}

void sendData() {
  PImage img = get();
  img.resize(16,16);
  img.loadPixels();

  println("");
  println("CLIENT: Start frame");

  int j=0;
  for (int i=0;i<img.pixels.length; i++, j++) {
    BUFFER[j] = (char)brightness(img.pixels[i]);

    println("CLIENT: pixel " + i + " = " + (int)BUFFER[j]);
    // Escape control chars
    if (BUFFER[j] == 10) {
      println("CLIENT: Escape at " + j);
      j++;
      BUFFER[j] = 10;
    }
  }

  // Frame end
  BUFFER[j] = 10;
  j++;
  BUFFER[j] = 1;
  j++;

  String s = new String(BUFFER,0,j);
  if (j != s.length()) {
    println("CLIENT: WARNING Java butchered your string.  Should be " + (j));
  }
  else
    println("CLIENT: Send length: " + s.length());
  //  println("CLIENT: Buffer converted to string is "+s.length()+" chars long");

  CLIENT.write(s);
}

