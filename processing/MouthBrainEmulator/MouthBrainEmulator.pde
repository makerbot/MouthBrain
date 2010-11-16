import processing.net.*;
import processing.serial.*;

// CONSTANTS
int COMM_MODE_SERIAL = 1;
int COMM_MODE_NETWORK = 2;
int COMM_MODE_PROXY = 3;

// CONFIGURATION
int COMM_MODE = COMM_MODE_NETWORK;
int COMM_CONTROL_CHAR = 10;
int COMM_BUFFER_SIZE = 4096;
int SERIAL_PORT = 1;
int SERIAL_RATE = 9600;
int NETWORK_PORT = 6683; // M-O-U-F
float BOARD_WIDTH_IN = 1;
float BOARD_HEIGHT_IN = 2;
float TONGUE_WIDTH_IN = 2;
float TONGUE_HEIGHT_IN = 2.5;
int GRID_WIDTH = 16;
int GRID_HEIGHT = 16;
float DPI = 256;

// CALCULATED CONSTANTS
float BOARD_WIDTH = BOARD_WIDTH_IN * DPI;
float BOARD_HEIGHT = BOARD_HEIGHT_IN * DPI;
float TONGUE_WIDTH = TONGUE_WIDTH_IN * DPI;
float TONGUE_HEIGHT = TONGUE_HEIGHT_IN * DPI;
float TONGUE_PIXEL_SPACING = (BOARD_WIDTH-DPI/16)/GRID_WIDTH;
float TONGUE_PIXEL_SIZE = TONGUE_PIXEL_SPACING*0.75;
int WINDOW_WIDTH = round(1.25 * TONGUE_WIDTH);
int WINDOW_HEIGHT = round(1.25 * TONGUE_HEIGHT);
float BOARD_TOP =  WINDOW_HEIGHT-TONGUE_HEIGHT-BOARD_HEIGHT/4;
float BOARD_LEFT = WINDOW_WIDTH/2-BOARD_WIDTH/2;
float TONGUE_TOP = WINDOW_HEIGHT-TONGUE_HEIGHT;
float TONGUE_LEFT = WINDOW_WIDTH/2-TONGUE_WIDTH/2;
float TONGUE_BASE_TOP = WINDOW_HEIGHT-TONGUE_HEIGHT*3/4-2;
float GRID_TOP = BOARD_TOP + BOARD_HEIGHT/2;
float GRID_LEFT = WINDOW_WIDTH/2-TONGUE_PIXEL_SPACING*8+TONGUE_PIXEL_SPACING/8;

// GLOBALS
int[] COMM_BUFFER = new int[COMM_BUFFER_SIZE];
Serial SERIAL;
Server SERVER;
int COMM_BUFFER_OFFSET = 0;

void setup() {
  size(WINDOW_WIDTH,WINDOW_HEIGHT);
  background(0);

  initBuffer();
  initComms();
  
  drawFrame();
}

void draw() {
  readData();
}

void initBuffer() {
  for (int i=0; i<COMM_BUFFER_SIZE; i++) {
    COMM_BUFFER[i] = 0;
  }
}

void initComms() {
  if (COMM_MODE == COMM_MODE_NETWORK || COMM_MODE == COMM_MODE_PROXY) {
    SERVER = new Server(this,NETWORK_PORT);
  }
  
  if (COMM_MODE == COMM_MODE_SERIAL || COMM_MODE == COMM_MODE_PROXY) {
    SERIAL = new Serial(this, Serial.list()[SERIAL_PORT], SERIAL_RATE);
  }
}

void readData() {
  Client client = SERVER.available();
  if (client != null) {
    readFromClient(client);
  }
}

void readFromClient(Client client) {
  //println("SERVER: clientEvent");
  int c = -1;
  int l = -1;

//  print("SERVER: Data = ");  
  while(client.available() > 0) {
    l = c;
    c = client.read();    
    COMM_BUFFER[COMM_BUFFER_OFFSET++] = c;
    
    //println("COMM_BUFFER[" + COMM_BUFFER_OFFSET + "]: " + c);

    if (l == 10 && c == 1) {
      //println();
      //println("SERVER: Frame end");
      drawFrame();
      COMM_BUFFER_OFFSET = 0;
    }
    
  }
//  println();
//  println("Buffer is " + COMM_BUFFER_OFFSET);
}

void drawFrame() {
  drawTongue();
  drawBoard();
  drawPixels();
}

void drawPixels() {
  int y;
  int x;
  int c;
  int pix=0;
  
  //println(COMM_BUFFER.length);
  //println(COMM_BUFFER_OFFSET); 
  for (int i=0; i<COMM_BUFFER_OFFSET-2; i++,pix++) {
      y = pix / GRID_HEIGHT;
      x = pix % GRID_WIDTH;
      c = COMM_BUFFER[i];
      
      if (c == 10) {
        i++;
        c = COMM_BUFFER[i];
        //println("Command " + c + " at " + (i-1));
      }
      else if (y<GRID_HEIGHT && x<GRID_WIDTH) {
        //FRAME_BUFFER[y][x] = c;
        noStroke();
        fill(250,247,57,255-c/2);
        rect(GRID_LEFT+x*TONGUE_PIXEL_SPACING,GRID_TOP+y*TONGUE_PIXEL_SPACING,TONGUE_PIXEL_SIZE,TONGUE_PIXEL_SIZE);
        //print(x+","+y+"="+c+" ");
      }
      else {
        println("SERVER: Warning: Attempt to write pixels out of bounds:  x="+x+" y="+y+" i="+i+" ofs="+COMM_BUFFER_OFFSET+ " n="+c);
      }
  }
//  println();
}

void drawBoard() {
  fill(123,204,69,200);
  stroke(72,120,40,200);

  rect(BOARD_LEFT,BOARD_TOP,BOARD_WIDTH,BOARD_HEIGHT);
}

void drawTongue() {
  fill(#E85163);
  stroke(#612129);
  ellipseMode(CORNER);
  strokeWeight(3);
  
  rect(TONGUE_LEFT,TONGUE_BASE_TOP,TONGUE_WIDTH,TONGUE_HEIGHT*3/4+2);
  arc(TONGUE_LEFT,TONGUE_TOP,TONGUE_WIDTH,TONGUE_HEIGHT/2,PI,TWO_PI);
}


