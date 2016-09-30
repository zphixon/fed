! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: accessors fed.util kernel sequences math math.parser io io.files
    io.encodings.utf8 locals prettyprint ;
IN: fed.command

ERROR: cmderr summary range args buffer ;

: oneranged ( range -- ok? )
    second not [
        t
    ] [
        f
    ] if
;

: noranged ( range -- ok? )
    dup first
    [ second ] dip
    or not
;

: inboundsd ( buffer elem -- ok? )
    [ totallines>> ] dip swap <=
;

:: a ( argstr range buffer -- buffer continue? )
    range oneranged [
        range first [
            buffer range first inboundsd [
                argstr empty? [
                    range first :> line
                    buffer lines>> :> into
                    getinput :> from
                    line into from splice :> newlines
                    newlines buffer lines<<
                    line buffer linenum<<
                    f buffer saved?<<
                    buffer t
                ] [
                    "no args allowed" range argstr buffer cmderr
                ] if
            ] [
                "out of bounds" range argstr buffer cmderr
            ] if
        ] [
            argstr empty? [
                buffer linenum>> :> line
                buffer lines>> :> into
                getinput :> from
                line into from splice :> newlines
                newlines buffer lines<<
                line buffer linenum<<
                f buffer saved?<<
                buffer t
            ] [
                "no args allowed" range argstr buffer cmderr
            ] if
        ] if
    ] [
        "no range allowed" range argstr buffer cmderr
    ] if
;

:: i ( argstr range buffer -- buffer continue? )
    range oneranged [
        range first [
            buffer range first inboundsd [
                argstr empty? [
                    range first 1 - :> line
                    buffer lines>> :> into
                    getinput :> from
                    line into from splice :> newlines
                    newlines buffer lines<<
                    line buffer linenum<<
                    f buffer saved?<<
                    buffer t
                ] [
                    "no args allowed" range argstr buffer cmderr
                ] if
            ] [
                "out of bounds" range argstr buffer cmderr
            ] if
        ] [
            argstr empty? [
                buffer linenum>> 1 - :> line
                buffer lines>> :> into
                getinput :> from
                line into from splice :> newlines
                newlines buffer lines<<
                line buffer linenum<<
                f buffer saved?<<
                buffer t
            ] [
                "no args allowed" range argstr buffer cmderr
            ] if
        ] if
    ] [
        "no range allowed" range argstr buffer cmderr
    ] if
;

:: w ( argstr range buffer -- buffer continue? )
    range noranged [
        argstr empty? [
            buffer lines>> buffer filename>> utf8 set-file-lines
            t buffer saved?<<
            t buffer changed?<<
            buffer t
        ] [
            "no args allowed" range argstr buffer cmderr
        ] if
    ] [
        "no range allowed" range argstr buffer cmderr
    ] if
;

:: d ( argstr range buffer -- buffer continue? )
    argstr empty? [ ] [
        "no args allowed" range argstr buffer cmderr
    ] if
    range first :> from!
    range second :> to!
    from [
        to [
            ! no change necessary
        ] [
            from to!
        ] if
    ] [
        buffer linenum>> from!
        buffer linenum>> to!
    ] if
    buffer lines>> :> linearray
    0 from 1 - linearray subseq :> before
    to buffer totallines>> linearray subseq :> after
    before after append :> newlines
    newlines buffer lines<<
    newlines length buffer totallines<<
    f buffer saved?<<
    buffer t
;

:: q ( argstr range buffer -- buffer continue? )
    range noranged [
        argstr empty? [
            buffer saved?>> [
                buffer f
            ] [
                "unsaved changes: quit? yes/n " write flush readln
                "yes" = [
                    f buffer changed?<<
                    buffer f
                ] [
                    "aborting" print
                    buffer t
                ] if
            ] if
        ] [
            "no args allowed" range argstr buffer cmderr
        ] if
    ] [
        "no range allowed" range argstr buffer cmderr
    ] if
;

:: p ( argstr range buffer -- buffer continue? )
    argstr empty? [
        range first :> from
        range second :> to
        from [ ! { 2 ? }
            to [ ! { 2 3 }
                from 1 - to buffer lines>> subseq [
                    print
                ] each
            ] [ ! { 2 f }
                from 1 - buffer lines>> nth print
            ] if
        ] [ ! { f f }
            buffer linenum>> 1 - buffer lines>> nth print
        ] if
    ] [
        "no args allowed" range argstr buffer cmderr
    ] if
    buffer t
;

:: n ( argstr range buffer -- buffer continue? )
    argstr empty? [
        range first :> from
        range second :> to
        from [ ! { 2 ? }
            to [ ! { 2 3 }
                from 1 - to buffer lines>> subseq [
                    from + number>string write "\t" write flush print
                ] each-index
            ] [ ! { 2 f }
                ! from 1 - buffer lines>> nth print
                from number>string write "\t" write flush
                from 1 - buffer lines>> nth print
            ] if
        ] [ ! { f f }
            buffer linenum>> number>string write "\t" write flush
            buffer linenum>> 1 - buffer lines>> nth print
        ] if
    ] [
        "no args allowed" range argstr buffer cmderr
    ] if
    buffer t
;

: nop ( argstr range buffer -- buffer continue? ) 2nip t ;

