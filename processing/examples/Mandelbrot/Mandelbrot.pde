// The Mandelbrot Set by Daniel Shiffman. 
// Modified by Zach Hoeken
// Establish a range of values on the complex plane
// A different range will allow us to "zoom" in or out on the fractal
// float xmin = -1.5; float ymin = -.1; float wh = 0.15;
float xmin = -2.5; 
float ymin = -2; 
float wh = 4;
float xmax = xmin + wh;
float ymax = ymin + wh;

//MOUTHBRAIN SPECIFIC PARAMS
boolean invert = true;
int courseness = 3;

BrainLink LINK;

void setup() {
  size(256, 256, P2D);
  frameRate(30);

  // Make sure we can write to the pixels[] array. 
  // Only need to do this once since we don't do any other drawing.
  LINK = new BrainLink(this);
}

void draw() {

  if (mousePressed && (mouseButton == LEFT)) {
    if (mouseX / 256 > 0.5)
      xmin = xmin * 0.9;
    else
      xmax = xmax * 0.9;

    if (mouseY / 256 > 0.5)
      ymin = ymin * 0.9;
    else
      ymax = ymax * 0.9;
  } 
  else if (mousePressed && (mouseButton == RIGHT)) {
    if (mouseX / 256 > 0.5)
      xmin = xmin * 1.1;
    else
      xmax = xmax * 1.1;

    if (mouseY / 256 > 0.5)
      ymin = ymin * 1.1;
    else
      ymax = ymax * 1.1;
  }

  background(255);
  loadPixels();

  // Maximum number of iterations for each point on the complex plane
  int maxiterations = 200;

  // Calculate amount we increment x,y for each pixel
  float dx = (xmax - xmin) / (width);
  float dy = (ymax - ymin) / (height);

  // Start y
  float y = ymin;
  for (int j = 0; j < height; j++) {
    // Start x
    float x = xmin;
    for (int i = 0;  i < width; i++) {

      // Now we test, as we iterate z = z^2 + cm does z tend towards infinity?
      float a = x;
      float b = y;
      int n = 0;
      while (n < maxiterations) {
        float aa = a * a;
        float bb = b * b;
        float twoab = 2.0 * a * b;
        a = aa - bb + x;
        b = twoab + y;
        // Infinty in our finite world is simple, let's just consider it 16
        if(aa + bb > 16.0) {
          break;  // Bail
        }
        n++;
      }

      // We color each pixel based on how long it takes to get to infinity
      // If we never got there, let's pick the color black
      if (n == maxiterations) {
        pixels[i+j*width] = 0;
      } 
      else {
        // Gosh, we could make fancy colors here if we wanted
        if (invert)
          pixels[i+j*width] = color(255 - (n*16 % 255) / courseness);
        else
          pixels[i+j*width] = color((n*16 % 255) / courseness);
      }
      x += dx;
    }
    y += dy;
  }
  updatePixels();

  LINK.sendData();
}

