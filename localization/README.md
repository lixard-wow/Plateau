# Translating Plateau

Plateau shows every word in English until someone translates it. English text is the key: the addon looks up each English sentence and uses your translation when there is one.

## Add or improve a language

1. Find your language file in `Plateau/Locales/`: `deDE` German, `esES` Spanish (Spain), `esMX` Spanish (Mexico), `frFR` French, `itIT` Italian, `koKR` Korean, `ptBR` Portuguese, `ruRU` Russian, `zhCN` Simplified Chinese, `zhTW` Traditional Chinese.
2. Open `localization/template.lua`. Every line looks like this:

   ```lua
   L["Show crowd control"] = "Show crowd control"
   ```

3. Copy the lines you want to translate to the end of your language file, then change only the text on the **right** side:

   ```lua
   L["Show crowd control"] = "Kontrolleffekte anzeigen"
   ```

   Never change the left side. It must match the English exactly, or the line does nothing.
4. You don't have to translate everything. Any line you leave out stays in English.
5. Reload the game (`/reload`) to see your changes.

## Sending your translation

Send your finished language file as a pull request or an issue on the [Plateau GitHub page](https://github.com/lixard-wow/Plateau). Say how you'd like to be credited; translators are named in the README and changelog.

The [LICENSE](../LICENSE) allows you to copy and edit the language files and this template for exactly this purpose. By sending a translation you confirm it's your own work and agree it can be included in Plateau. It doesn't allow sharing Plateau or a translated copy anywhere else.

## Placeholders

Some lines contain `%s` (a word or name) or `%d` (a whole number), like `L["A profile called %s already exists"]`. Keep every placeholder in your translation. If your language needs them in a different order, number them: `%2$s` is the second value and `%1$s` the first.

## Colors and icons

Text like `|cff8a93a6` … `|r` (a color) or `|T…|t` (an icon) must be copied as is. Translate only the words between them.

## Tips

- Other languages often run longer than English. If a label gets cut off, a shorter wording usually fits.
- Profile names stay in English because they are saved in your settings. You can translate the built-in look names (Minimal, Familiar layout and so on); that changes their look cards, while the profile list keeps the saved English name.
- Spell, class and zone names come from the game and are already in your language.

## For developers

`tests/make_locale_template.lua` rebuilds `localization/template.lua` from the code. Run it from the repository root after changing any player-facing text; the test suite fails while the template is out of date. Text shown to players must reach a lookup as one whole sentence: write `L["Active profile: %s"]:format(name)`, never `"Active profile: " .. name`.
