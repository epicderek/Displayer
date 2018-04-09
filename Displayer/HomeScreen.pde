import processing.video.Movie;
import java.util.Map;
import java.util.List;
import java.util.HashMap;
import java.util.ArrayList;

/**
 * A template for the home screen in which the different events are displayed.
 * A HomeScreen object contains all the relevant information pertaining to the 
 * elements of the home screen as well as the utilities supproted by it. These
 * utilities, nonetheless, has to be invoked explicitly. 
 * The front and back images of one item must share the same name. 
 */
public class HomeScreen
{
  //The length of the screen. 
  int screenXSize;
  //The height of the screen. 
  int screenYSize;
  //The number of items displayed on this home screen. 
  int itemCount;
  //The number of optional items to be displayed. 
  int auxItemCount;
  //The path in which the front covers of the ever-green items are contained. 
  String pathFrontMan;
  //The path in which the back covers of the optional items are stored. 
  String pathFrontOpt;
  //The path in which the back covers of the ever-green items are contained. 
  String pathBackMan;
  //The path in which the back covers of the optional items are stored. 
  String pathBackOpt;
  //All the ever-green items of this home screen. 
  Map<String,Item> itemsMan = new HashMap<String,Item>();
  //All the optional items for this home screen. 
  Map<String,Item> itemsOpt = new HashMap<String,Item>();
  //All the current items on display. 
  Map<Coordinate,Item> stack = new HashMap<Coordinate,Item>();
  
  /**
   * Construct a home screen object with the dimensions of the screen and the requisite
   * resources of the items. 
   * @param xSize The length of the screen.
   * @param ySize The height of the screen.
   * @param itemCount The number of items to be displayed on the screen. 
   * @param frsM The directory containing all the front pictures of the ever-green items. 
   * @param bksM The directory containing all the back pictures of the ever green items.
   * @param frsO The directory containing all the front pictures of the optional items.
   * @param bksO The directory containing all the back pictures of the optional items.
   * @param videoLinks A .csv file containing the paths to videos in the agreed format. 
   */
  public HomeScreen(int xSize, int ySize, int itemCount, String frsM, String bksM, String frsO, String bksO, File videoLinks)
  {
    screenXSize = xSize;
    screenYSize = ySize;
    //Stored the total number of items to be dislayed. 
    this.itemCount = itemCount;
    //Store the paths of the pictures for possible reference purposes. 
    pathFrontMan = frsM;
    pathFrontOpt = frsO;
    pathBackMan = bksM;
    pathBackOpt = bksO;
    //Load the images from the paths
    importItems(videoLinks);
    //Calculate and store the number of optional items. 
    auxItemCount = itemCount-itemsMan.size();
    if(auxItemCount<0)
      throw new RuntimeException("To Many Ever Green Items for Given Item Count!");
    tesselate();
    //Store the coordinates of all items and push the mandatory items on to stack.
    for(Item holder: itemsMan.values())
    {
      holder.storeGeometry();
      stack.put(holder.coor,holder);
    }
    //Store the coordinates of optional items. 
    for(Item holder: itemsOpt.values())
      holder.storeGeometry();
  }
  
  /**
   * Display all the items in their front covers with the allocated sizes
   * and postions from tesselation. 
   */
  public void display()
  {
    List<Item> optItems = new ArrayList<Item>(itemsOpt.values());
    //Randomly push optional items on to the stack of current home screen. 
    for(int i=0; i<auxItemCount; i++)
    {
      Item item = optItems.remove((int)random(optItems.size()));
      stack.put(item.coor,item);
    }
    //Display the fronts of the items chosen. 
    for(Item holder: stack.values())
      holder.displayFront();
  }
  
  private void importItems(File videoLinks)
  {
    //Process the ever-green items first. 
    Map<String,PImage> manF = loadImagesMap(pathFrontMan);
    Map<String,PImage> manB = loadImagesMap(pathBackMan);
    for(String holder: manF.keySet())
    {
      //The front image of this name.
      PImage imgF = manF.get(holder);
      if(manB.containsKey(holder))
      {
        //The back image of this name. 
        PImage imgB = manB.get(holder);
        //Check for size consistency. 
        itemsMan.put(holder,new Item(holder,imgF,imgB)); 
      }
      else
        throw new RuntimeException("Video Import Currently Not Supported!");
    }
    //Process the optional items second. 
    Map<String,PImage> optF = loadImagesMap(pathFrontOpt);
    Map<String,PImage> optB = loadImagesMap(pathBackOpt);
    for(String holder: optF.keySet())
    {
      //The front image under this name. 
      PImage imgF = optF.get(holder);
      if(optB.containsKey(holder))
      {
        //The back image under this name. 
        PImage imgB = optB.get(holder);
        //Check for size consistency. 
        if(imgF.width!=imgB.width||imgF.height!=imgB.height)
          throw new RuntimeException("The Front and Back Sizes of This Item Are Different!");
        itemsOpt.put(holder,new Item(holder,imgF,imgB)); 
      }
    }
  }
  
  
  //Assign the sizes and positions of the items after tesselation. 
  private void tesselate()
  {
    if(itemCount!=2)
      throw new RuntimeException("Unresolved Situation for Current Testing!");
    //Retrieve the items. 
    Item one = itemsMan.get("Be");
    Item two = itemsMan.get("No");
    //Set the sizes. 
    one.setSize(200,400);
    two.setSize(200,400);
    //Set the top left coordinates. 
    one.setCoordinate(143,74);
    two.setCoordinate(631,74);
  }
  
}
