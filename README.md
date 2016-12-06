# Pompeii II
Written by Konrad Aust, Laura Berry, Andrew Lata, and Yue Chen

This is a Commodore VIC20 game about dodging lava. It was written for a retrogames course at the University of Calgary.

To build, simply run the makefile. The resulting .prg file can be loaded into your favourite VIC-20 emulator (Or onto the hardware itself!)

To win, don't touch any lava when it turns red.
In a two player game, win by surviving longer than your opponent.

## Structure
    * This game uses a global tick system. Game state is changed in discrete steps. This is common for certain modern games.
    * The player's score increases each time they survive a danger phase of lava.
    * The higher the player's score, the faster the phases change, and the more tiles are generated as lava.
    * Uses a simple 16 bit linear congruential generator for lava generation.
    * We use a custom font for maximum immersion
    * Bitchin' theme tune
    * 2 player mode supported. The second player uses the joystick.

