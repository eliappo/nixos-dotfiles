(defcfg
  process-unmapped-keys yes
)

;; ISO keyboard layout with 102nd key (IntlBackslash)
(defsrc
  esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    
  caps a    s    d    f    g    h    j    k    l    ;    '    \    ret
  lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)

;; Pass through all keys unchanged - Danish mapping happens at OS level
(deflayer base
  caps 1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    
  esc  a    s    d    f    g    h    j    k    l    ;    '    \    ret
  lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           @spc           ralt rmet rctl
)

(deflayer symbols
  _    RA-8 S-8  S-9  RA-9 _    _    _    _    _    _    _    _    _
  _    S-1  RA-7 RA-0 _    _    _    _    _    S--  '    _    _    
  _    _    /    RA-7 RA-0 _    _    _    _    _    `    _    \    _
  _    _    _    _    _    _    RA-8 RA-9 _    102d ;    _    _
  _    _    _              spc            bspc ret  _
)

(defalias
  spc (tap-hold 200 200 spc (layer-toggle symbols))
)
