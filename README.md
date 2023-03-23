Snake Assembly x64
===========

This is a game I made for the Computer Organization course at the Vrije Universiteit in Amsterdam.

I made this with the [gamelib-x64](https://github.com/thegeman/gamelib-x64) repository, so not all credit is mine. The part I modified was only the file [game.s](https://github.com/RMusaH/myGame/blob/master/src/game/game.s) 

The [game.s](https://github.com/RMusaH/myGame/blob/master/src/game/game.s) file and its contents can be used or modified to any extent for anything you want to the extent permitted by the license of the original library.

Fell free to use my code as inspiration or to try to understand how to the gamelib-x64 works! :)

Down you can see how to boot the game as it is described in the original repository.

Requirements to boot the game
===========

_These requirements have already been fulfilled if you are using the virtual machine provided for the lab. We will not provide support for compilation or linking errors if you are not using this virtual machine._

To build your game based on gamelib-x64, you need to ensure you are using a Linux distribution on a x86-64 architecture (i.e., 64-bit Linux on any modern Intel/AMD processor) with a recent version of GNU binutils to compile. In addition, you will need Qemu or Bochs (both emulators for a.o. the x86-64 platforrm) to test your game.

Booting the game
===========

To get started on developing your game, execute the following steps:

 1.  Download a copy of gamelib-x64, using either `git clone` or the "Download ZIP" button to the right of this page.
 2.  Open a terminal and navigate to the root of the gamelib-x64 folder.
 3.  Execute `make` to compile gamelib-x64 against the default (empty) game.
 4.  Execute `make qemu` to launch the compiled game in the Qemu emulator.

