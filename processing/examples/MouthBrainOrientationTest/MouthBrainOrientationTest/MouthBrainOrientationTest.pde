BrainLink link;

void setup() {
  size(16,16);
  frameRate(5);
  
  link = new BrainLink(this);
  n=0;
  drawFrame();
}

int n;
int x;
int y;

void draw() {
}

void drawFrame() {
  background(0);
  fill(255);  

/*  
  x = (frameCount % 2) * 8;
  y = ((frameCount/2) % 2) * 8;
  rect(x,y,8,8);
*/

  n++;
  x = n % 4;
  
  if (x == 0)
    rect(0,0,16,4);
  else if (x == 1)
    rect(12,0,4,16);
  else if (x == 2)
    rect(0,12,16,4);
  else
    rect(0,0,4,16); 


  link.sendData();
}

void keyReleased() {
  drawFrame();
}

