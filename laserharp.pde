import processing.serial.*;
import cc.arduino.*;

import beads.*;
import org.jaudiolibs.beads.*;

//Minim minim; //initiates the class minim
//AudioPlayer melody1;


//SoundFile file; //playing sound with path
StringList audioName;


//SinOsc[] sine; // creates an array sine
Arduino arduino;
int[] pinNum= new int[8];
int[] inByte= new int[8];
//int inByte = 0; //byte to store serial value
int[] maxVal = new int [8]; // value to store the max value of your sensor reading
int[] minVal = new int [8];

//float[] notes= {261.6, 293.7, 277.2, 329.6, 349.2, 392, 440, 493.9, 523.3, 293.7*2, 329.6*2, 349.2*2, 392*2, 440*2, 493.9*2, 523.3*2};

// The 8 tracks are assembled in this order in the arrays:
// Kick, Tom, HiHat, Bass Tabla, Tabla, Tabla Flam, Piano1, Piano2

SamplePlayer[] audioFiles = new SamplePlayer[8];
Glide[] gainGlides = new Glide[8];
Gain[] gains = new Gain[8];


AudioContext ac;
String source;

void setup()
{
  //minim = new Minim(this);
  //melody1 = minim.loadFile("funky.mp3");
  ac = new AudioContext();
  ac.start();
  
  //file = new SoundFile(this,path);
  //file.play();
  arduino = new Arduino(this, Arduino.list()[3], 57600);
  
  
  //sine = new SinOsc[16];
  audioName = new StringList();
  audioName.append("kick.wav");
  audioName.append("tom.wav");
  audioName.append("hihat.wav");
  audioName.append("basstabla.wav");
  audioName.append("tabla.wav");
  audioName.append("tablaflam.wav");
  audioName.append("piano1.wav");
  audioName.append("piano2.wav");
  
  source = sketchPath("") + "data/";

  for (int i=0; i <8; i++) {
    pinNum[i]=i;
    inByte[i]=0;
    maxVal[i]=0;
    minVal[i]=1024;
    
    //populate SamplePlayer[] audioFiles
    String path = source + audioName.get(i);
    try {
      audioFiles[i] = new SamplePlayer(ac, new Sample(path));
      audioFiles[i].setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    } catch (Exception e) {
       System.out.println(e);
    }
    
    //populate the Glide[]
    gainGlides[i] = new Glide(ac, 0.0, 20);
    
    //populate the Gain[]
    gains[i] = new Gain(ac, 1, gainGlides[i]);
  
  }
  
  // Hook up the the audio chain
  // audioFile -> Gain -> ac
  for (int i = 0; i < 8; i++) {
    gains[i].addInput(audioFiles[i]);
    ac.out.addInput(gains[i]);
  }
  
  
  
}


void draw() {
     //melody1.loop( );
     
    if (millis() < 10000) {
      for (int i=0; i<8; i++){
        inByte[i]= arduino.analogRead(pinNum[i]);
        if (inByte[i] > maxVal[i]) {
          maxVal[i] = inByte[i];
        }
        if (inByte[i] < minVal[i]) {
          minVal[i] = inByte[i];} 
        } 
    } else {
      for (int i=0; i<8; i++){
        inByte[i]= arduino.analogRead(pinNum[i]);
        if (inByte[i] < ((minVal[i]+maxVal[i])/2.0)){
           gainGlides[i].setValue(1.0);
        } else {
           gainGlides[i].setValue(0.0);
        }
      }
   }
}
     
