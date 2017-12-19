/* light synthesizer */


int mode = 0;

PImage output;          //the output buffer
PVector viewPos;       //the position of the image in the view iwndow
SimpleTimer aniTimer;   //timer to control animation rate
void setup()
{
  size(1024,1024);
  initOutput(150, 4096);  //150 leds with 4096 frame of animation
  aniTimer = new SimpleTimer(100);
  viewPos = new PVector(0,0,1);
}


void draw()
{
  if(aniTimer.update() !=0 ) {
    
    output.loadPixels();
    
    switch(mode) {
      case 0:
        doBlack();
      break;
      case 1:
        doWhite();
      break;
      case 2:
        doRandomGrey();
      break;
      case 3:
        doRandomRGB();
      break;
      case 4:
        doRandomHSV();
      break;
    }
    
    output.updatePixels();
  
    
    background(22,22,23);
    
    translate(viewPos.x, viewPos.y);
    scale(viewPos.z);
    
    image(output, 0,0);
     
  
  }
  
}

void doBlack()
{
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      output.pixels[idx] = 0;
    
    }
  }
}

void doWhite()
{
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      output.pixels[idx] = color(255,255,255);
    }
  }
}

void doRandomGrey()
{
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      int grey = round(random(255));
      output.pixels[idx] = color(grey,grey,grey);
    }
  }
}

void doRandomRGB()
{
  colorMode(RGB,255);
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      int red = round(random(255));
      int green = round(random(255));
      int blue = round(random(255));
      output.pixels[idx] = color(red,blue,green);
    }
  }
}

void doRandomHSV()
{
  colorMode(HSB,360,100,100);
  for(int x = 0; x < output.width; x++) {
    for(int y = 0; y < output.height; y++) {
      int idx = x + y * output.width;
      int hue = round(random(360));
      int sat = round(random(100));
      int viv = round(random(100));
      output.pixels[idx] = color(hue,sat,viv);
    }
  }
  colorMode(RGB,255);
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

void keyPressed()
{
  switch(key) {
    case' ':
      mode = (mode+1)%5;
      break;
    case ']':
      aniTimer.set(round(aniTimer.trigger / 1.01) - 1);    
      break;
    case '[':
      aniTimer.set(round(aniTimer.trigger * 1.01) + 1);    
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
  public SimpleTimer(int trig){
    trigger = trig;
    lastTime = millis();
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
    int time = millis();
    timer += time - lastTime;
    lastTime = time;
    
  //  println(timer);
    
    if ( timer >= trigger ) 
    {
//      println("triggered");
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