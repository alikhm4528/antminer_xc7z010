#################################
# Gen Device Tree Vitis Project #
#################################

set hw "./platform/base.xsa"
set proc "ps7_cortexa9_0"
set workspace "./workspace/build"
set dt_dir "./dt_dir"
set project_name "empty"

set script_file [file tail [info script]]

# Help information for this script
proc print_help {} {
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--dt_dir <path>\]"
  puts "$script_file -tclargs \[--hw <path>\]"
  puts "$script_file -tclargs \[--workspace <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [lindex $argv $i]
    switch -regexp -- $option {
      "--dt_dir" { incr i; set dt_dir [lindex $argv $i] }
      "--hw" { incr i; set hw [lindex $argv $i] }
      "--workspace" { incr i; set workspace [lindex $argv $i] }
      "--project_name" { incr i; set project_name [lindex $argv $i] }
      "--help" { print_help }
    }
  }
}


file delete -force $workspace

setws $workspace

repo -set $dt_dir
platform create -name "device_tree_plat" -hw $hw -proc $proc -os device_tree

platform generate
