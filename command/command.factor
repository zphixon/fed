! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: accessors fed.util kernel sequences math math.parser io io.files
    io.encodings.utf8 locals prettyprint ;
IN: fed.command

: a ( range buffer -- buffer q? )
    [ dup first [ second ] dip [ = ] keep swap ] dip swap
    [
        dup totallines>> [ swap ] dip
        swap [ >= ] keep swap            ! check in bounds
        [
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
            ! drop
            .
            "? out of bounds" print ! out of bounds
        ] if
    ] [
        nip
        "? no range allowed" print ! no range allowed
    ] if
    t
;

! insert
: i ( buffer -- buffer )
    getinput
    [ dup lines>> ] dip
    [ dup linenum>> 1 - ] 2dip      ! get line number above
    splice                          ! splice in before line number
    >>lines                         ! set new lines
    dup lines>> length >>totallines ! set new file length
    f >>saved?
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

