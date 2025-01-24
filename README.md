[![Install](https://img.shields.io/badge/install-curseforge-f16436)](https://www.curseforge.com/wow/addons/alerta)

# <img width="36" height="36" src="inv_misc_head_dragon_01.jpg" alt="image" style="vertical-align: middle;"/> Alerta
Alerta is a WoW add-on that informs you of unexpected mob aggro.

Designed for `WoW Classic Hardcore`.

## Requirements

Enemy nameplates should be turned on in game due to WoW API limitations. Press V (default) to enable.

## How it works

When enemy is nearby and you are its primary target - you get sound notification.
Enemy threat is detected by two events `UNIT_THREAT_LIST_UPDATE` and `NAME_PLATE_UNIT_ADDED`.
Detection range is limited by WoW default plate range (cannot be changed in classic).

## Congiruation

You can configure addon using options menu (AddOns tab) or using `/alerta` chat command.

Following settings can be set:

- Sound - you can pick any sound from `SharedMedia`
- Channel - sound channel to be used to play sound
- Print aggro to chat - output aggro information to chat

Addons registers as `SharedMedia` following sounds:

- Alerta
- Alert Unexpected
- Another One
- Hello there

## Third-party references

Inspired by [Classic Hardcore Moments](https://www.youtube.com/@classichc) videos

Used [Ace libraries](https://www.wowace.com)

Icon belongs to [Blizzard](https://www.blizzard.com)
