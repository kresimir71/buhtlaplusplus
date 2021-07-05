
# Table of Contents

1.  [Introduction](#org4e08572)
    1.  [Makefile](#org515bdff)
        1.  [If `make` does not work](#org24b22bf)
    2.  [driver.cpp](#orgafb4a15)
    3.  [buhtla.pl](#org57c0b99)
    4.  [mapStacks](#org2856199)


<a id="org4e08572"></a>

# Introduction

This is further elaboration of the project 

[https://github.com/kresimir71/buhtla](https://github.com/kresimir71/buhtla)

Explanations already given there will not be repeated here. That means
also that prolog part will remain uncommented.  The difference and the
added value is that here part of the prolog program has been replaced
by C++.


<a id="org515bdff"></a>

## [Makefile](./Makefile)

It is certain that you will have to adjust `Makefile` to indicate the
correct place for `gprolog.h`.

In my case it is this one:

`-I/usr/local/gprolog-1.4.5/include`

To get it working proceed as follows:

    make
    
    #test
    . test.sh
    
    #another test
    ./buhtla <testinput2


<a id="org24b22bf"></a>

### If `make` does not work

You can also compile it directly.
Be warned that it is certain that you will have to adjust `-I/usr/local/gprolog-1.4.5/include` .
Fortunately, `gplc` can find the library files without our intervention.

    gplc  -c  buhtla.pl
    g++ -std=c++14 -I/usr/local/gprolog-1.4.5/include -c -o driver.o driver.cpp
    gplc --linker g++ driver.o buhtla.o -o buhtla

and test it with:

    #test
    . test.sh
    
    #another test
    ./buhtla <testinput2


<a id="orgafb4a15"></a>

## [driver.cpp](./driver.md)


<a id="org57c0b99"></a>

## [buhtla.pl](./buhtla.pl)

This file was described in detail in [https://github.com/kresimir71/buhtla](https://github.com/kresimir71/buhtla)


<a id="org2856199"></a>

## mapStacks

A utility implemented in C++

    
            mapStacks
             input: Input list, some external context data, a 'process' function
             output: three lists Output1, Output2, Output3
    
         the whole Output1 list as feedback
    ┌───────────────────────────────────────────┐        ┌─ some external context
    │     Output1                               │        │   
    └──  ┌┐ ┌┐ ┌┐ ┌┐ ┌┐    (push)               │        │   
         └┘ └┘ └┘ └┘ └┘ ◄────────────┐          │        │         
                                     │          ▼        ▼ 
          Output2                    │  ┌──────────────────────┐
         ┌┐ ┌┐ ┌┐ ┌┐ ┌┐              └──┤                      │ (pop) head and tail         Input
         └┘ └┘ └┘ └┘ └┘ ◄─────┐(push)   │     'process'        │◄────────────────────  ┌┐ ┌┐ ┌┐ ┌┐ ┌┐
                              └─────────┤                      │                       └┘ └┘ └┘ └┘ └┘
          output3                       └──┬────────┬──────────┘                     ▲
          ┌┐ ┌┐ ┌┐ ┌┐ ┌┐      (push)       │        │                                │
          └┘ └┘ └┘ └┘ └┘ ◄─────────────────┘        │                                │
                                                    │      some feedback pushed      │
                                                    └────────────────────────────────┘
    
         Note: Output1, Output2, Output3 are beeing extended at the end of the list
    
         Description: - on each iteration, 'process' gets the head and tail of Input
    	          - on each iteration, 'process' gets also the whole current Output1
    		  - on each iteration, 'process' extends Input at the head of list
    		  - some external context is present as additional input of 'process'

