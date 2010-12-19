#define XDIM 16
#define YDIM 16
#define TOTAL_PIXELS 256

byte anodePins[XDIM] = {
  17, 16, 15, 14,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13
};

/*
17 - PH0 - RX2
 16 - PH1 - TX2
 15 - PJ0 - RX3
 14 - PJ1 - TX3
 02 - PE4
 03 - PE5
 04 - PG5
 05 - PE3
 06 - PH3
 07 - PH4
 08 - PH5
 09 - PH6
 10 - PB4
 11 - PB5
 12 - PB6
 13 - PB7
 */

byte analogPins[XDIM] = {
  15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
};

byte cathodePins[YDIM] = {
  52, 50, 48, 46, 44, 42, 40, 38, 36, 34, 32, 30, 28, 26, 24, 22
};

byte frameBuffer[YDIM][XDIM];

//some variables for syncing.
byte syncIndex = 0;
boolean frameSync = false;
boolean lineSync = false;

//these are our frame sync tokens
#define FRAME_SYNC_LENGTH 7
char frameSyncString[] = "[FRAME]";

void setup()
{
  Serial.begin(115200);

  reset();
  //selftest();

  //todo: determine minimum detectable pulse, and if pulse length relates to strength.

  //todo: look into setting PUD in MCUCR to disable pullups across the board
  //this should do the trick.
  bitSet(MCUCR, 4);
}

void reset()
{
  //set our anode pins high impedance, high state
  for (byte i=0; i<XDIM; i++)
  {
    pinMode(anodePins[i], INPUT);
    digitalWrite(i, HIGH);
  }

  //set our cathode pins high impedance.
  for (byte i=0; i<YDIM; i++)
  {
    pinMode(cathodePins[i], INPUT);
    digitalWrite(cathodePins[i], LOW);
  }

  //make our analog pins high impedance.
  for (byte i=0; i<XDIM; i++)
  {
    pinMode(analogPins[i], INPUT);
    digitalWrite(i, LOW);
  }

  clearFrameBuffer();	
}

void clearFrameBuffer()
{
  //empty out our array.
  for (byte y=0; y<YDIM; y++)
  {
    for (byte x=0; x<XDIM; x++)
    {
      frameBuffer[y][x] = 0;
    }
  }
}

int scanIndex=0;
int lastTime = 0;

void loop()
{
  frameIn();

  if (millis()-lastTime > 500)
  {
    //    frameOut();
    lastTime = millis();
  }

  drawFrame();
}

void setScan()
{
  byte x = scanIndex%XDIM;
  byte y = scanIndex/YDIM;

  //clearFrameBuffer();
  frameBuffer[y][x] = 0;

  scanIndex++;

  if (scanIndex == TOTAL_PIXELS)
  {
    scanIndex = 0;
    clearFrameBuffer();
    //    drawFrame();
    //    delay(2000);
  }
}

void drawFrame()
{
  // For each row
  for (int y=0; y<YDIM; y++)
  {
    //POTENTIAL NEW PLAN:
    //STEP 1: create port variables for output pins that are set properly
    //STEP 2: write anode ports
    //STEP 3: enable cathode pin
    //STEP 4: delay appropriate amount of time
    //STEP 5: tristate anode ports
    //STEP 6: tristate cathose pin

    //OLD CODE
    //STEP 1: enable cathode pin (hiz => low)
    //STEP 2: enable anodes (hiz => high)
    //STEP 3: delay appropriate amount of time (delay...)
    //STEP 4: tristate cathode (low => hiz)
    //STEP 5: all anodes to low (any -> low)
    //STEP 6: all anodes to tristate (any -> tristate)

    // ROW ACTIVE: Output mode, LOW
    // ROW INACTIVE: High impedance
    // Turn the row on
    digitalWrite(cathodePins[y], LOW);
    pinMode(cathodePins[y], OUTPUT);

    // For each column
    for (int x=0; x<XDIM; x++)
    {

      // If we have some data
      if (frameBuffer[y][x] > 0)
      {
        // Turn the pixel on
        pinMode(anodePins[x], OUTPUT); //output
        //analogWrite(anodePins[x], frameBuffer[y][x]);
        digitalWrite(anodePins[x], HIGH); //energize electrode
      }
      else
      {
        // Turn the pixel off
        pinMode(anodePins[x], INPUT); //high impedance
        digitalWrite(anodePins[x], LOW); //turn off pullup
      }

      delayMicroseconds(5);
    }
    
    // For each column
    for (int x=0; x<XDIM; x++)
    {
      delayMicroseconds(5);

      digitalWrite(anodePins[x], LOW); //go low
      pinMode(anodePins[x], INPUT); //high impedance
    }
    pinMode(cathodePins[y], INPUT); //high impedance
    //digitalWrite(cathodePins[y], HIGH); //debug purposes only!!!
  }
}

void selftest()
{
  for (byte y=0; y<YDIM; y++)
  {
    for (byte x=0; x<XDIM; x++)
    {
      Serial.print(x, DEC);
      Serial.print(",");	
      for (byte i=0; i<YDIM; i++)
      {
        pinMode(cathodePins[i], OUTPUT);
        digitalWrite(i, HIGH);
      }
      Serial.print(y, DEC);

      //switch them low to drain charge. 
      digitalWrite(cathodePins[y], LOW);
      digitalWrite(anodePins[x], LOW);
      delay(1);
      digitalWrite(cathodePins[y], HIGH);

      //turn anode into input and test for charge.
      pinMode(anodePins[x], INPUT);
      if (digitalRead(anodePins[x]))
        Serial.println (" = Fail");
      else
        Serial.println (" = Win");

      //switch it back now
      pinMode(anodePins[x], OUTPUT);
      digitalWrite(anodePins[y], HIGH);
    }
  }

  for (byte x=0; x<XDIM; x++)
  {
    Serial.print("Analog ");
    Serial.print(x, DEC);

    if (analogRead(analogPins[x]) > 512)
      Serial.println(" = Win");
    else
      Serial.println(" = Fail");
  }
}

void frameOut()
{
  Serial.print("[FRAME]");
  for (byte y=0; y<YDIM; y++)
  {
    pinMode(cathodePins[y], OUTPUT);
    digitalWrite(cathodePins[y], LOW);

    for (byte x=0; x<XDIM; x++)
    {
      pinMode(anodePins[x], OUTPUT);
      digitalWrite(anodePins[x], HIGH);

      byte sample = analogRead(analogPins[x]) >> 2;

      digitalWrite(anodePins[x], LOW);
      pinMode(anodePins[x], INPUT);

      Serial.print(sample);
    }

    pinMode(cathodePins[y], INPUT); //high impedance
    digitalWrite(cathodePins[y], LOW); //pullup off
  }
}

void frameIn()
{
  byte syncIndex = 0;
  boolean frameSync = false;
  int pixelCount = 0;
  byte x = 0;
  byte y = 0;
  byte noData = 0;

  //anything at all?
  if (Serial.available() > 0)
  {
    while(true)
    {
      int b = Serial.read();

      //was the data good?
      if (b >= 0)
      {
        //we got real data.
        noData = 0;

        if (!frameSync)
        {
          //compare to the characters in our index.
          if (b == frameSyncString[syncIndex])
          {
            //Serial.print((byte)b);
            syncIndex++;

            if (syncIndex == FRAME_SYNC_LENGTH)
              frameSync = true;
          }
          else
            syncIndex = 0;
        }
        else
        {
          //Serial.print((byte)b, HEX);
          //Serial.print(' ');

          x = pixelCount % XDIM;
          y = pixelCount / XDIM;

          frameBuffer[y][x] = b;

          pixelCount++;

          if (pixelCount == TOTAL_PIXELS)
            return;
        }
      }
      //if we got bunk data, try waiting.
      else
      {
        noData++;
        delay(1);

        if (noData == 1000)
          return;
      }
    }
  }
}






