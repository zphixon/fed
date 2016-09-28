! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: kernel fed.util accessors io.encodings.utf8 sequences math
    prettyprint io.files io math.parser combinators locals peg.ebnf
    math.intervals arrays strings continuations accessors fed.buffer ;
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

: commandmatch ( commandstr -- command )
    {
        { "q" [ \ q ] }
        { "w" [ \ w ] }
        { "n" [ \ n ] }
        { "p" [ \ q ] }
        { "d" [ \ d ] }
        [ "?" print \ nop ]
    } case
;

:: rangematch ( buflen rangeraw -- range )
    rangeraw first :> from
    rangeraw second :> to
    rangeraw last :> comma

    ! command is not part of what we're looking at
    from to and [
        ! 1,2n
        { from to }
    ] [
        ! ,2n || 1,n || ,n || 1n
        comma [
            ! 1,n || ,2n
            from [
                ! 1,n
                { from buflen }
            ] [
                ! ,2n
                { 1 to }
            ] if
        ] [
            ! 1n
            { from from }
        ] if
    ] if
;

! EBNF grammar for parsing fed commands
EBNF: fedcommand
    digit     = [0-9]                              => [[ digit> ]]
    number    = (digit)+                           => [[ 10 digits>integer ]]
    range     = number?:from ","*:comma number?:to => [[ from to comma ?first 3array ]]
    letter    = [a-zA-Z]                           => [[ 1array >string ]]
    ranged    = (range)?letter
    command   = (ranged|number) "\n"               => [[ first ]]
    rule      = command
;EBNF
! unfortunately doesn't support comments inside

:: parse ( buffer command -- buffer quit? )
    command string>number :> num?

    [
        command fedcommand :> ast
        ast number? [
            ast .
        ] [
            ast .
            ast first :> rangeraw
            buffer totallines>> rangeraw rangematch .
        ] if
        ! command fedcommand :> ast
        ! ast number? [ don't rangematch ] [ buffer totallines>>
        ! ast rangematch ] if
        ! ast last :> commandstr
        ! ast first :> rangeraw
        ! commandstr commandmatch :> command
        ! buffer rangeraw rangematch :> range
        ! range command execute(
    ] [
        .
        "?" print
    ] recover

    num? [
        buffer totallines>> :> buflen
        1 num? <=
        num? buflen <= and            ! check bounds
        [
            num? buffer linenum<<
        ] [
            "?" print
        ] if
    ] [
        ! "?" print
    ] if

    buffer t
;

! : parsecommand ( buffer command -- buffer quit? )
!     {
!         { "q\n" [ q ] }                       ! quit
!         ! { "p" [ p t ] }                     ! print
!         ! { "n" [ n t ] }                     ! print with line numbers
!         { "a\n" [ a t ] }                     ! append
!         { "i\n" [ i t ] }                     ! insert
!         { "w\n" [ w t ] }                     ! write
!         ! { "d" [ d t ] }                     ! delete line
!         { "debug\n" [ dup . t ] }             ! debug
!         [ parse ]                           ! none of the above
!     } case                                  ! match command
! ;
