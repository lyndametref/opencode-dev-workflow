---
name: lilypond-piano
description: Use for creating and editing LilyPond piano scores. Handles multi-staff layout with right and left hands, master .ly file with includes, measure numbering synchronization, breaks in right hand only, and piano-specific score block with optional layout (staff size) and MIDI.
---

# LilyPond Piano Skill

This skill applies to multi-voice piano scores following the project's conventions.

## File layout

Create all three files for a piano:
- `<name>.ly` — master: `\version`, `\header`, `global`, includes for both hands, `\score` block.
- `<name>-right.ily` — right hand: `right = \relative <start> { ... }`
- `<name>-left.ily` — left hand: `left = \relative <start> { ... }`

Master must include each hand:
```lilypond
\include "<name>-right.ily"
\include "<name>-left.ily"
```

Each `.ily` file must start with the master marker:
```lilypond
% -*- master: <name>.ly; -*-
```

## Piano score block

Use this template (adjust tempo and optionally add layout staff size):
```lilypond
\score {
  \new PianoStaff \with {
    instrumentName = "Piano"
  } <<
    \new Staff = "right" \right
    \new Staff = "left" \left
  >>

  \midi {
    \context {
      \Staff
      midiInstrument = "acoustic grand"
    }
    \tempo 4 = 140
  }
}
```

Optional layout:
```lilypond
\layout {
  #(layout-set-staff-size 19)
}
```

## References

See `references/` for a working example:
- `references/tetris.ly` — master file
- `references/tetris_right.ly` — right hand
- `references/tetris_left.ly` — left hand

## Example (minimal, 4 measures)

```lilypond
% <name>.ly
\version "2.24.4"
\header {
  title = "Title"
  arranger = "Arranger"
}
global = {
  \key c \major
  \numericTimeSignature
  \time 4/4
}
\include "<name>-right.ily"
\include "<name>-left.ily"
\score {
  \new PianoStaff \with { instrumentName = "Piano" } <<
    \new Staff = "right" \right
    \new Staff = "left" \left
  >>
  \layout { #(layout-set-staff-size 19) }
  \midi { \context { \Staff midiInstrument = "acoustic grand" } \tempo 4 = 140 }
}
```

```lilypond
% -*- master: <name>.ly; -*-
right = \relative e'' {
  \clef "treble" \global
  e4 b8 [ c8 ] d8 [ e16 d16 c8 b8 ] | % 1
  a4 a8 [ c8 ] e4 d8 [ c8 ] | % 2
  b4 b8 [ c8 ] d4 e4 | % 3
  c4 a4 a2 | % 4
}
```

```lilypond
% -*- master: <name>.ly; -*-
left = \relative e, {
  \clef "bass" \global
  e8 [ e'8 e,8 e'8 ] e,8 [ e'8 e,8 e'8 ] | % 1
  a,8 [ a'8 a,8 a'8 ] a,8 [ a'8 a,8 a'8 ] | % 2
  gis,8 [ gis'8 gis,8 gis'8 ] e,8 [ e'8 e,8 e'8 ] | % 3
  a,8 [ a'8 a,8 a'8 ] a,8 [ b8 c8 d8 ] | % 4
}
```

## Editing rules

- **One measure per line** in every file. Never put two measures on the same line; never split a measure across lines.
- **Measure number comment at end of every measure line** in every file:
  ```lilypond
  des2 des2 | % 2
  ```
- **Measure numbers must align across all files**. Line N is the same measure in `<name>.ly`, `<name>-right.ily`, `<name>-left.ily`. This includes master marker context, variable definitions, clefs, global as relevant.
- **Apply every structural edit to all files together** (add/remove/reorder measures). Use blank lines to keep alignment when a hand needs a different number of physical lines.
- **Breaks only in right hand** (`\break`, `\noBreak`). Do not put breaks in left hand. The break stays on the measure line it follows and does not change numbering.
- **Use `\relative` with explicit starting note for each hand.**

## Style

- Only comments: measure-number comments and the `master:` line.
- Attach dynamics to notes (`_\mp`, `_\f`, ...); articulations after (`->`, `\fermata`).
- Indent music inside variables with 4 spaces.
- Keep minimal and idiomatic LilyPond.

## Workflow

1. Understand existing files if present; follow naming and conventions exactly.
2. For new scores, create master + right + left with proper includes and marker.
3. When editing, read all three files together to preserve alignment.
4. Make coordinated changes across all files.
5. Verify measure counts/numbering align.