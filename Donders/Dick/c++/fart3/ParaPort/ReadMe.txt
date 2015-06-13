///////////////////////////////////////////////////////////////////////////////
// 
// ReadMe.txt of ParaPort
//
// Software Release: v1.3
//
// copyright (c) 2002, 2003 by Paul R. ADAM
// all rights reserved
// read the "http://www.ParaPort.net/TermsOfUse.html"
//
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// remarks:
* Check "http://www.ParaPort.net" for newer versions.
* The functionality "getPortInfo" is not yet implemented


///////////////////////////////////////////////////////////////////////////////
// modifications in ParaPort v1.3:

* Correction of error on input data with multiple "PARAPORT_CYCLE" in method "executeCycle( )" ( "Count" > 1 )
* Enhancement on internal tracing in debug mode
* Addition of "setMask*( )" interface to class ParaPortCycle
* Support of "RepeatFactor" functionality ( details in "http://www.ParaPort.net/documentation/functionalSpecificationParaPort.html#pageRepeatFactor" )
* Modification of sample to demonstrate the "RepeatFactor" functionality


///////////////////////////////////////////////////////////////////////////////
// modifications in ParaPort v1.2:

* Correction of input data register
* Modification of Timing Model ( details in "http://www.ParaPort.net/documentation/functionalSpecificationParaPort.html" )
* ParaPortUtility: Minor GUI enhancements


///////////////////////////////////////////////////////////////////////////////
// modifications in ParaPort v1.1:

* This release is limited to output only
* Correction of return value of "ParaPortDll::openPort( )"
* Correction of algorithm to calculate the base address
* ParaPortUtility: Minor modifications on GUI ( error message boxes etc. )
* Addition of sample source code


///////////////////////////////////////////////////////////////////////////////
// ParaPort v1.0:

* first published version ( not anymore available )


///////////////////////////////////////////////////////////////////////////////
// files:
[Program Files]\ParaPort\              default installation directory
    ReadMe.txt                         this file
    TermsOfUse.txt                     a local copy of "http://www.ParaPort.net/TermsOfUse.html"
    bin\                               directory with binary files
        ParaPort.dll                   dynamic link library
        ParaPortUtility.exe            application to set/clear pins on the parallel port
    driver\                            directory with driver files
        ParaPort.inf                   information file needed to install the WDM driver
        ParaPort.sys                   WDM driver
    include\                           directory with C/C++ interface
        ParaPort.h                     header file
        ParaPortCycle.h                header file
        ParaPortDll.h                  header file
    sampleRepeatFactor\                directory with C++ source code samples to demonstrate the RepeatFactor
        bin\                           directory with binary files
            sampleRepeatFactor.exe     application which generates some pulses with different durations
        source\                        directory with source files
            sampleRepeatFactor.cpp     sample C++ source file


///////////////////////////////////////////////////////////////////////////////
// installing ParaPort:

1. Uncompress the zip-file in a temporary directory ( e.g.: "c:\temp\ParaPort" )

2. Execute the setup.exe and follow the instructions. The files will be extracted 
   in a target directory ( e.g.: "c:\Program Files\ParaPort" )

3. Launch the "Add/Remove Hardware Wizard" to install the driver MANUALLY.
   Details are explained online at "http://www.ParaPort.net/documentation/index.html"

4. Launch the "ParaPortUtility.exe" to access the parallel port.


///////////////////////////////////////////////////////////////////////////////
// documentation:

See on internet at "http://www.ParaPort.net" in section "Documentation"


///////////////////////////////////////////////////////////////////////////////
