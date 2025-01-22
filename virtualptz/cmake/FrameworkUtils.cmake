
#
# Below are code snippets taken from the LITIV framework to form a standalone
# project for the virtual ptz library and executables.
#
# Copyright 2015 Pierre-Luc St-Charles; visit https://github.com/plstcharles/litiv
# for the full version and licensing information (provided under Apache 2.0 terms)
#

macro(set_eval name)
    if(${ARGN})
        set(${name} 1)
    else(${ARGN})
        set(${name} 0)
    endif(${ARGN})
endmacro(set_eval)

macro(get_subdirectory_list result dir)
    file(GLOB children RELATIVE ${dir} ${dir}/*)
    set(dirlisttemp "")
    foreach(child ${children})
        if(IS_DIRECTORY ${dir}/${child})
            list(APPEND dirlisttemp ${child})
        endif(IS_DIRECTORY ${dir}/${child})
    endforeach(child ${children})
    set(${result} ${dirlisttemp})
endmacro(get_subdirectory_list result dir)
