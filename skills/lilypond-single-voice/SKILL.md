---
name: lilypond-single-voice
description: Use for creating and editing single-voice LilyPond scores (e.g. recorder, flute, violin, clarinet, trumpet, harp, etc.). Simple single-file layout (no split, no master, no .ily includes), one measure per line with measure number comments, and appropriate score/MIDI/layout setup.
---

# LilyPond Single Voice Skill

Applies to instruments with only one voice.

## File layout

- Create a single file only: `<name>.ly`
- No split, no master, no `.ily` include files.

## Score structure

Keep minimal. Include version, header, music variable, and score. Example:
```lilypond
\version "2.24.1"

\header {
  title = "..."
  composer = "..."
}

music = \relative c' {
  % music here
}

\score {
  \music

  \midi {
    \context {
      \Staff
      midiInstrument = "recorder"
    }
    \tempo 4 = 100
  }

  \layout {}
}
```

Adjust midi tempo and layout as needed. Can include `#(layout-set-staff-size N)` in layout if desired.

## References

See `references/` for an example based on the Tetris theme (recorder-friendly single voice):
- `references/tetris_recorder.ly` — single-voice adaptation of the right hand opening

## Example (minimal)

```lilypond
\version "2.24.4"

\header {
  title = "Title"
  composer = "Composer"
}

music = \relative e'' {
  \clef "treble"
  \key c \major
  \numericTimeSignature
  \time 4/4
  e4 b8 [ c8 ] d8 [ e16 d16 c8 b8 ] | % 1
  a4 a8 [ c8 ] e4 d8 [ c8 ] | % 2
  b4 b8 [ c8 ] d4 e4 | % 3
  c4 a4 a2 | % 4
}

\score {
  \music

  \midi {
    \context {
      \Staff
      midiInstrument = "recorder"
    }
    \tempo 4 = 140
  }

  \layout {
    #(layout-set-staff-size 19)
  }
}
```

## Editing rules

- **One measure per line**. Never put two measures on the same line; never split a measure across lines.
- **Measure number comment at end of every measure line**:
  ```lilypond
  c4 d4 e4 f4 | % 1
  ```
- **Use `\relative` with an explicit starting note.**
- **Breaks** (`\break`, `\noBreak`) go on the measure line they follow; they do not change measure numbering.

## Style

- Only comments: measure-number comments (no extra verbose comments unless explicitly requested).
- Attach dynamics to notes (`_\mp`, `_\f`, ...); articulations after (`->`, `\fermata`).
- Indent music inside the variable with 4 spaces.
- Minimal boilerplate.

## Workflow

1. Read existing single file to understand style and structure.
2. Make precise measure-level edits.
3. Keep each measure annotated with its correct number.