BrainLink LINK;
PFont f;

char c[] = {'A'};

void setup()
{
  size(32, 32);
  frameRate(1);

  f = loadFont("CharterBT-Roman-48.vlw");
  textFont(f, 48);  

  LINK = new BrainLink(this);

  drawFrame();
}

void draw()
{
}

void drawFrame() {
  String foo = new String(c);

  background(0);
  fill(255);
  textAlign(CENTER, CENTER);
  text(foo, 16, 15);    
  
  LINK.sendData();

  c[0]++;
  if (c[0] == '[')
    c[0] = 'A';
    
  println(c);
  println(foo);
}

void keyReleased() {
  drawFrame();
}

