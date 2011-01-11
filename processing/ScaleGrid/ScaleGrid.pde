void setup() {
  size(160,160);

  PImage im = generateGradient(color(100,100,100,0.5),color(255,255,255,0.5),160,160);
  image(im,0,0);
  createGradient(80,80,110,color(255),color(100));
  
  PImage img = get();
  if (img.width != 16 || img.height != 16) 
    img.resize(16,16);
  img.loadPixels();
  
  println("{");
  for (int y=0; y<16; y++) {
    print("{ ");
    for (int x=0; x<16; x++) {
      print(brightness(img.pixels[y*16+x])/255.0);
      if (x<15)
        print(",");
    }
    print("}");
    if (y<15) {
      print(",");
    }
    println();
  }
  println("}");
  
}

void createGradient (float x, float y, float radius, color c1, color c2){
  float px = 0, py = 0, angle = 0;

  // calculate differences between color components 
  float deltaR = red(c2)-red(c1);
  float deltaG = green(c2)-green(c1);
  float deltaB = blue(c2)-blue(c1);
  // hack to ensure there are no holes in gradient
  // needs to be increased, as radius increases
  float gapFiller = 8.0;
  float ratio = 0.0;
  
  for (int i=0; i< radius; i++){
    for (float j=0; j<360; j+=1.0/gapFiller){
      px = x+cos(radians(angle))*i;
      py = y+sin(radians(angle))*i;
      angle+=1.0/gapFiller;
      color c = color(
      (red(c1)+(i)*(deltaR/radius)*((160-py)/160)),
      (green(c1)+(i)*(deltaG/radius)*((160-py)/160)),
      (blue(c1)+(i)*(deltaB/radius)*((160-py)/160))
        );
      set(int(px), int(py), c);      
    }
  }
  // adds smooth edge 
  // hack anti-aliasing
  noFill();
  strokeWeight(3);
  ellipse(x, y, radius*2, radius*2);
}

// Generate a vertical gradient image
PImage generateGradient(color top, color bottom, int w, int h) {
  int tR = (top >> 16) & 0xFF;
  int tG = (top >> 8) & 0xFF;
  int tB = top & 0xFF;
  int bR = (bottom >> 16) & 0xFF;
  int bG = (bottom >> 8) & 0xFF;
  int bB = bottom & 0xFF;
 
  PImage bg = createImage(w,h,RGB);
  bg.loadPixels();
  for(int i=0; i < bg.pixels.length; i++) {
    int y = i/bg.width;
    float n = y/(float)bg.height;
    // for a horizontal gradient:
    // float n = x/(float)bg.width;
    bg.pixels[i] = color(
    lerp(tR,bR,n), 
    lerp(tG,bG,n), 
    lerp(tB,bB,n), 
    255); 
  }
  bg.updatePixels();
  return bg;
}
