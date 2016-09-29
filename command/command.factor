! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: accessors fed.util kernel sequences math math.parser io io.files
    io.encodings.utf8 locals prettyprint ;
IN: fed.command

ERROR: cmderr summary range args buffer ;

! ! check for second element false
! : checkrange ( range -- elem ok? )
!     dup second swap first f swap ? dup not not
! ;
!
! ! check if in bounds of buffer
! : inbounds ( elem buffer -- buffer elem inbounds? )
!     dup totallines>> [ swap ] dip
!     swap [ >= ] keep swap
! ;

: checkranged ( range -- ok? )
    second not [
        t
    ] [
        f
    ] if
;

: inboundsd ( buffer elem -- ok? )
    [ totallines>> ] dip swap <=
;

:: a ( argstr range buffer -- buffer continue? )
    ! "a:" print
    ! argstr .
    ! range .
    ! ! buffer .
    range checkranged [
        buffer range first inboundsd [
            argstr empty? [
                range first :> line
                buffer lines>> :> into
                getinput :> from
                line into from splice :> newlines
                newlines buffer lines<<
                line buffer linenum<<
                ! . .
                buffer t
            ] [
                "no args allowed" range argstr buffer cmderr
            ] if
        ] [
            "out of bounds" range argstr buffer cmderr
        ] if
    ] [
        "no range allowed" range argstr buffer cmderr
    ] if
;

! ! append
! : a ( argstr range buffer -- buffer q? )
!     [ checkrange ] dip swap [
!         inbounds [
!             swap
!             getinput
!             [ dup lines>> ] dip
!             [ swap dup ] 2dip
!             splice
!             [ swap ] dip
!             >>lines
!             swap
!             >>linenum
!             f >>saved?
!         ] [
!             drop
!             ! USE: prettyprint .
!             "? out of bounds" print
!         ] if
!     ] [
!         nip
!         "? no range allowed" print
!     ] if
!     t
! ;

: i ( range buffer -- buffer q? )
    [ checkrange ] dip swap [
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

! : w ( range buffer -- buffer q? )
!     [ checkrangeequal ] dip swap [
!     
!     ] [
!         nip
!         "? no range allowed" print
!     ] if
! ;

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

