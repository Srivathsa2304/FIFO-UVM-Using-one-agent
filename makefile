VLOG =  /tools/mentor/questa_10.6b/questasim/bin/vlog

VSIM = /tools/mentor/questa_10.6b/questasim/bin/vsim

all: comp_rtl comp run

comp_rtl:
	$(VLOG) +cover=bcstfex /projects/ADAD/FE/UVM/misc_codes/apb/rtl/apb_slave.sv

comp: 
	$(VLOG) +incdir+/projects/ADAD/FE/UVM/uvm-1.2/src /projects/ADAD/FE/UVM/uvm-1.2/src/uvm_pkg.sv +define+UVM_NO_DPI /project/ADAD/FE/UVM/misc_codes/apb/tb/io_if.sv /projects/ADAD/FE/UVM/misc_codes/apb/tb/apb_pkg.sv /projects/ADAD/FE/UVM/misc_codes/apb/tb/top.sv  

run: 
	$(VSIM)   -coverage  -novopt top +UVM_TESTNAME=test_read_write -l vsim.log -c
       ##add wave -r 

Which Questa 
which vlog
