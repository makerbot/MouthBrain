import processing.net.*;
import processing.serial.*;

// CONSTANTS
int COMMAND_GET_VERSION = 1;
int COMMAND_GET_CONFIG  = 2;
int COMMAND_GET_INPUTS  = 3;
int COMMAND_SEND_FRAME  = 4;

// CONFIGURATION
int SERIAL_PORT = 0;  //-1 to list ports, non-negative to choose the port.
int SERIAL_RATE = 115200;
int NETWORK_PORT = 6683; // M-O-U-F

// DISPLAY CONFIG
float BOARD_WIDTH_IN = 1;
float BOARD_HEIGHT_IN = 2;
float TONGUE_WIDTH_IN = 2;
float TONGUE_HEIGHT_IN = 2.5;
int GRID_WIDTH = 16;
int GRID_HEIGHT = 16;
float DPI = 128;

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
int[][] FRAME_BUFFER = new int[GRID_HEIGHT][GRID_WIDTH];
Serial SERIAL;
Server SERVER;
TastePacket PACKET;

void setup() {
  size(WINDOW_WIDTH,WINDOW_HEIGHT);
  background(0);

  frameRate(20);

  initBuffer();
  initComms();
}

void draw() {
  readData();
  drawFrame();
}

void initBuffer() {
  for (int y=0; y<GRID_HEIGHT; y++) {
    for (int x=0; x<GRID_WIDTH; x++) {
      FRAME_BUFFER[y][x] = 255;
    }
  }
}

void initComms() {
  SERVER = new Server(this,NETWORK_PORT);
  PACKET = new TastePacket(SERVER);

  if (SERIAL_PORT >= 0)
  {
    SERIAL = new Serial(this, Serial.list()[SERIAL_PORT], SERIAL_RATE);
    SERIAL.buffer(16);
    
    delay(10000);
    println("WARMUP");
    for (char c='a'; c<'z'; c++)
    {
     SERIAL.write((char)c);
    }
    println("COOLDOWN");
  
  }
  else
  {
    // List all the available serial ports:
    println("Available Serial Ports:");
    println(Serial.list());
  }
}

void serialEvent(Serial myPort)
{
     println("IN:" + myPort.readString()); 
}

void readData() {
  PACKET.read();

  if (PACKET.isFinished()) {
    int command = PACKET.getCommand();

    //if they want our version, let them know.
    if (command == COMMAND_GET_VERSION)
    {
      //TODO
      println("VERSION 0000");
    }
    //if they want our config, give it to them.
    else if(command == COMMAND_GET_CONFIG)
    {
      //TODO
      println("CONFIG REQUEST");
    }
    //if they want our inputs, let them know!
    else if (command == COMMAND_GET_INPUTS)
    {
    }
    //if they have a frame, update our framebuffer.
    else if (command == COMMAND_SEND_FRAME)
    {
      int[] data = PACKET.getPayload();

      if (data.length == GRID_HEIGHT * GRID_WIDTH) {
        for (int i=0; i<data.length; i++)
        {
          int y = i / GRID_HEIGHT;
          int x = i % GRID_WIDTH;

          FRAME_BUFFER[y][x] = data[i];
        }
 
        if (SERIAL_PORT >= 0)
        {
          sendFrame();
        }
      }
      else {
        println("ERROR: Frame byte count doesn't match grid size.");
      }
    }
    else {
      println("ERROR: Unknown command #" + command);
    }
  }
}

void drawFrame() {
  drawTongue();
  drawBoard();
  drawPixels();
}

void drawPixels() {
  for (int y=0; y<GRID_HEIGHT; y++) {
    for (int x=0; x<GRID_WIDTH; x++) {
      int pixel = FRAME_BUFFER[y][x];
      noStroke();
      fill(250,247,57,255-pixel);
      rect(GRID_LEFT+x*TONGUE_PIXEL_SPACING,GRID_TOP+y*TONGUE_PIXEL_SPACING,TONGUE_PIXEL_SIZE,TONGUE_PIXEL_SIZE);
    }
  }
}

void sendFrame() {
  
//  println("HOST: Start Frame");

  SERIAL.write('[');
  SERIAL.write('F');
  SERIAL.write('R');
  SERIAL.write('A');
  SERIAL.write('M');
  SERIAL.write('E');
  SERIAL.write(']');

  for (int y=0; y<GRID_HEIGHT; y++) {
    for (int x=0; x<GRID_WIDTH; x++) {
      SERIAL.write((byte)FRAME_BUFFER[y][x]);
    }
    //delay(1);
  }

//  println("HOST: End Frame");

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

