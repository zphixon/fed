# fed - factor ed clone

Todo:

* Layering of commands **!!**
* Ranges -- mostly:
  * update commands that use ranges to use ranges (I kinda started bass
  ackwards)

## what

This is a clone of gnu `ed`, the standard text editor on \*nix systems. `ed`
is what [real programmers
](http://explainxkcd.com/wiki/index.php/378:_Real_Programmers) use. Of course
`fed` is written in `ed`. [(not really)](https://github.com/neovim/neovim)

## why

People probably haven't used `ed` seriously since the 80s, unless you're
sshing into really old systems. It has, surprisingly, been continuously
maintained by GNU project devs for a while, with the 2008 release of ed
1.0 containing changes as far back as 1994. It contains quite a few
extensions to the original ed, including extensions on the POSIX version as
well as including features from BSD and SunOS and backwards compatibility
that breaks POSIX compliance. I don't feel like reading the POSIX myself so
don't expect complete compatibility with either GNU or POSIX `ed`.

`ed` is pretty historic, and it's in fact older than I am. It would be a
shame to see such influential technology die out, hence why I'm trying to
continue it in a modern form.

Unfortunately, `ed` is a ~~stupid, moronic, frankly ridiculous piece of
software that supports some frankly ridiculous things~~ antiquated bit of
software, so my sanity is a bit hard pressed. Since when do you have to write
a command parser for a text editor?

## how

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

