# Hyprland Lua renderer.
#
# Hyprland 0.56 reads `hypr/hyprland.lua` (preferred over `hypr/hyprland.conf`).
# This renders the *same* `desktop.hyprland.settings` attrset that used to feed
# `toHyprconf` into equivalent Lua, so hyprlang and Lua stay in lockstep.
#
# Shapes handled:
# - config sections  -> hl.config({ <name> = <table> }).
# - `bezier` list    -> hl.curve(name, { type = "bezier", ... }).
# - `animation` list -> hl.animation({ leaf, enabled, speed, bezier, style }).
#   hyprlang rows are `leaf, enabled, speed, curve, style`.
# - `bind` list      -> hl.bind("MOD + KEY", hl.dsp.*(...)).
# - `bindm` list     -> hl.bind(..., { mouse = true }) with drag()/resize().
# - `monitor` list   -> hl.monitor({ output, mode, position, scale, ... }).
# - `windowrule` new-syntax rows (`effect args, match:prop value, ...`)
#                      -> hl.window_rule({ match = {...}, effect = ... }).
# - `workspace` rows (`name, monitor:output`)
#                      -> hl.workspace_rule({ workspace, monitor }).
{ lib }:
let
  trim =
    s:
    let
      noLead =
        let
          m = builtins.match "^[[:space:]]*(.*)$" s;
        in
        if m == null then s else builtins.head m;
      noTrail = builtins.match "(.*[^[:space:]])[[:space:]]*$" noLead;
    in
    if noTrail == null then "" else builtins.head noTrail;

  splitComma = s: builtins.map trim (lib.splitString "," s);

  splitSpace = s: builtins.filter (x: x != "") (lib.splitString " " s);

  luaString =
    s:
    "\""
    +
      lib.replaceStrings
        [
          "\\"
          "\""
          "\n"
          "\r"
          "\t"
        ]
        [
          "\\\\"
          "\\\""
          "\\n"
          "\\r"
          "\\t"
        ]
        s
    + "\"";

  luaNumber = n: builtins.toJSON n;

  luaNumberFromString = s: luaNumber (builtins.fromJSON s);

  # Literal for plain config-section values (bool/int/float/string/list/attrs).
  toLua =
    v:
    if builtins.isBool v then
      (if v then "true" else "false")
    else if builtins.isInt v || builtins.isFloat v then
      luaNumber v
    else if builtins.isString v then
      luaString v
    else if builtins.isList v then
      "{ " + lib.concatStringsSep ", " (builtins.map toLua v) + " }"
    else if builtins.isAttrs v then
      "{ " + lib.concatStringsSep ", " (lib.mapAttrsToList (k: x: k + " = " + toLua x) v) + " }"
    else if v == null then
      "nil"
    else
      throw "lua: unsupported config value ${builtins.toJSON v}";

  # Everything that is not a top-level rule list is a config section.
  sectionOrder = [
    "general"
    "decoration"
    "animations"
    "group"
    "input"
    "binds"
    "cursor"
    "misc"
    "xwayland"
    "ecosystem"
    "render"
    "quirks"
    "debug"
  ];

  specialKeys = [
    "bezier"
    "animation"
    "bind"
    "bindm"
    "monitor"
    "workspace"
    "windowrule"
  ];

  nonEmpty = v: v != { } && v != [ ] && v != "" && v != null;

  renderConfig =
    settings:
    let
      known = builtins.filter (n: builtins.hasAttr n settings && nonEmpty settings.${n}) sectionOrder;
      extra = builtins.filter (
        n:
        builtins.hasAttr n settings
        && !(builtins.elem n (specialKeys ++ sectionOrder))
        && nonEmpty settings.${n}
      ) (builtins.attrNames settings);
    in
    lib.concatStringsSep "\n\n" (
      builtins.map (n: "-- " + n + "\nhl.config({\n    " + n + " = " + toLua settings.${n} + ",\n})") (
        known ++ extra
      )
    );

  renderCurve =
    spec:
    let
      parts = splitComma spec;
      name = builtins.head parts;
      points = builtins.tail parts;
    in
    assert builtins.length points == 4;
    "hl.curve("
    + luaString name
    + ", { type = \"bezier\", points = { { "
    + luaNumberFromString (builtins.elemAt points 0)
    + ", "
    + luaNumberFromString (builtins.elemAt points 1)
    + " }, { "
    + luaNumberFromString (builtins.elemAt points 2)
    + ", "
    + luaNumberFromString (builtins.elemAt points 3)
    + " } } })";

  renderAnimation =
    spec:
    let
      parts = splitComma spec;
      leaf = builtins.elemAt parts 0;
      enabled = (builtins.elemAt parts 1) == "1";
      speed = luaNumberFromString (builtins.elemAt parts 2);
      curve = builtins.elemAt parts 3;
      style = if builtins.length parts > 4 then builtins.elemAt parts 4 else null;
    in
    "hl.animation({\n    leaf = "
    + luaString leaf
    + ",\n    enabled = "
    + (if enabled then "true" else "false")
    + ",\n    speed = "
    + speed
    + ",\n    bezier = "
    + luaString curve
    + (if style == null then "" else ",\n    style = " + luaString style)
    + ",\n})";

  directionName =
    d:
    {
      l = "left";
      r = "right";
      u = "up";
      d = "down";
    }
    .${d} or (throw "lua: unknown focus direction ${d}");

  # "mods, key, dispatcher, arg..." (arg may itself hold commas).
  parseBind =
    spec:
    let
      raw = lib.splitString "," spec;
      rest = lib.drop 3 raw;
    in
    {
      mods = trim (builtins.elemAt raw 0);
      key = trim (builtins.elemAt raw 1);
      dispatcher = trim (builtins.elemAt raw 2);
      arg = if rest == [ ] then "" else trim (lib.concatStringsSep "," rest);
    };

  bindKeyString =
    b:
    let
      # Hyprland's Lua key parser wants canonical upper-case modifiers.
      mods =
        if b.mods == "" then
          [ ]
        else
          [ (lib.concatStringsSep "+" (builtins.map lib.toUpper (splitSpace b.mods))) ];
    in
    lib.concatStringsSep " + " (mods ++ [ b.key ]);

  mapDispatcher =
    dispatcher: arg:
    if dispatcher == "exec" then
      "hl.dsp.exec_cmd(" + luaString arg + ")"
    else if dispatcher == "killactive" then
      "hl.dsp.window.kill()"
    else if dispatcher == "layoutmsg" then
      "hl.dsp.layout(" + luaString arg + ")"
    else if dispatcher == "togglegroup" then
      "hl.dsp.group.toggle()"
    else if dispatcher == "pseudo" then
      "hl.dsp.window.pseudo()"
    else if dispatcher == "togglefloating" then
      "hl.dsp.window.float({ action = \"toggle\" })"
    else if dispatcher == "fullscreen" then
      "hl.dsp.window.fullscreen({ mode = \""
      + (if arg == "1" then "maximized" else "fullscreen")
      + "\", action = \"toggle\" })"
    else if dispatcher == "pin" then
      "hl.dsp.window.pin()"
    else if dispatcher == "movefocus" then
      "hl.dsp.focus({ direction = \"" + directionName arg + "\" })"
    else if dispatcher == "movewindow" then
      "hl.dsp.window.move({ direction = \"" + directionName arg + "\" })"
    else if dispatcher == "resizeactive" then
      let
        xy = splitSpace arg;
      in
      "hl.dsp.window.resize({ x = "
      + luaNumberFromString (builtins.elemAt xy 0)
      + ", y = "
      + luaNumberFromString (builtins.elemAt xy 1)
      + ", relative = true })"
    else if dispatcher == "workspace" then
      "hl.dsp.focus({ workspace = " + luaString arg + " })"
    else if dispatcher == "movetoworkspace" then
      "hl.dsp.window.move({ workspace = " + luaString arg + " })"
    else if dispatcher == "submap" then
      "hl.dsp.submap(" + luaString arg + ")"
    else
      throw "lua: unsupported dispatcher ${dispatcher}";

  renderBind =
    spec:
    let
      b = parseBind spec;
    in
    "hl.bind(" + luaString (bindKeyString b) + ", " + mapDispatcher b.dispatcher b.arg + ")";

  renderMouseBind =
    spec:
    let
      b = parseBind spec;
      action =
        if b.dispatcher == "movewindow" then
          "hl.dsp.window.drag()"
        else if b.dispatcher == "resizewindow" then
          "hl.dsp.window.resize()"
        else
          throw "lua: unsupported mouse dispatcher ${b.dispatcher}";
    in
    "hl.bind(" + luaString (bindKeyString b) + ", " + action + ", { mouse = true })";

  numericMonitorFields = [
    "transform"
    "bitdepth"
    "sdrbrightness"
    "sdrsaturation"
    "vrr"
  ];

  renderMonitor =
    spec:
    let
      parts = splitComma spec;
      at = i: d: if builtins.length parts > i then builtins.elemAt parts i else d;
      rest = lib.drop 4 parts;
      pairCount = builtins.div (builtins.length rest) 2;
      pairs = builtins.genList (i: {
        key = trim (builtins.elemAt rest (i * 2));
        value = trim (builtins.elemAt rest (i * 2 + 1));
      }) pairCount;
      renderPair =
        p:
        "    "
        + p.key
        + " = "
        + (
          if builtins.elem p.key numericMonitorFields then luaNumberFromString p.value else luaString p.value
        )
        + ",";
    in
    assert (builtins.length rest) - pairCount * 2 == 0;
    "hl.monitor({\n    output = "
    + luaString (at 0 "")
    + ",\n    mode = "
    + luaString (at 1 "preferred")
    + ",\n    position = "
    + luaString (at 2 "auto")
    + ",\n    scale = "
    + luaString (at 3 "1")
    + (if pairs == [ ] then "" else ",\n" + lib.concatStringsSep "\n" (builtins.map renderPair pairs))
    + "\n})";

  boolRuleEffects = [
    "float"
    "pin"
    "fullscreen"
    "immediate"
    "no_blur"
    "no_anim"
  ];

  vec2RuleEffects = [
    "move"
    "size"
    "max_size"
    "min_size"
  ];

  intRuleEffects = [
    "rounding"
    "border_size"
  ];

  floatRuleEffects = [
    "scrolling_width"
    "rounding_power"
  ];

  boolOn =
    v:
    builtins.elem v [
      "on"
      "1"
      "true"
      "yes"
    ];

  renderRuleEffect =
    name: arg:
    if builtins.elem name boolRuleEffects then
      (if boolOn arg then "true" else "false")
    else if builtins.elem name vec2RuleEffects then
      # Expression vec2: keep the hyprlang "x y" expression verbatim.
      luaString arg
    else if builtins.elem name intRuleEffects then
      luaNumberFromString arg
    else if builtins.elem name floatRuleEffects then
      luaNumberFromString arg
    else
      # String effects (idle_inhibit, opacity, tag, border_color, ...).
      luaString arg;

  renderWindowRule =
    spec:
    let
      parts = splitComma spec;
      ruleTokens = splitSpace (builtins.head parts);
      effectName = builtins.head ruleTokens;
      effectArg = lib.concatStringsSep " " (builtins.tail ruleTokens);
      matchParts = builtins.tail parts;
      renderMatch =
        m:
        let
          tokens = splitSpace m;
          prop = builtins.head tokens;
          value = lib.concatStringsSep " " (builtins.tail tokens);
          key = lib.removePrefix "match:" prop;
        in
        "        "
        + key
        + " = "
        + (if key == "xwayland" then (if boolOn value then "true" else "false") else luaString value)
        + ",";
    in
    "hl.window_rule({\n    match = {\n"
    + lib.concatStringsSep "\n" (builtins.map renderMatch matchParts)
    + "\n    },\n    "
    + effectName
    + " = "
    + renderRuleEffect effectName effectArg
    + ",\n})";

  renderWorkspaceRule =
    spec:
    let
      parts = splitComma spec;
      name = builtins.head parts;
      monitor = lib.removePrefix "monitor:" (builtins.elemAt parts 1);
    in
    "hl.workspace_rule({\n    workspace = "
    + luaString name
    + ",\n    monitor = "
    + luaString monitor
    + ",\n})";

  section =
    title: lines: if lines == [ ] then "" else "-- " + title + "\n" + lib.concatStringsSep "\n" lines;

  render =
    settings:
    let
      get = n: settings.${n} or [ ];
    in
    lib.concatStringsSep "\n\n" (
      builtins.filter (s: s != "") [
        "-- Generated by modules/hjem/desktop/hyprland/lua.nix. Do not edit by hand."
        (renderConfig settings)
        (section "curves" (builtins.map renderCurve (get "bezier")))
        (section "animations" (builtins.map renderAnimation (get "animation")))
        (section "monitors" (builtins.map renderMonitor (get "monitor")))
        (section "workspace rules" (builtins.map renderWorkspaceRule (get "workspace")))
        (section "window rules" (builtins.map renderWindowRule (get "windowrule")))
        (section "key bindings" (builtins.map renderBind (get "bind")))
        (section "mouse bindings" (builtins.map renderMouseBind (get "bindm")))
      ]
    )
    + "\n";
in
{
  inherit
    render
    renderAnimation
    renderBind
    renderConfig
    renderCurve
    renderMonitor
    renderMouseBind
    renderWindowRule
    renderWorkspaceRule
    toLua
    ;
}
