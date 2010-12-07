#define XDIM 16
#define YDIM 16
#define TOTAL_PIXELS 256

byte anodePins[XDIM] = {
  17, 16, 15, 14,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13
};
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
  
  //todo: look into setting PUD in MCUCR to disable pullups across the board
  //todo: determine minimum detectable pulse, and if pulse length relates to strength.
}

void reset()
{
  //set our anode pins high.
  for (byte i=0; i<XDIM; i++)
  {
    pinMode(anodePins[i], INPUT);
    digitalWrite(i, LOW);
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
  //frameOut();
  
//  delay(250);
  
  /*  
  if (millis()-lastTime > 10)
  {
    setScan();
    lastTime = millis();
  }
  */
  
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
    // For each column
    for (int x=0; x<XDIM; x++)
    {
    	// ROW ACTIVE: Output mode, LOW
    	// ROW INACTIVE: High impedance
        // Turn the row on
        
        digitalWrite(cathodePins[y], LOW);
        pinMode(cathodePins[y], OUTPUT);
        
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

      delayMicroseconds(10);

        pinMode(cathodePins[y], INPUT); //high impedance
        //digitalWrite(cathodePins[y], HIGH); //debug purposes only!!!

        digitalWrite(anodePins[x], LOW); //go low
        pinMode(anodePins[x], INPUT); //high impedance

    }
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


