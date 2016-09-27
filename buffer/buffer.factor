! Copyright (C) 2016 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: fed.buffer

TUPLE: buffer lines linenum totallines prompt filename ;

: <buffer> ( -- buffer )
    { "" } 1 1 "" "" buffer boa
;

