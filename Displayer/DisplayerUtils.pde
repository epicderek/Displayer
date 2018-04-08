//This file contains all the utilities and helper methods invoked by the different
//stages of the program. 

//*********************************File Utils***************************************
  //Fetch all the files in the given directory. If no files are contained in this directory,
  //an empty array is returned. 
  public File[] listFiles(String path)
  {
    File file = new File(path);
    //If valid
    if(file.isDirectory())
    {
      File[] files = file.listFiles();
      return files;
    }
    else
      return new File[0];
  }
  
  //Fetch all images contained in this directory. 
  public PImage[] loadImages(String path)
  {
    File[] files = listFiles(path);
    PImage[] ims = new PImage[files.length];
    for(int i=0; i<files.length; i++)
      ims[i] = loadImage(String.format("%s%s%s",path,"\\",files[i].getName()));
    return ims;
  }
  
  //Fetch all images contained in this directory and record their names despite the last character in a map. 
  public Map<String,PImage> loadImagesMap(String path)
  {
    Map<String,PImage> write = new HashMap<String,PImage>();
    File[] files = listFiles(path);
    for(int i=0; i<files.length; i++)
    {
      String name = files[i].getName();
      PImage img = loadImage(String.format("%s%s%s",path,"\\",name));
      String formattedName = name.substring(0,name.indexOf("."));
      write.put(formattedName.substring(0,formattedName.length()-1),img);
    }
    return write;
  }
  
  //Returne the index of the element with the least float value in the float array.
  public int minimum(float[] input)
  {
    float min = input[0];
    int index = 0;
    for(int i=1; i<input.length; i++)
    {
      if(input[i]<min)
      {
        min = input[i];
        index = i;
      }
    }
    return index;
  }
  
//********************************Photo Utils*********************************
  //Return the average color of the image.
  public color average(PImage img)
  {
    //Trimming factors, ignoring the marginal effect.
    int barX = (int)(img.width*0.1);
    int barY = (int)(img.height*0.1);
    float red=0, green=0, blue=0;
    for (int i=barX; i<=img.width-barX; i++)
    {
      for (int j=barY; j<=img.height-barY; j++)
      {
        //Fetch the color and increment the overall color.
        color co = img.get(i, j);
        red+=red(co);
        green+=green(co);
        blue+=blue(co);
      }
    }
    //The total pixels in the picture.
    int size = (img.width-2*barX+1)*(img.height-2*barY+1);
    return color(red/size, green/size, blue/size);
  }
  
  //Return the average color of the given region in the given image in terms 
  //of a float array with three elements indicating red, green, blue correspondingly.
  public float[] average(int xIni, int yIni, int xFin, int yFin, PImage img)
  {
    float red=0, green=0, blue=0;
    for (int i=xIni; i<=xFin; i++)
    {
      for (int j=yIni; j<=yFin; j++)
      {
        //Increment the overall color by the color present.
        color co = img.get(i, j);
        red+=red(co);
        green+=green(co);
        blue+=blue(co);
      }
    }
    //The total number of pixels computed.
    int size = (xFin-xIni+1)*(yFin-yIni+1);
    return new float[]{red/size, green/size, blue/size};
  }
  
  //Scale the given image by prox horizontally and proy vertically. 
  //x and y are the initial coordinate of the picture.
  public void scale(float prox, float proy, int x, int y, PImage image)
  {
    int sizeX = (int)(image.width*prox);
    int sizeY = (int)(image.height*proy);
    for (int i=x; i<sizeX+x; i++)
    {
      int xRes = (int)((i-x)/prox);
      for (int j=y; j<sizeY+y; j++)
      {
        int yRes = (int)((j-y)/proy);
        color co = image.get(xRes, yRes);
        set(i, j, co);
      }
    }
  }
  
  //Scale the given image to the given size with a given set of coordinates of the 
  //top left of the images to be displayed. 
  public void scale(int xSize, int ySize, int x, int y, PImage img)
  {
    float xRatio = float(xSize)/img.width;
    float yRatio = float(ySize)/img.height;
    scale(xRatio,yRatio,x,y,img);
  }
  
  //Scale the given picture to the given size in the given coordinates while
  //flipping the picture horizontally. 
  public void reverseX(int sizeX, int sizeY, int x, int y, PImage img)
  {
    float prox = float(sizeX)/img.width;
    float proy = float(sizeY)/img.height;
    for(int i=x; i<x+sizeX; i++)
    {
      int xRes = img.width-(int)((i-x)/prox);
      for (int j=y; j<sizeY+y; j++)
      {
        int yRes = (int)((j-y)/proy);
        color co = img.get(xRes, yRes);
        set(i, j, co);
      }
    }
  }
  
  //Scale the given picture to the given size in the given coordinates while
  //flipping the picture vertically. 
  public void reverseY(int sizeX, int sizeY, int x, int y, PImage img)
  {
    float prox = float(sizeX)/img.width;
    float proy = float(sizeY)/img.height;
    for(int i=x; i<x+sizeX; i++)
    {
      int xRes = (int)((i-x)/prox);
      for (int j=y; j<sizeY+y; j++)
      {
        int yRes = img.height-(int)((j-y)/proy);
        color co = img.get(xRes, yRes);
        set(i, j, co);
      }
    }
  }
  
//*************************Graphical Component Utils***************************

  /**
   * A concise representation of the top left x and y coordinate of an item. 
   * Its application is the quick access of information. It provides functionality
   * for checking if a given coordinate is the in the given item. 
   */
  public class Coordinate
  {
    //The x coordinate of the top left corner. 
    int startX;
    //The y coordinate of the top left corner. 
    int startY;
    //The x coordinate of the right bottom corner. 
    int endX;
    //The y coordinate of the right bottom corner. 
    int endY;
    
    /**
     * Construct a coordinate object from the starting postisions
     * and dimensions of the item. 
     */
    public Coordinate(int startX, int startY, int sizeX, int sizeY)
    {
      this.startX = startX;
      this.startY = startY;
      endX = startX + sizeX;
      endY = startY + sizeY;
    }
    
    /**
     * Check if the given coordinate falls in the domain of this 
     * item. 
     */
    public boolean isIn(int xPos, int yPos)
    {
      return xPos>startX&&xPos<endX&&yPos>startY&&yPos<endY;
    }
  }
  
  /**
   * An item represents a complex of a front cover a back cover, either an image or a video,
   * the dimensions of this item, and its top left coordinate. 
   */
  public class Item
  {
    //The name of this item. Should be consistent with the front and back name despite the last character. 
    String name;
    //The width of this item. 
    int sizeX;
    //The height of this item. 
    int sizeY;
    //The x coordinate of the top left corner of this item. 
    int startX;
    //The y coordinate of the top left corner of this item. 
    int startY;
    //The front cover of this item. 
    PImage front;
    //The back of this item, either an image or a video. 
    Object back;
    //A coordinate representation of this item. 
    Coordinate coor;
    //A flipper for user interaction. 
    Flipper flipper;
    //An expander for expanding the back of the item if applicable. 
    Expander expander;
    
    /**
     * Construct an item with all the necessary informatio given. 
     * @param name The name of this item. 
     * @param front The front cover of this item. 
     * @param back The back of this item, an image or a video. 
     */
    public Item(String name, PImage front, Object back)
    {
      this.front = front;
      this.back = back;
      this.name = name;
    }
    
    /**
     * Set the top left corner's coordinate of this item. 
     * @param startX The x coordinate of the top left corner of this item. 
     * @param startY The front cover of this item. 
     */
    public void setCoordinate(int startX, int startY)
    {
      this.startX = startX;
      this.startY = startY;
    }
    
    /**
     * Set the sizes of this item. 
     * @param sizeX The width of this item.
     * @param sizeY The height of this item. 
     */
    public void setSize(int sizeX, int sizeY)
    {
      this.sizeX = sizeX;
      this.sizeY = sizeY;
    }
    
    /**
     * Store the present geometry, coordinate and dimensions, in the 
     * format of a coordinate object. This method can only be invoked
     * succeeding the invokation of the setter methods for dimensions 
     * and coordinate. The flipper and expander, if applicable to this
     * item, are also configured in this step. 
     */
    public void storeGeometry()
    {
      coor = new Coordinate(startX,startY,sizeX,sizeY);
      flipper = new Flipper(startX+sizeX/2,startY+sizeY/2,sizeX,sizeY,startX,startY,10,new int[]{0,0,0},front);
      if(back instanceof PImage)
        expander = new Expander(screenXSize, screenYSize, screenXSize/2, screenYSize/2, sizeX, sizeY, 0.04, (PImage)back);
    }
    
    /**
     * Display the front of the item at its current position. 
     */
    public void displayFront()
    {
      scale(sizeX,sizeY,startX,startY,front);
    }
    
    /**
     * Display the back of the item at ite current position. 
     */
    public void displayBack()
    {
      scale(sizeX,sizeY,startX,startY,(PImage)back);
    }
    
  }
  
  /**
   * A cutomized representation for a button, including a coordinate 
   * representation of the region, a picture, and an indicator for its
   * presence at the present stage. A method for checking whether the position
   * of a click falls under this region is included.  
   */
  public class Button
  {
    //The coordinate of this button. 
    Coordinate coor;
    //The picture of this button. 
    PImage icon;
    //Whether the button is activated at the present stage. 
    boolean activated;
    
    /**
     * Create a button of the given position and dimensions. 
     * @param startX The x coordinate of the top left corner of this button. 
     * @param startY The front cover of this button. 
     * @param xSize The length of the screen.
     * @param ySize The height of the screen.
     * @param ic The image of the icon of this button. 
     */
    public Button(int startX, int startY, int sizeX, int sizeY, PImage ic)
    {
      coor = new Coordinate(startX,startY,sizeX,sizeY);
      icon = ic;
      activated = false;
    }
    
    /**
     * Activate this button for use. 
     */
    public void activate()
    {
      activated = true;
    }
    
    /**
     * Disctivate this button for use. 
     */
    public void disactivate()
    {
      activated = false;
    }
    
    /**
     * Check to see if the given position falls under the
     * domain of this button. 
     */
    public boolean isIn(int xPos, int yPos)
    {
      return coor.isIn(xPos,yPos);
    }
    
    /**
     * Make the button on the screen. 
     */
    public void makeButton()
    {
      scale(coor.endX-coor.startX,coor.endY-coor.startY,coor.startX,coor.startY,icon);
    }
  }
  
   /**
     * A flipper offers the funcionality of flipping an image either vertically or horizontally. 
     * It has two methods for accordingly. To use either of the method, invoke the method, and when
     * it returns a false, the flipping is finished. 
     */
    public class Flipper
    {
      //The x axis to be flipped. 
      private int midXAxis;
      //The y axis to be flipped. 
      private int midYAxis;
      //The original width of this picture. 
      private int width;
      //The original height of the picture. 
      private int height;
      //The original x coordinate of the picture.
      private int xPos;
      //The original y coordinate of the picture. 
      private int yPos;
      //The change in size of the picture in each frame. 
      private int increment;
      //The background color bo be displayed as the picture is being flipped. 
      private int[] col;
      //The icon or image of this flipper. 
      private PImage icon;
      //A helper measure of the current width.
      private int wide;
      //A helper measure of the current height;
      private int high; 
      //The starting stage of flipps.
      private boolean forwardX, forwardY;
      //The reverse stage of the flipps. 
      private boolean reverseX, reverseY; 
      
      /**
       * Create a flipper that may flip either horizontally or vertically. 
       * @param midX The x axis to be flipped.
       * @param midY The y axis to be flipped.
       * @param sizeX The original width of this picture. 
       * @param sizeY The original height of the picture. 
       * @param xPos The original x coordinate of the picture.
       * @param yPos The original y coordinate of the picture. 
       * @param inc The change in size of the picture in each frame. 
       * @param col The background color bo be displayed as the picture is being flipped.
       * @param img The icon or image of this flipper. 
       */
      public Flipper(int midX, int midY, int sizeX, int sizeY, int xPos, int yPos, int inc, int[] col, PImage img)
      {
        midXAxis = midX;
        midYAxis = midY;
        width = sizeX;
        height = sizeY;
        this.xPos = xPos;
        this.yPos = yPos;
        increment = inc;
        this.col = col;
        icon = img;
        //Initialize the initial width and height. 
        wide = width-increment;
        high = height-increment;
        //Initialize the initial states. 
        forwardX = true;
        forwardY = true;
        reverseX = false;
        reverseY = false; 
      }
      /**
       * Flip the fiven image with respect to given vertical axis, that is, horizontally.
       * The flipping would stop when the boolean returned become false. 
       */
      public boolean flipHorizontal()
      {
        //If in the second stage of reversing. 
        if(reverseX)
        {
          if(wide<width)
          {
            fill(col[0],col[1],col[2]);
            int prevX = midXAxis-(wide-increment)/2;
            noStroke();
            rect(prevX,yPos,wide-10,height);
            int xStart = midXAxis-wide/2;
            reverseX(wide,height,xStart,yPos,icon);
            wide+=increment;
            return true;
          }
          //The end stage of flipping reached. Reinitialize the states. 
          wide = width;
          forwardX = true;
          reverseX = false; 
          return false;
        }
        if(forwardX&&wide>0)
        {
          fill(col[0],col[1],col[2]);
          int prevX = midXAxis-(wide+increment)/2;
          noStroke();
          rect(prevX,yPos,wide+10,height);
          int xStart = midXAxis-wide/2;
          scale(wide,height,xStart,yPos,icon);
          wide-=increment;
          return true;
        }
        else
        {
          forwardX = false;
          wide = increment;
          reverseX = true;
          return true;
        }
      }
      
      /**
       * Flip the fiven image with respect to given vertical axis, that is, horizontally.
       * The flipping would stop when the boolean returned become false. 
       */
      public boolean flipVertical()
      {
        //If in the second stage of reversing. 
        if(reverseY)
        {
          if(high<height)
          {
            fill(col[0],col[1],col[2]);
            int prevY = midYAxis-(high-increment)/2;
            noStroke();
            rect(xPos,prevY,width,high-10);
            int yStart = midYAxis-high/2;
            reverseY(width,high,xPos,yStart,icon);
            high+=increment;
            return true;
          }
          //The end stage of flipping reached. Reinitialize the states. 
          high = height;
          forwardY = true;
          reverseY = false; 
          return false;
        }
        if(forwardY&&high>0)
        {
          fill(col[0],col[1],col[2]);
          int prevY = midYAxis-(high+increment)/2;
          noStroke();
          rect(xPos,prevY,width,high+10);
          int yStart = midYAxis-high/2;
          scale(width,high,xPos,yStart,icon);
          high-=increment;
          return true;
        }
        else
        {
          forwardY = false;
          high = increment;
          reverseY = true;
          return true;
        }
      }
    } 
    
    /**
     * A means of expanding a picture proportionally in its dimensions with respect to one 
     * fixed center until either its edges exceeds the current screen dimensions. 
     */
    public class Expander
    {
      //The dimensions of the screen. 
      private int[] screen = new int[2];
      //The x and y coordinate of the center of the picture. 
      private int[] center = new int[2];
      //The width and height of the picture. 
      private int[] size = new int[2];
      //The proportion the dimensions of the picture expands in each frame. 
      private float ratio; 
      //The image being expanded. 
      private PImage image;
      //The current dimensions of the expanding item. 
      private int[] dims = new int[2];
      
      /**
       * Create an expander from the given dimensions and location with 
       * the given ratio of growth. 
       * @param The width of the screen. 
       * @param The height of the screen. 
       * @param The x coordinate of the center of the picture.
       * @param The y coordinate of the center of the picture.
       * @param The width of the picture.
       * @param The height of the picture.
       * @param The proportion the dimensions of the picture expands in each frame.
       * @param The image being expanded. 
       */
      public Expander(int maxX, int maxY, int x, int y, int xSize, int ySize, float ratio, PImage img)
      {
        screen[0] = maxX;
        screen[1] = maxY;
        center[0] = x;
        center[1] = y;
        size[0] = xSize;
        size[1] = ySize;
        this.ratio = ratio;
        image = img; 
        //Initialize the dimensions. 
        dims[0] = size[0];
        dims[1] = size[1];
      }
      
      /**
       * Expand the image per frame with respect to its center. 
       * The expansion is complete when a false is returned. 
       */
      public boolean expand()
      {
        dims[0] = (int)(dims[0]*(1+ratio));
        dims[1] = (int)(dims[1]*(1+ratio));
        //If within the screen after growth. 
        if(center[0]+dims[0]/2<screen[0]&&center[0]-dims[0]/2>0&&center[1]+dims[1]/2<screen[1]&&center[1]-dims[1]/2>0)
        {
          background(backGround[0],backGround[1],backGround[2]);
          scale(dims[0],dims[1],center[0]-dims[0]/2,center[1]-dims[1]/2,image);
          return true;
        }
        dims[0] = size[0];
        dims[1] = size[1];
        return false;
      }
    }
  
  