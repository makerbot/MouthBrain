int pixelSize = 4;
int gridWidth = 16;
int gridHeight = 16;

void setup()
{
  width = gridWidth*4*pixelSize;
  height = gridHeight*4*pixelSize;
  
  size(width, height);
}

void draw()
{
  if (mousePressed)
  {
    fill(0);
  }
  else
  {
    fill(255);
  }
  
  ellipse(mouseX, mouseY, 80, 80);
}
