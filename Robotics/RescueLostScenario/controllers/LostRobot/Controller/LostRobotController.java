package Controller;

import com.cyberbotics.webots.controller.*;
import java.util.*;
import java.lang.*;
import java.util.concurrent.TimeUnit ;

import LostUnits.*;

public class LostRobotController {

  private String name;

  private Robot robot;

  private MoveLostUnit movement;
  private CommLostUnit communication;

  public LostRobotController() {

    robot = new Robot();

    name = robot.getName();

    movement = new MoveLostUnit(robot, name);
    communication = new CommLostUnit(robot, movement);
  }

  public void run() {

    movement.findStartPosition();

    movement.findTargetPosition();

    communication.sendNeedOfHelp();
  } 
}






