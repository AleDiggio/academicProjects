package Units;

import java.util.*;
import com.cyberbotics.webots.controller.*;
import java.lang.*;

import Utils.*;

public class MovementUnit {

  public double[] startPosition = {-6,6};  // (X,Z)
  public double[] estimatedPosition = new double[]{startPosition[0], startPosition[1]}; 
  public double[] cellPosition = new double[]{startPosition[0], startPosition[1]};

  public double actualTheta = 90;
  private final double maxVelocity = 9;

  private Motor leftMotor;
  private Motor rightMotor;

  private PositionSensor leftSensor;
  private PositionSensor rightSensor;

  private Compass compass;

  private Robot robot;

  public MovementUnit(Robot robot) {

    leftMotor = robot.getMotor("wheel_left_joint");
    rightMotor = robot.getMotor("wheel_right_joint");

    leftSensor = robot.getPositionSensor("wheel_left_joint_sensor");
    rightSensor = robot.getPositionSensor("wheel_right_joint_sensor");
    leftSensor.enable(1);
    rightSensor.enable(1);

    compass = robot.getCompass("compass");
    compass.enable(1);

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

    leftMotor.setPosition(Double.POSITIVE_INFINITY);
    rightMotor.setPosition(Double.POSITIVE_INFINITY);

    leftMotor.setAcceleration(-1);
    rightMotor.setAcceleration(-1);


    double[] values = calcValues(startPosition, endPosition) ;

    double trasl = values[0];
    double rot = values[1];

    double actAngle = actualTheta;

    double finalAngle = mod(actAngle + rot);

    if ((actAngle > 359 && actAngle < 360) && (finalAngle > 0 && finalAngle < 1) ) {

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
          } while(actAngle > finalAngle + 0.72) ;
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

    //go forward
    while(attPos < finalPos) {
      rightMotor.setVelocity(0.5 * maxVelocity);
      leftMotor.setVelocity(0.5 * maxVelocity);
      robot.step(1);
      attPos = getPosVal();
    }

    leftMotor.setVelocity(0);
    rightMotor.setVelocity(0);
    robot.step(1);

    // POSIZIONE STIMATA TRAMITE ODOMETRIA
    estimatedPosition[0] = estimatedPosition[0] + ( -trasl * Math.cos( Math.toRadians(actualTheta) + (Math.PI)/2) );
    estimatedPosition[1] = estimatedPosition[1] + ( -trasl * Math.sin( Math.toRadians(actualTheta) + (Math.PI)/2) );
    
    //POSIZIONE PREVISTA DELLA CELLA 
    cellPosition = endPosition;

  }

  public void moveTo(double[] target, Grid grid) {
      
    List<double[]> path = PathFinding.findPath(grid, grid.DoubleToNode(cellPosition), grid.DoubleToNode(target));

    for(int i = 0; i < path.size(); i++) {
      goToPoint(cellPosition, path.get(i));
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

  private double mod(double val) {

      double result = val % 360;
      if (result < 0)
      {
          result += 360;
      }
      return result;
  }
}

