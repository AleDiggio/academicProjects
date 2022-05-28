package Units;

import java.util.*;
import com.cyberbotics.webots.controller.*;

import Utils.*;

public class CommunicationUnit {

  // Comunicazione
  private Emitter emitter2;
  private Receiver receiver2;
  private Emitter emitter3;
  private Receiver receiver3;
  private Emitter emitter4;
  private Receiver receiver4;
  public List<Emitter> emitters;
  public List<Receiver> receivers;

  private Robot robot;
  private MapExplorationUnit mapExploration;


  public CommunicationUnit(Robot robot, MapExplorationUnit mapExploration) {

    emitter2 = robot.getEmitter("emitter2");
    receiver2 = robot.getReceiver("receiver2");
    emitter3 = robot.getEmitter("emitter3");
    receiver3 = robot.getReceiver("receiver3");
    emitter4 = robot.getEmitter("emitter4");
    receiver4 = robot.getReceiver("receiver4");
    receiver2.enable(1);
    receiver3.enable(1);
    receiver4.enable(1);

    emitters = new ArrayList<>();
    emitters.add(emitter2);
    emitters.add(emitter3);
    emitters.add(emitter4);

    receivers = new ArrayList<>();
    receivers.add(receiver2);
    receivers.add(receiver3);
    receivers.add(receiver4);

    this.robot = robot;
    this.mapExploration = mapExploration;

  }

  public void waitForNeedOfHelp(Emitter emitter, Receiver receiver, int channel) {

    /* Il valore -7 per le coordinate serve a capire quando effettivamente si stanno ricevendo
     * coordinate reali dai LostRobot.
     *
     * Ogni ricevitore ha un suo buffer da dove estrarre i pacchetti contenenti i dati ricevuti.
     *
    */
    
    String receivedMessage = "empty";
    double[] receivedCoord = {-7, -7};

    while(!receivedMessage.equals("HELP")) {   
      receivedMessage = receiveMessage(receiver);
    }

    System.out.println("[RESCUE_ROBOT]: HELP CALL RECEIVED...");
    System.out.println("[RESCUE_ROBOT]: LOST SEND ME YOUR LOCATION...");
    sendMessage("LOST.LOCATION", emitter); 

    while(receivedCoord[0] == -7) {   
      System.out.println("[RESCUE_ROBOT]: COORDINATES RECEIVED...");
      receivedCoord = receiveCoord(receiver);
    }

    double[] coordLost = new double[] {receivedCoord[0], receivedCoord[1]};

    //Date le coordinate segnare con R quella cella
    Cell lostCell = mapExploration.toCellFormat(coordLost);
    lostCell.status = 'R';     

    receivedCoord[0] = -7;
    receivedCoord[1] = -7;


    System.out.println("[RESCUE_ROBOT]: LOST ON CHANNEL "+ channel + "SEND ME YOUR TARGET COORDINATES...");
    sendMessage("TARGET.LOCATION", emitter); 

    while(receivedCoord[0] == -7) {   
      System.out.println("[RESCUE_ROBOT]: LOST ON CHANNEL "+ channel + " SEND ME YOUR TARGET COORDINATES...");
      receivedCoord = receiveCoord(receiver);
    }

    double[] coordTarget = new double[] {receivedCoord[0], receivedCoord[1]};

    System.out.println("[RESCUE_ROBOT]: ELABORATING PATH...");
    List<double[]> path = PathFinding.findPath(mapExploration.grid, mapExploration.grid.DoubleToNode(coordLost), mapExploration.grid.DoubleToNode(coordTarget));  //********
    
    System.out.println("[RESCUE_ROBOT]: SENDING COORDINATES...");
    for(int i = 0; i < path.size(); i++) {
      sendCoord(path.get(i),emitter);
    }


    double[] endPathCoord = {8,8};
    sendCoord(endPathCoord, emitter);

    mapExploration.grid.updateGrid(mapExploration.realMap);

  }

  public void sendCoord(double[] coord, Emitter emitter) {

    String message = Double.toString(coord[0]) + " " + Double.toString(coord[1]);
    sendMessage(message, emitter);

  }

  public double[] receiveCoord(Receiver receiver) {

    double[] coord = {-7, -7};
    String message = receiveMessage(receiver);
    if(message.equals("empty")) {
      return coord;
    }
    String[] coordinates = message.split(" ");
    coord[0] = Double.parseDouble(coordinates[0]);
    coord[1] = Double.parseDouble(coordinates[1]);


    return coord;
  }


  public void sendMessage(String message, Emitter emitter) {
    
    byte[] byteMess = message.getBytes();
    emitter.send(byteMess);

    robot.step(1); 

  }

  public String receiveMessage(Receiver receiver) {

    String message = "empty";
    if(receiver.getQueueLength() != 0) {
      message = new String(receiver.getData());
      receiver.nextPacket();
    }
    
    robot.step(1);

    return message;
  }

}

