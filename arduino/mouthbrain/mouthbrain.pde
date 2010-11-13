#define XDIM 16
#define YDIM 16

byte anodePins[XDIM] = {13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 14, 15, 16, 17};
byte cathodePins[YDIM] = {52, 50, 48, 46, 44, 42, 40, 38, 36, 34, 32, 30, 28, 26};
byte analogPins[XDIM] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};

void setup()
{
	for (byte i=0; i<XDIM; i++)
	{
		pinMode(anodePins[i], OUTPUT);
		digitalWrite(i, HIGH);
	}
	
	for (byte i=0; i<XDIM; i++)
	{
		pinMode(analogPins[i], INPUT);
		digitalWrite(i, HIGH);
	}
	
	for (byte i=0; i<YDIM; i++)
	{
		pinMode(cathodePins[i], OUTPUT);
		digitalWrite(i, HIGH);
	}
	
	selftest();
}

void selftest()
{
	for (byte y=0; y<YDIM; y++)
	{
		for (byte x=0; x<XDIM; x++)
		{
			Serial.print(x);
			Serial.print(",");
			Serial.print(y);
			
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
		Serial.print(x);
		
		if (analogRead(analogPins[x]) > 512)
			Serial.println(" = Win");
		else
			Serial.println(" = Fail");
	}
}

void analogRead()
{
	Serial.println("[AFRAME]");
	for (byte y=0; y<YDIM; y++)
	{
		Serial.println("[LINE]");
		
		digitalWrite(cathodePins[y], LOW);
		for (byte x=0; x<XDIM; x++)
		{
			digitalWrite(anodePins[x], HIGH);
			byte sample = analogRead(analogPins[x]) >> 2;
			digitalWrite(anodePins[x], LOW);
			
			Serial.print(x);
		}
		
		digitalWrite(cathodePins[y], HIGH);
	}
}

void streamFrame()
{
	
}
