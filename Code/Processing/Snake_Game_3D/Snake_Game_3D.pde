/*
 ******************************************************************************
 * Sketch  Snake Game
 * Author  Ethan Pan @ Freenove (http://www.freenove.com)
 * Date    2016/8/14
 * Revision Nicolas Huppe & Charles Richard (Cegep de Sherbrooke)
 ******************************************************************************
 * Brief
 *   This sketch is used to play snake game through communicate to an Arduino
 *   board or other micro controller.
 *   It will automatically detect and connect to a device (serial port) which
 *   use the same trans format.
 *
 * Modifications (2022-10-19)
 *  Affichage du texte en langue française
 *  Ajustement de la coueleur du ver via un detecteur de proximité (A2),
 *  Modification aléatoire de la couleur de la nourriture à manger par le ver
 *  Le joueur doit ajuster la couleur du ver à la couleur de la nourriture
 *  pour manger cette dernière.
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
int threshold = 200;
int thresholdcolor = 200;
int cpt = 0;
int snakecolor = 0;
int foodcolor = 2;
int cptcolor = 0;
color[] couleurs = {color(51,255,51),color(0,128,255),color(255,0,127)}; 
int nbcouleurs = 3;
int foodspeed = 200;

/* Private variables ---------------------------------------------------------*/
SerialDevice serialDevice = new SerialDevice(this);

Snake snake;
Food food;


void setup() {
  size(1280, 720, P3D);
  background(128,128,128);
  textAlign(CENTER, CENTER);
  textSize(64);
  text("Démarrage...", width / 2, (height - 40) / 2);
  textSize(16);
  text("www.cegepsherbrooke.qc.ca", width / 2, height - 20);
  frameRate(1000 / 40);

  food = new Food(new GridMap(new Size(width, height), 40, 4));
  snake = new Snake(new GridMap(new Size(width, height), 40, 4));
}

void draw() {
  if (!serialDevice.active())
  {
    if (!serialDevice.start())
    {
      delay(1000);
      return;
    }
  }

  int[] analogs = new int[3];
  analogs = serialDevice.requestAnalogs(3);


  if (analogs != null)
  {

     if (analogs[1] < 512 - threshold)
    {    
      if (snake.direction != Direction.DOWN)
        snake.nextDirection = Direction.UP;
    } 
    else if (analogs[1] > 512 + threshold) {
      if (snake.direction != Direction.UP)
        snake.nextDirection = Direction.DOWN;
    }
    if (analogs[0] < 512 - threshold) {
      if (snake.direction != Direction.RIGHT)
        snake.nextDirection = Direction.LEFT;
    } 
    else if (analogs[0] > 512 + threshold) {
      if (snake.direction != Direction.LEFT)
        snake.nextDirection = Direction.RIGHT;
    }
    
   if (cptcolor>1)
    {
     
      int input = analogs[2];
      if(input < 300)
      {snakecolor=0;}
      
      
      if(input >= 350 && input < 600)
      {snakecolor=1;}
      
      if(input >= 750)
      {snakecolor=2;}
     
    }
    else cptcolor++;
    
  }
  
  background(225,225,225);
  
  if (snake.gameState == GameState.WELCOME)
  {
    rectMode(CENTER);
    stroke(0, 0, 0);
    fill(0, 0, 0, 50);
    rect(width / 2, height / 2, width / 2, height / 3);
    fill(255, 255, 255);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Jeu du Serpent", width / 2, height / 2 - 24);
    text("Appuyez sur Espace pour démarrer", width / 2, height / 2 + 24);
  } else if (snake.gameState == GameState.PLAYING)
  {
    if (snake.body[0].x == food.position.x && snake.body[0].y == food.position.y && snakecolor == foodcolor)
    {
      snake.grow();
      food.generate(snake.body, snake.length);
      snake.speedUp();
      
      if(foodspeed>50){foodspeed = foodspeed - 10; }
      
      
    }
    snake.step();
    showGame();
  } else if (snake.gameState == GameState.LOSE)
  {
    showGame();
    rectMode(CENTER);
    stroke(0, 0, 0);
    fill(0, 0, 0, 50);
    rect(width / 2, height / 2, width / 2, height / 3);
    fill(255, 255, 255);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Vous avez perdu!", width / 2, height / 2 - 24);
    text("Appuyez sur Espace pour démarrer", width / 2, height / 2 + 24);
  }
}

void showGame()
{
  
  
  //nb boucles avant changement de couleur de la nourriture
  cpt++;
  if (cpt>foodspeed  )
  {
    foodcolor= (int)random(nbcouleurs);
    cpt=0;
  }
  
  snake.display(couleurs[snakecolor]);
  food.display(couleurs[foodcolor]);

  fill(255, 255, 255);
  textSize(16);
  textAlign(LEFT, CENTER);
  text("Appuyez sur Entrer pour visiter www.cegepsherbrooke.qc.ca", 20, height - 20);
  textAlign(RIGHT, CENTER);
  text("Appuyez sur Espace pour redémarrer", width - 20, height - 20);
  textAlign(LEFT, CENTER);
  text("Pointage : " + (snake.length - 3), 20, 20);
  textAlign(RIGHT, CENTER);
  text("Vitesse : " + ((50 - snake.speed) / 5 + 1), width - 20, 20);
}

void keyPressed() {
  if (key == CODED)
  {
    if (keyCode == UP)
    {
      if (snake.direction != Direction.DOWN)
        snake.nextDirection = Direction.UP;
    } else if (keyCode == DOWN) {
      if (snake.direction != Direction.UP)
        snake.nextDirection = Direction.DOWN;
    } else if (keyCode == LEFT) {
      if (snake.direction != Direction.RIGHT)
        snake.nextDirection = Direction.LEFT;
    } else if (keyCode == RIGHT) {
      if (snake.direction != Direction.LEFT)
        snake.nextDirection = Direction.RIGHT;
    }
  } else
  {
    if (key == '\n' || key == '\r')
    {
      link("https://www.cegepsherbrooke.qc.ca/fr/t-as-deja-tout-un-genie");
    } else if (key == ' ')
    {
      snake.reset();
      food.generate(snake.body, snake.length);
      snake.gameState = GameState.PLAYING;
    }
  }
}
