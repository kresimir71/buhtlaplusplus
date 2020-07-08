
# Table of Contents

1.  [Introduction](#orgf76cab8)
    1.  [Makefile](#org92d8253)
        1.  [If `make` does not work](#orgae0fdb8)
    2.  [driver.cpp](#orgd1fd57c)
    3.  [buhtla.pl](#orgf25db9b)


<a id="orgf76cab8"></a>

# Introduction

This is further elaboration of the project 

[https://github.com/kresimir71/buhtla](https://github.com/kresimir71/buhtla)

Explanations already given there will not be repeated here. That means
also that prolog part will remain uncommented.  The difference and the
added value is that here part of the prolog program has been replaced
by C++.


<a id="org92d8253"></a>

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


<a id="orgae0fdb8"></a>

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


<a id="orgd1fd57c"></a>

## [driver.cpp](./driver.md)


<a id="orgf25db9b"></a>

## [buhtla.pl](./buhtla.pl)

This file was described in detail in [https://github.com/kresimir71/buhtla](https://github.com/kresimir71/buhtla)

