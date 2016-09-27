! fed.factor: factor ed clone
! see LICENSE.txt for copyright notice

USING: sequences sequences.generalizations prettyprint
    command-line math kernel io io.encodings.utf8
    io.files accessors math.parser combinators strings
    locals arrays namespaces fed.buffer ;
IN: fed

: testbuf ( -- buffer )
    "work/fed/test" dup utf8 file-lines <buffer> [ dup length>> dup ] dip
    swap >>totallines swap >>linenum swap >>lines swap >>filename
;

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
;

! insert
: i ( buffer -- buffer )
    getinput
    [ dup lines>> ] dip
    [ dup linenum>> 1 - ] 2dip      ! get line number above
    splice                          ! splice in before line number
    >>lines                         ! set new lines
    dup lines>> length >>totallines ! set new file length
;

! save file
: w ( buffer -- buffer )
    dup filename>> swap
    dup lines>> rot
    utf8 set-file-lines
;

: d ( buffer -- buffer )
    dup lines>>
    [ dup linenum>> 0 swap 1 - ] dip
    dup [ subseq ] dip
    [ dup linenum>> ] 2dip [ swap ] dip
    dup [ length ] dip
    subseq append
    dup length
    [ >>lines ] dip
    >>totallines
;

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

! dreading the day I need to refactor
: fedloop ( buffer -- buffer )
    ! wait for commands
    [                                           ! loop begin
        dup prompt>> write flush readln         ! prompt for command
        {
            { "q" [                             ! match quit
                ! dup lines>> [ print ] each      ! print out file for now
                f ] }                           ! condition for loop
            { "a" [ a t ] }                     ! append
            { "i" [ i t ] }                     ! insert
            { "w" [ w t ] }
            { "d" [ d t ] }
            { "debug" [ dup .  t ] }            ! debug
            [ parsecommand ]                    ! none of the above
        } case                                  ! match command
    ] loop                                      ! loop while still editing
;

: fed ( -- )
    ! 1 2 (command-line) subseq first ! get filename to edit
    command-line get first
    dup exists? [
        dup utf8 file-lines <buffer>
        [ dup length dup ] dip
        swap >>totallines
        swap >>linenum
        swap >>lines
        swap >>filename
    ] [
        drop <buffer>
        "no file name: cannot save" print
    ] if

    ! print length: not really right but whatever it's familiar
    dup lines>> "\n" join length number>string print

    fedloop ! enter main loop

    lines>> "\n" join length number>string print
;

MAIN: fed

