! fed.factor: factor ed clone

USING: sequences sequences.generalizations prettyprint
    command-line math kernel io io.encodings.utf8
    io.files accessors math.parser combinators strings
    locals arrays fed.buffer ;
IN: fed

! splice array into another
: splice ( index into from -- result )
    [ dup 0 swap ] 2dip
    [ [ subseq ] keep swap ] dip
    [ [ length ] keep subseq ] 2dip
    rot append append
;

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
    swap dup -rot lines<<           ! set result to lines
    dup lines>> length              ! get length of lines
    swap dup -rot totallines<<      ! set length to file length
;

! insert
: i ( buffer -- buffer )
    getinput
    [ dup lines>> ] dip
    [ dup linenum>> 1 - ] 2dip      ! get line number above
    splice                          ! splice in before line number
    swap dup -rot lines<<           ! set result to lines
    dup lines>> length              ! get length
    swap dup -rot totallines<<      ! set to file length
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
                dup lines>> [ print ] each      ! print out file for now
                f ] }                           ! condition for loop
            { "a" [ a t ] }                     ! append
            { "i" [ i t ] }                     ! insert
            { "d" [ dup .  t ] }                ! debug
            [ parsecommand ]                    ! none of the above
        } case                                  ! match command
    ] loop                                      ! loop while still editing
;

: fed ( -- )
    1 2 (command-line) subseq first ! get filename to edit
    dup print
    dup exists? [
        utf8 file-lines <buffer>
        dup -rot lines<<
        dup lines>> length
        swap dup -rot linenum<<
        dup lines>> length
        swap dup -rot totallines<<
    ] [
        drop <buffer>
    ] if

    ! print length: not really right but whatever it's familiar
    dup lines>> "\n" join length .

    fedloop ! enter main loop

    ! lines>> write ! to file
    drop
;

MAIN: fed

