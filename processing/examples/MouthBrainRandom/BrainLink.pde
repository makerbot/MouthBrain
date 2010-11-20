import processing.net.*;

class BrainLink
{
  Client CLIENT;

  int COMMAND_GET_VERSION = 1;
  int COMMAND_GET_CONFIG  = 2;
  int COMMAND_GET_INPUTS  = 3;
  int COMMAND_SEND_FRAME  = 4;

  BrainLink(PApplet applet)
  {
    CLIENT = new Client(applet, "127.0.0.1", 6683);
  }

  BrainLink(PApplet applet, String ip)
  {
    CLIENT = new Client(applet, ip, 6683);
  }

  BrainLink(PApplet applet, String ip, int port)
  {
    CLIENT = new Client(applet, ip, port);
  }

  void sendData()
  {
    PImage img = get();
    img.resize(16,16);
    img.loadPixels();

    TastePacket packet = new TastePacket(CLIENT);
    
    //format our packet and get ready to send.
    packet.setCommand(COMMAND_SEND_FRAME);
    for (int i=0;i<img.pixels.length; i++) {
      packet.addData(img.pixels[i]);
    }
    packet.transmit();
  }
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

  void read() {

    //bail if we don't have a connection or whatnot.
    client = server.available();
    if (client == null) {
      reset();
      return;
    }
    
    println("TP: Got new client with " + client.available() + " byte message.");
    
    int c = -1;
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
            
            println("TP: synced up!");
          }
        }
        //have we synced properly?  we're now looking for the command byte.
        else if (state == STATE_SYNC)
        {
          command = c;
          state = STATE_COMMAND;
          
           println("TP: got command #" + command);
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
            println("TASTEPACKET: packet length of " + packetLength + " is too long.");
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

    //if we got this far, just reset.
    reset();
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

