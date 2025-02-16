Game Boy battery-less patching for bootleg cartridges
=====================================================


Some Game Boy bootleg cartridges made nowadays have no battery in their PCBs. Instead, they use a single Flash ROM that stores both the game and the savegame.<br/>
Pirate cartridge sellers patch the ROMs they are going to sell so the games redirect reads/writes calls from/to SRAM and use the Flash ROM instead.

This [RGBDS](https://github.com/gbdev/rgbds) skeleton project allows you to create your own battery-less patches for your Game Boy ROMs, so you can reflash a bootleg cartridge with your favorite game and keep its loading/saving features working.

It's based on [BennVennElectronic's tutorial](https://www.youtube.com/watch?v=l2bx-udTN84).<br/>
All this does is to automate and ease the process by making the most of RGBDS's [RGBLINK overlaying features](https://rgbds.gbdev.io/docs/v0.7.0/rgblink.1#O).<br/>Still, Game Boy hardware and debugging knowledge is needed because user will need to find some offsets, free RAM sections, etc, where our new code will be stored.

For now, it's only compatible with WR/AAA/A9 cart types and 64kb flashable sector size. But code should be easily scalable to other types if somebody does the reverse engineer needed for them.

Thanks to BennVennElectronic and Lesserkuma for their help!


Additional RTC Patch
--------------------

disassembled from:<br>
https://www.infine.st/<br>
https://www.romhacking.net/hacks/4450/<br>

Thank you infinest for the original patch.

"This patch allows the player to change the real-time clock while in the Pokegears clock menu.<br>
Simply press up to advance and down to turn back the time.<br>
Holding the A button allows you to change it faster."


How to
------
1. Install rgbds, get [RGBDS](https://rgbds.gbdev.io/install) and unzip it at `rgbds` folder or specify your rgbds folder using `RGBDS=../rgbds/ make`
2. Place the game you are going to patch as `roms/"category"/"romname"/"romname".gbc` file. The last folder and the ROM must have the same name.
3. Optional: If a savegame of the game exists at `roms/"category"/"romname"/"romname".sav` then it will be included into the batteryless ROM.
4. Copy one of the example `settings.asm` files to your new `roms/"category"/"romname"` directory and carefully edit it, filling all needed offsets and constants for your game.
5. Compile with `make`.
6. If there were no errors, a ROM  will be created in the same folder as the input.gbc.
7. Flash your bootleg cartridge with the new generated ROM.

Note: when saving, the game might freeze a few frames. This is normal, it's just the cheap Flash ROM chip doing its magic!



Examples
--------
You can find `settings.asm` examples for some ROM hacks and translations in the `roms/` folder.<br/>
Just create a new folder in `roms/*/` - if both a `settings.asm` and a `input.gbc`file are present, it will be build by `make`



Licences
--------
```src/rtc.asm``` is licenced under the GPLv3 licence.<br>
```src/hardware.inc``` is licenced under the CC0-1.0 licence.<br>
```src/batteryless.asm```, ```src/main``` and all ```settings.asm``` files are licenced under the MIT licence.<br>
That means, that this Project is a a whole is licenced under the GPLv3,<br>
while individual source files are dual-licenced with their original licence and the GPLv3<br>
Most source files should have SPDX licence headers.
