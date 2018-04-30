import processing.video.*;

int numPixels;
float []previousFrame;
Capture cam;
float pixAverage;

int videoScale = 20; 
int vcol, vrow;
    Capture video;
  
int cols, rows;
int scl= 20;
int w = 1280;
int h = 720;


void setup()
{
  size(1280,720, P3D);
  cam = new Capture(this, width, height);
  cam.start(); 
  numPixels = cam.width * cam.height;
  previousFrame = new float[numPixels];
  loadPixels();
  stroke(0, 255, 255);
  strokeWeight(4);
  frameRate(10);

  vcol = width/videoScale;  
  vrow = height/videoScale;
  video = new Capture(this, vcol, vrow);
  //video.start();

  cols = w / scl;
  rows = h / scl;
}

// Read image from the camera
void captureEvent(Capture video) {  
  video.read();
} 

void draw()
{
  if (cam.available())
  {
    cam.read();
    cam.loadPixels();
    int x = 0;
    int y = 0;
    int sum = 0;
    for (int i = 0; i < numPixels; i++)
    {
      float currColor = red(cam.pixels[i]);
      float prevColor = previousFrame[i];
      float d = abs(prevColor-currColor);
      if (d>50)
      {
        int xt = i % cam.width;
        int yt = i / cam.width;
        x += xt;
        y += yt;
        sum ++;
        pixels[i] = color(currColor,0,0);
      }
      else
        pixels[i] = color(currColor);
      previousFrame[i] = currColor;
    }
    if (sum>1000)
    {
      updatePixels();
      x /= sum;
      y /= sum;    
      drawTarget(x,y);
    }
  }
}
void drawTarget(int x, int y)
{
  line(x,y-15 , x,y-4);
  line(x,y+15 , x,y+4);
  line(x-15,y , x-4,y);
  line(x+15,y , x+4,y);
}