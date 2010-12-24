import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

BrainLink link;
Minim minim;
AudioSample yes;
AudioSample no;

void setup() {
  size(16,16);
  frameRate(5);
  
  minim = new Minim(this);
  yes = minim.loadSample("bityes.wav");
  no = minim.loadSample("bitno.wav");
  
  link = new BrainLink(this);
  direction = int(random(4));
  drawFrame();
}

int direction;
int myScore = 0;
int myTotal = 0;

void draw() {
}

void drawBlank() {
  background(0);
  link.sendData();
}

void drawFrame() {
  int n = direction;
  while (n == direction) 
    direction = int(random(4));

  background(0);
  fill(255);
  noStroke();

println(direction);
  if (direction == 0) // UP
    rect(0,0,16,4);
  else if (direction == 1) // RIGHT
    rect(12,0,4,16);
  else if (direction == 2) // DOWN
    rect(0,12,16,4);
  else
    rect(0,0,4,16); // LEFT

  link.sendData();

  //n++;
  //x = n % 4;
}

void keyReleased() {
  println("keyCode="+keyCode+" direction="+direction);
  boolean success = (keyCode == UP && direction == 0) ||
    (keyCode == RIGHT && direction == 1) ||
    (keyCode == DOWN && direction == 2) ||
    (keyCode == LEFT && direction == 3);
    
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
  
  drawBlank();
  drawFrame();
}

void stop() {
   yes.close();
   no.close();
   minim.stop();
}

