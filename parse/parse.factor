! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: combinators fed.command io kernel accessors namespaces strings
    continuations prettyprint math math.parser sequences arrays
    locals sequences sorting peg.ebnf peg ;
IN: fed.parse

: commandmatch ( commandstr -- command )
    {
        { "q" [ \ q ] }
        { "w" [ \ w ] }
        { "n" [ \ n ] }
        { "p" [ \ q ] }
        { "d" [ \ d ] }
        { "a" [ \ a ] }
        [ drop "? unknown command" print \ nop ]
    } case
;

:: rangematch ( buflen rangeraw -- range )
    rangeraw first :> from
    rangeraw second :> to
    rangeraw last :> comma

    ! command is not part of what we're looking at
    from to and [                             ! 1,2n
        from to sort-pair 2array
    ] [                                       ! ,2n || 1,n || ,n || 1n
        comma [                               ! 1,n || ,2n
            from [                            ! 1,n
                from buflen sort-pair 2array
            ] [                               ! ,2n || ,n
                to [                          ! ,2n
                    1 to sort-pair 2array
                ] [                           ! ,n
                    1 buflen 2array
                ] if
            ] if
        ] [                                   ! 12n
            { from from }
        ] if
    ] if
;

! note to self: do not change
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
        { 1 1 } :> rangereal!
        ast number? [
            ! ast .
            ! { ast ast } rangereal!
            buffer ast >>linenum t
        ] [
            ! ast .
            ast first :> rangeraw
            buffer totallines>> rangeraw rangematch rangereal!
            ast last :> commandstr
            commandstr commandmatch :> cmd
            ! rangereal .
            rangereal first rangereal second and [
                rangereal buffer cmd execute( r b -- b q? )
            ] [
                buffer linenum>> :> ln
                { ln ln } buffer cmd execute( r b -- b q? )
            ] if
        ] if

        ! rangereal .
    ] [
        .
        ! drop
        "? error parsing" print
        buffer t
    ] recover
;


