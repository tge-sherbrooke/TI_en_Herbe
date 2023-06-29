/* //<>//
 ******************************************************************************
 * Sketch  Three Dimensional Box
 * Author  Ethan Pan @ Freenove (http://www.freenove.com)
 * Date    2016/8/14
 * Revision Nicolas Huppe & Charles Richard (Cegep de Sherbrooke)
 ******************************************************************************
 * Brief
 *   This sketch is used to control a 3D box through communicate to an Arduino 
 *   board or other micro controller.
 *   It will automatically detect and connect to a device (serial port) which 
 *   use the same trans format.
 *
 * Modifications (2022-10-19)
 *  Affichage du texte en langue française
 *  Ajout d'un effet de zoom de la boite 3D via un detecteur de proximité (A2)
 ******************************************************************************
 * Copyright
 *   Copyright © Freenove (http://www.freenove.com)
 * License
 *   Creative Commons Attribution ShareAlike 3.0 
 *   (http://creativecommons.org/licenses/by-sa/3.0/legalcode)
 ******************************************************************************
 */

/* Includes ------------------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
SerialDevice serialDevice = new SerialDevice(this);

void setup()
{
  size(720, 360, P3D);
  background(102);
  textAlign(CENTER, CENTER);
  textSize(64);
  text("Démarrage...", width / 2, (height - 40) / 2);
  textSize(16);
  text("www.cegepsherbrooke.qc.ca", width / 2, height - 20);
  frameRate(1000 / 40);
}

void draw()
{
  if (!serialDevice.active())
  {
    if (!serialDevice.start())
    {
      delay(1000);
      return;
    }
  }

  int[] analogs = new int[4];
  analogs = serialDevice.requestAnalogs(4);
  if (analogs != null)
  {
    background(102);
    drawJoystick(analogs[0], analogs[1]);
    drawBox(analogs[0], analogs[1],(int)((float)analogs[2]/10.3));
    drawBoxColor(analogs[0], analogs[1],(int)((float)analogs[2]/10.3));
  }
}

void drawBox(int x, int y,int size)
{
  pushMatrix();
  translate(width / 3, height / 2, 0); 
  rotateY((x - 512) / 512.0);
  rotateX((512 - y) / 512.0);
  noFill();  
  box(size);
  popMatrix();
}

void drawBoxColor(int x, int y,int size)
{
  pushMatrix();
  translate(width * 2 / 3, height / 2, 0); 
  rotateY((x - 512) / 512.0);
  rotateX((512 - y) / 512.0);
  fill(227, 118, 12);
  box(size);
  popMatrix();
}

void drawJoystick(int x, int y)
{
  int radiusOuter = 60;
  int radiusInner = radiusOuter / 2;

  fill(255, 255, 255);
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Appuyez sur Entrer pour visiter www.cegepsherbrooke.qc.ca", width / 2, height - 20);
  textAlign(LEFT, CENTER);
  text("X: " + x, width - 124, height - 20);
  text("Y: " + y, width - 64, height - 20);

  int posX = width - radiusOuter - 10;
  int posY = height - radiusOuter - 40;
  fill(128, 128, 128);
  ellipse(posX, posY, radiusOuter * 2, radiusOuter * 2);

  posX = posX + (x - 512) * (radiusOuter - radiusInner) / 512;
  posY = posY + (y - 512) * (radiusOuter - radiusInner) / 512;
  fill(32, 32, 32);
  ellipse(posX, posY, radiusInner * 2, radiusInner * 2);
}

void keyPressed() 
{
  if (key == '\n' || key == '\r')
  {
    link("https://www.cegepsherbrooke.qc.ca/fr/t-as-deja-tout-un-genie");
  }
}
