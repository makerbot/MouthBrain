import processing.video.*;
import processing.net.*;

Client CLIENT;
Movie MOVIE;
char[] BUFFER = new char[514];

void setup() {
  size(128,128,P2D);

  CLIENT = new Client(this, "127.0.0.1", 6683);
  MOVIE = new Movie(this,"test.mov");
  MOVIE.loop();

  noStroke();
  
  frameRate(10);
}

void draw() {
  image(MOVIE, 0, 0, width, height);
  sendData();
}

void sendData() {
  PImage img = get();
  img.resize(16,16);
  img.loadPixels();
  
 // println("");
//  println("CLIENT: Start frame");

  int j=0;
  for (int i=0;i<img.pixels.length; i++,j++) {
      BUFFER[j] = (char)brightness(img.pixels[i]);
      
      // Escape control chars
      if (BUFFER[j] == 10) {
//        println("CLIENT: Escape at " + j);
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
//  println("CLIENT: Buffer converted to string is "+s.length()+" chars long");

  CLIENT.write(s);
  image(img,0,0);

}

