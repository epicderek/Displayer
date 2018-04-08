//A photomosaic used to display when the screen is at rest or at start. 
PhotoMosaic mosaic;
//Home screen for this displayer. 
HomeScreen home;
//The width of the screen. 
int screenXSize;
//The height of the screen. 
int screenYSize;
//Whether action has been taken by the user in this frame.
boolean action;
//Whether the screen is at rest and thereby the photomosaic should be invoked. 
boolean isRest;
//The counter for counting the time of inaction. 
int sleepCounter;
//Whether the current stage is the home screen. 
boolean isHomeScreen;
//The item on the home screen presently being clicked. 
Item itemClicked;
//If a specific item is currently being displayed. 
boolean onDisplay;
//If there is currently flipping occuring. 
boolean inFlip;
//If the back cover of an item is expanding. 
boolean inExpand;
//The background color of all stages. 
int[] backGround = {0,0,0};
//Return button from display of an item to the home screen. 
Button retHButton;

void setup()
{
  //Screen size.
  size(974,548);
  screenXSize = 974;
  screenYSize = 548;
  //Initialize mosaic depicter with proper paths. 
  mosaic = new PhotoMosaic(5000,"C:\\Users\\Maggie\\Desktop\\Displayer\\mosaic_res\\tar","C:\\Users\\Maggie\\Desktop\\Displayer\\mosaic_res\\ele"); 
  //Initialize the home screen with proper dimensions and paths. 
  home = new HomeScreen(screenXSize,screenYSize,2,"C:\\Users\\Maggie\\Desktop\\Displayer\\home_screen_items\\ever_green\\front","C:\\Users\\Maggie\\Desktop\\Displayer\\home_screen_items\\ever_green\\back","C:\\Users\\Maggie\\Desktop\\Displayer\\home_screen_items\\optional\\front","C:\\Users\\Maggie\\Desktop\\Displayer\\home_screen_items\\optional\\back",null);  
  //Indicate no user intervention at the beginning. 
  action = false;
  //Set initially the screen to be resting. 
  isRest = true;
  //Set the other stages to be false initially. 
  isHomeScreen = false;
  //Set the counter for inaction to be zero. 
  sleepCounter = 0;
  //The initial state of no item being displayed. 
  onDisplay = false;
  inFlip = false;
  inExpand = false; 
  //Set up button for returning from display to home screen. 
  retHButton = new Button(0,400,148,148,loadImage("C:\\Users\\Maggie\\Desktop\\Displayer\\buttons\\button.jpg"));
}

void draw()
{
  if(isRest)
    mosaic.mosaic();
  //If particular actions are being conducted on the home screen.
  if(onDisplay)
  {
    //If an item is expanding. 
    if(inExpand)
    {
      if(itemClicked.expander.expand())
        return;
      else
      {
        inExpand = false;
        //The reference to the current item is dropped. 
        itemClicked = null;
      }
    }
    //The display process has ended. 
    //Maintain the display and make the return button. 
    retHButton.activate();
    retHButton.makeButton();
  }
  //The home screen has already been displayed. 
  else if(isHomeScreen)
  {
    //An item has been clicked. 
    if(itemClicked!=null&&inFlip)
    {
      if(itemClicked.flipper.flipHorizontal())
        return;
      else
      {
        //Stop the current stage. 
        inFlip = false;
        //Continue to display. 
        onDisplay = true;
        if(itemClicked.expander!=null)
          inExpand = true;
      }
    }
  }
    
}

//The essential modelling and control of the program regarding what stage is currently 
//involved and what action should be accordingly taken is modelled by this mouseClicked
//method. According to the idiom of this program, it is by controlling the truth of
//booleans. It is to be noted that, generally, this method is invoked succeeding the 
//invokation of the same stage in the draw. So it serves as a terminator for the last 
//stage and an initializer for the new. 
void mouseClicked()
{
  //Check to see if the action is correct. 
  action = true;
  if(isRest)
  {
    isRest = false;
    isHomeScreen = true;
    //Display home screen. 
    background(backGround[0],backGround[1],backGround[1]);
    home.display();
    return;
  }
  //If an item is currently being flipped. 
  if(inFlip)
  {
    return; 
  }
  //If the screen is currently on display while the actions may have ended. 
  if(onDisplay)
  {
    //If the display of the specific item is finished. 
    if(!inExpand)
    {
      //The return home screen button must already exist at this point. 
      if(retHButton.isIn(mouseX,mouseY))
      {
         onDisplay = false;
         retHButton.disactivate();
         //Redraw the home screen and reshuffle the optional items. 
         background(backGround[0],backGround[1],backGround[2]);
         home.display();
      }
    }
    return;
  }
  //If the home screen is clicked after it is displayed. 
  if(isHomeScreen)
  {
    //Sift the item being clicked to tell draw to flip it.
    //Or pass if no item is clicked. 
    for(Coordinate holder: home.stack.keySet())
    {
      if(holder.isIn(mouseX,mouseY)) 
      {
        itemClicked = home.stack.get(holder);
        inFlip = true;
        return;
      }
    }
    return;
  }
}