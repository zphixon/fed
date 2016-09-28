# fed - factor ed clone

Todo:

* Layering of commands **!!**
* Ranges **!!**

This is a clone of `ed`, the standard text editor on \*nix systems. `ed` is
what [real programmers
](http://explainxkcd.com/wiki/index.php/378:_Real_Programmers) use. Of course
`fed` is written in ed. (just kidding)

Factor is a pretty neat concatenative stack-based language that has an
*awesome* library and community, and I'm really enjoying it so far. I wrote
a little `ed` clone to test the waters, basically, and what's really
interesting is how many ways there are to do something.

Factor is probably the Python killer for me: it supports compiling and script
execution.

One gripe I have with it is how little functionality is actually in the core
language. You have to `USING: ;` a lot of stuff in order to get something to
run. Additionally the error messages can be misleading, especially with macros
or locals. The awesome repl and help system more than make up for it however.

