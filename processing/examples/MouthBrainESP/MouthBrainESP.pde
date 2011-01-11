import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

BrainLink link;
Minim minim;
AudioSample yes;
AudioSample no;

PImage[] images = new PImage[5];
int x[] = { 5, 138, 261, 5, 261 };
int y[] = { 5, 138, 5, 261, 261 };

PFont myfont;

void setup()
{
  size(400, 400);
  frameRate(5);
  
  images[0] = loadImage("circle.gif");
  images[1] = loadImage("cross.gif");
  images[2] = loadImage("square.gif");
  images[3] = loadImage("star.gif");
  images[4] = loadImage("waves.gif");
  
  minim = new Minim(this);
  yes = minim.loadSample("bityes.wav");
  no = minim.loadSample("bitno.wav");
  
  link = new BrainLink(this);
  index = int(random(5));
  drawFrame();
  
  myfont = loadFont("CharterBT-Roman-48.vlw");
  textFont(myfont);
}

int index;
int myScore = 0;
int myTotal = 0;

void draw()
{
  for (int i=0; i<5; i++)
  {
    image(images[i], x[i], y[i]);
    text(i+1, x[i], y[i]+50);
  }
}

void drawFrame()
{
  int n = index;
  while (n == index) 
    index = int(random(5));

  println(index);
  
  link.sendData(images[index]);
}

void keyReleased()
{
  println("key=" + key + " index="+index);
  boolean success = (keyCode == '1' && index == 0) ||
    (keyCode == '2' && index == 1) ||
    (keyCode == '3' && index == 2) ||
    (keyCode == '4' && index == 3) ||
    (keyCode == '5' && index == 4);
    
  myTotal++;
  
  if (success) {
    yes.trigger();
    println("SUCCESS");
    myScore++;
  } 
  else {
    no.trigger();
    println("FAILURE");
  }
  
  link.sendMessage("Score: " + myScore + "/" + myTotal + "(" + (((float)myScore/myTotal)*100) + ")");
  
  drawFrame();
}

void stop() {
   yes.close();
   no.close();
   minim.stop();
}
