BrainLink LINK;

void setup()
{
  size(16, 16);
  frameRate(5);

  LINK = new BrainLink(this);
}

int i = 0;

void draw()
{
  background(255);
  loadPixels();
  pixels[i] = color(0);
  updatePixels();

  i++;
  i = i % pixels.length;
  
  LINK.sendData();
}

