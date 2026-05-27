#========================================================
# CLEAN WORK LIBRARY
#========================================================
if {[file exists work]} {
    vdel -all
}
 
#========================================================
# LIBRARY
#========================================================
vlib work
vmap work work
 
#========================================================
# TEST LIST
#========================================================
set test_list {
    USB2p0_LS_CT_set_address_test
    USB2p0_LS_CT_clear_feature_test
    USB2p0_LS_CT_set_configuration_test
    USB2p0_LS_CT_set_feature_test
    USB2p0_LS_CT_set_interface_test
    USB2p0_LS_CT_get_configuration_test
    USB2p0_LS_CT_get_interface_test
   USB2p0_LS_CT_get_status_test
    USB2p0_LS_CT_get_descriptor_test
   USB2p0_LS_interrupt_in_test
   USB2p0_LS_interrupt_out_test
   USB2p0_FS_CT_set_configuration_test
    USB2p0_FS_CT_set_interface_test
    USB2p0_FS_CT_set_address_test
    USB2p0_FS_CT_clear_feature_test
    USB2p0_FS_CT_set_feature_test
    USB2p0_FS_CT_get_configuration_test
    USB2p0_FS_CT_get_descriptor_test 
    USB2p0_FS_CT_get_status_test
    USB2p0_FS_CT_get_interface_test
    USB2p0_FS_interrupt_in_test
    USB2p0_FS_interrupt_out_test
    USB2p0_FS_bulk_in_test
    USB2p0_FS_bulk_out_test
    USB2p0_FS_isochronous_in_test
    USB2p0_FS_isochronous_out_test
 
    USB2p0_HS_CT_set_configuration_test
    USB2p0_HS_CT_set_address_test
    USB2p0_HS_CT_set_interface_test
    USB2p0_HS_CT_set_feature_test
    USB2p0_HS_CT_clear_feature_test
 
    USB2p0_HS_CT_get_configuration_test
    USB2p0_HS_CT_get_interface_test
    USB2p0_HS_CT_get_status_test
    USB2p0_HS_CT_get_descriptor_test
    USB2p0_HS_interrupt_in_test
    USB2p0_HS_interrupt_out_test
   USB2p0_HS_bulk_in_test
   USB2p0_HS_bulk_out_test
   USB2p0_HS_isochronous_in_test
   USB2p0_HS_isochronous_out_test
    }
 
#========================================================
# DIRECTORIES
#========================================================
file mkdir Regression
file mkdir coverage_reports
 
#========================================================
# PASS / FAIL VARIABLES
#========================================================
proc check_result {logfile testname} {
 
    # Check log file exists
    if {![file exists $logfile]} {
        echo "❌ FAILED : $testname (log file not found)"
        return "FAIL"
    }
 
    set fh [open $logfile r]
    set content [read $fh]
    close $fh
 
    set fatal_count 0
    set error_count 0
 
    foreach line [split $content "\n"] {
 
        if {[regexp {Number of FATAL reports\s*:\s*(\d+)} $line match count]} {
            set fatal_count $count
        }
 
        if {[regexp {Number of ERROR reports\s*:\s*(\d+)} $line match count]} {
            set error_count $count
        }
    }
 
    if {$fatal_count == 0 && $error_count == 0} {
        echo "✅ PASSED : $testname"
        return "PASS"
    } else {
        echo "❌ FAILED : $testname (FATAL=$fatal_count ERROR=$error_count)"
        return "FAIL"
    }
}
 
 
#========================================================
# REGRESSION LOOP
#========================================================
set pass_count 0
set fail_count 0
set fail_list {}
 
set last_mode ""
foreach testname $test_list {
 
    echo "======================================="
    echo "RUNNING TEST : $testname"
    echo "======================================="
# Decide mode
    if {[string match "*HS*" $testname]} {
        set mode "HS"
    } else {
        set mode "LS_FS"
    }
 
    # UCDB FILE NAME
#====================================================
# COMPILE
#====================================================
# Compile ONLY if mode changes
    if {$mode ne $last_mode} {
 
        echo "COMPILING FOR MODE : $mode"
 
        if {$mode eq "HS"} {
            vlog -work work -cover bsectf +fcover -sv -incr -mfcu \
                +define+UTMI_16BIT \
                top/USB2p0_UTMI_interface.sv \
                top/USB2p0_PHY_interface.sv \
                top/USB2p0_pkg.sv \
                top/USB2p0_top.sv
        } else {
            vlog -work work -cover bsectf +fcover -sv -incr -mfcu \
                top/USB2p0_UTMI_interface.sv \
                top/USB2p0_PHY_interface.sv \
                top/USB2p0_pkg.sv \
                top/USB2p0_top.sv
        }
 
        set last_mode $mode
    }
 
set ucdb_file "coverage_reports/${testname}.ucdb"
 
    #====================================================
    # SIMULATION COMMAND
    #====================================================
    exec vsim -c \
        -coverage \
        -cvgperinstance \
        -debugDB \
        -batch \
         +acc \
        work.USB2p0_top \
        +UVM_TESTNAME=$testname \
        -l Regression/${testname}.log \
        -do "add log -r /*; coverage save -onexit $ucdb_file; run -all; quit -f"
          catch {eval exec $sim_cmd} sim_result
 
   #====================================================
    # CHECK PASS / FAIL
    #====================================================
    set result [check_result Regression/${testname}.log $testname]
 
    if {$result == "PASS"} {
        incr pass_count
    } else {
        incr fail_count
        lappend fail_list $testname
    }
 
    echo "COMPLETED : $testname"
}
 
#========================================================
# SHOW GENERATED UCDB FILES
#========================================================
echo "======================================="
echo "GENERATED COVERAGE FILES"
echo "======================================="
set ucdb_files [glob -nocomplain coverage_reports/*.ucdb]
 
if {[llength $ucdb_files] == 0} {
    echo "❌ NO UCDB FILES FOUND"
} else {
    foreach f $ucdb_files {
        echo $f
    }
}
 
#========================================================
# MERGE COVERAGE
#========================================================
echo "======================================="
echo "MERGING COVERAGE DATABASES"
echo "======================================="
 
set ucdb_files [glob -nocomplain coverage_reports/*.ucdb]
set ucdb_files [lsearch -all -inline -not $ucdb_files "coverage_reports/merged_cov.ucdb"]
 
if {[llength $ucdb_files] == 0} {
    echo "❌ NO UCDB FILES TO MERGE"
} else {
    eval vcover merge coverage_reports/merged_cov.ucdb $ucdb_files
}
 
#========================================================
# GENERATE COVERAGE REPORT
#========================================================
echo "======================================="
echo "GENERATING COVERAGE REPORT"
echo "======================================="
 
vcover report -details -html coverage_reports/merged_cov.ucdb
 
#========================================================
# FINAL REGRESSION SUMMARY
#========================================================
echo "======================================="
echo "        REGRESSION SUMMARY"
echo "======================================="
 
echo "TOTAL  TESTS : [llength $test_list]"
echo "PASSED TESTS : $pass_count"
echo "FAILED TESTS : $fail_count"
 
echo "======================================="
 
#========================================================
# PRINT FAILED TESTS
#========================================================
if {$fail_count > 0} {
    echo "FAILED TESTCASES:"
    foreach ft $fail_list {
        echo "   ❌ $ft"
    }
}
 
echo "======================================="
echo "REGRESSION COMPLETED"
echo "======================================="
