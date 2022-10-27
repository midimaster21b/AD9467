# Run using "vivado -mode tcl -source ip_gen.tcl"
set outputDir ./ip_gen
file mkdir $outputDir

create_project ip_gen $outputDir -part xczu7ev-ffvc1156-2-e

source sample_fifo.tcl

exit
