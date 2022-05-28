package LostUnits;

import java.util.*;
import com.cyberbotics.webots.controller.*;

public class CommLostUnit {

  private List<double[]> path;
  private int indexPath;

  // Comunicazione
  private Emitter emitter;
  private Receiver receiver;

  private Robot robot;
  private MoveLostUnit movement;

  private int deadLockCounter;


  public CommLostUnit(Robot robot, MoveLostUnit movement) {

    emitter = robot.getEmitter("emitter");
    receiver = robot.getReceiver("receiver");
    receiver.enable(1);

    this.robot = robot;
    this.movement = movement;

    indexPath = 0;

    deadLockCounter = 0;
    
  }

  public void sendNeedOfHelp() {

    String receivedMessage = "empty";
    double[] receivedCoord = {-7, -7};
    List<double[]> path = new ArrayList<double[]>();

    sendMessage("HELP"); //1

    while(!receivedMessage.equals("LOST.LOCATION")) { 
      receivedMessage = receiveMessage();
    }

    System.out.println("[LOST_ROBOT-" + movement.name + "]" + ": SENDING MY COORDINATES...");
    sendCoord(movement.cellPosition); 

    while(!receivedMessage.equals("TARGET.LOCATION")) { 
      receivedMessage = receiveMessage();
    }

    System.out.println("[LOST_ROBOT-" + movement.name + "]" + ": SENDING TARGET COORDINATES...");
    sendCoord(movement.targetPosition); 


    // Ricevo le coordinate del percorso generato da Rescue Robot
    while(receivedCoord[0] != 8.0) {  
      receivedCoord = receiveCoord();
      if(receivedCoord[0] != -7.0 && receivedCoord[0] != 8 ) {
        path.add(receivedCoord);
        System.out.println("[LOST_ROBOT-" + movement.name + "]" + ": COORDINATE RECEIVED: " + receivedCoord[0] + " ," + receivedCoord[1]);       
      }
    }

    if(path.size() == 0) {
      System.out.println("[LOST_ROBOT-" + movement.name + "]" + ": ERROR ON RECEIVED PATH !!!! ");
      System.exit(1);
    }

    // Vado nelle coordinate del percorso
    for (int i = 0; i < path.size(); i++) {
      double[] val = new double[]{path.get(i)[0], path.get(i)[1]};
      movement.goToPoint(movement.cellPosition, val);
      if(movement.flagMoved == 1) {
        indexPath = i - 1;
      }
      if(movement.flagMoved == 0) {
        indexPath = i - 2;
      }
      if(movement.flagError == 1) {
        break;
      }
    }

    while(movement.flagError == 1) {
      deadLockCounter += 1;
      System.out.println("[LOST_ROBOT-" + movement.name + "]" + ": ERROR!!! - BACK TO BASE");
      movement.initCounter();
      for(int i = indexPath; i >= 0; i--) {
        movement.goToPoint(movement.cellPosition, path.get(i));
      }
      movement.goToPoint(movement.cellPosition,movement.startPosition);
      //Attesa una volta arrivata alla base
      for(int i = 0; i < movement.counterWait/5; i++) {
        movement.leftMotor.setVelocity(0);
        movement.rightMotor.setVelocity(0);
        robot.step(1);
      }
      //Riprovo ad andare al target
      movement.flagError = 0;
      movement.flagMoved = 0;
      for(int i = 0; i < path.size(); i++) {
        double[] val = new double[]{path.get(i)[0], path.get(i)[1]};
        movement.goToPoint(movement.cellPosition, val);
        if(movement.flagMoved == 1) {
          indexPath = i - 1;
        }
        if(movement.flagMoved == 0) {
          indexPath = i - 2;
        }
        if(movement.flagError == 1) {
          break;
        }
      }

      if(deadLockCounter == 5) {
        System.out.println("[LOST_ROBOT-" + movement.name + "]" + ": ERROR!!! - IMPOSSIBILE TO REACH TARGET!!!");
        System.exit(1);
      }
    }

    if(movement.name.equals("BLUE")) {
      movement.goToPoint(movement.cellPosition, new double[] {6, 7.5});
    } 

    if(movement.name.equals("GREEN")) {
      movement.goToPoint(movement.cellPosition, new double[] {-7.5, 0});
    }

    if(movement.name.equals("GOLD")) {
      movement.goToPoint(movement.cellPosition, new double[] {7.5, -3});
    }

    System.out.println("[LOST_ROBOT-" + movement.name + "]" + ": ARRIVED TO TARGET - THANK YOU!....");

  }

  private void sendCoord(double[] coord) {

    String message = Double.toString(coord[0]) + " " + Double.toString(coord[1]);
    sendMessage(message);

  }

  private double[] receiveCoord() {

    double[] coord = {-7, -7};
    String message = receiveMessage();

    if(message.equals("empty")) {
      return coord;
    }
    String[] coordinates = message.split(" ");
    coord[0] = Double.parseDouble(coordinates[0]);
    coord[1] = Double.parseDouble(coordinates[1]);

    return coord;
  }


  private void sendMessage(String message) {
    
    byte[] byteMess = message.getBytes();
    emitter.send(byteMess);

    robot.step(1); 

  }

  private String receiveMessage() {

    String message = "empty";
    if(receiver.getQueueLength() != 0) {
      message = new String(receiver.getData());
      receiver.nextPacket();
    }
    
    robot.step(1);

    return message;

  }

}

