Phage
=====

*Release notes moved here from a now defunct blog. Beware; there are broken links here.*

Version 0.2.1 -------------

I just fixed a bug that caused Phage to be confused about whether you or the AI had won
the game. This would sometimes cause Phage to declare that the AI won the game, when in
fact you had. Pesky cheating AIs. At least I get to test whether auto-updating with
Sparkle works then, which I introduced in the [last release](/2007/04/26/phage-02/).

[Download Phage 0.2.1](http://code.brautaset.org/Phage/download/Phage_0.2.1.dmg) (0.5 MB
disk image). [Visit the homepage](http://code.brautaset.org/Phage/).

Version 0.2 -----------

There's not a lot of changes in here, but one of them should make incremental releases
much more manageable. I also gave the website a little face lift, so hopefully it
shouldn't scare off people now.

The changes in this release are:

* Added a progress indicator for things that go on in the background.
* Added a "Move hint" menu item. Selecting this makes the AI give you a hint for a move.
* Added a "Check for updates" menu item to check if new versions are available, using the
wonderful [Sparkle](http://sparkle.andymatuschak.org/) framework. You also have the option
to automatically check for new versions on startup.


[Download Phage](http://code.brautaset.org/Phage/download/Phage_0.2.dmg) (0.5 MB disk
image). [Visit the homepage](http://code.brautaset.org/Phage/).

Introducing Phage
-----------------

[Phage](http://code.brautaset.org/Phage/) is a strategy game for 2 players, where you play
against an AI (built using my [game-tree search](http://code.brautaset.org/SBAlphaBeta)
framework). The interface is a bit crude&mdash;click origin, then click target instead of
drag and drop&mdash;and the featureset is somewhat limited, but it's got the basics
(making moves, undo) and I'd like it out there for people to play with.

<img src="http://blog.brautaset.org/files/2007/03/phage.png" border="0" width="400"
alt="phage.png" align="" />

Previously I've just been re-implementing old classics (like
[Reversi](http://code.brautaset.org/CocoaGames/Desdemona.dmg) &amp;
[Connect-4](http://code.brautaset.org/CocoaGames/Puck.dmg)), but this is completely
original.  After seeing some of my game-tree search work online Steve Gardner, Phage's
inventor, contacted me about creating a computer version of his game. So I did, after
<del>stalling</del> mulling it over for about a year.

I created the core of the game logic at a [hack
day](http://fotango.com/blog/2006/11/24/hackdays) four weeks ago and a first stab at an
interface the following weekend. A new hack day is coming up, and assuming I get the
chance to hack more on Phage then, what do you think I should focus on next? A more
challenging AI? Drag-n-drop of pieces? Highlight possible moves? Answers in the comments
please!
