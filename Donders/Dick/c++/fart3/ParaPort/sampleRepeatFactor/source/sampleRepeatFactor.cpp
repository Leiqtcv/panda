/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// main.cpp: main procedure
//
// copyright (c) 2002, 2003 by Paul R. ADAM
// all rights reseved
// read the "http://www.ParaPort.net/TermsOfUse.html"
//
// more information on "http://www.ParaPort.net"
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>

#include "../include/ParaPortDll.h"
#include "../include/ParaPortCycle.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
int main( int argc, char *argv[ ] )
{
 printf( "test program\n\n" );
 ParaPortDll* Dll = ParaPortDll::getSingleton( );
 HANDLE Handle;
 if ( !Dll->loadLibrary( "./ParaPort.dll" ) )
 {
  printf( "Error: %d in Dll->loadLibrary( \"./ParaPort.dll\" );\n", GetLastError( ) );
  ParaPortDll::deleteSingleton( );
  getchar( );
  return 1;
 }
 Handle = Dll->openPort( "LPT1" );
 if ( Handle == INVALID_HANDLE_VALUE )
 {
  printf( "Error: %d in Dll->openPort( \"LPT1\" );\n", GetLastError( ) );
  ParaPortDll::deleteSingleton( );
  getchar( );
  return 2;
 }

 ParaPortCycle Cycle[ 10 ];
 Cycle[ 0 ].setData( 0x00 );
 Cycle[ 0 ].clearInit( );
 Cycle[ 0 ].clearLineFeed( );
 Cycle[ 0 ].clearSelectIn( );
 Cycle[ 0 ].clearStrobe( );

 Cycle[ 1 ].setData( 0x01 );
 Cycle[ 1 ].setInit( );
 
 Cycle[ 2 ].setData( 0x02 );
 Cycle[ 2 ].clearInit( );

 Cycle[ 3 ].setData( 0x03 );
 Cycle[ 3 ].setLineFeed( );
 Cycle[ 3 ].setRepeatFactor( 1 );

 Cycle[ 4 ].setData( 0x04 );
 Cycle[ 4 ].clearLineFeed( );

 Cycle[ 5 ].setData( 0x05 );
 Cycle[ 5 ].setSelectIn( );
 Cycle[ 5 ].setRepeatFactor( 2 );
 
 Cycle[ 6 ].setData( 0x06 );
 Cycle[ 6 ].clearSelectIn( );

 Cycle[ 7 ].setData( 0x07 );
 Cycle[ 7 ].setStrobe( );
 Cycle[ 7 ].setRepeatFactor( 4 );
 
 Cycle[ 8 ].setData( 0x08 );
 Cycle[ 8 ].clearStrobe( );
 
 Cycle[ 9 ].setData( 0x09 );

 if ( !Dll->executeCycle( Handle, Cycle, sizeof( Cycle ) / sizeof( Cycle[ 0 ] ) ) )
  printf( "Error: %d in Dll->executeCycle( );\n", GetLastError( ) );

 for ( int i = 0; i < sizeof( Cycle ) / sizeof( Cycle[ 0 ] ); i ++ )
 {
  printf( "i: %d\n", i );
  if ( !Dll->executeCycle( Handle, Cycle + i, 1 ) )
   printf( "Error: %d in Dll->executeCycle( );\n", GetLastError( ) );
  getchar( );
 }
 Dll->closePort( Handle );
 ParaPortDll::deleteSingleton( );
 getchar( );
 return 0;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
