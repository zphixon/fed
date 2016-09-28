! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

! USING: kernel fed.util accessors io.encodings.utf8 sequences math
!     prettyprint io.files io math.parser combinators locals peg.ebnf
!     math.intervals arrays strings continuations accessors fed.buffer
!     sorting ;

USING: accessors fed.util kernel sequences math math.parser io io.files
    io.encodings.utf8 ;

IN: fed.command

! append
: a ( buffer -- buffer )
    getinput                        ! get user input
    [ dup lines>> ] dip             ! get lines
    [ dup linenum>> ] 2dip          ! get line number
    splice                          ! splice in at line number
    >>lines                         ! set new lines
    dup lines>> length >>totallines ! set new length of file
    f >>saved?
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

: q ( buffer -- buffer quit? )
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

: nop ( -- ) ;

