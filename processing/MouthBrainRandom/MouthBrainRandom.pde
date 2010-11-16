BrainLink LINK;

void setup()
{
  noStroke();
  size(16*16, 16*16,P2D);
  frameRate(10);
  
  LINK = new BrainLink(this);
}

void draw()
{
  background(255);
  
  for (int i=0; i < 16; i++) {
    for (int j=0; j < 16; j++)
    {
      fill(random(0, 255));
      rect(i*16, j*16, 16, 16);
    }
  }
  
  LINK.sendData();
}
