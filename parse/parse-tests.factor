! Copyright (C) 2016 Zack Hixon
! see LICENSE.txt for copyright notice

USING: tools.test fed.command vectors ;
IN: fed.command.tests

[
    1
] [
    "1\n" fedcommand
] unit-test

[
    V{ { 1 2 "," } "n" }
] [
    "1,2n\n" fedcommand
] unit-test

[
    V{ { 1 f "," } "n" }
] [
    "1,n\n" fedcommand
] unit-test

[
    V{ { f 2 "," } "n" }
] [
    ",2n\n" fedcommand
] unit-test

[
    V{ { f f "," } "n" }
] [
    ",n\n" fedcommand
] unit-test

[
    V{ { 1 f f } "n" }
] [
    "1n\n" fedcommand
] unit-test

[
    V{ { f f f } "n" }
] [
    "n\n" fedcommand
] unit-test

