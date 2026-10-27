% -*- master: tetris.ly; -*-
right =  \relative e'' {
  \repeat volta 2 {
    \clef "treble" \global
    e4 \ff b8 [ c8 ] d8 [ e16 d16 c8 b8 ] | % 1
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
  <e gis>2 <gis b>2 |  % 12
  <c e>2 <a c>2 | % 13
  <b d>2 <gis b>2 | % 14
  <a c>4 <c e>4 <e a>4 <e a>4 | % 15
  <e gis>1
  \repeat volta 2 {
    | \break
    <b e>4 <gis b>8 [ <a c>8 ] <b d>8 [ e16 d16 <a c>8 <gis b>8 ] | % 17
    <e a>4 <e a>8 [ <a c>8 ] <c e>4 <b d>8 [ <a c>8 ] | % 18
    <gis b>8 [ e8 ] gis8 [ c8 ] <b d>4 <c e>4 | % 19
    <a c>4 <e a>4 <e a>2 | \break % 20
    <f d'>4 <f d'>8 [ <a f'>8 ] <c a'>4 <b g'>8 [ <a f'>8 ] | % 21
    \barNumberCheck #22 <g e'>4 <g e'>8 [ <e c'>8 ] <g e'>4 <f d'>8
    [ <e c'>8 ] | % 22
    <gis b>8 [ e8 ] gis8 [ c8 ] <b d>4 <c e>4 | % 23
    <a c>4 <e a>4 <e a>2
  }
  | \break
  <c e>2 <a c>2 | % 25
  <b d>2 <as b>2 | % 26
  <a c>2 <e a>2 | % 27
  <e as>2 <as b>2 | \break % 28
  <c e>2 <a c>2 | % 29
  <b d>2 <as b>2 | % 30
  <a c>4 <c e>4 <e a>4 <e a>4 | % 31
  <e as>1 \bar "|." % 32
}