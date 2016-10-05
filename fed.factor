! fed.factor: factor ed clone - (c) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: accessors command-line fed.buffer io io.encodings.utf8
    io.files kernel math.parser namespaces sequences fed.parse
    kernel ;
IN: fed

: fedloop ( buffer -- buffer )
    ! wait for commands
    [                                           ! loop begin
        ! dup prompt>> write flush readln         ! prompt for command
        ! "\n" append parse                       ! make it easier to parse
        dup prompt?>> [
            dup prompt>> write flush
        ] [ ] if
        readln "\n" append parse
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

    dup lines>> length 0 = [
        1 >>linenum
        1 >>totallines
        { "" } >>lines
    ] [
    ] if

    flush
    fedloop ! enter main loop

    dup changed?>> [
        lines>> "\n" join length number>string print
    ] [
        drop
    ] if
;

MAIN: fed

