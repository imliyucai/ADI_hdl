proc gen_fmc_constr {{fmc_index1 fmc} {fmc_index2 {}}} {
  
  set project_name [get_property NAME [current_project]]
  set carrier [string replace $project_name 0 [string first "_" $project_name] ""]
  set eval_board [string replace $project_name [string first "_" $project_name] 30 ""]
  
  set col0_max 0
  set col1_max 0
  set col2_max 0
  set col3_max 0
  set io_standard_max 0
  variable temp_pin 0
  
  set carrier_path [glob ../../common/$carrier/$carrier\_$fmc_index1*.txt]
  set carrier_file [open $carrier_path r]
  set carrier_data [read $carrier_file]
  close $carrier_file
  set line_c [join $carrier_data " "]
  
  set constr_file [open "fmc_constr.xdc" w+]
  
  if {[string length $fmc_index2] == 0} {
    set eval_board_path [glob ../common/$eval_board\_fmc*.txt]
    set eval_board_file [open $eval_board_path r]
    set eval_board_data [read $eval_board_file]
    close $eval_board_file
    set line_e [join $eval_board_data " "]
    for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
      for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} { 
        if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
          if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
            if {[string length [lindex $line_c [expr $j*5]]] > $col0_max} {
              set col0_max [string length [lindex $line_c [expr $j*5]]]
            }
            if {[string length [lindex $line_c [expr $j*5+1]]] > $col1_max} {
              set col1_max [string length [lindex $line_c [expr $j*5+1]]]
            }
            if {[string length [lindex $line_c [expr $j*5+2]]] > $col2_max} {
              set col2_max [string length [lindex $line_c [expr $j*5+2]]] 
            }  
          }
        }
        if {[string length [lindex $line_e [expr $i*6+3]]] > $col3_max} {
          set col3_max [string length [lindex $line_e [expr $i*6+3]]]  
        }
        if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
          set io_standard [lindex $line_e [expr $i*6+4]]
          if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
            append io_standard " [lindex $line_e [expr $i*6+5]]"
          }
          if {[string length $io_standard] > $io_standard_max} {
            set io_standard_max [string length $io_standard]
          }
        }
      }  
    }
    
    for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
      for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} { 
        if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
          if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
            if {[string compare [lindex $line_c [expr $j*5]] $temp_pin] == 0} {continue}
            set temp_pin [lindex $line_c [expr $j*5]]
            set spaces_0 ""
            set spaces_1 ""
            set spaces_2 ""
            set spaces_3 ""
            for {set k 0} {$k < [expr $col0_max - [string length [lindex $line_c [expr $j*5]]]]} {incr k} {append spaces_0 " "}
            for {set k 0} {$k < [expr $col1_max - [string length [lindex $line_c [expr $j*5+1]]]]} {incr k} {append spaces_1 " "}
            for {set k 0} {$k < [expr $col2_max - [string length [lindex $line_c [expr $j*5+2]]]]} {incr k} {append spaces_2 " "}
            for {set k 0} {$k < [expr $col3_max - [string length [lindex $line_e [expr $i*6+3]]]]} {incr k} {append spaces_3 " "} 
            if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
              set io_standard "$spaces_2 IOSTANDARD [lindex $line_e [expr $i*6+4]]"
              if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
                append io_standard " [lindex $line_e [expr $i*6+5]]"
              }
            } else {
                set io_standard ""
            }
            set io_standard [string map -nocase {"," " "} $io_standard]
            for {set k 0} {$k < [expr $io_standard_max + [string length $spaces_2] + 12 - [string length $io_standard]]} {incr k} {append spaces_3 " "} 
            puts $constr_file "set_property  -dict \{PACKAGE_PIN [lindex $line_c [expr $j*5+2]]$io_standard\} \[get_ports [lindex $line_e [expr $i*6+3]]\]$spaces_3 ; ## [lindex $line_c [expr $j*5]]$spaces_0  [lindex $line_c [expr $j*5+1]] $spaces_1 [lindex $line_c [expr $j*5+3]]" 
          }
        }
      }
    }
  } else {
      set eval_board_path [glob ../common/$eval_board\_fmc1.txt]
      set eval_board_file [open $eval_board_path r]
      set eval_board_data [read $eval_board_file]
      close $eval_board_file
      set line_e [join $eval_board_data " "]
      for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
        for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} { 
          if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
            if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
              if {[string length [lindex $line_c [expr $j*5]]] > $col0_max} {
                set col0_max [string length [lindex $line_c [expr $j*5]]]
              }
              if {[string length [lindex $line_c [expr $j*5+1]]] > $col1_max} {
                set col1_max [string length [lindex $line_c [expr $j*5+1]]]
              }
              if {[string length [lindex $line_c [expr $j*5+2]]] > $col2_max} {
                set col2_max [string length [lindex $line_c [expr $j*5+2]]] 
              }  
            }
          }
          if {[string length [lindex $line_e [expr $i*6+3]]] > $col3_max} {
            set col3_max [string length [lindex $line_e [expr $i*6+3]]]  
          }
          if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
            set io_standard [lindex $line_e [expr $i*6+4]]
            if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
              append io_standard " [lindex $line_e [expr $i*6+5]]"
            }
            if {[string length $io_standard] > $io_standard_max} {
              set io_standard_max [string length $io_standard]
            }
          }
        }  
      }
      for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
        for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} { 
          if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
            if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
              set spaces_0 ""
              set spaces_1 ""
              set spaces_2 ""
              set spaces_3 ""
              for {set k 0} {$k < [expr $col0_max - [string length [lindex $line_c [expr $j*5]]]]} {incr k} {append spaces_0 " "}
              for {set k 0} {$k < [expr $col1_max - [string length [lindex $line_c [expr $j*5+1]]]]} {incr k} {append spaces_1 " "}
              for {set k 0} {$k < [expr $col2_max - [string length [lindex $line_c [expr $j*5+2]]]]} {incr k} {append spaces_2 " "}
              for {set k 0} {$k < [expr $col3_max - [string length [lindex $line_e [expr $i*6+3]]]]} {incr k} {append spaces_3 " "} 
              if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
                set io_standard "$spaces_2 IOSTANDARD [lindex $line_e [expr $i*6+4]]"
                if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
                  append io_standard " [lindex $line_e [expr $i*6+5]]"
                }
              } else {
                  set io_standard ""
              }
              set io_standard [string map -nocase {"," " "} $io_standard]
              for {set k 0} {$k < [expr $io_standard_max + [string length $spaces_2] + 12 - [string length $io_standard]]} {incr k} {append spaces_3 " "} 
              puts $constr_file "set_property  -dict \{PACKAGE_PIN [lindex $line_c [expr $j*5+2]]$io_standard\} \[get_ports [lindex $line_e [expr $i*6+3]]\]$spaces_3 ; ## [lindex $line_c [expr $j*5]]$spaces_0  [lindex $line_c [expr $j*5+1]] $spaces_1 [lindex $line_c [expr $j*5+3]]" 
            }
          }
        }
      }
      puts $constr_file ""
      set carrier_path [glob ../../common/$carrier/$carrier\_$fmc_index2*.txt]
      set carrier_file [open $carrier_path r]
      set carrier_data [read $carrier_file]
      close $carrier_file
      set line_c [join $carrier_data " "]
      
      set eval_board_path [glob ../common/$eval_board\_fmc2.txt]
      set eval_board_file [open $eval_board_path r]
      set eval_board_data [read $eval_board_file]
      close $eval_board_file
      set line_e [join $eval_board_data " "]
      
      for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
        for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} { 
          if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
            if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
              if {[string length [lindex $line_c [expr $j*5]]] > $col0_max} {
                set col0_max [string length [lindex $line_c [expr $j*5]]]
              }
              if {[string length [lindex $line_c [expr $j*5+1]]] > $col1_max} {
                set col1_max [string length [lindex $line_c [expr $j*5+1]]]
              }
              if {[string length [lindex $line_c [expr $j*5+2]]] > $col2_max} {
                set col2_max [string length [lindex $line_c [expr $j*5+2]]] 
              }  
            }
          }
          if {[string length [lindex $line_e [expr $i*6+3]]] > $col3_max} {
            set col3_max [string length [lindex $line_e [expr $i*6+3]]]  
          }
          if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
            set io_standard [lindex $line_e [expr $i*6+4]]
            if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
              append io_standard " [lindex $line_e [expr $i*6+5]]"
            }
            if {[string length $io_standard] > $io_standard_max} {
              set io_standard_max [string length $io_standard]
            }
          }
        }  
      }
      for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
        for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} { 
          if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
            if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
              set spaces_0 ""
              set spaces_1 ""
              set spaces_2 ""
              set spaces_3 ""
              for {set k 0} {$k < [expr $col0_max - [string length [lindex $line_c [expr $j*5]]]]} {incr k} {append spaces_0 " "}
              for {set k 0} {$k < [expr $col1_max - [string length [lindex $line_c [expr $j*5+1]]]]} {incr k} {append spaces_1 " "}
              for {set k 0} {$k < [expr $col2_max - [string length [lindex $line_c [expr $j*5+2]]]]} {incr k} {append spaces_2 " "}
              for {set k 0} {$k < [expr $col3_max - [string length [lindex $line_e [expr $i*6+3]]]]} {incr k} {append spaces_3 " "} 
              if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
                set io_standard "$spaces_2 IOSTANDARD [lindex $line_e [expr $i*6+4]]"
                if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
                  append io_standard " [lindex $line_e [expr $i*6+5]]"
                }
              } else {
                  set io_standard ""
              }
              set io_standard [string map -nocase {"," " "} $io_standard]
              for {set k 0} {$k < [expr $io_standard_max + [string length $spaces_2] + 12 - [string length $io_standard]]} {incr k} {append spaces_3 " "} 
              puts $constr_file "set_property  -dict \{PACKAGE_PIN [lindex $line_c [expr $j*5+2]]$io_standard\} \[get_ports [lindex $line_e [expr $i*6+3]]\]$spaces_3 ; ## [lindex $line_c [expr $j*5]]$spaces_0  [lindex $line_c [expr $j*5+1]] $spaces_1 [lindex $line_c [expr $j*5+3]]" 
            }
          }
        }
      }
    }
  close $constr_file
  add_files -fileset constrs_1 -norecurse fmc_constr.xdc
}