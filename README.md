# TUMIKI Fighters

Stick more enemies and become much stronger.

Sticky 2D shooter, 'TUMIKI Fighters'.

## REV 2

This is an experimental fork to test new features.
Currently this version adds:
- proper screen resize. Full screen is full resolution rather than scaled 480, and resizing keeps the proper aspect ratio
- REV mode
  - standardized control scheme. The tilt is locked on unless the secondary button is pressed, which inverts the logic compared to the original
  - point blanking. Deals more damage at close range
- Options: level select, boss rush, bullet slowdown, REV mode (default to true). Disabling REV mode means there are no changes to the gameplay; bullet slowdown is the original code.


## How to play

Control your ship and destroy enemies. The ship is destroyed when it is hit by a bullet. The body of the enemy has no collision damage.

You can catch the enemy's broken pieces. Pieces are stuck to your ship and counterattack the enemies. You can also earn the bonus score by keeping many pieces stuck. Stuck pieces are destroyed when they touch an enemy's bullet.

While holding a slow key, the ship becomes slow and the ship direction is fixed. Stuck pieces are pulled in and you can prevent a crash of them, but the bonus score reduces to one fifth. Enemy's pieces are not stuck while holding this key.
<hr/>

The game was created by [Kenta Cho](https://www.asahi-net.or.jp/~cs8k-cyu/windows/tf_e.html "Kenta Cho - TUMIKI Fighters") and released with BSD 2-Clause License. (See readme.txt/readme_e.txt)

This fork is a port to D version 2, Linux, SDL2, Pandora, DragonBox Pyra.

It uses the [libBulletML](https://shinh.skr.jp/libbulletml/index_en.html "libBulletML") library by shinichiro.h.

It uses [BindBC-SDL](https://github.com/BindBC/bindbc-sdl "BindBC-SDL") (D bindings to SDL), which is under [Boost Software License](https://www.boost.org/LICENSE_1_0.txt "Boost Software License").
