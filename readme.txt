$GHV NDI Controller
GHV NDI controller is a matlab/simulink CLAW simulation package for that simulates a Generic Hypersonic Vehicle being controlled by a Nonlinesr Dynamic Inversion controller

$$ Contents
This package contains the following files:

top_level_sim.slx
Primary execution file. Contains the simulink architecture required to run the simulator.

top_level_sim_init.m
Initialization file called automatically before running the simulink model. Contains simulator and CLAW parameters for simulator configuration.

Getaeroforcesmoments.m
Helper function for calculating forces and moments on the vehicle body.

Getaerocoefficients.m
Helper function for calculating aero coefficients of the vehicle at any given state.

/lib
Contains various helper functions used in the model that assist with sim configuration and data processing.


$$
The GHV NDI Controller is executed through the top_level_sim.slx file. To run the simulator, open this file and run the simulink model.  Inputs to the controller can be adjusted within the CommandProcessing module found within this file.

Vehicle parameters, CLAW settings, and initial conditions can be configured through the top_level_sim_init.m file. 


**Service DNS**
**`https://v.that1team.com:443` **

http://thelads.ddns.net:80
NP6UuqzUh4
z8SxFZ9rFq