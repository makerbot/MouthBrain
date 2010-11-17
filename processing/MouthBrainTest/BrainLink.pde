import processing.net.*;

class BrainLink
{
  Client CLIENT;
  byte[] BUFFER = new byte[512];

  BrainLink(PApplet applet)
  {
    CLIENT = new Client(applet, "127.0.0.1", 6683);
  }

  BrainLink(PApplet applet, String ip)
  {
    CLIENT = new Client(applet, ip, 6683);
  }

  BrainLink(PApplet applet, String ip, int port)
  {
    CLIENT = new Client(applet, ip, port);
  }

  void sendData() {
    PImage img = get();
    img.resize(16,16);
    img.loadPixels();

    //println("");
    //println("CLIENT: Start frame");

    int j=0;
    for (int i=0;i<img.pixels.length; i++, j++) {
      BUFFER[j] = (byte)(255-brightness(img.pixels[i]));

      //println("BUFFER[" + j + "]:  " + i + " = " + (int)BUFFER[j]);
      //println("PIXEL[" + i + "]: " + (int)BUFFER[j]);
      // Escape control chars
      if (BUFFER[j] == 10) {
        //println("CLIENT: Escape at " + j);
        j++;
        BUFFER[j] = 10;
      }
    }

    // Frame end
    BUFFER[j] = 10;
    j++;
    BUFFER[j] = 1;
    j++;

    //println("CLIENT: Send length: " + j);
    //  println("CLIENT: Buffer converted to string is "+s.length()+" chars long");

    CLIENT.write(subset(BUFFER, 0, j));
  }
}

