# Pompeii II

This is a Commodore VIC20 game about dodging lava. It was written for a retrogames course at the University of Calgary.

## Structure:
  * Main program main.asm, includes BASIC stub and program entry point / all included files
  * Keep all global game state in one file. (Data section in zero page, and outside zero page)
  * Comments. Minimum: one comment for each block of aseembly, including a short high-level description of what he block does.
  * Flat project structure (All assembly can be stored at the top level folder)
  * Game operates on discrete ticks (Think 1 tick = 1 frame)
    * Main game loop: Call tick(), wait for a given amount of time, repeat
    * If you need an event to occur after x number of ticks:
        * Set a field in memory to x
        * Every tick, decrement x. When x hits zero, do the action.
 
  * Naming Conventions
    - Code Labels: [filename]\_[functionName]\_[labelName]
    - Data Labels: 
      - For global state: global\_[labelName], zero\_[labelName]
      - For local state: [filename]\_[local]\_[label]
    - Assembler Macro Names:
      - In all caps.
    - All non-caps labels are in camelcase between the underscores
      - eg. lava.asm has a function lavaGen.
        - lava_lavaGen_loop1: is a good label name
        - lava_lava_gen_loop1: is a bit confusing.

## Scheduling with ticks
The program flow for scheduling events based on ticks looks something like this:

With this logic, do\_action() will get called every 26 frames.

var next\_act = 26

tick() {
    ...
    if(next_act == 0) {
        do_action()
        next_act = 26
    }
    else {
        next_act -= 1
    }
}
