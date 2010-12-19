BrainLink LINK;
int i = 0;

void setup()
{
  size(16, 16);
  frameRate(1);

  LINK = new BrainLink(this);
  
  drawFrame();
}

void draw() {
  drawFrame();
}

void drawFrame()
{
  background(0);
  loadPixels();
  pixels[i] = color(255);
  updatePixels();

  i++;
  i = i % pixels.length;
  
  LINK.sendData();
}

void mouseReleased() {
  drawFrame();
}

void keyReleased() {
  drawFrame();
}


