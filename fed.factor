! fed.factor: factor ed clone - (c) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: sequences sequences.generalizations prettyprint
    command-line math kernel io io.encodings.utf8
    io.files accessors math.parser combinators
    arrays namespaces fed.buffer fed.command fed.util ;
IN: fed

: fedloop ( buffer -- buffer )
    ! wait for commands
    [                                           ! loop begin
        dup prompt>> write flush readln         ! prompt for command
        {
            { "q" [ q ] }                       ! quit
            { "p" [ p t ] }                     ! print
            { "n" [ n t ] }                     ! print with line numbers
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

    ! dup clone
    fedloop ! enter main loop

    drop

    ! dup changed?>> [
    !     lines>> "\n" join length number>string print drop
    ! ] [
    !     drop lines>> "\n" join length number>string print
    ! ] if
;

MAIN: fed

