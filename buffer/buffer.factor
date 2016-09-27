! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: kernel ;
IN: fed.buffer

TUPLE: buffer lines linenum totallines prompt filename saved? changed? ;

: <buffer> ( -- buffer )
    { "" } 1 1 "" "" t f buffer boa
;

