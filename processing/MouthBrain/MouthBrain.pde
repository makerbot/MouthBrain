int pixelSize = 8;
int gridWidth = 16;
int gridHeight = 16;

int[][] gridOut = new int[gridWidth][gridHeight];
int[][] gridIn  = new int[gridWidth][gridHeight];

int gridOutXPos = int(gridWidth*pixelSize*2.5);
int gridOutYPos = int(gridWidth*pixelSize*0.5);

int gridInXPos = int(gridWidth*pixelSize*0.5);
int gridInYPos = int(gridWidth*pixelSize*0.5);

PFont ubuntu14;

color low = color(0, 0, 255);
color high = color(255, 0, 0);

void setup()
{
  frameRate(30);
  
  int w = gridWidth*4*pixelSize;
  int h = gridHeight*3*pixelSize;

  ubuntu14 = loadFont("data/Ubuntu-Regular-14.vlw");
  textFont(ubuntu14);
  textMode(SCREEN);

  for (int x=0; x<gridOut.length; x++)
  {
    for (int y=0; y<gridOut[x].length; y++)
    {
      gridOut[x][y] = 0;
      gridOut[x][y] = int(random(0, 255));
    }
  }

  for (int x=0; x<gridIn.length; x++)
  {
    for (int y=0; y<gridIn[x].length; y++)
    {
      gridIn[x][y] = 0;
      gridIn[x][y] = int(random(0, 255));
    }
  }

  size(w, h);
}

void draw()
{
  background(175);

  fill(0);
  text("INPUT GRID", gridInXPos-1, gridInYPos-pixelSize);
  drawGrid(gridInXPos, gridInYPos, gridIn);

  fill(0);
  text("OUTPUT GRID", gridOutXPos-1, gridOutYPos-pixelSize);
  drawGrid(gridOutXPos, gridOutYPos, gridOut);
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
