This is an AVRxt inspired CPU design. I did this to learn more about Computer Architecture and this is absolutely not affiliated with Microchip Technology inc 
and is entirely designed from my imagination and what I thought to be the actual hardware underlying the AVRxt instruction set. To run code you will have to obtain
the opcodes of your code and enter them in the flash program memory unit in order. The current program loaded into the memory is a simple push button code below.

loop:
sbis VPORTA_IN, 7 //skip next instruction if PA7 is 1
cbi VPORTD_OUT, 7 //clear output PD7 to 0, turn LED ON
sbic VPORTA_IN, 7 //skip next instruction if PA7 is 0
sbi VPORTD_OUT, 7 //set output PD7 to 1, turn LED OFF
rjmp loop;

You can load any code that isnt limited by my version of the ALU right now. I will be updating ALU to add a dadda multiplier and update the rest of the cpu flags.


