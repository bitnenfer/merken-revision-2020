[![MERKÉN](https://img.youtube.com/vi/fM0lwf--fZk/0.jpg)](https://www.youtube.com/watch?v=fM0lwf--fZk)

MERKÉN
======

Hi! I am [bitnenfer](https://twitter.com/bitnenfer), the programmer of [MERKÉN](https://www.pouet.net/prod.php?which=85246). This was a production released during Revision 2020 for the Oldskool Demo compo. We're very happy to have received 2nd place.

I want to release the code for this tiny demo because I feel people can learn from reading other people's code even if it is pure hell, like this project for example.
You'll probably notice there is a lot of redundant and ugly code, lots of macros and weird jumps.

I don't include the tools I built for developing the demo, it only includes the generated assets and code.

I also would like to mention that the music was made by [Francisco "Foco" Cerda](https://twitter.com/FranciscoFoco) using Carillon Tracker and played using the output of the split saved file which includes a player, so there isn't much audio code apart from initializing Carillon's music player and updating it every frame.

Some of Foco's work:
- [SoundCloud](https://soundcloud.com/franciscofoco)
- [Website](http://www.cerdamusic.com/)

Source Code
-----------

All the code can be found in the `code` folder. Inside you'll find a `src` and `include` folder. 

Files in the `src` folder are assembled into object files and the ones in `include` contain constant data, like register addresses, assets and constat values.

- `main.asm`
Cartridge header, entry point, Initializes music, DMA transfer and executes the different effects.

- `memory.asm`
Includes a bunch of memory related subroutines like memcpy, memset, save_vram_memcpy, etc.

- `lcd.asm`
I don't use this a lot. It includes some subroutines for turning the LCD on and off, wait for a scanline and wait for vblank.

- `oam.asm`
This is just to let the assembler and linker that the shadow OAM RAM will be used and it shouldn't allocate from that region.

This are the list of effects. I'll describe them by the order they appear.

- `fx1.asm`
This is the where the logo is displayed and scrolled.

- `fx3.asm`
This is where the matapacos doggo appears and scrolls "matapaco is love".  

- `fx4.asm`
This is where I do the scanline wobble with the matapacos doggo.

- `fx2.asm`
This is the twister and scrolling "Hola, Revision!".

- `fx6.asm`
This is me underwater effect.

- `fx7.asm`
This is a small looping animation of my cat Shin.

- `fx8.asm`
This is a small looping animation.

- `fx9.asm`
This is a small looping animation.

- `fx5.asm`
This is a mix of two effect. A rotating cylinder showing the credits and the previous effect of `fx9.asm`.


How to Assemble
---------------

I used the [RGBDS](https://github.com/rednex/rgbds) toolchain to assemble and link this project.
To assemble it you need to install this toolchain and set the path to the binaries for the assembler and linker in the `build.bat` on line 23. With that setup you can just run build.bat and it'll create a build folder in the root of the project and generate a `.gb` which you'll be able to run on an emulator or test it on a device using a flashcart.

If you have questions you can ask me via [twitter](https://twitter.com/bitnenfer) or send me an e-mail at felipe [a] voidptr.io .

Felipe A. (bitnenfer)
