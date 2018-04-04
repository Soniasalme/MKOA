import processing.video.*;

//Capture cam;

int videoScale = 20; 
int vcol, vrow;
    Capture video;
  
int cols, rows;
int scl= 20;
int w = 1280;
int h = 720;


void setup() {
  size(1280,720, P3D);
  
  vcol = width/videoScale;  
  vrow = height/videoScale;
  video = new Capture(this, vcol, vrow);
  video.start();

  
  cols = w / scl;
  rows = h / scl;
  
  
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
  
  
  stroke(255); 
  noFill();

translate(width/2,height/2+20);
rotateX(PI/3);

  translate(-w/2,-h/2);
  for (int y = 0 ; y < rows; y++) {
    beginShape(TRIANGLE_STRIP);
  for (int x = 0; x < cols; x++) {
    vertex(x*scl, y*scl);
      vertex(x*scl, (y+1)*scl);
  
 //rect (x*scl, y *scl, scl, scl);
    }
     endShape();
  }
}