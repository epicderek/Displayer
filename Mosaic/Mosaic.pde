
/**
 * This class provides an effect of a photo mosaic by replacing a given background 
 * or target image with images provided in the library with the appropriate size. 
 * The sequence of methods calls and the associated variables are clearly commented 
 * for manipulation.
 */
class PhotoMosaic
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
  private float size;
  
  /**
   * Create a photomosaic given the paths to both the target picture and the pictures
   * that serves as tiles and the division factor which indicates the number of tiles
   * this mosaic is to be rendered by. 
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
  }
  
  /**
   * Mosaic the given picture. 
   */
  public void mosaic()
  {
    //Fragment the picture.
    tile((int)size,tar);
  }
  
  //Load the image properly into the target image and the array of images for the element pictures.
  private void loadImg()
  {
    //Input the target file
    tar = loadImage(pathTar+"\\"+listFiles(pathTar)[0].getName());
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

  //Fetch all the files in the given directory.
  private File[] listFiles(String path)
  {
    File file = new File(path);
    //If valid
    if(file.isDirectory())
    {
      File[] files = file.listFiles();
      return files;
    }else{
      return null;
      }
  }
  
  //Tile the picture by replacing each valid square region with a picture contained in the images array with the smallest error in average color.
  private void tile(int inc, PImage img)
  {
    for (int i=0; i<img.width; i+=inc)
    {
      for (int j=0; j<img.height; j+=inc)
      {
        //The average color of the region.
        float[] ave = average(i,j,i+inc,j+inc,img);
        //Record the errors for each picture as for this region.
        for(int c=0; c<images.length; c++)
        {
          error[c] = (ave[0]-red(col[c]))*(ave[0]-red(col[c]))+(ave[1]-green(col[c]))*(ave[1]-green(col[c]))+(ave[2]-blue(col[c]))*(ave[2]-blue(col[c]));
        }
        //The index for the picture with the minimal error in the images array.
        int index=minimum(error);
        //Fetch the correponding image.
        PImage min = images[index];
        //The horizontal and vertical porportions that the picture would be required to scaled to provide a square image of the given size.
        float xPor = size/min.width;
        float yPor = size/min.height;
        //Scale the picture and place it at this position as its top left coordinates.
        scale(xPor,yPor,i,j,min);
      }
    }
  }
  
  //Return the average color of the image.
  private color average(PImage img)
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
  
  //Return the average color of the given region in the given image in terms of a float array with three elements indicating red, green, blue correspondingly.
  private float[] average(int xIni, int yIni, int xFin, int yFin, PImage img)
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
  
  //Scale the given image by prox horizontally and proy vertically. x and y are the initial coordinate of the picture.
  private void scale(float prox, float proy, int x, int y, PImage image)
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
  
  //Returne the index of the element with the least float value in the float array.
  private int minimum(float[] input)
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
}
