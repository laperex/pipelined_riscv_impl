create_project build_project_riscv ./build -part xc7s50csga324-1

# Add RTL sources
foreach f [glob -nocomplain ./srcs/sources/*] {
    add_files $f
}

# Add simulation files
foreach f [glob -nocomplain ./srcs/sim/*] {
    add_files -fileset sim_1 $f
}

# Add constraint files
foreach xdc_file [glob -nocomplain ./srcs/constrs/*.xdc] {
    add_files $xdc_file
    set_property FILE_TYPE XDC [get_files $xdc_file]
    set_property USED_IN_SYNTHESIS true [get_files $xdc_file]
    set_property USED_IN_IMPLEMENTATION true [get_files $xdc_file]
}

update_compile_order -fileset sources_1

set_property top processor_tb [get_filesets sim_1]

update_compile_order -fileset sim_1

launch_simulation