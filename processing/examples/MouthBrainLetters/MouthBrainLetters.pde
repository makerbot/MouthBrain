BrainLink LINK;
PFont f;

void setup()
{
  size(32, 32);
  frameRate(1);
  noLoop();

  f = loadFont("CharterBT-Roman-48.vlw");
  textFont(f, 48);  

  LINK = new BrainLink(this);

  background(255);
  fill(0);
  textAlign(CENTER, CENTER);
}


char c;

void draw()
{
  text("A", 16, 16);    
  
  LINK.sendData();
}

