import processing.net.*;

int COMMAND_GET_VERSION  = 1;
int COMMAND_GET_CONFIG   = 2;
int COMMAND_GET_INPUTS   = 3;
int COMMAND_GET_FRAME    = 4;
int COMMAND_SEND_FRAME   = 5;
int COMMAND_SEND_VERSION = 6;
int COMMAND_SEND_CONFIG  = 7;
int COMMAND_SEND_INPUTS  = 8;

class BrainLink
{
  Client client;
  TastePacket packet;

  BrainLink(PApplet applet)
  {
    client = new Client(applet, "127.0.0.1", 6683);
    packet = new TastePacket(client);
  }

  BrainLink(PApplet applet, String ip)
  {
    client = new Client(applet, ip, 6683);
    packet = new TastePacket(client);
  }

  BrainLink(PApplet applet, String ip, int port)
  {
    client = new Client(applet, ip, port);
    packet = new TastePacket(client);
  }

  void sendData()
  {
    PImage img = get();
    if (img.width != 16 || img.height != 16) 
      img.resize(16,16);
    img.loadPixels();

    //format our packet and get ready to send.
    packet.setCommand(COMMAND_SEND_FRAME);
    for (int i=0;i<img.pixels.length; i++) {
      packet.addData(int(brightness(img.pixels[i])));
    }
    packet.transmit();
  }

  int[][] readData()
  {
    //format our packet and get ready to send.
    packet.setCommand(COMMAND_GET_INPUTS);
    packet.transmit();

    int tries = 0;
    while (!packet.isFinished())
    {
      packet.read();
      delay(1);
      tries++;

      if (tries == 1000)
      {
        println("CLIENT: Failed to read input.");
        return new int[16][16];
      }
    }

    int[][] gridIn  = new int[16][16];

    int command = packet.getCommand();

    if (command == COMMAND_SEND_INPUTS)
    {
      int[] data = packet.getPayload();

      if (data.length == 256) {
        for (int i=0; i<data.length; i++)
        {
          int y = i / 16;
          int x = i % 16;

          gridIn[y][x] = data[i];

          packet.reset();
        }

        //println("CLIENT: Successful Input Frame.");
      }
      else {
        println("ERROR: Frame byte count doesn't match grid size.");
      }
    }
    else {
      println("ERROR: Unknown command #" + command);
    }

    return gridIn;
  }
}

class BrainLinkClient
{
}

class TastePacket
{
  Client client;
  Server server;

  int bufferSize = 4096;

  int state;
  int command;
  int receivedCRC;
  int calculatedCRC;
  int packetLength;
  int bufferIndex;
  int[] buffer = new int[bufferSize];

  String sync = "feedme!!";

  byte STATE_NEW      = 0;
  byte STATE_SYNC     = 1;
  byte STATE_COMMAND  = 2;
  byte STATE_LENGTH   = 3;
  byte STATE_CRC      = 4;
  byte STATE_FINISHED = 5;

  TastePacket(Client c)
  {
    client = c;
    reset();
  }

  TastePacket(Server s)
  {
    server = s;
    reset();
  }

  void reset() {
    state = STATE_NEW;
    command = 0;
    receivedCRC = 0;
    calculatedCRC = 0;
    packetLength = 0;
    bufferIndex = 0;

    for (int i=0; i<bufferSize; i++) {
      buffer[i] = 0;
    }
  }

  void setCommand(int c)
  {
    command = c;
  }

  void addData(int i)
  {
    buffer[bufferIndex] = i;
    bufferIndex++;
  }

  void addData(String s)
  {
    for (int i=0; i<s.length(); i++)
      addData((int)s.charAt(i));
  }

  void transmit()
  {
    client.write(sync);
    client.write((byte)command);
    client.write((byte)(bufferIndex>>8));
    client.write((byte)bufferIndex);
    client.write((byte)calculatedCRC);
    for (int i=0; i<bufferIndex; i++)
      client.write((byte)buffer[i]);

    reset();
  }

  void read()
  {
    read(client);
  }

  /*
    Packet structure is as follows:
   -----------------------------
   | BYTE # | NAME/DESCRIPTION |
   | 0 - 7  | SYNC STRING      |
   | 8      | COMMAND BYTE     |
   | 9, 10  | PAYLOAD SIZE     |
   | 11     | CRC              |
   | 12 - N | PAYLOAD          |
   -----------------------------  
   */
  void read(Client newClient)
  {

    client = newClient;

    int c = -1;
    int tries = 0;

    while (!isFinished())
    {
      if (client.available() > 0)
      {
        //println("TP: Client with " + client.available() + " byte message.");

        while(client.available() > 0)
        {
          c = client.read();

          //println("TP: Byte: " + c + " (" + (char)c + ")");

          if (c >= 0)
          {
            //are we looking for a new incoming packet?
            if (state == STATE_NEW)
            {
              if ((char)c == sync.charAt(bufferIndex))
              {
                buffer[bufferIndex] = c;
                bufferIndex++;
              }
              else
                reset();

              //if the buffer is now at the same length as our sync string, we matched. switch our mode and reset the index.
              //we'll use the full buffer for the packet payload.
              if (bufferIndex == sync.length()) {
                state = STATE_SYNC;
                bufferIndex = 0;

                //println("TP: synced up!");
              }
            }
            //have we synced properly?  we're now looking for the command byte.
            else if (state == STATE_SYNC)
            {
              command = c;
              state = STATE_COMMAND;

              //println("TP: got command #" + command);
            }
            //have we received our command byte?  we're now looking for length data.
            else if (state == STATE_COMMAND)
            {
              packetLength = c;
              packetLength = packetLength << 8;

              //did we get some bullshit?
              c = client.read();
              if (c == -1) {
                reset();
                return;
              } 
              else {
                packetLength += c;
              }

              if (packetLength > bufferSize) {
                //println("TASTEPACKET: packet length of " + packetLength + " is too long.");
                reset();
              } 
              else {
                state = STATE_LENGTH;
                //println("TP: payload length of " + packetLength);
              }
            }
            //have we received our payload length bytes?  we're now looking for the crc byte.
            else if (state == STATE_LENGTH)
            {
              receivedCRC = c;
              state = STATE_CRC;

              if (packetLength == 0)
                state = STATE_FINISHED;
            }
            //have we received our CRC info? we're now reading in our payload.
            else if (state == STATE_CRC)
            {
              buffer[bufferIndex] = c;
              bufferIndex++;

              if (bufferIndex == packetLength)
                state = STATE_FINISHED;
            }
            //something weird happened.
            else
              reset();
          }

          //if we got a packet, we're done.
          if (state == STATE_FINISHED)
            return;
        }
      }

      delay(1);
      tries++;

      if (tries == 1000)
      {
        println("TP: PacketTimeout.");
        reset();
        break;
      }
    }
  }

  boolean isFinished()
  {
    return state == STATE_FINISHED;
  }

  int getCommand()
  {
    return command;
  }

  int[] getPayload ()
  {
    return subset(buffer, 0, bufferIndex);
  }
}

