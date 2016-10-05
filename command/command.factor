! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: accessors fed.util kernel sequences math math.parser io io.files
    io.encodings.utf8 locals prettyprint arrays ;
IN: fed.command

! append after curret line
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
                    newlines length buffer totallines<<
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
                newlines length buffer totallines<<
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

! insert at current line
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
                    newlines length buffer totallines<<
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
                newlines length buffer totallines<<
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

! delete lines
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
    from buffer linenum<<
    f buffer saved?<<
    buffer t
;

! quit editor
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

! save file
:: w ( argstr range buffer -- buffer continue? )
    range noranged [
        argstr empty? [
            buffer lines>> buffer filename>> utf8 set-file-lines
            t buffer saved?<<
            t buffer changed?<<
            buffer t
        ] [
            argstr "q" = [
                buffer lines>> buffer filename>> utf8 set-file-lines
                t buffer saved?<<
                t buffer changed?<<
                "" { f f } buffer q
            ] [
                "no args allowed" range argstr buffer cmderr
            ] if
        ] if
    ] [
        "no range allowed" range argstr buffer cmderr
    ] if
;

! print without line numbers
:: p ( argstr range buffer -- buffer continue? )
    argstr empty? [
        range first :> from
        range second :> to
        from [
            to [
                from 1 - to buffer lines>> subseq [
                    print
                ] each
            ] [
                from 1 - buffer lines>> nth print
            ] if
        ] [
            buffer linenum>> 1 - buffer lines>> nth print
        ] if
    ] [
        "no args allowed" range argstr buffer cmderr
    ] if
    flush
    buffer t
;

! print with line numbers
:: n ( argstr range buffer -- buffer continue? )
    argstr empty? [
        range first :> from
        range second :> to
        from [                                                          ! { 2 ? }
            to [                                                        ! { 2 3 }
                from 1 - to buffer lines>> subseq [
                    from + number>string write "\t" write flush print
                ] each-index
            ] [                                                         ! { 2 f }
                from number>string write "\t" write flush
                from 1 - buffer lines>> nth print
            ] if
        ] [                                                             ! { f f }
            buffer linenum>> number>string write "\t" write flush
            buffer linenum>> 1 - buffer lines>> nth print
        ] if
    ] [
        "no args allowed" range argstr buffer cmderr
    ] if
    flush
    buffer t
;

: c ( argstr range buffer -- buffer continue? )
    [ dup ] 2dip
    [ dup ] dip
    [ first f 2array swap ] 2dip
    d drop
    i
;

: Q ( argstr range buffer -- buffer continue? )
    [ noranged ] dip swap [
        [ empty? ] dip swap [
            f
        ] [
            "no args allowed" { } "" { } cmderr
        ] if
    ] [
        "no range allowed" { } "" { } cmderr
    ] if
;

: P ( argstr range buffer -- buffer continue? )
    2nip
    dup prompt?>> not >>prompt?
    t
;

: nop ( argstr range buffer -- buffer continue? ) 2nip t ;

