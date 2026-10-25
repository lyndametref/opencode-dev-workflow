---
name: musicxml-to-lilypond
description: Convert a MusicXML score (.musicxml, .xml, .mxl) to LilyPond using musicxml2ly, then restructure the raw output to the lilypond-piano or lilypond-single-voice layout. Use when the user provides a MusicXML file to turn into a LilyPond score.
---

# MusicXML to LilyPond Skill

Converts MusicXML input into LilyPond. It just make the conversion and does not check for the layout and guidelines. Input must be MusicXML. MuseScore files (`.mscz`, `.mscx`) are not accepted: ask the user for a MusicXML export.

## Prerequisites

- `musicxml2ly` available on PATH (ships with LilyPond).
- `lilypond` available for compile checks.

## Procedure

1. **Convert**
   - `musicxml2ly -o <name>.ly <name>.musicxml`
   - `.mxl` input works the same way: `musicxml2ly -o <name>.ly <name>.mxl`
   - Add `-m` only if a MIDI block is wanted.
   - Use `-l <language>` only if the user asks for non-English pitch names.
2. **Check output**: the `.ly` file exists and is not empty. Read any error or warning output.
3. **Compile** with `lilypond <name>.ly` and fix errors and warnings.
4. **Report**: files created, checks performed, compile result, and any conversion losses or open questions.

## Notes

- `musicxml2ly` output is raw; do not treat it as final engraving.
- Do not change the composer's music. If the conversion is wrong, report it instead of editing notes to fit.
- Use `--npl` (no page layout) if the source page breaks interfere with the skill's layout; state this in the report.
- Intermediate files go in `./.tmp/` and must be removed before finishing.

## Common options

- `-m, --midi`: add MIDI block.
- `-a, --absolute`: absolute pitch mode instead of relative.
- `--npl, --no-page-layout`: ignore source page layout and breaks.
- `--nb, --no-beaming`: use LilyPond automatic beaming.
- `-o, --output=file`: output file name.
