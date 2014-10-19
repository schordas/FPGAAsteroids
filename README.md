FPGA Asteroids
==============

Hardware and Tools
------------------
To run this program and play the game you will need:
  * A Digilent Spartan-6 FPGA Board
  * A PmodJSTK joy stick
  * Digilent Adept to load the bit file onto the FPGA

Setup
-----
  * Plug the joy stick into the JA1 slot.
  * Connect the FPGA to your computer via USB.
  * Connect the FPGA board to a monitor via VGA.
  * Open Digilent Adept, connect to the FPGA, and initialize the board with
    the asteroids bit file.


Controls
--------
The joy stick controls the jet position.

Button Up	- RESET the game.
Button Center	- Fire bullets.
Button Left	- Decrease bullet speed.
Button Right	- Increase bullet speed.
Button Down	- Pause/Start the game.

Switches 0 - 7	- change the color of the jet

The 7 Segment Display will have the current score

LED 0-3 is the current bullet speed in binary(default at 7).
LED 4-7 is the current game level (start at one(LED 4 will light up) max at
four(LED 7 will light up))

Collaborators
-------------
*Created by Samuel Chordas and Richard Chan*
