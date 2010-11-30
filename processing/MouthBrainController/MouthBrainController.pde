import processing.net.*;
import processing.serial.*;

// CONFIGURATION
int SERIAL_PORT = 0;  //-1 to list ports, non-negative to choose the port.
int SERIAL_RATE = 115200;
int NETWORK_PORT = 6683; // M-O-U-F
String MB_VERSION = "0001";

// DISPLAY CONFIG
float BOARD_WIDTH_IN = 1;
float BOARD_HEIGHT_IN = 1.75;
float TONGUE_WIDTH_IN = 2;
float TONGUE_HEIGHT_IN = 2.5;
int GRID_WIDTH = 16;
int GRID_HEIGHT = 16;
float DPI = 150;

// CALCULATED CONSTANTS
int PIXEL_COUNT = GRID_WIDTH * GRID_HEIGHT;
float BOARD_WIDTH = BOARD_WIDTH_IN * DPI;
float BOARD_HEIGHT = BOARD_HEIGHT_IN * DPI;
float TONGUE_WIDTH = TONGUE_WIDTH_IN * DPI;
float TONGUE_HEIGHT = TONGUE_HEIGHT_IN * DPI;
float TONGUE_PIXEL_SPACING = (BOARD_WIDTH-DPI/16)/GRID_WIDTH;
float TONGUE_PIXEL_SIZE = TONGUE_PIXEL_SPACING*0.75;
int WINDOW_WIDTH = round(1.35 * TONGUE_WIDTH);
int WINDOW_HEIGHT = round(1.35 * TONGUE_HEIGHT);
float BOARD_TOP =  WINDOW_HEIGHT-TONGUE_HEIGHT-BOARD_HEIGHT/4;
float BOARD_LEFT = WINDOW_WIDTH/2-BOARD_WIDTH/2;
float TONGUE_TOP = WINDOW_HEIGHT-TONGUE_HEIGHT;
float TONGUE_LEFT = WINDOW_WIDTH/2-TONGUE_WIDTH/2;
float TONGUE_BASE_TOP = WINDOW_HEIGHT-TONGUE_HEIGHT*3/4-2;
float GRID_TOP = BOARD_TOP + BOARD_HEIGHT * 0.45;
float GRID_LEFT = WINDOW_WIDTH/2-TONGUE_PIXEL_SPACING*8+TONGUE_PIXEL_SPACING/8;
float INPUT_GRID_TOP = GRID_TOP + TONGUE_PIXEL_SPACING * (GRID_HEIGHT+3);
float INPUT_GRID_LEFT = GRID_LEFT;

// GLOBAL OUTPUT STUFF
int[][] FRAME_BUFFER = new int[GRID_HEIGHT][GRID_WIDTH];

// GLOBAL COMMS
Serial SERIAL;
Server SERVER;
TastePacket PACKET;

// GLOBAL INPUT STUFF
int[][] INPUT_BUFFER = new int[GRID_HEIGHT][GRID_WIDTH];
int inputBufferIndex;
boolean inputBufferSync;
String inputBufferSyncWord = "[FRAME]";

void setup() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  background(0);

  frameRate(60);

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

  for (int y=0; y<GRID_HEIGHT; y++) {
    for (int x=0; x<GRID_WIDTH; x++) {
      INPUT_BUFFER[y][x] = 0;
    }
  }
}

void initComms() {
  SERVER = new Server(this,NETWORK_PORT);
  PACKET = new TastePacket(SERVER);

  //either open a serial port or list them.
  if (SERIAL_PORT >= 0)
  {
    inputBufferIndex = 0;
    inputBufferSync = false;
    SERIAL = new Serial(this, Serial.list()[SERIAL_PORT], SERIAL_RATE);
    SERIAL.buffer(1);
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
  //println("IN:" + myPort.readString());
  char c = myPort.readChar();

  //double check we got a valid character.
  if (c >= 0 && c <= 255)
  {
    //once we've synced, time for pixels!
    if (inputBufferSync)
    {
      int x = inputBufferIndex % GRID_WIDTH;
      int y = inputBufferIndex / GRID_HEIGHT;
      inputBufferIndex++;

      INPUT_BUFFER[y][x] = (int)c;

      //once we've gotten all pixels, we're done.
      if (inputBufferIndex == PIXEL_COUNT)
      {
        inputBufferIndex = 0;
        inputBufferSync = false;
      }
    }
    //keep reading characters until we find our sync string.
    else
    {
      //just compare it one at a time. if we match, increment. 
      if (c == inputBufferSyncWord.charAt(inputBufferIndex))
        inputBufferIndex++;

      //once we've matched all the characters, we're in sync!
      if (inputBufferIndex == inputBufferSyncWord.length())
      {
        inputBufferIndex = 0;
        inputBufferSync = true;
      }
    }
  }
}

void readData() {

  Client client = SERVER.available();

  while (client != null)
  {
    //println("SERVER: Got client, reading packet.");
    PACKET.read(client);

    if (PACKET.isFinished()) {
      int command = PACKET.getCommand();

      //println("SERVER: got command " + command);

      //if they want our version, let them know.
      if (command == COMMAND_GET_VERSION)
      {
        //println("SERVER: got version request.");
        //format our packet and get ready to send.
        PACKET.setCommand(COMMAND_SEND_VERSION);
        PACKET.addData("MouthBrain Version " + MB_VERSION);
        PACKET.transmit();
      }
      //if they want our config, give it to them.
      else if(command == COMMAND_GET_CONFIG)
      {
        //println("SERVER: got config request.");
        //format our packet and get ready to send.
        PACKET.setCommand(COMMAND_SEND_CONFIG);
        PACKET.addData("Not Yet Implemented");
        PACKET.transmit();
      }
      //if they want our inputs, let them know!
      else if (command == COMMAND_GET_INPUTS)
      {
        //println("SERVER: Got inputs request.");

        //format our packet and get ready to send.
        PACKET.setCommand(COMMAND_SEND_INPUTS);
        for (int i=0;i<PIXEL_COUNT; i++) {
          int y = i / GRID_HEIGHT;
          int x = i % GRID_WIDTH;
          PACKET.addData(INPUT_BUFFER[y][x]);
        }
        PACKET.transmit();
      }
      //if they want our output frame, let them know!
      else if (command == COMMAND_GET_FRAME)
      {
        //println("SERVER: Got frame request.");

        //format our packet and get ready to send.
        PACKET.setCommand(COMMAND_SEND_FRAME);
        for (int i=0;i<PIXEL_COUNT; i++) {
          int y = i / GRID_HEIGHT;
          int x = i % GRID_WIDTH;
          PACKET.addData(FRAME_BUFFER[y][x]);
        }
        PACKET.transmit();
      }
      //if they have a frame, update our framebuffer.
      else if (command == COMMAND_SEND_FRAME)
      {
        //println("SERVER: Received frame.")

        int[] data = PACKET.getPayload();

        if (data.length == PIXEL_COUNT) {
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
          println("SERVER: Frame byte count doesn't match grid size.");
        }
      }
      else {
        println("SERVER: Unknown command #" + command);
      }

      PACKET.reset();
    }
    else
    {
      println("SERVER: packet not finished.");
    }

    client = SERVER.available();
  }
}

void drawFrame() {
  background(0);

  /*
  for (int y=0; y<GRID_HEIGHT; y++) {
    for (int x=0; x<GRID_WIDTH; x++) {
      INPUT_BUFFER[y][x] = (int)(random(0, 255));
    }
  }
  */

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

      pixel = INPUT_BUFFER[y][x];
      fill(250,247,57,pixel);
      rect(INPUT_GRID_LEFT+x*TONGUE_PIXEL_SPACING, INPUT_GRID_TOP+y*TONGUE_PIXEL_SPACING, TONGUE_PIXEL_SIZE, TONGUE_PIXEL_SIZE);
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

