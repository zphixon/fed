! fed.factor: factor ed clone
! see LICENSE.txt for copyright notice

USING: sequences sequences.generalizations prettyprint
    command-line math kernel io io.encodings.utf8
    io.files accessors math.parser combinators strings
    locals arrays namespaces fed.buffer ;
IN: fed

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

! ugh
: parsecommand ( buffer command -- buffer quit? )
    string>number dup [             ! convert to number
        [ 1 >= ] keep               ! check bounds of number
        [ dup totallines>> ] 2dip
        rot swap
        [ >= ] keep -rot and        ! if inside bounds
        [
            swap dup -rot linenum<< ! set line number
        ] [
            drop                    ! print error
            "?" print
        ] if
    ] [
        "?" print                   ! unknown command
        drop
    ] if
    t
;

: fedloop ( buffer -- buffer )
    ! wait for commands
    [                                           ! loop begin
        dup prompt>> write flush readln         ! prompt for command
        {
            { "q" [ q ] }                       ! quit
            { "p" [ p t ] }                     ! print
            { "n" [ n t ] }
            { "a" [ a t ] }                     ! append
            { "i" [ i t ] }                     ! insert
            { "w" [ w t ] }                     ! write
            { "d" [ d t ] }                     ! delete line
            { "debug" [ dup .  t ] }            ! debug
            [ parsecommand ]                    ! none of the above
        } case                                  ! match command
    ] loop                                      ! loop while still editing
;

: fed ( -- )
    command-line get first

    dup [ ] [
        "File name required." print
        drop ""
    ] if

    dup exists? [
        dup utf8 file-lines <buffer>
        [ dup length dup ] dip
        swap >>totallines
        swap >>linenum
        swap >>lines
        swap >>filename
    ] [
        drop <buffer>
        "file does not exist: cannot save (yet!)" print
    ] if

    ! print length: not really right but whatever it's familiar
    dup lines>> "\n" join length number>string print

    dup clone
    fedloop ! enter main loop

    dup changed?>> [
        lines>> "\n" join length number>string print drop
    ] [
        drop lines>> "\n" join length number>string print
    ] if
;

MAIN: fed

