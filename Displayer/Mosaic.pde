/**
 * This class provides an effect of a photo mosaic by replacing a given background 
 * or target image with images provided in the library with the appropriate size. 
 * The sequence of methods calls and the associated variables are clearly commented 
 * for manipulation.
 */
public class PhotoMosaic
{
  //The path of the folder containing the target or background picture to be mosaiced.
  private String pathTar;
  //The path for the pictures as the resources for tiling. 
  private String pathEle;
  //The array containing all the pictures as elements for the mosaic, not including the target picture.
  private PImage[] images;
  //The average colors of the element picture array.
  private color[] col;
  //An array containing the relative error of each element picture to a given average color. 
  private float[] error;
  //The background picture.
  private PImage tar;
  //The factor that the total area would be divided to obtain the area of each piece of the mosaic.
  private int divisionFactor;
  //The sidelength of each fragmented square.
  private int size; 
  //The x coordinate of the top left corner. 
  private int startX;
  //The y coordinate of the top left corner. 
  private int startY;
  //The width of the mosaic. 
  private int width;
  //The height of the mosaic. 
  private int height; 
  
  /**
   * Create a photomosaic given the paths to both the target picture and the pictures
   * that serves as tiles and the division factor which indicates the number of tiles
   * this mosaic is to be rendered by. The dimensions of the mosaic is assumed to be 
   * the size of the image. And the top left corner of the mosaicis supposed to be 
   * the top left corner of the screen. 
   * @param divisionFactor The number of tiles this mosaic to be tiled with. 
   * @param pathTar The path of the target picture. 
   * @param pathEle The path of the element pictures. 
   */
  public PhotoMosaic(int divisionFactor, String pathTar, String pathEle)
  {
    this.divisionFactor = divisionFactor;
    this.pathTar = pathTar;
    this.pathEle = pathEle;
    loadImg();
    //Calculate the side length of each square by the division factor.
    size = (int)sqrt(tar.width*tar.height/this.divisionFactor); 
    //Initialize the dimensions of the mosaic. 
    width = tar.width;
    height = tar.height;
  }
  
  /**
   * Create a photomosaic given the paths to both the target picture and the pictures
   * that serves as tiles and the division factor which indicates the number of tiles
   * this mosaic is to be rendered by. 
   * @param divisionFactor The number of tiles this mosaic to be tiled with. 
   * @param pathTar The path of the target picture. 
   * @param pathEle The path of the element pictures. 
   * @param startX The x coordinate of the top left corner of the mosaic. 
   * @param startY The y coordinate of the top left corner of the mosaic. 
   * @param sizeX The width of the mosaic. 
   * @param sizeY The height of the mosaic. 
   */
  public PhotoMosaic(int divisionFactor, String pathTar, String pathEle, int startX, int startY, int sizeX, int sizeY)
  {
    this.divisionFactor = divisionFactor;
    this.pathTar = pathTar;
    this.pathEle = pathEle;
    loadImg();
    //Calculate the side length of each square by the division factor.
    size = (int)sqrt(tar.width*tar.height/this.divisionFactor);
    //Intialize the positions and dimensions of the mosaic. 
    this.startX = startX;
    this.startY = startY;
    width = sizeX;
    height = sizeY; 
  }
  
  /**
   * Mosaic the given picture. 
   */
  public void mosaic()
  {
    //Fragment the picture.
    tile(size,tar);
  }
  
  //Load the image properly into the target image and the array of images for the element pictures.
  private void loadImg()
  {
    //Input the target file. 
    tar = loadImages(pathTar)[0];
    //The images for elements. 
    File[] ims = listFiles(pathEle);
    int numEle = ims.length;
    images = new PImage[numEle];
    col = new color[numEle];
    error = new float[numEle];
    for(int i=0; i<numEle; i++)
    {
      images[i] = loadImage(pathEle+"\\"+ims[i].getName());
      col[i] = average(images[i]);
    }
  }
  
  //Tile the picture by replacing each valid square region with a picture contained in the images array with the smallest error in average color.
  private void tile(int inc, PImage img)
  {
    for (int i=startX; i<width; i+=inc)
    {
      for (int j=startY; j<height; j+=inc)
      {
        //Calculate the corresponding coordinate of the current position in the
        //actual picture. 
        int[] coor = {(int)((i-startX)*float(tar.width)/width),(int)((j-startY)*tar.height/height)};  
        //The average color of the region.
        float[] ave = average(coor[0],coor[1],coor[0]+(int)(inc*float(tar.width)/width),coor[1]+(int)(inc*float(tar.height)/height),img);
        //Record the errors for each picture as for this region.
        for(int c=0; c<images.length; c++)
        {
          error[c] = (ave[0]-red(col[c]))*(ave[0]-red(col[c]))+(ave[1]-green(col[c]))*(ave[1]-green(col[c]))+(ave[2]-blue(col[c]))*(ave[2]-blue(col[c]));
        }
        //The index for the picture with the minimal error in the images array.
        int index=minimum(error);
        //Fetch the correponding image.
        PImage min = images[index];
        //Scale the picture and place it at this position as its top left coordinates.
        scale(size,size,i,j,min);
      }
    }
  }
  
}
