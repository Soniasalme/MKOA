import processing.video.*;
// Variable for capture device
Capture video;
// Previous Frame
PImage prevFrame;
// How different must a pixel be to be a "motion" pixel
float threshold = 30;
boolean mousePressed = false;


int cols, rows;
int scl= 20;
int w = 1280;
int h = 720;
float flying = 0;
float[][] terrain;
float top = 100;

void setup() {
  size(960, 540,P3D);
  video = new Capture(this, width, height);
  video.start();

  cols = w / scl;
  rows = h / scl;
  terrain = new float[cols][rows];
  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);


}
void captureEvent(Capture video) {
  // Save previous frame for motion detection!!
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height); // Before we read the new frame, we always save the previous frame for comparison!
  prevFrame.updatePixels();  // Read image from the camera
  video.read();
}

void draw() {
  background(0);
  loadPixels();

  video.loadPixels();
  prevFrame.loadPixels();
  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      int loc = x + y*video.width;            // Step 1, what is the 1D pixel location
      color current = video.pixels[loc];      // Step 2, what is the current color
      color previous = prevFrame.pixels[loc]; // Step 3, what is the previous color

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current);
      float g1 = green(current);
      float b1 = blue(current);
      float r2 = red(previous);
      float g2 = green(previous);
      float b2 = blue(previous);
      float diff = dist(r1, g1, b1, r2, g2, b2);

      // Step 5, How different are the colors?
      // If the color at that pixel has changed, then there is motion at that pixel.
      if (diff > threshold) {
        // If motion, display black
        mousePressed = true;
      } else {
        // If not, display white
        mousePressed = false;
      }
    /*  if (diff > threshold) {
        // If motion, display black
        pixels[loc] = color(0);
      } else {
        // If not, display white
        pixels[loc] = color(255);
      } */
    }

  }
  flying -= 0.05;

   if(mousePressed){
   //  flying += 0.25;
   //  top += 0.5;
   for(top=0; top<200;top++){
     top += 10;
   }
   }
   else if (mousePressed == false){
     flying -=0.05;
     top = 30;
     //top -=0.5;

   }

   else {
     flying +=0.05;
   }


    float yoff = flying;
  for (int y = 0 ; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff,yoff), 0,  1, -1*top, top);
      xoff += 0.2;
  }
  yoff += 0.2;
   }
  background(0);
  stroke(255);
  if (mousePressed){
    stroke(random(255),0, random(200));
  }
  noFill();

  translate(width/2,height/2-50); //te lo posiciona en el (0,0) que es el centro
  rotateX(PI/3);

  translate(-w/2,-h/2); //hace lo contratio para que este en el centro de la imagen y no el (0,0)
  for (int y = 0 ; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      vertex(x*scl, y*scl, terrain[x][y]);
      vertex(x*scl, (y+1)*scl, terrain[x][y+1]);


 //rect (x*scl, y *scl, scl, scl);
    }
     endShape();
  }
  updatePixels();


}

/*void mousePressed(){
 mousePressed = true;
}

void mouseReleased(){
  mousePressed = false;
}
*/
