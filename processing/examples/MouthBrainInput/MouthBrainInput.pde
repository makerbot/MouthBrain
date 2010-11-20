int pixelSize = 8;
int gridWidth = 16;
int gridHeight = 16;

int[][] gridIn  = new int[gridWidth][gridHeight];

int gridInXPos = int(gridWidth*pixelSize*0.5);
int gridInYPos = int(gridWidth*pixelSize*0.5);

BrainLink LINK;

color low = color(0, 0, 255);
color high = color(255, 0, 0);

void setup()
{
  frameRate(30);
  
  LINK = new BrainLink(this);
  
  int w = gridWidth*2*pixelSize;
  int h = gridHeight*2*pixelSize;

  size(w, h);
}

void draw()
{
  background(175);

  gridIn = LINK.readData();

  fill(0);
  text("INPUT GRID", gridInXPos-1, gridInYPos-pixelSize);
  drawGrid(gridInXPos, gridInYPos, gridIn);
}


void drawGrid(int x, int y, int[][] data)
{
  stroke(0);
  fill(255);
  rect(x-1, y-1, pixelSize*gridWidth+2, pixelSize*gridHeight+2);

  for (int i=0; i<data.length; i++)
  {
    for (int j=0; j<data.length; j++)
    {
      int xPos = x+i*pixelSize;
      int yPos = y+j*pixelSize;
      
      color c = getColorFromValue(data[i][j]);
      
      stroke(c);
      fill(c);
      rect(xPos, yPos, pixelSize, pixelSize);
    }
  }
}

color getColorFromValue(int v)
{
   return 255-v; 
}
