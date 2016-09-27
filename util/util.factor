! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: kernel io arrays sequences ;
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

