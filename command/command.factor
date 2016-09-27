! Copyright (C) 2016 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: fed.command

TUPLE: command num ;

: <command> ( -- command )
    0 command boa
;

