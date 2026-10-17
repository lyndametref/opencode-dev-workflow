% -*- master: tetris.ly; -*-
left =  \relative e, {
  \repeat volta 2 {
    \clef "bass" \global
    e8 [ e'8 e,8 e'8 ] e,8 [ e'8 e,8 e'8 ] | % 1
    a,8 [ a'8 a,8 a'8 ] a,8 [ a'8 a,8 a'8 ] | % 2
    gis,8 [ gis'8 gis,8 gis'8 ] e,8 [ e'8 e,8 e'8 ] | % 3
    a,8 [ a'8 a,8 a'8 ] a,8 [ b8 c8 d8 ] | \break % 4
    d,8 [ d'8 d,8 d'8 ] d,8 [ d'8 d,8 d'8 ] | % 5
    c,8 [ c'8 c,8 c'8 ] c,8 [ c'8 c,8 c'8 ] | % 6
    g,8 [ g'8 g,8 g'8 ] e8 [ e'8 e,8 e'8 ] | % 7
    a,8 [ a'8 a,8 a'8 ] a,8 [ a'8 ] a,4 | \break % 8
  }
  a8 [ e'8 a,8 e'8 ] a,8 [ e'8 a,8 e'8 ] | % 9
  b8 [ d8 b8 d8 ] b8 [ d8 b8 d8 ] | % 10
  a8 [ e'8 a,8 e'8 ] a,8 [ e'8 a,8 e'8 ] |
  gis,8 [ e'8 gis,8 e'8 ]
  gis,8 [ e'8 gis,8 e'8 ] |  % 12
  a,8 [ e'8 a,8 e'8 ] a,8 [ e'8 a,8 e'8 ] | % 13
  b8 [ d8 b8 d8 ] b8 [ d8 b8 d8 ] | % 14
  a8 [ e'8 a,8 e'8 ] a,8 [ e'8 a,8 e'8 ] | % 15
  gis,8 [ e'8 gis,8 e'8 ] gis,4 gis4 % 16
  \repeat volta 2 {
    | \break
    e8 [ e'8 e,8 e'8 ] e,8 [ e'8 e,8 e'8 ] | % 17
    a,8 [ a'8 a,8 a'8 ] a,8 [ a'8 a,8 a'8 ] | % 18
    gis,8 [ gis'8 gis,8 gis'8 ] e,8 [ e'8 e,8 e'8 ] | % 19
    a,8 [ a'8 a,8 a'8 ] a,8 [ b8 c8 d8 ] | \break % 20
    d,8 [ d'8 d,8 d'8 ] d,8 [ d'8 d,8 d'8 ] | % 21
    \barNumberCheck #22 c,8 [ c'8 c,8 c'8 ] c,8 [ c'8 c,8 c'8 ] | % 22
    gis8 [ gis'8 gis,8 gis'8 ] e,8 [ e'8 e,8 e'8 ] | % 23
    a,8 [ a'8 a,8 a'8 ] a,8 [ a'8 ] a,4 % 24
  }
  | \break
  a8 [ e'8 a,8 e'8 ] a,8 [ e'8 a,8 e'8 ] | % 25
  b8 [ d8 b8 d8 ] b8 [ d8 b8 d8 ] | % 26
  a8 [ e'8 a,8 e'8 ] a,8 [ e'8 a,8 e'8 ] | % 27
  gis,8 [ e'8 gis,8 e'8 ] gis,8 [ e'8 gis,8 e'8 ] | \break % 28
  a,8 [ e'8 a,8 e'8 ] a,8 [ e'8 a,8 e'8 ] | % 29
  b8 [ d8 b8 d8 ] b8 [ d8 b8 d8 ] | % 30
  a8 [ e'8 a,8 e'8 ] a,8 [ e'8 a,8 e'8 ] | % 31
  <gis, e'>1 \bar "|." % 32
}