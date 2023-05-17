# NESWorkshop
NES assembly programming workshop

In this workshop you will get started with developing NES games on your machine.

## Getting started
* Install Visual Studio Code https://code.visualstudio.com/
* Add extention to Visual Studio Code: ca65 Macro Assembler Language Support (6502/65816) by Cole Campbell
* Install FCEUX emulator https://github.com/TASEmulators/fceux
* Instal CC65 (windows: download from https://cc65.github.io/getting-started.html, mac: brew install cc65, linux: download package or build yourself) 


## Workshop Steps
### First build  
* check out repo https://github.com/jresoort/NESWorkshop
* update build_game.bat or build_game.sh (depending on platform) to point to cl65 executable
* run script to build game.nes file
* run game.nes in fceux emulator to try out

### Show sprites  
* We are enabling sprites  #0
* and loading them to memory #1

### Move a sprite
* Move the first sprite up every frame   #2

### Move sprite with controller    
* disable #2
* enable read value from controller #3
* enable controls #4

### Update sprites with different char file
* disable importing of fonts.chr file #5
* enable import og chars.inc file #6

### Fire bullets 
* enable fire button #7
* enable movement of bullet #8

### Show background
* disable #0
* enable background #9

### Add background scrolling
* enable background scrolling #10

### Use 'advanced' movement for player sprite
* disable #4
* enable #11


Well done, you have completed the guided steps. Now it's time to experiment. For example, change the speed of your player or bullets. Change the appearance and cololr of the sprites. Add enemies to shoot at. 


## Special thanks
Workshop code based on: NesHacker DevEnvironmentDemo, https://github.com/NesHacker/DevEnvironmentDemo

Font created by: 'WhoaMan', nesdev.org forum post https://forums.nesdev.org/viewtopic.php?t=10284


## Additional sources of information:
6502:
* https://archive.org/details/Programming_the_6502_OCR
* https://www.chibiakumas.com/6502/CheatSheet.pdf
* http://www.6502.org/tutorials/

NES:
* https://www.nesdev.org/
* https://nerdy-nights.nes.science/
* https://famicom.party/book/
* https://www.chibiakumas.com/6502/nesfamicom.php
* https://www.youtube.com/@NesHacker/videos
* https://github.com/NesHacker
* https://nesdoug.com/


## Additional tools:
Graphics
* NES Lightbox https://famicom.party/neslightbox/
* YY-CHR (Windows only) https://www.romhacking.net/utilities/119/
* NESIFIER (Windows only) https://nesdoug.com/2021/01/07/nesifier/
* NES Asset Workshop (Windows only) https://www.romhacking.net/utilities/1742/

Music
* FamiStudio https://famistudio.org/
* Famitracker (Windows only) http://famitracker.com/index.php
