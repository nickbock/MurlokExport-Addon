# Contributing to MurlokExport

Bug reports, ideas and translations are welcome as [issues](../../issues/new/choose). Pull requests too: open one against `main`.

## How this repo fits together

WoW addons cannot make web requests, so all data is baked into `MurlokExport/Data/Export.lua` by a separate, daily data build. That file is **not in this repo**: the build takes the addon from here, adds a fresh `Export.lua`, and publishes the result to CurseForge.

| Path | |
| --- | --- |
| `MurlokExport/` | **The release.** This folder is zipped as-is; nothing outside it ships. |
| `MurlokExport/MurlokExport.toc` | Manifest and load order. A file not listed here does not load. |
| `MurlokExport/{Core,Frames,Locales}/` | The addon: XML frame templates + Lua mixins. |
| `MurlokExport/Libs/` | Vendored LibDBIcon-1.0, LibDataBroker-1.1, AceLocale-3.0. Don't edit. |
| `README.md` | The CurseForge description, word for word. |
| `Changelog.md` | Sent to CurseForge verbatim as release notes, so it is user-facing copy. |

## Testing in game

1. Install the latest MurlokExport from CurseForge once, so you have a `Data/Export.lua`.
2. Copy `MurlokExport/` from this repo over `Interface/AddOns/MurlokExport/` in your WoW folder, keeping the `Data/` folder from step 1.
3. `/reload`, then open the addon with `/me`. Check for Lua errors (BugSack helps).

## Translations

Strings live in `MurlokExport/Locales/<locale>.lua`, with `enUS.lua` as the reference. Add a missing key to your locale's file, or fix a wrong one.

## The data format

`Export.lua` sets one global, `MurlokExport`; top-level keys are the six modes (`m+`, `solo`, `2v2`, `3v3`, `blitz`, `rbg`) plus `timestamp`.

```
MurlokExport["m+"][class][spec][hero] = {
  id, count, rating,
  secondary_stats = { haste|crit|mastery|versatility = {percent, value} },  -- sorted desc
  minor_stats     = { leech|speed|avoidance          = {percent, value} },
  talents = { <up to 5 export strings> },
  traits  = { class|spec|hero|pvp = { [nodeID] = {count, rank} } },
  equips  = { [slot] = { order,
                items        = { [itemID]    = {count, rank, bonus={...}} },
                gems         = { [itemID]    = {count, rank} },
                enchantments = { [enchantID] = {count, rank, source={type,id}} } } }
}
```

The top-level `count` is how many of the **specialization's** top 50 play this hero tree. Every nested `count` is how many of **this hero's** own top 50 use it, so a nested count can exceed the top-level one. `rank` is the index of the highest-rated player using it, `0` being #1; it drives `core:getRankColor` in `MurlokExport/Core/Core.lua`. Only the top 5 per slot per category are kept.

## Other addons that depend on this one

- **Talent Loadout Ex** (CurseForge `730873`) reads the `MurlokExport` table and the global `ClassConfig` from `_G`. `ClassConfig` is global only because `MurlokExport/Frames/ClassList.lua` omits `local`: keep it that way. It uses `id`, `rating`, `talents[1]`, `traits.pvp[*].count` and the class/spec/hero key names, so treat those as a public API.
- **Gorloc Consumables** (CurseForge `1725989`) is an optional dependency read in game through `core:GetConsumablesAPI()`. It must stay optional: without it, the Consumables toggle and tab hide and nothing errors.

## Things to know

- **New WoW patch:** bump `## Interface:` in the TOC (12.1.5 → `120105`) and `## Version:`, and add a `Changelog.md` entry. A release players should hear about in game also gets an entry in `ReleaseNotes` in `MurlokExport/Frames/WhatsNew.lua`, keyed by `## Version:`, with strings in every locale.
- **`MurlokExport/Core/Init.lua` is the fragile part**: it reaches into `PlayerSpellsFrame.TalentsFrame` and `MenuTemplates` internals. Check it first after a patch.
- **Anything the game loads goes inside `MurlokExport/`** and is listed in the TOC. The lint check fails a PR whose TOC lists a missing file.

## License

MurlokExport is licensed under the GNU General Public License v3.0, see [LICENSE](LICENSE). The libraries in `MurlokExport/Libs/` keep their own licenses.
