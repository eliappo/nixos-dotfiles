(defcfg
  process-unmapped-keys yes
  linux-dev(
            /dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd
            )
)

;; ISO keyboard layout with 102nd key (IntlBackslash)
(defsrc
  esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    
  caps a    s    d    f    g    h    j    k    l    ;    '    \    ret
  lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
  left down up rght del
  )

;; Home row mods with GACS order (GUI/Win, Alt, Ctrl, Shft)
;; Left hand:  A-gui  S-alt  D-ctrl  F-shift
;; Right hand: J-shift  K-ctrl  L-alt  ;-gui
(deflayer base
  _    1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    
  _ @a   @s   @d   @f   g    h    @j   @k   @l   @;   '    \    ret
  lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
  esc  lmet lalt          @syml                ralt rmet rctl
  left down up rght esc ;; Arrow keys
)

(deflayer symbols
  _     RA-8 S-8  S-9  RA-9 _      _    _    _       _    _    _    _    _
  S-1   ,    RA-7 RA-0 S-,  S--    _    _    _       S--  '    _    _    
  S-2   S-]  S-0  S-/  RA-4 S-3    _    _    @btick  _    _    _    \    _
  RA-2  RA-] 102d RA-= /    S-102d S-7  RA-9 _       102d ;    _    _
  _    _    _              spc              bspc ret  _
  \ _ _ RA-102d S-6
)

(defalias
  ;; Space with layer toggle
  syml (tap-hold 200 200 spc (layer-toggle symbols))

  
  ;; Left hand home row mods (GACS order)
  a (tap-hold 200 200 a lmet)  ;; A - GUI/Win/Super
  s (tap-hold 200 200 s lalt)  ;; S - Alt
  d (tap-hold 200 200 d lctl)  ;; D - Ctrl
  f (tap-hold 200 200 f lsft)  ;; F - Shift
  
  ;; Right hand home row mods (GACS order, mirrored)
  j (tap-hold 200 200 j rsft)  ;; J - Shift
  k (tap-hold 200 200 k rctl)  ;; K - Ctrl
  l (tap-hold 200 200 l ralt)  ;; L - Alt
  ; (tap-hold 200 200 ; rmet)  ;; ; - GUI/Win/Super
  btick (macro S-=)
)

