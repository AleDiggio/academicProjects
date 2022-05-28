package LostUnits;

import java.util.*;
import com.cyberbotics.webots.controller.*;
import java.lang.*;

public class MoveLostUnit {

  public double[] startPosition = {Double.NaN, Double.NaN}; 
  public double[] cellPosition = {Double.NaN, Double.NaN}; 
  public double[] targetPosition = {Double.NaN,Double.NaN};

  private double actualTheta = 90;
  private final double maxVelocity = 9;

  public String name;
  public int counterWait;

  public int flagError;
  public int flagMoved;

  public Motor leftMotor;
  public Motor rightMotor;

  private DistanceSensor frontSensor;
  private DistanceSensor prioritySensor;

  private PositionSensor leftSensor;
  private PositionSensor rightSensor;

  private Compass compass;

  private GPS gps; 

  private Robot robot;

  public MoveLostUnit(Robot robot, String name) {

    leftMotor = robot.getMotor("wheel_left_joint");
    rightMotor = robot.getMotor("wheel_right_joint");

    frontSensor = robot.getDistanceSensor("front");
    frontSensor.enable(1);
    prioritySensor = robot.getDistanceSensor("priority");
    prioritySensor.enable(1);

    leftSensor = robot.getPositionSensor("wheel_left_joint_sensor");
    rightSensor = robot.getPositionSensor("wheel_right_joint_sensor");
    leftSensor.enable(1);
    rightSensor.enable(1);

    compass = robot.getCompass("compass");
    compass.enable(1);

    gps = robot.getGPS("gps");
    gps.enable(1);

    flagError = 0;
    flagMoved = 0;
    this.name = name;
    counterWait = initCounter();

    this.robot = robot;

  }

  private double[] calcValues(double[] startPosition, double[] endPosition) {

    double startPositionX = startPosition[0];
    double startPositionY = startPosition[1];
    double startPositionTheta = Math.toRadians(actualTheta);


    double endPositionX = endPosition[0];
    double endPositionY = endPosition[1];

    double[] values = {0, 0}; 

    double trasl = Math.sqrt( Math.pow((endPositionX - startPositionX), 2 ) + Math.pow((endPositionY - startPositionY),2) ) ;


    double rot1 = (Math.atan2( endPositionY - startPositionY, endPositionX - startPositionX ) - startPositionTheta) + (Math.PI)/2;

    values[0] = trasl;  //in cm * 100
    values[1] = Math.toDegrees(rot1);

    return values;

  }

  public void goToPoint(double[] startPosition, double[] endPosition) {

    if(startPosition[0] == endPosition[0] && startPosition[1] == endPosition[1]) {
      leftMotor.setVelocity(0);
      rightMotor.setVelocity(0);
      robot.step(1);

      return;
    }

    flagError = -1;
    flagMoved = -1;

    leftMotor.setPosition(Double.POSITIVE_INFINITY);
    rightMotor.setPosition(Double.POSITIVE_INFINITY);

    leftMotor.setAcceleration(-1);
    rightMotor.setAcceleration(-1);

    double[] values = calcValues(startPosition, endPosition) ;

    double trasl = values[0];
    double rot = values[1];

    double actAngle = actualTheta;

    double finalAngle = (actAngle + rot) % 360;
    if(finalAngle < 0) {
      finalAngle += 360;
    }

    if ((actAngle > 358.8 && actAngle < 360) && (finalAngle > 0 && finalAngle < 1.2) ) {

    } else {

      if(Math.abs(finalAngle - actAngle) < 0.5 ) {

      } else {
        if(actAngle > finalAngle) {
          //turn left
          do {
            leftMotor.setVelocity(-0.1 * maxVelocity);
            rightMotor.setVelocity(0.1 * maxVelocity);
            robot.step(1); 
            actAngle = getNorthDegrees();
          } while(actAngle > finalAngle + 0.7) ;
          leftMotor.setVelocity(0);
          rightMotor.setVelocity(0);
          robot.step(1);
        } 

        if(actAngle < finalAngle) {
          //turn right
          do {
            leftMotor.setVelocity(0.1 * maxVelocity);
            rightMotor.setVelocity(-0.1 * maxVelocity);
            robot.step(1);
            actAngle = getNorthDegrees();
          } while(actAngle < finalAngle - 0.7) ;
          leftMotor.setVelocity(0);
          rightMotor.setVelocity(0);
          robot.step(1);
        }
      }
    }

    actualTheta = actAngle;

    double attPos;
    if(Double.isNaN(getPosVal())) {
      attPos = 0;
    } else {
      attPos = getPosVal();
    }

    double finalPos = trasl + attPos;

    //Check se un altro robot usa la cella
    while(frontSensor.getValue() < 1.47) {
      //wait
      if(name.equals("GOLD")) {
      }
      counterWait -= 1;
      robot.step(1);
      if(counterWait == 0) {
        flagError = 1;
        flagMoved = 0;
        return ;
      }
    }

    counterWait = initCounter();
    double counter = 2;

    //go forward
    while(attPos < finalPos) {
      //Check se un altro robot sta per arrivare sulla cella
      if(prioritySensor.getValue() < 0.7  && counter != 0) {
        //wait
      if(name.equals("GOLD")) { 
      }
        for(int i = 0; i < 200; i++) {
          rightMotor.setVelocity(0);
          leftMotor.setVelocity(0);
          robot.step(1);
        }

        counter -= 1;
      } else {
          while(frontSensor.getValue() < 0.2) {
            //Check se durante il movimento stiamo per collidire con un altro robot
            if(name.equals("GOLD")) {
            }
            rightMotor.setVelocity(0);
            leftMotor.setVelocity(0);
            counterWait -= 1;
            robot.step(1);
            if(counterWait == 0) {
              cellPosition[0] = gps.getValues()[0];
              cellPosition[1] = gps.getValues()[2];
              flagError = 1;
              flagMoved = 1;
              return ;
            }
          }
      }

      counterWait = initCounter();
      rightMotor.setVelocity(0.6 * maxVelocity);
      leftMotor.setVelocity(0.6 * maxVelocity);
      robot.step(1);
      attPos = getPosVal();
    }

    leftMotor.setVelocity(0);
    rightMotor.setVelocity(0);
    robot.step(1);
    
    cellPosition = endPosition;
  }

  public void findStartPosition() {

    // Tramite GPS calcola la posizione dove si trova robot disperso
    while(Double.isNaN(cellPosition[0]) || Double.isNaN(cellPosition[1])) {
      cellPosition[0] = gps.getValues()[0];
      cellPosition[1] = gps.getValues()[2];
      robot.step(1);
    }
    cellPosition[0] = roundCoord(cellPosition[0]);
    cellPosition[1] = roundCoord(cellPosition[1]);

    startPosition[0] = roundCoord(cellPosition[0]);
    startPosition[1] = roundCoord(cellPosition[1]);

  }

  public void findTargetPosition() {

    if(name.equals("GREEN")) {
      targetPosition[0] = -6;
      targetPosition[1] = 0;
    }

    if(name.equals("BLUE")) {
      targetPosition[0] = 6;
      targetPosition[1] = 6;
    }

    if(name.equals("GOLD")) {
      targetPosition[0] = 6;
      targetPosition[1] = -3;
    }

  }

  private double getNorthDegrees() {
    double[] coord = compass.getValues();

    double rad = Math.atan2(coord[0], coord[2]);
    double bearing = (rad - 1.5708) / Math.PI * 180.0 ;

    if (bearing < 0.0) {
      bearing += 360.0;
    }

    return bearing;
  }

  private double getPosVal() {
    double val = leftSensor.getValue();
    double tiagoRadius = 0.0985;

    return (tiagoRadius * val);
  }


  private double roundCoord(double val) {
    double roundVal = (double) Math.round(val);

    if(roundVal == 4 || roundVal == 5) {
      roundVal = 4.5;
    }

    if(roundVal == -4 || roundVal == -5) {
      roundVal = -4.5;
    }

    if(roundVal == 1 || roundVal == 2) {
      roundVal = 1.5;
    }

    if(roundVal == -1 || roundVal == -2) {
      roundVal = -1.5;
    }

    return roundVal;
  }

  public int initCounter() {
    
    if(name.equals("GREEN")) {
      return 1000;
    }

    if(name.equals("BLUE")) {
      return 1800;
    }

    return 400;

  }

}

