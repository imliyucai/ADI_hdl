#!/usr/bin/env python3

import os
import re
import codecs
import sys

##############################################################################
#
# Class definitions
##############################################################################
class Port (object):
    def __init__ (self, name="unknown", direction="unknown", ptype="wire"):
        self.name = name
        self.direction = direction
        self.ptype = ptype


class Occurrence (object):
    # path - to the file where the occurrence was found
    # line - where the instantiated module is 
    # line_end - where the instantiated module ends
    # pos_start_ports - how many lines after .line the ports list starts, inside 
    #                   the instantiated module
    def __init__ (self, path="unknown", line="unknown"):
        self.path = path
        self.line = line
        self.line_end = -1
        self.pos_start_ports = -1


class Interface (object):
    def __init__ (self):
        self.interface = []

    def add_port (self, port):
        self.interface.append(port)


##############################################################################
#
# Functions 
##############################################################################
def is_comment (line):
    rcoma = re.compile(r'^\s*//')
    rcomb = re.compile(r'^\s*/\*')
    if (rcoma.match(line) or rcomb.match(line)):
        return True
    else:
        return False

def is_multiline_comment (line):
    if ((line.strip()).startswith("*")):
        return True
    else:
        if ((line.find("/*") != -1) or (line.find("*/") != -1)):
            return True
        else:
            return False

def is_paramdef (line):
    rparameter = re.compile(r'^\s*parameter\s.*')
    if (rparameter.match(line)):
        return True
    else:
        return False

def is_iodef (line):
    rinput = re.compile(r'^\s*input\s.*')
    routput= re.compile(r'^\s*output\s.*')
    rinout = re.compile(r'^\s*inout\s.*')
    if ((rinput.match(line)) or (routput.match(line)) or (rinout.match(line))):
        return True
    else:
        return False

# check if the given string is made only of spaces or tabs
def only_spaces_or_tabs (line):
    line = line.strip()
    line = line.strip("\t")
    if (line == ""):
        return True
    else:
        return False


# check if one of the modified files appears in the warning message
def list_has_substring (modified_files, message):
    for mfile in modified_files:
        if (message.find(mfile) != -1):
            return True
    
    return False


# check if file is between the modified files specified as arguments
def string_in_list (module_path, modified_files):
    for mfile_path in modified_files:
        if (("./" + mfile_path) == module_path or mfile_path == module_path):
            return True
    
    return False


###############################################################################
#
# Check if file has correct properties, meaning that the file extension has to 
# be .v and it should not be some certain files.
# Returns true or false.
###############################################################################
def check_filename (filename):

    if (filename.endswith('.v') == False):
        return False
    if (filename.find("tb") != -1):
        return False
    
    return True


###############################################################################
#
# Detect all modules present in the given directory. 
# Return a list with the fullpaths.
###############################################################################
def detect_all_modules (directory):

    detected_modules_list = []

    for folder, dirs, files in os.walk(directory):
        for file in files:
            if (check_filename(file)):
                fullpath = os.path.join(folder, file)
                detected_modules_list.append(fullpath);

    return detected_modules_list


###############################################################################
#
# Determine the file name from the fullpath.
# Return the string containing the file name without extension.
###############################################################################
def get_file_name (module_path):

    # split the path using the / and take the last group, which is the file.ext
    split_path = module_path.split("/")
    module_filename = split_path[len(split_path) - 1]
    
    # take the module name from the filename with the extension
    filename_wout_ext = module_filename.split(".")[0]
    
    return filename_wout_ext


###############################################################################
#
# Check if there are lines after `endmodule and two consecutive empty lines.
###############################################################################
def check_extra_lines (module_path, lines, lw):
 
    remove_end_lines = False
    passed_endmodule = False
    line_nb = 1
    prev_line = ""
    for line in lines:
        # GC: check for lines after endmodule 
        if (line.find("endmodule") != -1):
            passed_endmodule = True
        
        # if we passed the endmodule tag
        if (passed_endmodule and (line.find("endmodule") == -1)):
            remove_end_lines = True
        
        # GC: check for empty lines
        if (line_nb >= 2):
            if (only_spaces_or_tabs(prev_line) and only_spaces_or_tabs(line) 
                and (not is_comment(prev_line)) and (not is_comment(line))):
                lw.append(module_path + " : " + str(line_nb) + " two consecutive empty lines")
                
        line_nb += 1
        
        if (line_nb >= 2):
            prev_line = line
    
    if (remove_end_lines):
        lw.append(module_path + " : extra lines after endmodule")


###############################################################################
#
# Check for guideline rules applied to module definitions and the entire file, 
# except for the module instances. They are processed in check_guideline_instances.
# Return the string containing the module name and print errors for guideline
#        if it is not respected.
###############################################################################
def get_and_check_module (module_path, list_of_lines, lw):

    # list of warnings
    lw_initial_size = len(lw)
    lw.append("\nAt module definition:")

    # GC: check for lines after endmodule and empty lines
    check_extra_lines (module_path, list_of_lines, lw)

    module_name = ""
    name_found = False
    params_exist = False
    end_line = -1
    line_nb = 1
    passed_module = False
    passed_endmodule = False
    last_iodef_line = -1
    last_paramdef_line = -1
        
    for line in list_of_lines:
        pos_module = line.find("module")
        pos_endmodule = line.find("endmodule")
        pos_diez = line.find("#")
        pos_paranth1 = line.find("(")
        pos_paranth2 = line.find(")")
        pos_comma = line.find(",")
    
        if (pos_module == 0):
            passed_module = True
            
        if (pos_endmodule != -1):
            passed_endmodule = True
        
        if (is_paramdef(line)):
            if (pos_comma == -1):
                last_paramdef_line = line_nb
            else:
                pos_comment = line.find("/")
                ## if the first found comma is after a /, it means it's the 
                ## last parameter line 
                if (pos_comment > 0 and pos_comment < pos_comma):
                    last_paramdef_line = line_nb
 
        if (is_iodef(line)):
            if (pos_comma == -1):
                last_iodef_line = line_nb 
            else:
                pos_comment = line.find("/")
                ## if the first found comma is after a /, it means it's the 
                ## last io line 
                if (pos_comment > 0 and pos_comment < pos_comma):
                    last_iodef_line = line_nb      
        
        # if still inside the module declaration (with params)
        if (name_found and params_exist and end_line == -1):
            if (0 <= pos_paranth2 and pos_paranth2 < pos_paranth1):
                if (re.search("\)\\s\(", line) != None):
                    rest_of_line = line.strip().strip("(").strip().strip(")")
                    if (pos_paranth2 != 0 or rest_of_line != ""):
                        lw.append(module_path + " : " + str(line_nb) + " at ) ( not at the beginning of an empty line")
                else:
                    lw.append(module_path + " : " + str(line_nb) + " at ) ( has to have exactly 1 space")
                    
        # if still inside the module declaration (w/o params)
        if (name_found and end_line == -1):
            pos_closing = line.find(");")
            if (pos_closing != -1):
                end_line = line_nb
                if ((last_iodef_line + 1 != line_nb) or (pos_closing != 0)):
                    lw.append(module_path + " : " + str(line_nb) + " at ); not on an empty line")

        # GC: check for indentation of the file 
        ## if it's a regular line
        if ((pos_module == -1) and (pos_endmodule == -1) 
            and (not only_spaces_or_tabs(line)) 
            and (not is_comment(line)) and (not is_multiline_comment(line))
            and passed_module and (not passed_endmodule) 
            and (line.find("`") == -1)):
            indent_nb = len(line) - len(line.lstrip())
            
            if (not (indent_nb >= 2)):
                if (line_nb != (last_paramdef_line+1) and line_nb != (last_iodef_line+1)):
                    lw.append(module_path + " : " + str(line_nb) + " no indentation found")
            else: 
                # take only iodef from modules and not from functions also
                if (indent_nb != 2 and is_paramdef(line)):
                    lw.append(module_path + " : " + str(line_nb) + " indentation is not proper")
    
        # get the module name by reading the line that contains "module"
        # GC: check for proper positioning of the module declaration
        if ((not is_comment(line)) and (not name_found)):
            if (pos_module == 0):
                ## situations accepted
                ## 1. module module_name (
                ## 2. module module_name #(
                
                # 2nd situation
                if (pos_diez > 0):
                    if (pos_paranth1 == pos_diez + 1):
                        module_name = re.search("module(.*?)#\(", line)
                        
                        if (module_name != None):
                            module_name = module_name.group(1)
                            module_name = module_name.strip()
                            
                            name_found = True
                        else:
                            lw.append(module_path + " : " + str(line_nb) + " at module name - error")
                    else:
                        lw.append(module_path + " : " + str(line_nb) + " at module #( guideline not respected")
                    
                    params_exist = True
                # 1st situation
                else:
                    module_name = line.strip("module")
                    module_name = module_name.strip()
                    module_name = module_name.strip("\n")
                    module_name = module_name.strip()
                    module_name = module_name.strip("(")
                    module_name = module_name.strip()
                    
                    name_found = True

        line_nb += 1
  
    if (not name_found):
        lw.append(module_path + " : module name couldn't be extracted\n") 
           
    lw_last_size = len(lw)
    
    if (lw_last_size == lw_initial_size + 1):
        lw.pop()

    return module_name


###############################################################################
# 
# Find all occurrences of the given module (path) in all files from the given 
# directory (recursive) or in all files from list_of_files (if specified).
# Return list of paths (for the occurrences) relative to the given directory.
###############################################################################
def find_occurrences (directory, module_name, list_of_files):

    occurrences_list = []
    
    for folder, dirs, files in os.walk(directory):
        for file in files:
            fullpath = os.path.join(folder, file)
            
            if (not check_filename(fullpath)):
                continue
            
            search = False
            if (list_of_files and (string_in_list(fullpath, list_of_files))):
                search = True
            elif (not list_of_files):
                search = True

            ## the file with the module definition is not accepted and
            ## neither the files that have to be avoided 
            if (search and file != (module_name + ".v")):
                with codecs.open(fullpath, 'r', encoding='utf-8', errors='ignore') as f:
                    line_nb = 1
    
                    for line in f:
                        if ((line.find(module_name) != -1) and (not is_comment(line))):
                            pos = line.find(module_name)
                            pos_dot = line.find(".")
                            
                            # if there is no dot before the module name
                            if (pos_dot == -1 or pos < pos_dot):
                                if ((line[pos+len(module_name)] == ' ') or (line[pos+len(module_name)] == '#') 
                                    or (line[pos+len(module_name)] == '(') or (line[pos+len(module_name)] == '\t')):
                                    
                                    # if before the instance name there are only spaces, then it is ok
                                    if (only_spaces_or_tabs(line[:pos-1]) == True): 
                                        new_occurrence = Occurrence(path=fullpath, line=line_nb)
                                        ## check if it has a parameters list; 
                                        ## then instance name is on the same line
                                        if ("#" not in line):
                                            new_occurrence.pos_start_ports = 0
                                            
                                        occurrences_list.append(new_occurrence)
                        line_nb += 1
    return occurrences_list                    


###############################################################################
# 
# Find the lines where an occurrence starts, ends and where its list of ports 
# starts.
# Return nothing (the occurrence_item fields are directly modified)
###############################################################################
def set_occurrence_lines (occurrence_item, list_of_lines):

    pos_start_module = -1
    pos_end_module = -1
    param_exist = False
    instance_lines = []
    
    line_nb = 1
    # find the start and the end line of the module instance
    for line in list_of_lines:
        if (pos_end_module == -1):
            if (occurrence_item.line == line_nb):
                pos_start_module = line_nb

                if ("#" in line):
                    param_exist = True
            
            # if we are inside of the module instance
            if (pos_start_module != -1):
                if (line.find(");") != -1):
                    pos_end_module = line_nb
                    occurrence_item.line_end = pos_end_module
        else: 
            break
        line_nb += 1
    
    if (not param_exist):
        occurrence_item.pos_start_ports = 0
    else:
        # with parameters: get the ports' list in all_lines, including parameters 
        all_lines = ""
        line_nb = 1

        for line in list_of_lines:
            if (pos_start_module <= line_nb and line_nb <= pos_end_module):
                all_lines = all_lines + line
            elif (line_nb > pos_end_module):
                break
            line_nb += 1

        ## find the line where the instance name is; 
        ## the ports should start from the next line, which is pos_start_ports+1
        
        # find a string that is spread over multiple lines
        aux_instance_name = re.findall('\)\n(.*?)\(', all_lines, re.M)
        
        # if )\n i_... (
        if (len(aux_instance_name) > 0):
            instance_name = aux_instance_name[0].strip(" ")
        else:
            # if ) i_... (
            instance_name = re.findall('\)(.*?)\(', all_lines, re.M)[0].strip(" ")
        
        line_nb = 1
        pos_start_ports = -1
        
        # update occurrence_item.pos_start_ports if it wasn't already set
        for line in list_of_lines:
            if (pos_start_module <= line_nb and line_nb <= pos_end_module):
                if ((instance_name in line) and (pos_start_ports == -1)):
                    # if not already specified in find_occurrences, without a parameters list
                    if (occurrence_item.pos_start_ports == -1): 
                        pos_start_ports = line_nb - pos_start_module
                        occurrence_item.pos_start_ports = pos_start_ports
            elif (line_nb > pos_end_module):
                break
            line_nb += 1


###############################################################################
# 
# Check for the guideline rules applied to the module instaces and output 
# warnings for each line, if any.
###############################################################################
def check_guideline_instances (occurrence_item, lw):
    
    # list of warnings
    lw_initial_size = len(lw)
    lw.append("\nAt instances:")
    
    with open(occurrence_item.path, 'r') as in_file:
        list_of_lines = in_file.readlines()

    # have all the fields of the occurrence_item
    set_occurrence_lines(occurrence_item, list_of_lines)
    
    ## with parameters: get the module instance's lines in all_lines, 
    ## including the parameters 
    all_lines = ""
    line_nb = 1

    for line in list_of_lines:
        if (occurrence_item.line <= line_nb and line_nb <= occurrence_item.line_end):
            all_lines = all_lines + line
        elif (line_nb > occurrence_item.line_end):
            break
        line_nb += 1

    port_pos = 0
    line_nb = 1
    spaces_nb = -1
    passed_module = False
    passed_endmodule = False

    for line in list_of_lines:
        inside_module_instance = False
        line_start_ports = occurrence_item.line + occurrence_item.pos_start_ports
        
        if ((occurrence_item.line <= line_nb) and (line_nb <= occurrence_item.line_end)):
            inside_module_instance = True
            
            # GC: indentation for the line where the instance name is
            if (line_start_ports == line_nb):
                spaces_nb = len(line) - len(line.lstrip())
                if ((spaces_nb <= 0) or (spaces_nb % 2 != 0)):
                    lw.append(occurrence_item.path + " : " + str(line_nb) + " wrong indentation at instance name")
            
            # GC: indentation for the line where the module name is
            if (occurrence_item.line == line_nb):
                start_spaces_nb = len(line) - len(line.lstrip())
                if ((start_spaces_nb <= 0) or (start_spaces_nb % 2 != 0)):
                    lw.append(occurrence_item.path + " : " + str(line_nb) + " wrong indentation at module name")
            
        # GC: check for proper positioning of the module instance 
        if (inside_module_instance):
            if ("#" in line):
                diez_ok = False
                
                if ("." in line):
                    lw.append(occurrence_item.path + " : " + str(line_nb) + " #(. in module instance")
                else:
                    pos_diez = line.find("#")
                    pos_paranth1 = line.find("(")
                    pos_paranth2 = line.find(")")
                    
                    if ((0 < pos_diez) and (pos_diez + 1 == pos_paranth1) and (pos_paranth2 == -1)):
                        diez_ok = True
                    else:
                        if (pos_paranth2 != -1):
                            lw.append(occurrence_item.path + " : " + str(line_nb) + " parameters must be each on its own line")
                        else:
                            lw.append(occurrence_item.path + " : " + str(line_nb) + " parameters list is not written ok")
                    
                    # for the line where the instance name is
                    # find a string like )\n ... ( 
                    aux_instance_name = re.findall('\)\n(.*?)\(', all_lines, re.M)
                    instance_name = ""
                    
                    # if )\n i_... (
                    if (len(aux_instance_name) > 0):
                        instance_name = aux_instance_name[0].strip(" ")
                        if (")" not in instance_name):
                            lw.append(occurrence_item.path + " : " + str(line_start_ports) + " ) i_... ( instance name not written ok")
                            
                    else:
                        try:
                            # if ) i_... (
                            instance_name = re.findall('\)(.*?)\(', all_lines, re.M)[0].strip(" ")
                        except Exception:
                            lw.append(occurrence_item.path + " : " + str(occurrence_item.line + occurrence_item.pos_start_ports) + " couldn't extract instance name")
            
            pos_dot = line.find(".")
            pos_comma = line.find(",")
            pos_closing = line.find(");")    
            
            # GC: all ); of instances cannot be on an empty line
            aux_line = line.strip()
            aux_line = aux_line.strip("\t")
            aux_line = aux_line.strip(")")
            aux_line = aux_line.strip(";")
            if ((pos_closing != -1) and (only_spaces_or_tabs(aux_line))):
                lw.append(occurrence_item.path + " : " + str(line_nb) + " ); when closing module instance")
                
            # every dot starting from (.line + .pos_start_ports) line means a new port is declared
            if ((line_start_ports <= line_nb) and (pos_dot != -1)):
                port_indentation = len(line) - len(line.lstrip())
                port_pos += 1
                
                # 1. the first port in the module instance
                # 2. anywhere inside the instance, but not the first or last
                # 3. when .port());
                # 4. last port when .port()\n  and ); is on the next line
                
                # no situation or error situation
                situation = 0
                inst_closed = False
                if (pos_closing != -1):
                    inst_closed = True
                    
                # 1st situation
                if (port_pos == 1):
                    situation = 1
                else:
                    # 3rd situation
                    if ((pos_dot != -1) and inst_closed):
                        situation = 3
                    else:
                        # 4th situation
                        if ((pos_dot != -1) and (pos_comma == -1) and (not inst_closed)):
                            situation = 4
                        else: 
                            # 2nd situation
                            if ((pos_dot != -1) and (pos_comma != -1) and (not inst_closed)):
                                situation = 2
                            else:
                                lw.append(occurrence_item.path + " : " + str(line_nb) + " problem when finding the situation")
                
                if (situation != 0):
                    # the rest of the ports must have the same indentation as the previous line
                    if (port_indentation - spaces_nb != 2):
                        avoid_indentation_check = False
                        
                        if ((line.find("({") != -1) or (line.find("})") != -1)):
                            avoid_indentation_check = True
                        
                        if (not avoid_indentation_check):
                            lw.append(occurrence_item.path + " : " + str(line_nb) + " indentation inside module instance")
            else:
                # if inside the parameters list
                if (occurrence_item.line <= line_nb and line_nb < line_start_ports and (pos_dot != -1)):
                    param_indentation = len(line) - len(line.lstrip())
                    if (param_indentation - start_spaces_nb != 2):
                        lw.append(occurrence_item.path + " : " + str(line_nb) + " indentation inside parameters list")
                    
        line_nb += 1
        
        if (line_nb > occurrence_item.line_end):
            break

    lw_last_size = len(lw)
    
    if (lw_last_size == lw_initial_size + 1):
        lw.pop()

###############################################################################
#
# Check guideline for Verilog files in repository
###############################################################################

## all files given as parameters to the script (or all files from repo 
## if no flag is specified)
modified_files = []
error_files = []
guideline_ok = True
# detect all modules from current directory (hdl)
all_modules = detect_all_modules("./")

xilinx_modules = []
xilinx_modules.append("system_bd")
xilinx_modules.append("system_wrapper")
xilinx_modules.append("IBUFDS")
xilinx_modules.append("OBUFDS")
xilinx_modules.append("BUFR")
xilinx_modules.append("BUFG")
xilinx_modules.append("BUFG_GT")
xilinx_modules.append("BUFGCE_DIV")
xilinx_modules.append("BUFGMUX_CTRL")
xilinx_modules.append("IBUFDS_GTE2")
xilinx_modules.append("IBUFDS_GTE3")
xilinx_modules.append("IBUFDS_GTE4")
xilinx_modules.append("IBUFDS_GTE5")
xilinx_modules.append("GTHE3_CHANNEL")
xilinx_modules.append("GTHE4_CHANNEL")
xilinx_modules.append("GTYE4_CHANNEL")
xilinx_modules.append("GTXE2_CHANNEL")
xilinx_modules.append("ALT_IOBUF")
xilinx_modules.append("SYSMONE")

# if there is an argument specified
if (len(sys.argv) > 1):

    # -m means a file name/s will be specified (including extension!)
    # mostly used for testing manually, changing the folder_path
    if (sys.argv[1] == "-m"):
        arg_nb = 2
        
        while (arg_nb < len(sys.argv)):
            # look in the folder_path = current folder 
            for root, dirs, files in os.walk("./"):
                for name in files:
                    if((name == sys.argv[arg_nb]) and (check_filename(name))):
                        module_path = os.path.abspath(os.path.join(root, sys.argv[arg_nb]))
                        modified_files.append(module_path)
            arg_nb += 1
    
    # -p means a path/s will be specified 
    # mostly used for github action
    if (sys.argv[1] == "-p"):
        arg_nb = 2
        
        while (arg_nb < len(sys.argv)):
            if (os.path.exists(sys.argv[arg_nb])):
                if (check_filename(sys.argv[arg_nb])):
                    modified_files.append(sys.argv[arg_nb])
            else:
                error_files.append(sys.argv[arg_nb])
            arg_nb += 1
    
else:
    ## if there is no argument then the script is run on /projects folder
    ## because this way it raises warnings also in the /library folder 
    modified_files = detect_all_modules("./")


# no matter the number of arguments
if (len(modified_files) <= 0):
    print("NO detected modules")
    guideline_ok = True
else:
    for module_path in all_modules:
        module_name = get_file_name(module_path)
        
        # list of warnings 
        lw = []
        
        # if the detected module is between the modified files
        if (string_in_list(module_path, modified_files)):
            fp = open("%s" % (module_path), "r")
            list_of_lines = fp.readlines()
            fp.close()
            
            module_name = get_and_check_module(module_path, list_of_lines, lw)
            file_name = get_file_name(module_path)
            
            # file_name is without the known extension, which is .v
            if (module_name != file_name):
                # applies only to the library folder
                if (module_path.find("library") != -1):
                    guideline_ok = False
                    error_files.append(module_path)
    
        occurrences_list = find_occurrences("./", module_name, modified_files)
        
        if (len(occurrences_list) > 0):
            for occurrence_item in occurrences_list:
                check_guideline_instances(occurrence_item, lw)
        
        if (len(lw) > 0):
            guideline_ok = False
            print ("\n -> For %s in:" % module_path)
            for message in lw:
                print(message)
                
                
    for module_name in xilinx_modules:
        lw = []
        xilinx_occ_list = find_occurrences("./", module_name, modified_files)
        
        if (len(xilinx_occ_list) > 0):
            for xilinx_occ_it in xilinx_occ_list:
                # if the xilinx module was found in the files that are of interest
                for it in all_modules:
                    if (xilinx_occ_it.path == it):
                        # only then to check the guideline 
                        check_guideline_instances(xilinx_occ_it, lw)
        
        if (len(lw) > 0):
            title_printed = False
            
            for message in lw:
                if (list_has_substring(modified_files, message)):
                    if (not title_printed):    
                        print ("\n -> For %s in:" % module_name)
                        title_printed = True
                    guideline_ok = False
                    print(message)

if (error_files):
    error_in_library = False
    
    for file in error_files:
        ## for files in /projects folder, 
        ## the module - file name check doesn't matter
        if (file.find("library") != -1):
            error_in_library == True
    
    if (error_in_library):
        guideline_ok = False
        print ("Files with name errors:")
        for file in error_files:
            ## for files in /projects folder, 
            ## the module - file name check doesn't matter
            if (file.find("library") != -1):
                print (file)

if (not guideline_ok):
    sys.stderr.write("Guideline not respected")
    exit(-1)