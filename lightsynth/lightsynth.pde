/* light synthesizer */


int mode = 0;

PImage output;          //the output buffer
PVector viewPos;       //the position of the image in the view iwndow
SimpleTimer aniTimer;   //timer to control animation rate
PImage ledImage;
ArrayList<LedPixel> ledPixels;  

void setup()
{
  size(1024,800);
  initOutput(150, 4096);  //150 leds with 4096 frame of animation
  aniTimer = new SimpleTimer(100);
  viewPos = new PVector(0,0,1);

  setupLeds();
  
}



class LedPixel
{
  PVector pos;
  PImage icon;
  color tint;
  
  public LedPixel(PImage icon, float px, float py)
  {
    this.icon = icon;
    pos = new PVector(px,py,1);
    tint = color(128,128,128);
  }
  
  public void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    scale(pos.z);
    tint(tint);
    image(icon, 0,0);
    popMatrix();  
  }
}


void setupLeds()
{
  ledImage = loadImage("resources/images/ledIcon.png");
  ledPixels = new ArrayList();
  for(int n = 0; n < 150; n++)
  {
    float y = cos(TWO_PI * n/150) * height * 0.3;
    float x = sin(TWO_PI * n/150) * height * 0.3;
    ledPixels.add(new LedPixel(ledImage, x, y));
  }
}


float anim_vpos = 0;
float anim_vspd = 0.1;
float anim_hpos = 0;
float anim_hspd = 0.0;
float anim_hspr = 1.0;
color fetchPixelColor(int x,int y, PImage src)
{
    int src_idx = x + y * src.width;
    color col = src.pixels[src_idx];
    return col;
}
void animateLeds()
{
  blendMode(ADD);
  pushMatrix();
  translate(width - height*0.5, height*0.5);
  
  int y0 = round(anim_vpos);
  int y1 = (y0+1)%output.height;
  float yfrac = anim_vpos - y0;
  for(int n = 0; n < ledPixels.size(); n++)
  {
    float x = anim_hpos + (n * anim_hspr);
    int x0 = round(x);
    int x1 = (x0+1)%output.width;
    
    float frac = x - x0;
    color a = fetchPixelColor(x0,y0, output);
    color b = fetchPixelColor(x1,y0, output);
    color c = lerpColor(a,b,frac);
    a = fetchPixelColor(x0,y1, output);
    b = fetchPixelColor(x1,y1, output);
    color d = lerpColor(a,b,frac);
    
    LedPixel pixel = ledPixels.get(n);
    pixel.tint = lerpColor(c,d,yfrac);
    pixel.draw();
  }
  
  anim_vpos += anim_vspd;
  anim_vpos %= output.height;
  anim_hpos += anim_hspd;
  anim_hpos %= output.width;
  popMatrix();
  blendMode(BLEND);
  tint(255);
}
int prev_mode = 0;
int anim_mode = 0;
int max_mode = 6;
void draw()
{
  /* check timer for an update */
  if(aniTimer.update() !=0 ) {
    /* prepare the buffer */
    output.loadPixels();
    /* generate buffer content */
    if(mode != prev_mode || anim_mode != 0)
    {
      switch(mode) {
        case 0:
          doBlack(output);
          break;
        case 1:
          doWhite(output);
          break;
        case 2:
          doRandomGrey(output);
          break;
        case 3:
          doRandomRGB(output);
          break;
        case 4:
          doRandomHSV(output);
          break;
        case 5:
          doPlasmaGrey(output);
          break;
      }
      prev_mode = mode;
    }
    /* write the buffer */
    output.updatePixels();
  
    /* display background */
    background(22,22,23);
    
    /* display buffer */
    pushMatrix();
    translate(viewPos.x, viewPos.y);
    scale(viewPos.z);
    
    image(output, 0,0);
    popMatrix();
    
    /* display leds */
    animateLeds();  
  }
  
}

void doBlack(PImage target)
{
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      target.pixels[idx] = 0;
    
    }
  }
}

void doWhite(PImage target)
{
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      target.pixels[idx] = color(255,255,255);
    }
  }
}

void doRandomGrey(PImage target)
{
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      int grey = round(random(255));
      target.pixels[idx] = color(grey,grey,grey);
    }
  }
}

void doRandomRGB(PImage target)
{
  colorMode(RGB,255);
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      int red = round(random(255));
      int green = round(random(255));
      int blue = round(random(255));
      target.pixels[idx] = color(red,blue,green);
    }
  }
}

void doRandomHSV(PImage target)
{
  colorMode(HSB,360,100,100);
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      int hue = round(random(360));
      int sat = round(random(100));
      int viv = round(random(100));
      target.pixels[idx] = color(hue,sat,viv);
    }
  }
  colorMode(RGB,255);
}

float plasmaGreyParams[] = { 0.01, 0.02, 0.001, 0.002 };
float plasmaGreyCoeffs[] = { 0.2, 0.4, 0.01, 0.02 };
void doPlasmaGrey(PImage target)
{
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      float value = (sin(x * plasmaGreyParams[0]) + cos(y * plasmaGreyParams[1]) + sin(x*y * plasmaGreyParams[2]) + cos((x-width*0.75) * (y-height*0.75) * plasmaGreyParams[3]));
      value /= 2* (plasmaGreyCoeffs[0] + plasmaGreyCoeffs[1] + plasmaGreyCoeffs[2] + plasmaGreyCoeffs[3]);
      value += 0.5;
      value *= 255;
   
      target.pixels[idx] = color(Tables.gamma_8bit[int(value)]);
    }
  }  
  
}


void mouseWheel(MouseEvent event) 
{
  float e = event.getCount();
  
  viewPos.z += viewPos.z * 0.1 * e;
  if (abs(viewPos.z-1) < 0.05) { viewPos.z = 1; }
  println("zoom: " + viewPos.z);
}

void mouseDragged() 
{
  viewPos.x += mouseX - pmouseX;
  viewPos.y += mouseY - pmouseY;
  
  
}

void mousePressed(MouseEvent event)
{
  if(mouseButton == RIGHT)
  {
    viewPos.x = 0;
    viewPos.y = 0;
    viewPos.z = 1;
  }
}


float snapValue(float value)
{
  if(abs(value) < 0.01)
  {
     value = 0;  
  } else if (abs(abs(value) - 1) < 0.01 )
  {
     value = round(value);
  }
  return value;
}
void keyPressed()
{
  switch(key) {
    case' ':
      mode = (mode+1)%max_mode;
      println("mode: " + mode);
      break;
    
    case '=':
      anim_vspd += 0.01;
      anim_vspd = snapValue(anim_vspd);
      println("anim_vspd: " + anim_vspd);
      break;
    case '-':
      anim_vspd -= 0.01;
      anim_vspd = snapValue(anim_vspd);
      println("anim_vspd: " + anim_vspd);
      break;
    
    case ']':
      anim_hspd += 0.01;
      anim_hspd = snapValue(anim_hspd);
      println("anim_hspd: " + anim_hspd);
      break;
    case '[':
      anim_hspd -= 0.01;
      anim_hspd = snapValue(anim_hspd);
      println("anim_hspd: " + anim_hspd);
      break;
    
    case '#':
      anim_hspr += 0.01;
      anim_hspr = snapValue(anim_hspr);
      println("anim_hspr: " + anim_hspr);
      break;
    case '\'':
      anim_hspr -= 0.01;
      anim_hspr = snapValue(anim_hspr);
      println("anim_hspr: " + anim_hspr);
      break;
    
    
    case ',':
      aniTimer.set(round(aniTimer.trigger / 1.01) - 1);
      break;
    case '.':
      aniTimer.set(round(aniTimer.trigger * 1.01) + 1);    
      break;
    
    case '\\':
      aniTimer.togglePause();
      break;
    case'`':
      if(anim_mode != 0) anim_mode = 0;
      else anim_mode = 1;
      println("anim_mode: " + anim_mode);
      break;
  }

}

void initOutput(int w, int h)
{
  output = createImage(w, h, RGB); 
}

class SimpleTimer {
  int timer = 0;
  int lastTime;
  int trigger;
  int paused = 0;
  
  public SimpleTimer(int trig){
    trigger = trig;
    lastTime = millis();
  }

  public void togglePause()
  {
    if(paused > 0) paused = 0;
    else paused = 1;
  }

  public void set(int trig)
  {
    if(trig > 1)
    {
      trigger = trig;
      println(trigger);
    }
  }
  
  public void reset() 
  {
    timer = 0;
    lastTime = millis();
  }
  
  public int update()
  {
    if(paused != 0)
    {
      return 2;
    }
    int time = millis();
    timer += time - lastTime;
    lastTime = time;

    if ( timer >= trigger ) 
    {
      if( timer >= trigger<<1) 
      {
        timer %= trigger; 
      } else 
      {
        timer -= trigger; 
      }    
      return 1;
    }
    return 0;
  }
}