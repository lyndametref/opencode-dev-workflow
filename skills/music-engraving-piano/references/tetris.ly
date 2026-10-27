\version "2.24.4"

\header {
  source =  "http://musescore.com/score/123325"
  title =  "Tetris Korobeiniki"
  arranger = "Bereczki Zoltán"
}


global = {
  \key c \major
  \numericTimeSignature
  \time 4/4
}
% The two hands live in their own files, so each can also be
% typeset on its own (see the commented \score block in each of them).
\include "tetris_right.ly"
\include "tetris_left.ly"

\score {
  \new PianoStaff \with {
    instrumentName = "Piano"
  } <<
    \new Staff = "right" \right
    \new Staff = "left" \left
  >>
  \layout {
    #(layout-set-staff-size 19)
  }
  \midi {
    \context {
      \Staff
      midiInstrument = "acoustic grand"
    }
    \tempo 4 = 140
  }
}
