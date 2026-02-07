(defcfg
  process-unmapped-keys yes
  linux-dev(
            /dev/input/by-path/platform-i8042-serio-0-event-kbd
            /dev/input/by-id/usb-CX_2.4G_Wireless_Receiver-event-kbd
            /dev/input/by-id/usb-Compx_Flow84-L@Lofree-event-kbd
            )
)

;; ISO keyboard layout with 102nd key (IntlBackslash)
(defsrc
  esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    
  caps a    s    d    f    g    h    j    k    l    ;    '    \    ret
  lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)

;; Home row mods with GACS order (GUI/Win, Alt, Ctrl, Shift)
;; Left hand:  A-gui  S-alt  D-ctrl  F-shift
;; Right hand: J-shift  K-ctrl  L-alt  ;-gui
(deflayer base
  caps 1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    
  esc  @a   @s   @d   @f   g    h    @j   @k   @l   @;   '    \    ret
  lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           @syml2          @syml rmet rctl
)

(deflayer symbols
   _    RA-8 S-8  S-9  RA-9 _      _    _    _    _    _    _    _    _
   S-1  ,    RA-7 RA-0 S-,  S--    _    _    _    S--  '    _    _    
   S-6  S-]  S-0  S-/  RA-4 S-\    _    _    _    _    `    _    \    _
RA-102d RA-] 102d RA-= /    S-102d S-7  RA-9 _    102d ;    _    _
   _    _    _              spc              bspc ret  _
)

(deflayer symbols2
   _    RA-8 S-8  S-9  RA-9 _      _     _    _    _    _    _    _    _
   S-1  ,    RA-7 RA-0 S-,  S--    _     _    _    S--  '    _    _    
   S-6  S-]  S-0  S-/  RA-4 S-\    _     _    _    _    `    _    \    _
   RA-2 S-6  \    S-2  -    RA-102d S-7  RA-9 _    102d ;    _    _
   _    _    _              spc              bspc ret  _
)

(defalias
  syml (tap-hold 200 200 ralt (layer-toggle symbols))
  syml2 (tap-hold 200 200 spc (layer-toggle symbols2))
  
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
)
