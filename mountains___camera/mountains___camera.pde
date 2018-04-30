import processing.video.*;

//Capture cam;
boolean mousePressed = false;

int videoScale = 20; 
int vcol, vrow;
    Capture video;
  
int cols, rows;
int scl= 20;
int w = 1280;
int h = 720;

float flying = 0;
float[][] terrain;
float top = 100;

void setup() {
  size(1280,720, P3D);
  
  vcol = width/videoScale;  
  vrow = height/videoScale;
  video = new Capture(this, vcol, vrow);
  video.start();

  
  cols = w / scl;
  rows = h / scl;
  terrain = new float[cols][rows];
  
  
  /*String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();    
  }*/    
}


// Read image from the camera
void captureEvent(Capture video) {  
  video.read();
} 
  
void draw() {
  
  video.loadPixels();  
  // Begin loop for columns  
  for (int i = 0; i < cols; i++) {
    // Begin loop for rows    
    for (int j = 0; j < rows; j++) {
      // Where are you, pixel-wise?      
      int x = i*videoScale;      
      int y = j*videoScale;
      int loc = (video.width -i -1) + j * video.width;
      //color c = video.pixels[i + j*video.width];
      color c = video.pixels[loc];
      fill(c);   
      stroke(0);      
      rect(x, y, videoScale, videoScale);    
    }  
  }
  
  /*if (cam.available() == true) {
    cam.read();
  }
  image(cam, 0, 0);
  // The following does the same, and is faster when just drawing the image
  // without any additional resizing, transformations, or tint.
  //set(0, 0, cam);*/
  
 
   flying -= 0.05;
  
   if(mousePressed){
   //  flying += 0.25;
   //  top += 0.5;
   for(top=0; top<200;top++){
     top += 5;
   }
   }
   else if (mousePressed == false){
     flying -=0.05;
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
  
  stroke(255); 
  noFill();

  translate(width/2,height/2+50); //te lo posiciona en el (0,0) que es el centro
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
}

void mousePressed(){
 mousePressed = true;
}

void mouseReleased(){
  mousePressed = false;
}