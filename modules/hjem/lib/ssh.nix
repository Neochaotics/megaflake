# OpenSSH client config renderer.
#
# Ported from home-manager's `programs/ssh.nix` (BSD-3-Clause, (c) Home
# Manager contributors) so `~/.ssh/config` is byte-identical.
{
  lib,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    findFirst
    mapAttrsToList
    optional
    optionalString
    removeAttrs
    toList
    ;

  isPath = x: builtins.substring 0 1 (toString x) == "/";

  addressPort =
    entry:
    let
      address = entry.address or "localhost";
      port = entry.port or null;
    in
    (findFirst (candidate: candidate.when)
      {
        out = " [${address}]:${toString port}";
      }
      [
        {
          when = address == null;
          out = " ${toString port}";
        }
        {
          when = address != null && isPath address;
          out = " ${address}";
        }
      ]
    ).out;

  mkSetEnvStr =
    envStr:
    concatStringsSep " " (
      mapAttrsToList (name: value: ''${name}="${lib.escape [ ''"'' "\\" ] (toString value)}"'') envStr
    );

  yesNo = value: if value then "yes" else "no";

  renderValue = value: if lib.isBool value then yesNo value else toString value;

  renderValues = sep: values: concatStringsSep sep (map renderValue (toList values));

  renderForward =
    f: if lib.isAttrs f then addressPort f.bind + addressPort f.host else " ${renderValue f}";

  renderDynamicForward = f: if lib.isAttrs f then addressPort f else " ${renderValue f}";

  renderDuplicateDirective =
    indent: name: renderItem: values:
    concatStringsSep "\n" (map (value: "${indent}${name}${renderItem value}") (toList values));

  # Per ssh_config(5), the first obtained value for most parameters wins, so
  # these list-valued directives are rendered comma/space separated instead of
  # as duplicate directives.
  commaListDirectives = [
    "CASignatureAlgorithms"
    "Ciphers"
    "HostbasedAcceptedAlgorithms"
    "HostbasedKeyTypes"
    "HostKeyAlgorithms"
    "IgnoreUnknown"
    "KbdInteractiveDevices"
    "KexAlgorithms"
    "MACs"
    "PreferredAuthentications"
    "ProxyJump"
    "PubkeyAcceptedAlgorithms"
    "PubkeyAcceptedKeyTypes"
  ];

  spaceListDirectives = [
    "CanonicalDomains"
    "CanonicalizePermittedCNAMEs"
    "ChannelTimeout"
    "GlobalKnownHostsFile"
    "PermitRemoteOpen"
    "SendEnv"
    "UserKnownHostsFile"
  ];

  directiveRenderers =
    indent:
    lib.genAttrs commaListDirectives (name: value: "${indent}${name} ${renderValues "," value}")
    // lib.genAttrs spaceListDirectives (name: value: "${indent}${name} ${renderValues " " value}")
    // {
      SetEnv = value: "${indent}SetEnv ${mkSetEnvStr value}";
      LocalForward = renderDuplicateDirective indent "LocalForward" renderForward;
      RemoteForward = renderDuplicateDirective indent "RemoteForward" renderForward;
      DynamicForward = renderDuplicateDirective indent "DynamicForward" renderDynamicForward;
    };

  sshDirectiveStrWithIndent =
    indent: name: value:
    let
      renderDirective =
        (directiveRenderers indent).${name}
          or (values: renderDuplicateDirective indent name (v: " ${renderValue v}") values);
    in
    optionalString (value != null && value != [ ] && value != { }) (renderDirective value);

  sshDirectiveStr = sshDirectiveStrWithIndent "  ";

  blockHeader =
    name:
    let
      isLiteralHeader = lib.any (prefix: lib.hasPrefix prefix name) [
        "Host "
        "Match "
      ];
    in
    optionalString (!isLiteralHeader) "Host " + name;

  matchBlockStr =
    _key: cf:
    let
      header = cf.header or "Host " + _key;
      extraOptions = cf.__hmSshBlockExtraOptions or { };
      settings = removeAttrs cf [
        "header"
        "__hmSshBlockExtraOptions"
        "extraOptions"
      ];
      orderedNames =
        # IgnoreUnknown only applies to unknown options that appear after it.
        optional (builtins.hasAttr "IgnoreUnknown" settings) "IgnoreUnknown"
        ++ builtins.filter (name: name != "IgnoreUnknown") (lib.attrNames settings);
    in
    concatStringsSep "\n" (
      [ header ]
      ++ lib.filter (line: line != "") (map (name: sshDirectiveStr name settings.${name}) orderedNames)
      ++ optional (extraOptions != { }) (
        lib.generators.toKeyValue {
          mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
          listsAsDuplicateKeys = true;
          indent = "  ";
        } extraOptions
      )
    );

  # Maps the legacy `matchBlocks.<name>` submodule onto the directive renderer,
  # keeping the exact same key order as home-manager.
  legacyBlockSettings =
    cf:
    let
      headers =
        optional ((cf.match or null) != null) "Match ${cf.match}"
        ++ optional ((cf.host or null) != null) "Host ${cf.host}";
    in
    lib.filterAttrs (_: v: v != null && v != [ ] && v != { }) {
      header = lib.head (headers ++ [ null ]);
      # Options the host did not set are absent rather than null, so that the
      # rendered block keeps home-manager's key order and skips empties.
      Port = cf.port or null;
      ForwardAgent = cf.forwardAgent or null;
      ForwardX11 = if (cf.forwardX11 or false) then true else null;
      ForwardX11Trusted = if (cf.forwardX11Trusted or false) then true else null;
      IdentitiesOnly = cf.identitiesOnly or null;
      IdentityFile = cf.identityFile or null;
      IdentityAgent = cf.identityAgent or null;
      User = cf.user or null;
      HostName = cf.hostname or null;
      ServerAliveInterval = cf.serverAliveInterval or null;
      ServerAliveCountMax = cf.serverAliveCountMax or null;
      SendEnv = cf.sendEnv or null;
      SetEnv = cf.setEnv or null;
      Compression = cf.compression or null;
      CheckHostIP = if (cf.checkHostIP or true) then null else false;
      ProxyCommand = cf.proxyCommand or null;
      ProxyJump = cf.proxyJump or null;
      CertificateFile = cf.certificateFile or null;
      AddressFamily = cf.addressFamily or null;
      LocalForward = cf.localForwards or null;
      RemoteForward = cf.remoteForwards or null;
      DynamicForward = cf.dynamicForwards or null;
      AddKeysToAgent = cf.addKeysToAgent or null;
      HashKnownHosts = cf.hashKnownHosts or null;
      UserKnownHostsFile = cf.userKnownHostsFile or null;
      ControlMaster = cf.controlMaster or null;
      ControlPath = cf.controlPath or null;
      ControlPersist = cf.controlPersist or null;
      KexAlgorithms = cf.kexAlgorithms or null;
      __hmSshBlockExtraOptions = cf.extraOptions or { };
    };
in
{
  inherit
    blockHeader
    legacyBlockSettings
    matchBlockStr
    sshDirectiveStr
    sshDirectiveStrWithIndent
    ;
}
