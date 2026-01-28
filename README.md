Space Cadet is a seven-segment display based game for the Cyclone IV E EP4CE115F29C7 FPGA Board.
The player controls a ship using a toggle switch to avoid randomly generated obstacles displayed on seven-segment displays.
Inputs (controls): KEY[1] (start), SW[6] (up/down control)
Outputs: HEX displays, LEDR bar (specifically LEDR 6-15)

====Features====

*Finite State Machine (FSM) game control--
  Controls game start, run, and game-over behavior.

*Timer/FSM-driven scoring and difficulty scaling
  Game speed and score increases every 20 seconds of survival time, represented by the LED bar.

*Pseudorandom obstacle positioning
  Uses a Linear Feedback Shift Register (LFSR) to generate obstacle positions.

*Seven-segment display animation
  Obstacles shift across the display to simulate movement.

*Collision detection
  Detects overlap between player position and obstacle patterns.

====Tools Used====

*Quartus II – Synthesis and FPGA programming

*ModelSim – Simulation and functional verification

*SystemVerilog – Hardware description language
