# Flappy Bird

This repository is a HDL design of flappy bird. 

# How to simulate/synthesize or view waveforms
Make sure you have verilator, iverilog, yosys, and gtkwave installed

Add to your ~/.bashrc the following:
```
module load verilator
module load iverilog
module load yosys
module load gtkwave
```
If there is an error with your path, add this instead to the ~/.bashrc:
```
export PATH=<enter path here>:$PATH
```

To refresh ~/.bashrc, run ```source ~/.bashrc```

Syntax for simulation: your module must be in the source directory and the testbench must be in the testbench directory with the name ```<module_name_in_source>_tb.sv```
For example, if you want to have a testbench for vga.sv, the testbench must be named vga_tb.sv in the testbench directory.

Command to simulate: ```make sim_<name_of_your_module_here>_src```
Example: ```make sim_vga_src```

Command to synthesize: ``` make sim_<name_of_your_module_here>_syn```
Example: ```make sim_vga_syn```

Command to view waveform: ```make waves_<name_of_your_module_here>```
Example: ```make waves_vga```

To clean all temporary files from synthesis, compilation, and simulation: ```make clean```
