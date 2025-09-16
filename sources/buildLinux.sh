#!/bin/sh

FLAGS="-frelease -fdata-sections -ffunction-sections -fno-section-anchors -c -O2 -Wall -pipe -fversion=BindSDL_Static -fversion=SDL_201 -fversion=SDL_Mixer_202"
IMPORT_FLAGS="-I`pwd`/import"

rm import/*.o*
rm import/sdl/*.o*
rm import/bindbc/sdl/*.o*
rm src/abagames/util/*.o*
rm src/abagames/util/bulletml/*.o*
rm src/abagames/util/sdl/*.o*
rm src/abagames/tf/*.o*

cd import
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS $IMPORT_FLAGS -I. \{\} \;
cd sdl
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS $IMPORT_FLAGS \{\} \;
cd ../bindbc/sdl
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS $IMPORT_FLAGS \{\} \;
cd ../../..

cd src/abagames/util
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS $IMPORT_FLAGS -I../.. \{\} \;
cd ../../..

cd src/abagames/util/bulletml
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS $IMPORT_FLAGS -I../../.. \{\} \;
cd ../../../..

cd src/abagames/util/sdl
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS $IMPORT_FLAGS -I../../.. \{\} \;
cd ../../../..

cd src/abagames/tf
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS $IMPORT_FLAGS -I../.. \{\} \;
cd ../../..

gdc -o TUMIKI_Fighters -s -Wl,--gc-sections -static-libphobos import/*.o* import/sdl/*.o* import/bindbc/sdl/*.o* src/abagames/util/*.o* src/abagames/util/bulletml/*.o* src/abagames/util/sdl/*.o* src/abagames/tf/*.o* -lGL -lSDL2_mixer -lSDL2 -lbulletml -L./lib/x64
