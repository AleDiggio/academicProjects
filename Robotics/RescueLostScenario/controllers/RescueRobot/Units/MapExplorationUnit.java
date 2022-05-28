package Units;

import java.util.*;
import com.cyberbotics.webots.controller.*;
import java.lang.*;

import Utils.*;

public class MapExplorationUnit {

  public int mapDim = 9;
  public double cellLen = 1.5; //13.5 x 13.5 - 9 celle da 1.5m^2

  public List<Double> index;

  public Cell[][] realMap = new Cell[mapDim][mapDim];
  public Grid grid;

  //Sensori
  private DistanceSensor frontSensor;      //Anteriore
  private DistanceSensor rearSensor;       //Posteriore
  private DistanceSensor sideLeftSensor;   //Laterale sinistra
  private DistanceSensor sideRightSensor;  //Laterale destra

  private MovementUnit movement;

  public MapExplorationUnit(Robot robot, MovementUnit movement) {

    frontSensor = robot.getDistanceSensor("front");
    frontSensor.enable(1);

    rearSensor = robot.getDistanceSensor("rear");
    rearSensor.enable(1);

    sideLeftSensor = robot.getDistanceSensor("sideLeft");
    sideLeftSensor.enable(1);

    sideRightSensor = robot.getDistanceSensor("sideRight");
    sideRightSensor.enable(1);

    index = new ArrayList<Double>();
    index.add(-6.0);
    index.add(-4.5);
    index.add(-3.0);
    index.add(-1.5);
    index.add(0.0);
    index.add(1.5);
    index.add(3.0);
    index.add(4.5);
    index.add(6.0);

    // REAL MAP BUILDING 
    for(int i = 0; i < 9; i++) {
        for(int j = 0; j < 9; j++) {
            realMap[i][j] = new Cell(index.get(j), index.get(i), 'S', false);       //IMPOSTARE A S 
        }
    }

    grid = new Grid(mapDim, mapDim, realMap);

    this.movement = movement;

  }


  public void startMapExploration(double [] start) {

    Cell visitCell = toCellFormat(start);
    
    //INSIEME DI FRONTIERA DOVE PRENDERE LA PROSSIMA CELLA DA VISITARE
    List<Cell> nextPossibleCell = new ArrayList<Cell>();  

    nextPossibleCell.add(visitCell);

    while(nextPossibleCell.size() != 0) {

      visitCell = nextPossibleCell.get(0);
      nextPossibleCell.clear();

      movement.goToPoint(movement.cellPosition, toDoubleFormat(visitCell));


      visitCell.visited = true;

      double frontValue = frontSensor.getValue();
      double rearValue = rearSensor.getValue();
      double sideLeftValue = sideLeftSensor.getValue();
      double sideRightValue = sideRightSensor.getValue();

      Cell frontCell = getFrontCell();
      if(frontCell != null) {
        if(frontValue >= 1.5) {
          frontCell.status = 'F';
          if(frontCell.visited != true) {
            nextPossibleCell.add(frontCell);
          }
        } else {
          frontCell.status = 'O';
        }
      }

      Cell rearCell = getRearCell();
      if(rearCell != null) {
        if(rearValue >= 1.5) {
          rearCell.status = 'F';
          if(rearCell.visited != true) {
            nextPossibleCell.add(rearCell);
          }
        } else {
          rearCell.status = 'O';
        }
      }

      Cell sideRightCell = getSideRightCell();
      if(sideRightCell != null) {
        if(sideRightValue >= 1.5) {
          sideRightCell.status = 'F';
          if(sideRightCell.visited != true) {
            nextPossibleCell.add(sideRightCell);
          }
        } else {
          sideRightCell.status = 'O';
        }        
      }

      Cell sideLeftCell = getSideLeftCell();
      if(sideLeftCell != null) {
        if(sideLeftValue >= 1.5) {
          sideLeftCell.status = 'F';
          if(sideLeftCell.visited != true) {
            nextPossibleCell.add(sideLeftCell);
          }
        } else {
          sideLeftCell.status = 'O';
        }
      }

      System.out.println("[RESCUE_ROBOT]: MAP SITUATION: ...");
      printStatusMap();

      if(getUnknownCells().size() == 0) {
        grid.updateGrid(realMap);
        return ;
      }
    }

    // CORREZIONE DELLA POSIZIONE ANDANDO DA DOVE SI STIMA ESSERE ODOMETRICAMENTE ALLA CELLA IN CUI SI DOVREBBE ESSERE
    System.out.println("[RESCUE_ROBOT]: CORRECTING POSITION...");  
    movement.goToPoint(movement.estimatedPosition, movement.cellPosition);

    grid.updateGrid(realMap);

    List<Cell> unknownCells = new ArrayList<Cell>();
    unknownCells = getUnknownCells();

    List<Cell> neighbours;

    List<Cell> nextCells = new ArrayList<Cell>(); 
    double[] nextCell = new double[] {-7,-7};

    if(unknownCells.size() != 0) {

      for(int i = 0; i < unknownCells.size(); i++) {

        neighbours = getNeighbours(unknownCells.get(i));

        if(neighbours.size() == 0) {
          unknownCells.get(i).status = 'O';
        } else {

          for(int j = 0; j < neighbours.size(); j++) {

            if(neighbours.get(j).status == 'F' && neighbours.get(j).visited != true) {
              nextCells.add(neighbours.get(j));
            }
          }
        }
      }

      if(nextCells.size() != 0) {
        nextCell[0] = nextCells.get(0).x;
        nextCell[1] = nextCells.get(0).y;

        movement.moveTo(nextCell, grid);
        startMapExploration(nextCell);
      }
    }

  }

  public List<Cell> getUnknownCells() {
    
    List<Cell> unknown = new ArrayList<Cell>();

    for(int i = 0; i < mapDim; i++) {
      for(int j = 0; j < mapDim; j++) {
        if(realMap[i][j].status == 'S') {
          unknown.add(realMap[i][j]);
        }
      }
    }
    return unknown;
  }

  public List<Cell> getNeighbours(Cell cell) {

    List<Cell> neighbour = new ArrayList<Cell>();

    int indexI = -7;
    int indexJ = -7;

    for(int i = 0; i < mapDim; i++) {
      for(int j = 0; j < mapDim; j++) {
        if(realMap[i][j].x ==  cell.x && realMap[i][j].y == cell.y ) {
          indexI = i;
          indexJ = j;
        }
      }
    }

    if(indexI > 0) {
      neighbour.add(realMap[indexI-1][indexJ]);
    }

    if(indexI < mapDim-1) {
      neighbour.add(realMap[indexI+1][indexJ]);
    }
    if(indexJ > 0) {
      neighbour.add(realMap[indexI][indexJ-1]);
    }
    if(indexJ < mapDim-1) {
      neighbour.add(realMap[indexI][indexJ+1]);
    }
    
    return neighbour;
  }

  // Metodo che date le coordinate in double restituisce l'oggetto Cella
  public Cell toCellFormat(double[] pos) {

    for(int i = 0; i < mapDim; i++) {
      for(int j = 0; j < mapDim; j++) {
        if(realMap[i][j].x ==  pos[0] && realMap[i][j].y == pos[1]) {
          return realMap[i][j];
        }
      }
    }
    return null;
  }

  public double[] toDoubleFormat(Cell cell) {

    return new double[] { cell.x, cell.y };

  }

  //Cella a cui punta il front sensor
  private Cell getFrontCell() {

    double[] coordCell = new double[]{movement.cellPosition[0], movement.cellPosition[1]};
    double theta = toRound(movement.actualTheta);


    if( (theta == 0 || theta == 360) && coordCell[1] > -6) {

      coordCell[0] = coordCell[0];
      coordCell[1] = coordCell[1] - cellLen;

      return toCellFormat(coordCell);

    }

    if( theta == 90 && coordCell[0] < 6) {
      
      coordCell[0] = coordCell[0] + cellLen;
      coordCell[1] = coordCell[1];

      return toCellFormat(coordCell);
    }

    if (theta == 180 && coordCell[1] < 6 ) {

      coordCell[0] = coordCell[0];
      coordCell[1] = coordCell[1] + cellLen;

      return toCellFormat(coordCell);
    }

    if (theta == 270 && coordCell[0] > -6) {
      
      coordCell[0] = coordCell[0] - cellLen;
      coordCell[1] = coordCell[1];

      return toCellFormat(coordCell); 
    }

    return null ;
  
  }

  //Cella a cui punta il rear sensor
  private Cell getRearCell() {

    double[] coordCell = new double[]{movement.cellPosition[0], movement.cellPosition[1]};
    
    double theta = toRound(movement.actualTheta);

    if((theta == 0 || theta == 360) && coordCell[1] < 6 ) {

      coordCell[0] = coordCell[0];
      coordCell[1] = coordCell[1] + cellLen;

      return toCellFormat(coordCell);
    }

    if( theta == 90 && coordCell[0] > -6) {
      
      coordCell[0] = coordCell[0] - cellLen;
      coordCell[1] = coordCell[1];

      return toCellFormat(coordCell);
    }

    if (theta == 180 && coordCell[1] > -6) {

      coordCell[0] = coordCell[0];
      coordCell[1] = coordCell[1] - cellLen;

      return toCellFormat(coordCell);
    }

    if (theta == 270 && coordCell[0] < 6) {
      
      coordCell[0] = coordCell[0] + cellLen;
      coordCell[1] = coordCell[1];

      return toCellFormat(coordCell); 
    }

    return null ;
  
  }

  // Cella a cui punta il sideRightSensor
  private Cell getSideRightCell() {
    
    double[] coordCell = new double[]{movement.cellPosition[0], movement.cellPosition[1]};
    
    double theta = toRound(movement.actualTheta);

    if((theta == 0 || theta == 360) && coordCell[0] < 6 ) {

      coordCell[0] = coordCell[0] + cellLen;
      coordCell[1] = coordCell[1];

      return toCellFormat(coordCell);
    }

    if( theta == 90 && coordCell[1] < 6) {
      
      coordCell[0] = coordCell[0];
      coordCell[1] = coordCell[1] + cellLen;

      return toCellFormat(coordCell);
    }

    if (theta == 180 && coordCell[0] > -6) {

      coordCell[0] = coordCell[0] - cellLen;
      coordCell[1] = coordCell[1];

      return toCellFormat(coordCell);
    }

    if (theta == 270 && coordCell[1] > -6) {
      
      coordCell[0] = coordCell[0];
      coordCell[1] = coordCell[1] - cellLen;

      return toCellFormat(coordCell); 
    }

    return null ;

  }

  // Cella a cui punta il sideRightSensor
  private Cell getSideLeftCell() {

    double[] coordCell = new double[]{movement.cellPosition[0], movement.cellPosition[1]};
    
    double theta = toRound(movement.actualTheta);

    if( (theta == 0 || theta == 360) && coordCell[0] > -6) {

      coordCell[0] = coordCell[0] - cellLen;
      coordCell[1] = coordCell[1];

      return toCellFormat(coordCell);
    }

    if( theta == 90 && coordCell[1] > -6) {
      
      coordCell[0] = coordCell[0];
      coordCell[1] = coordCell[1] - cellLen;

      return toCellFormat(coordCell);
    }

    if (theta == 180 && coordCell[0] < 6 ) {

      coordCell[0] = coordCell[0] + cellLen;
      coordCell[1] = coordCell[1];

      return toCellFormat(coordCell);
    }

    if (theta == 270 && coordCell[1] < 6) {
      
      coordCell[0] = coordCell[0];
      coordCell[1] = coordCell[1] + cellLen;

      return toCellFormat(coordCell); 
    }

    return null ;
  }

  public void printStatusMap() {
    char visit;
    System.out.println(" -6     -4.5    -3     -1.5     0    1.5     3     4.5     6     ");
    for(int i = 0; i < mapDim; i++) {
      for(int j = 0; j < mapDim; j++) {
        if(realMap[i][j].visited == true) {
          visit = '*';
        } else {
          visit = ' ';
        }
        System.out.print(" (" + realMap[i][j].status + "," + visit + ") ");
      }
      System.out.println("");
    }
  }

  public List<double[]> getPath(double[] start, double[] end) {
    return PathFinding.findPath(grid, grid.DoubleToNode(start), grid.DoubleToNode(end));
  }

  private double toRound(double theta) {

    if(theta >= 0 && theta < 3) {
      return 0;
    }

    if(theta <= 360 && theta > 357) {
      return 0;
    }

    if(theta >= 88 && theta <= 92) {
      return 90;
    }

    if(theta >= 177 && theta <= 182) {
      return 180;
    }

    if(theta >= 268 && theta < 272) {
      return 270;
    }

    return -1;
  }

}

