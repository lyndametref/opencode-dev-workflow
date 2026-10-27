\version "2.24.4"

\header {
  title = "Tetris Korobeiniki (Recorder)"
  arranger = "Adapted from piano arrangement"
}

music = \relative e'' {
  \clef "treble"
  \key c \major
  \numericTimeSignature
  \time 4/4
  \repeat volta 2 {
    e4 b8 [ c8 ] d8 [ e16 d16 c8 b8 ] | % 1
    a4 a8 [ c8 ] e4 d8 [ c8 ] | % 2
    b4 b8 [ c8 ] d4 e4 | % 3
    c4 a4 a2 | \break % 4
    d4 d8 [ f8 ] a4 g8 [ f8 ] | % 5
    e4 e8 [ c8 ] e4 d8 [ c8 ] | % 6
    b4 b8 [ c8 ] d4 e4 | % 7
    c4 a4 a2 | \break % 8
  }
  <c e>2 <a c>2 | % 9
  <b d>2 <gis b>2 | % 10
  <a c>2 <e a>2 | % 11
  <e gis>2 <gis b>2 | % 12
  <c e>2 <a c>2 | % 13
  <b d>2 <gis b>2 | % 14
  <a c>4 <c e>4 <e a>4 <e a>4 | % 15
  <e gis>1 | % 16
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
