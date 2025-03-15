#################################
######### Build Script ##########
#################################

# Generic Variables
set proj_name "base"
set origin_dir "."
set build_dir "${origin_dir}/workspace/build"
set platform_dir ${build_dir}/platform

# Config Variables
set base_script "${origin_dir}/scripts/base.tcl"
set script_file [file tail [info script]]

# Help information for this script
proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--base_script <path>\]"
  puts "$script_file -tclargs \[--example_dir <path>\]"
  puts "$script_file -tclargs \[--help\]\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name"    { incr i; set proj_name [lindex $::argv $i] }
      "--base_script"    { incr i; set base_script [lindex $::argv $i] }
      "--example_dir"    { incr i; set example_dir [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Runtime Variables
set xsa_output "${platform_dir}/${proj_name}.xsa"
set example_dir ""

source ${base_script}

# Launch synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check synthesis status
if {[get_property STATUS [get_runs synth_1]] != "synth_design Complete!"} {
    puts "Synthesis failed!"
    exit 1
}

# Launch implementation
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# Check implementation status
if {[get_property STATUS [get_runs impl_1]] != "write_bitstream Complete!"} {
    puts "Bitstream generation failed!"
    exit 1
}

# Export the hardware as XSA (including bitstream)
write_hw_platform -fixed -include_bit -force ${xsa_output}
puts "XSA file generated successfully at ${xsa_output}"

# Close project
close_project
exit 0
