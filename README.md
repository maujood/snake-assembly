snake-assembly
==============

The "snake" game in IA-32 assembly language. I made it as the course project for my course in assembly language programming (undertaken in Fall 2007).


Running the program
-------------------

A compiled executable (snake.exe) is available for download. Tested on Windows 7 and Windows XP.

Move the snake using the arrow keys.

The game provides the following speed levels:

* Earthworm (very slow)
* Centipede (still too slow - but okay for wimps)
* Cobra (makes for interesting gameplay)
* Black Mamba (be careful - this is the fastest snake ever discovered)

For added challenge, players can select a level:

* None (open playing field)
* Box (the playing field is surrounded by walls)
* Rooms (the snake operates in a space of four rooms)


Information on compiling the code
---------------------------------

snake.asm contains the code for the game. It is dependent on Irvine32.inc which is not provided in this repository. Irvine32.inc and other required files and information for compiling the code in your environment is available at: http://kipirvine.com/asm/
