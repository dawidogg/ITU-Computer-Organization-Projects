# İTÜ Computer Organization Projects

Team members: Denıs Iurıe Davıdoglu (150200916), Matay Aydın (150200075), Mustafa Kırcı (150200096).

During the Computer Organization course, we learned how computers work on the lowest level, and developed a simple architecture in Verilog. In Project 1, we described the main hardware components, such as register files and ALU. In Project 2, we were assigned implementing an instruction set using hardwired control. More details on the design can be found in the pdfs included.
What stands out is that, although not required in the assignment, we wrote an assembler in the C programming language, so that we could debug our design easily by just writing assembly code. `/Project2` folder has a `run` command, which assembles a program, compiles the design using `iverilog`, runs the simulation, and shows the differences occurred in memory after the execution. For example:
```
* ./run swap.asm (compiles and executes swap.asm program located in /assembly_programs directory)
* ./run jump_test.asm --wave (compiles, executes, and opens the waveform in `gtkwave`)
```
Note: testing was done in Linux environment. 
See the "Testing" section in Project 2's report for program execution examples. 


