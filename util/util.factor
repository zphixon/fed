! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: kernel io arrays sequences accessors math ;
IN: fed.util

! splice array into another
: splice ( index into from -- result )
    [ dup 0 swap ] 2dip
    [ [ subseq ] keep swap ] dip
    [ [ length ] keep subseq ] 2dip
    rot append append
;

! get input until single . on a line
: getinput ( -- input )
    { } [
        readln
        [ "." = ] keep swap
        [
            drop
            f
        ] [
            1array append
            t
        ] if
    ] loop
;

: oneranged ( range -- ok? )
    second not [
        t
    ] [
        f
    ] if
;

: noranged ( range -- ok? )
    dup first
    [ second ] dip
    or not
;

: inboundsd ( buffer elem -- ok? )
    [ totallines>> ] dip swap <=
;

ERROR: rangeerr summary from to ;
ERROR: cmderr summary range args buffer ;

