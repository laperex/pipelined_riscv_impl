# Lorem Ipsum

Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

## Usage

### Requirements

- Vivado 2020.2+ installed and on `$PATH`
- A supported FPGA board (e.g., Digilent Nexys A7 or Boolean)
- ModelSim or Vivado Simulator (for simulation)

### To launch Vivado and automatically set up the project:

1. **(Optional)** Source the Vivado environment:
   
```bash
	source /opt/Xilinx/Vivado/2024.1/settings64.sh
```

Launch Vivado and initialize the project:

```bash
	vivado -mode gui -source init.tcl
```

