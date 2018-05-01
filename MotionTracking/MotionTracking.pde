/*****************************************************

A computer vision/motion tracking example
creted and shared by Soniconlab.

For further examples and tutorials, visit
www.soniconlab.com

******************************************************/

//Import video and OSC libraries
//Video library comes with Processing IDE
//OSC is included in the 'code' folder in this sketch's directory
import processing.video.*;
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

//Set variables
Capture video;
PImage prevFrame;

boolean highMotionLimit = false;
boolean lowMotionLimit = false;

//Set high and low threshold limits
float highThresholdValue = 30;
float lowThresholdValue = 8;

float avgMotionVal;
float mapMotionVal = 0;

//Store final motion value
float finalMotionVal;

//Class for smoothing values
SmoothValue smoothValue;

PFont font;

//Set here the IP address to send OSC values
String ipAddress = "127.0.0.1";
int portSend = 7400;

void setup() {
  size(520, 240);
  frameRate(30);
  font = loadFont("ArialMT-32.vlw");

  //Setup OSC
  //Set listening port
  oscP5 = new OscP5(this, 7401);
  //Set broadcast address and port
  myRemoteLocation = new NetAddress(ipAddress, portSend);

  //Smoothing every X values
  smoothValue = new SmoothValue(50);

  //Get and print in an array the devices/cameras that can be used for capturing
  String[] devices = Capture.list();
  println(devices);

  //Change the name of your current camera to read frames
  video = new Capture(this, 1280, 720, "FaceTime HD Camera", 15);

  prevFrame = createImage(video.width, video.height, RGB);
  if(video!=null){
    video.start();
  }

  noCursor();
}

void draw() {
  background(0);
  // Capture video
  if (video.available()) {
    // Copy image of video and save previous frame for motion detection (frame comparison)
    prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
    prevFrame.updatePixels();
    video.read();
  }

  //Display the camera feed on the window
  image(video, 200, 0, width-200, height);

  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();

  // Begin loop to walk through every pixel
  // Start with a total of 0
  float totalMotion = 0;

  // Sum the brightness of each pixel
  for (int i = 0; i < video.pixels.length; i++) {
    color current = video.pixels[i];
    // Step 2, what is the current color
    color previous = prevFrame.pixels[i];
    // Step 3, what is the previous color
    // Step 4, compare colors (previous vs. current)
    float r1 = red(current); 
    float g1 = green(current);
    float b1 = blue(current);
    float r2 = red(previous); 
    float g2 = green(previous);
    float b2 = blue(previous);
    float diff = dist(r1, g1, b1, r2, g2, b2);
    totalMotion += diff;
  }

  //Calculate average motion / Smooth values
  float avgMotion = totalMotion / video.pixels.length;
  float smoothAverage = smoothValue.val(avgMotion);  
  finalMotionVal = smoothAverage;

  //High & Low Thresholds
  if (finalMotionVal > highThresholdValue) highMotionLimit = true;
  else highMotionLimit = false;

  if (finalMotionVal < lowThresholdValue) lowMotionLimit = true;
  else lowMotionLimit = false;

  println("Average Motion: " + avgMotion);
  println("Smooth Motion: " + smoothAverage);
  println("Final Motion Detection: " + finalMotionVal);
  println("");
  println("High threshold passed: " + highMotionLimit);
  println("Low threshold passed: " + lowMotionLimit);
  println("");

  //Draw the visual elements on the screen window
  drawInterface();

  //Send the values using the OSC
  sendOSCMessage();
  
  if(finalMotionVal>highThresholdValue){
    fill(random(255));
    ellipse(0.05, 0.05, video.width,video.height);
  }

}



void drawInterface() {
  //Draw screen interface (sliders and text)
  stroke(72, 155, 212);
  strokeWeight(1);
  fill(230, 230, 230, 230);
  rect(5, 20, 190, 20);
  noStroke();
  fill(72, 155, 212, 120);  
  if (finalMotionVal < highThresholdValue) {
    mapMotionVal = map (finalMotionVal, 0, highThresholdValue, 0, 185);
  }
  rect(10, 23, mapMotionVal, 15);

  textFont(font, 12);  
  fill(230, 230, 230, 230);
  text("Final Motion Value: "+ finalMotionVal, 5, 13);

  if (finalMotionVal < lowThresholdValue) fill(0, 230, 80, 230);
  else fill(230, 230, 230, 230);
  text("Low Threshold: "+ lowThresholdValue, 5, 60);

  if (finalMotionVal > highThresholdValue) fill(0, 230, 80, 230);
  else fill(230, 230, 230, 230);
  text("High Threshold: "+ highThresholdValue, 5, 80);

  fill(230, 230, 230, 230);
  text("- OSC Settings -", 5, 120);
  text("Send IP Address: " + ipAddress, 5, 140);
  text("Send Port Number: " + portSend, 5, 160);  

  textFont(font, 16);
  text("fps: " + frameRate, 205, height-10);
}



void sendOSCMessage() {
  //Create a new OSC message with the prefix: /MotionAmount
  OscMessage motionMsg = new OscMessage("/MotionAmount");
  //add the final motion value
  motionMsg.add(finalMotionVal);
  //send the message
  oscP5.send(motionMsg, myRemoteLocation); 

  //Create a new OSC message with the prefix: /TriggerHigh
  OscMessage triggerHighMsg = new OscMessage("/TriggerHigh");
  //add the trigger high value (boolean)
  triggerHighMsg.add(highMotionLimit);
  //send the message
  oscP5.send(triggerHighMsg, myRemoteLocation);

  //Create a new OSC message with the prefix: /TriggerLow
  OscMessage triggerLowMsg = new OscMessage("/TriggerLow");
  //add the trigger low value (boolean)
  triggerLowMsg.add(lowMotionLimit);
  //send the message
  oscP5.send(triggerLowMsg, myRemoteLocation);
}

//Class to smooth incoming values/average motion
class SmoothValue {
  float floatTab[];

  //Passing an argument to the constructor sets the size of 
  SmoothValue(int size) {
    floatTab = new float[size];
    for (int i = 0; i < size; i++) {
      floatTab[i] = 0;
    }
  }

  //This method receives a series of float numbers,
  //and returns their mean value
  int val(float newValue) {
    for (int i = floatTab.length - 1; i > 0; i--) {
      floatTab[i] = floatTab[i-1];
    }
    floatTab[0] = newValue;
    int sum = 0;
    for (int i = 0; i < floatTab.length; i++) {
      sum += floatTab[i];
    }
    int mean = sum / floatTab.length;
    return mean;
  }
}
