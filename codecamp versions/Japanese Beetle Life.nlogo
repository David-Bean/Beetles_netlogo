globals[
  mgrass-color
  grass-steps
  root-color
  dirt-color
  default-root-health
  blade-growth-step

  time-days
  day
  tick-delay
  months
  month
  month-count
  month-roll

  beetle-color
  beetle-size
  beetle-rotate
  beetle-max-health
  beetle-max-eggs
  f-beetle-color
  m-beetle-color
  beetle-egg-lay-health

  larvae-color
  larvae-size
  larvae-rotate
  larvae-max-health

  pupae-color
  pupae-size

  eggs-color
  eggs-size
  max-eggs-health

]

breed [beetles beetle]
breed [larvae larva]
breed [eggs egg]
breed [pupae pupa]

turtles-own[health gender]
beetles-own[egg-count max-eggs]

;beetles-own[health]
patches-own[patch-health root-health]

to setup
  clear-all
  reset-ticks

  set months (list "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
  set month-count 0
  ;;; Need to figure out what month it is based on the day. Assume 30 days per month
  set grass-steps 4
  set mgrass-color 53
  set root-color 47
  set dirt-color brown
  set default-root-health 3
  set blade-growth-step 0.25

  set time-days 1
  set day 1
  set tick-delay 0.033
  ;set grow-chance-per-tick (7 * 60) / 8  ; 1 in 7 chance per day, 60 ticks per second. 1 second = 1 day. / 10 for each grass growth substep (setting to slider variable. default 53)
  set month item 0 months
  set month-roll True

  set f-beetle-color 121
  set m-beetle-color 123
  set beetle-size 3
  set beetle-rotate 30
  set beetle-max-health 40
  set-default-shape beetles "bug"
  set beetle-max-eggs 60; TEMPORARILY CHANGING TO GIVE MORE EGGS (original value was 5)
  set beetle-egg-lay-health 30

  set larvae-color white
  set larvae-size 3
  set larvae-rotate 50
  set larvae-max-health 40
  set-default-shape larvae "caterpillar"

  set eggs-color white
  set eggs-size 1.25
  set-default-shape eggs "circle"
  set max-eggs-health 40

  set pupae-color 135
  set pupae-size 2
  set-default-shape pupae "triangle 2"


  ask patches[
    set pcolor one-of (list mgrass-color)
    set patch-health (mgrass-color - pcolor)
    set root-health default-root-health

  ]

end

to go

  ask patches[grow]
  ask turtles[
    season-check
    (ifelse
      breed = beetles [move-beetle live-beetle]
      breed = larvae [move-larvae live-larvae]
      []
    )
  ]
  set-time
  set-date


  ;wait tick-delay
  tick
end
; 1 in 7 * 60


to season-check
  let chance random 2
  let adulthood FALSE
  let young-adult FALSE
  let teenager FALSE
  if (breed = larvae) [set teenager TRUE]
  if (breed = pupae) [set young-adult TRUE]
  if (breed = beetles) [set adulthood TRUE]
  if (month = "September" and teenager = FALSE)[
    if breed = eggs [change-larvae]]
  if (month = "May" and young-adult = FALSE)[
      if breed = larvae [change-pupae]]
  if (month = "June" and adulthood = FALSE)[
      if breed = pupae [change-beetles
      set adulthood TRUE]]

;  if month = "September" and chance = 1[
;    (ifelse
;      breed = eggs [change-larvae]
;      breed = beetles [die]
;      [die]
;  )]
;  if month = "May" and chance = 1[
;    (ifelse
;      breed = larvae [change-pupae]
;      breed = eggs [change-larvae]
;      [die]
;  )]
;  if month = "June" and chance = 1[
;    (ifelse
;      breed = pupae [change-beetles]
;      breed = larvae [change-pupae]
;      [die]
;  )]

;if month = "September" and day mod 241 = 0[
;    (ifelse
;      breed = eggs [change-larvae]
;      breed = beetles [die]
;      [die]
;  )]
;  if month = "May" and day mod 121 = 0[
;    (ifelse
;      breed = larvae [change-pupae]
;      breed = eggs [change-larvae]
;      [die]
;  )]
;  if month = "June" and day mod 151 = 0[
;    (ifelse
;      breed = pupae [change-beetles]
;      breed = larvae [change-pupae]
;      [die]
;  )]
end




;;; BEETLE METHODS
to add-beetles
  create-beetles add-critters-number[
  set max-eggs random beetle-max-eggs
  set size beetle-size
  set health 20 + random 20 - random 20
  set gender one-of(list "male" "female")
    if(gender = "male")[set color m-beetle-color]
    if(gender = "female")[set color f-beetle-color]
  setxy random world-width random world-height]
end

to move-beetle
  fd beetle-stride
  rt random beetle-rotate - random beetle-rotate
end

to live-beetle
  set health (health - beetle-hunger-rate)
  beetle-eat-grass
  death-check-beetle
  beetle-egg-try
end

to beetle-eat-grass
  if (patch-health > -3 and patch-health <= 0)[
    set pcolor pcolor + ammount-beetles-eat
    set patch-health (mgrass-color - pcolor)
    ifelse (health + ammount-beetles-eat < beetle-max-health)[
      set health health + ammount-beetles-eat
    ][set health beetle-max-health]

    if (patch-health <= -3)[
      set pcolor root-color
  ]]
end

to beetle-egg-try
  if (health > beetle-egg-lay-health and gender = "female")[
    if(egg-count < max-eggs)[
      beetle-lay-egg]
  ]
end

to beetle-lay-egg
  if (gender = "female" and random egg-lay-rate-mult = 1)[
    hatch-eggs 1[
      set color eggs-color
      set size eggs-size
      set health max-eggs-health]
    set egg-count egg-count + 1
  ]
end

to make-lay-egg
  ask beetles[beetle-lay-egg]
end

to death-check-beetle
  if (health < 0) or month-count > 6 [die]
end







;;; LARVAE METHODS
to add-larvae
  create-larvae add-critters-number[
    set color white
    set size larvae-size
    set health 20 + random 20 - random 20
    setxy random world-width random world-height
  ]
end

to move-larvae
  ifelse not (month = "November" or month = "December" or month = "January" or month = "February")[
    fd larvae-stride
    rt random larvae-rotate - random larvae-rotate
  ][
    fd 0.25 * larvae-stride
    rt 0.25 * random larvae-rotate - 0.25 * random larvae-rotate

  ]

end

to live-larvae
  set health (health - larvae-hunger-rate)
  if month = "February"[
    set health larvae-max-health]
  ifelse not (month = "November" or month = "December" or month = "January" or month = "February")[
    set color white
    larvae-eat-grass
    death-check-larvae][
    set color 126
  ]
end

to larvae-eat-grass
  if(root-health > 0)[
    set root-health root-health - ammount-larvae-eat
    ifelse (health + ammount-larvae-eat < larvae-max-health)[
      set health health + ammount-beetles-eat
    ][set health larvae-max-health]
  ]
  if(root-health <= 0)[
    set pcolor dirt-color]
end

to death-check-larvae
  if (health < 0)[die]
end

;;; PUPAE METHODS
to add-pupae
  create-pupae add-critters-number[
    set color pupae-color
    set size pupae-size
    setxy random world-width random world-height]
end

;;; EGG METHODS
to add-eggs
  create-eggs add-critters-number[
    set color eggs-color
    set size eggs-size
    setxy random world-width random world-height]
end



;;; LIFE STAGE METHODS
to metamorphosis
  ask turtles[
    (ifelse
      breed = eggs [change-larvae]
      breed = larvae [change-pupae]
      breed = pupae [change-beetles]
      breed = beetles [die]
      []
      )
  ]
end

to change-larvae
  hatch-larvae 1 [
    set color larvae-color
    set size larvae-size
    set health health ;keeping health they had when they changed
  ]if (True)[die]
end

to change-pupae
  hatch-pupae 1 [
    set color pupae-color
    set size pupae-size
    set health health
  ]if (True)[die]
end

to change-eggs
  hatch-eggs 1 [
    set color eggs-color
    set size eggs-size
    set health health
  ]if (True)[die]
end

to change-beetles
  hatch-beetles 1 [
    set max-eggs random beetle-max-eggs
    set color beetle-color
    set size beetle-size
    set health health
    set gender one-of(list "male" "female")
    if(gender = "male")[set color m-beetle-color]
    if(gender = "female")[set color f-beetle-color]
  ]if (True)[die]
end

to all-change-larvae
  ask turtles[change-larvae]
end

to all-change-pupae
  ask turtles[change-pupae]
end

to all-change-eggs
  ask turtles[change-eggs]
end

to all-change-beetles
  ask turtles[change-beetles]
end




;;; PATCH METHODS
to grow
  set patch-health (mgrass-color - pcolor)

  if(random grass-growth-rate = 1)[
    let num_root_neighbors count (neighbors with [pcolor = root-color])
    let num_dead_neighbors count (neighbors with [pcolor = dirt-color])

    if(pcolor = mgrass-color)[ ;;; If mature grass... Only mature grass can spread
      if num_dead_neighbors > 0[
        ask one-of neighbors with [pcolor = dirt-color][
          if random 100 < grass-sprout-rate[
            set pcolor root-color]]]
    ]
    if(pcolor = root-color)[  ;;; If just roots...
      set patch-health 6
      if random 100 < grass-sprout-rate[
        set pcolor mgrass-color + grass-steps; random chance to turn to young grass
        set root-health default-root-health
      ]

    ]
    if(mgrass-color + grass-steps + 1 > pcolor and pcolor > mgrass-color)[ ;;; If grass not yet mature, chance to age up. Grass ages up by subtracting from color value.
      let current-color pcolor
      if random 100 < grass-growth-rate[
        ifelse(current-color - blade-growth-step < mgrass-color)[
        set pcolor (current-color - blade-growth-step)
        ][
          set pcolor mgrass-color
        ]
    ]
  ]]
; Need to make yellows have a chance to turn green, but only allow greens to turn browns yellow
; Want roots on a spectrum from brown to yellow
; Want grass on a spectrum from yellow to green

; root sprout rate = grass sprout rate
end


;;; WORLD METHODS
to set-time
  set time-days time-days + tick-delay
  set day floor time-days
  set month item month-count months
end


to set-date
  if(day mod 30 = 0 and month-roll = True)[
    set month-roll False
    ifelse(month-count = 11)[
      set month-count 0]
    [set month-count month-count + 1]
  ]
  if (day mod 30 != 0)[
    set month-roll True]
end

@#$#@#$#@
GRAPHICS-WINDOW
337
24
1551
639
-1
-1
6.0
1
10
1
1
1
0
1
1
1
-100
100
-50
50
0
0
1
ticks
30.0

BUTTON
30
67
93
100
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
92
67
155
100
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
551
187
584
grass-chance-to-spread
grass-chance-to-spread
0
100
10.0
1
1
%
HORIZONTAL

SLIDER
14
595
186
628
birth-rate
birth-rate
0
1
0.89
0.01
1
eggs/day
HORIZONTAL

SLIDER
16
642
188
675
mr-eggstolarva
mr-eggstolarva
0
0.1
0.071
.001
1
NIL
HORIZONTAL

SLIDER
16
687
190
720
mr-larva-pupa
mr-larva-pupa
0
.1
0.02
.01
1
NIL
HORIZONTAL

SLIDER
30
100
202
133
add-critters-number
add-critters-number
0
100
20.0
1
1
NIL
HORIZONTAL

BUTTON
5
133
102
166
NIL
add-beetles
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
255
187
288
beetle-hunger-rate
beetle-hunger-rate
0
0.5
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
13
476
186
509
grass-growth-rate
grass-growth-rate
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
14
512
186
545
grass-sprout-rate
grass-sprout-rate
0
50
2.0
1
1
NIL
HORIZONTAL

BUTTON
102
133
197
166
Add Larvae
add-larvae
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
223
187
256
beetle-stride
beetle-stride
0
1
0.4
.05
1
NIL
HORIZONTAL

SLIDER
15
374
187
407
larvae-stride
larvae-stride
0
.2
0.036
.001
1
NIL
HORIZONTAL

MONITOR
30
24
87
69
Day
day
0
1
11

MONITOR
86
24
156
69
NIL
month
17
1
11

SLIDER
15
406
187
439
larvae-hunger-rate
larvae-hunger-rate
0
.5
0.178
.001
1
NIL
HORIZONTAL

SLIDER
15
288
187
321
ammount-beetles-eat
ammount-beetles-eat
0
3
0.9
.05
1
NIL
HORIZONTAL

SLIDER
16
439
188
472
ammount-larvae-eat
ammount-larvae-eat
0
.65
0.08
.005
1
NIL
HORIZONTAL

BUTTON
5
165
103
198
NIL
add-eggs
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
103
165
197
198
NIL
add-pupae
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
187
246
323
293
NIL
metamorphosis
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
189
337
320
370
Change all to Larvae
all-change-larvae
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
189
370
320
403
Change all to Pupae
all-change-pupae
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
188
304
320
337
Change all to Eggs
all-change-eggs
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
188
403
321
436
Change all to Beetles
all-change-beetles
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
197
445
278
478
Lay Eggs
make-lay-egg
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
14
341
186
374
egg-lay-rate-mult
egg-lay-rate-mult
0
1000
51.0
1
1
NIL
HORIZONTAL

PLOT
338
643
1549
798
Populations v Time
Time (days)
Population
0.0
360.0
0.0
100.0
true
true
"" ""
PENS
"eggs" 1.0 0 -12895429 true "" "plotxy day count eggs"
"larvae" 1.0 0 -10022847 true "" "plotxy day count larvae"
"pupae" 1.0 0 -16777216 true "" "plotxy day count pupae"
"beetles" 1.0 0 -14333415 true "" "plotxy day count beetles"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

caterpillar
true
0
Polygon -7500403 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210
Line -16777216 false 135 255 90 210
Line -16777216 false 165 225 120 195
Line -16777216 false 135 165 180 210
Line -16777216 false 150 150 201 186
Line -16777216 false 165 135 210 150
Line -16777216 false 165 120 225 120
Line -16777216 false 165 106 221 90
Line -16777216 false 157 91 210 60
Line -16777216 false 150 60 180 45
Line -16777216 false 120 30 96 26
Line -16777216 false 124 0 135 15

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
