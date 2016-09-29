! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: accessors fed.util kernel sequences math math.parser io io.files
    io.encodings.utf8 locals ;
IN: fed.command

: checkrangeequal ( range -- elem equal? )
    dup first [ second ] dip [ = ] keep swap
;

: inbounds ( elem buffer -- buffer elem inbounds? )
    dup totallines>> [ swap ] dip
    swap [ >= ] keep swap
;

! append
: a ( range buffer -- buffer q? )
    [ checkrangeequal ] dip swap [
        inbounds [
            swap
            getinput
            [ dup lines>> ] dip
            [ swap dup ] 2dip
            splice
            [ swap ] dip
            >>lines
            swap
            >>linenum
            f >>saved?
        ] [
            drop
            ! USE: prettyprint .
            "? out of bounds" print
        ] if
    ] [
        nip
        "? no range allowed" print
    ] if
    t
;

: i ( range buffer -- buffer q? )
    [ checkrangeequal ] dip swap [
        inbounds [
            swap getinput
            [ dup lines>> ] dip
            [ swap dup 1 - ] 2dip
            splice
            [ swap ] dip
            >>lines
            swap
            >>linenum
            f >>saved?
        ] [
            drop
            ! USE: prettyprint .
            "? out of bounds" print
        ] if
    ] [
        nip
        "? no range allowed" print
    ] if
    t
;

! save file
: w ( buffer -- buffer )
    dup filename>> swap
    dup lines>> rot
    utf8 set-file-lines
    t >>saved?
    t >>changed?
;

! delete line
: d ( buffer -- buffer )
    dup lines>>                          ! get lines
    [ dup linenum>> 0 swap 1 - ] dip     ! set up first subsequence
    dup [ subseq ] dip                   ! get lines before deleted line
    [ dup linenum>> ] 2dip [ swap ] dip  ! set up second subsequence
    dup [ length ] dip
    subseq append                        ! get lines after deleted line
    dup length                           ! get new totallines
    [ >>lines ] dip                      ! set new lines
    >>totallines                         ! set new totallines
    f >>saved?
;

: q ( range buffer -- buffer quit? )
    nip
    dup saved?>> [
        f
    ] [
        "unsaved changes: quit? yes/n " write flush readln
        "yes" = [
            f >>changed?
            f
        ] [
            "aborting" print
            t
        ] if
    ] if
;

: p ( buffer -- buffer )
    dup lines>> [ print ] each
;

: n ( buffer -- buffer )
    dup lines>> [
        1 + number>string write bl print
    ] each-index
;

: nop ( range buffer -- buffer ) nip ;

