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

String outputModes[] = {"blank", "random", "image", "webcam"};
String outputMode = "random";

void setup()
{
  frameRate(30);
  
  int w = gridWidth*4*pixelSize;
  int h = gridHeight*3*pixelSize;

  ubuntu14 = loadFont("data/Ubuntu-Regular-14.vlw");
  textFont(ubuntu14);
  textMode(SCREEN);

  size(w, h);
}

void draw()
{
  background(175);
  
  drawOutputModes();

  gridOut = generateOutputFrame();

  fill(0);
  text("INPUT GRID", gridInXPos-1, gridInYPos-pixelSize);
  drawGrid(gridInXPos, gridInYPos, gridIn);

  fill(0);
  text("OUTPUT GRID", gridOutXPos-1, gridOutYPos-pixelSize);
  drawGrid(gridOutXPos, gridOutYPos, gridOut);
}

void drawOutputModes()
{
  int startX = gridOutXPos-1;
  int startY = gridOutYPos + pixelSize*gridHeight+15;

  for (int i=0; i<outputModes.length; i++)
  {
    int realY = startY+i*30;
    stroke(0);
    if (outputMode == outputModes[i])
      fill(200);
    else
      fill(255);
      
    rect(startX, realY, pixelSize*gridWidth+2, 20);
    
    fill(0);
    text(outputModes[i], startX+5, realY+15);
  }
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

int[][] generateOutputFrame()
{
  if (outputMode == "random")
    return generateRandomFrame();
  else
    return generateBlankFrame();
}

int[][] generateBlankFrame()
{
  int[][] pixelData = new int[gridWidth][gridHeight];
  
  for (int x=0; x<gridOut.length; x++)
  {
    for (int y=0; y<gridOut[x].length; y++)
    {
      pixelData[x][y] = 0;
    }
  }

  for (int x=0; x<gridIn.length; x++)
  {
    for (int y=0; y<gridIn[x].length; y++)
    {
      pixelData[x][y] = 0;
    }
  }
  
  return pixelData;
}

int[][] generateRandomFrame()
{
  int[][] pixelData = new int[gridWidth][gridHeight];
  
  for (int x=0; x<gridOut.length; x++)
  {
    for (int y=0; y<gridOut[x].length; y++)
    {
      pixelData[x][y] = int(random(0, 255));
    }
  }

  for (int x=0; x<gridIn.length; x++)
  {
    for (int y=0; y<gridIn[x].length; y++)
    {
      pixelData[x][y] = int(random(0, 255));
    }
  }
  
  return pixelData;
}
