# The Hardhat Climber (Lo Scalatore)

"The Hardhat Climber" is a VIC-20 video game written in BASIC by Chris Lesher 
and subsequently published in the [January 1984 issue](https://www.commodore.ca/gallery/magazines/gazette/Compute-Gazette-Issue-07-01.pdf) of Compute's Gazette as a type-in listing.

In Italy, the game was known under the name "Lo Scalatore" following its appearance in the [SuperVIC & C64 magazine (June 1984)](https://archive.org/details/Super_1984_01).

As a tribute to this simple yet beautiful game, I embarked on a complete reverse-engineering of its source code, comprising a total of 79 tightly packed BASIC V2 lines. The resulting commented file can be seen [here](lo_scalatore_commentato.bas). Please note that the comments are provided in Italian.

I've taken the liberty of creating an enhanced version of the game by turning it into machine language using the [Mospeed](https://github.com/EgonOlsen71/basicv2) compiler. This improved edition features a slightly accelerated game pace with a flicker-free smooth animation achieved by synchronizing screen drawing with the raster beam. Furthermore, some minor bugs have been fixed, and a proper credit/copyright screen page has been added. You can download this [2023 turbo edition here](mospeed/lo_scalatore_turbo_2023.prg).

This repository also contains the following:

- [the original BASIC listing](original/lo_scalatore.orig.bas.txt) typed in by `saver71` from the SuperVIC magazine.
- [the original game file](original/lo_scalatore.orig.prg) in `.prg` format.

Additional folders in this repository include:

- `cbm_prg_studio/`: CBM PRG STUDIO files used during the conversion from .prg
- `asmproc/`: (W.I.P.) an attempt to create a pure machine language version of the game
- `mospeed/`: Mospeed compiler files
- `original/`: original files
- `xc/`: (W.I.P.) an attempt to create an XC= Basic version of the game

