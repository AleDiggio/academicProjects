package Controller;

import com.cyberbotics.webots.controller.*;
import java.util.*;
import java.lang.*;

import Units.*;
import Utils.Cell;


public class RescueRobotController {
  
  private Supervisor robot;

  private MovementUnit movement;
  private MapExplorationUnit mapExploration;
  private CommunicationUnit communication;

  private int channel;

  Node rootNode;
  Field childrenField;

  public RescueRobotController() {

    robot = new Supervisor();

    rootNode = robot.getRoot();
    childrenField = rootNode.getField("children");

    movement = new MovementUnit(robot);
    mapExploration = new MapExplorationUnit(robot, movement);
    communication = new CommunicationUnit(robot, mapExploration);

  }


  public void run() {

    System.out.println("[RESCUE_ROBOT]: MAP EXPLORATION....");

    mapExploration.startMapExploration(movement.startPosition);

    System.out.println(" *** MAP EXPLORATION COMPLETED *** ");

    System.out.println("[RESCUE_ROBOT]: BACK TO BASE...");

    movement.moveTo(movement.startPosition, mapExploration.grid);

    spawnLostRobots();

    mapExploration.printStatusMap();

    System.out.println("[RESCUE_ROBOT]: SWITCH CHANNEL TO LISTEN HELP REQUEST...");
    
    for(int i = 0; i < communication.emitters.size(); i++) {
      channel = i+2;
      communication.waitForNeedOfHelp(communication.emitters.get(i), communication.receivers.get(i), channel);
    }

    
  }

  //Metodo per fare spawnare i robot in punti casuali della mappa
  public void spawnLostRobots() {

    List<double[]> coordLost = new ArrayList<double[]>();

    List<double[]> targetPositions = new ArrayList<double[]>();
    targetPositions.add(new double[]{6, -3});
    targetPositions.add(new double[]{6, 6});
    targetPositions.add(new double[]{-6, 0});

    List<double[]> forbiddenCord = new ArrayList<double[]>();
    forbiddenCord.add(new double[]{-6, 6});
    forbiddenCord.add(targetPositions.get(0));
    forbiddenCord.add(targetPositions.get(1));
    forbiddenCord.add(targetPositions.get(2));


    int flag = 0;

    double coordX = 0;
    double coordY = 0;
    double[] startPos = new double[]{coordX, coordY};
    
    for(int i = 0; i < 3; i++) {
      do {
        flag = 0;
        int indexCoord1 = (int)(Math.random() * (8 + 1));
        int indexCoord2 = (int)(Math.random() * (8 + 1));

        coordX = mapExploration.index.get(indexCoord1);
        coordY = mapExploration.index.get(indexCoord2);
        startPos = new double[]{coordX, coordY};

        if(mapExploration.toCellFormat(startPos).status != 'F') {
          flag = 1;
        }

        if(flag == 0) {  
          for(int k = 0; k < forbiddenCord.size(); k++) {
            if(forbiddenCord.get(k)[0] == coordX && forbiddenCord.get(k)[1] == coordY) {
              flag = 1;
            }
          }
        } 
      } while(flag == 1);
      mapExploration.toCellFormat(startPos).status = 'R';
      mapExploration.grid.updateGrid(mapExploration.realMap);
      coordLost.add(new double[]{coordX,0.095, coordY});
      List<double[]> path = mapExploration.getPath(startPos, targetPositions.get(i));
      for(int j = 0; j < path.size(); j++) {
        forbiddenCord.add(path.get(j));
      }
    }

    //Import Gold
    childrenField.importMFNode(-1, "LostGold.wbo");
    Node lostGold = robot.getFromDef("LostGold");
    Field translationField = lostGold.getField("translation");
    translationField.setSFVec3f(coordLost.get(0));

    //Import Blue
    childrenField.importMFNode(-1, "LostBlue.wbo");
    Node lostBlue = robot.getFromDef("LostBlue");
    translationField = lostBlue.getField("translation");
    translationField.setSFVec3f(coordLost.get(1));

    //Import Green
    childrenField.importMFNode(-1, "LostGreen.wbo");
    Node lostGreen = robot.getFromDef("LostGreen");
    translationField = lostGreen.getField("translation");
    translationField.setSFVec3f(coordLost.get(2));

  }

}



