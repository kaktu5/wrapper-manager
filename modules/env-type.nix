{
  config,
  lib,
  name,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    name = mkOption {
      type = types.str;
      description = ''
        Name of the variable.
      '';
      default = name;
    };

    value = mkOption {
      type = let
        inherit (types) anything attrsOf coercedTo either nullOr str;
        strLike = coercedTo anything (x: "${x}") str;
      in
        nullOr (either (attrsOf anything) strLike);
      description = ''
        Value of the variable to be set.
        Set to `null` to unset the variable.

        Can be either:
        - A string or a type convertible to it
        - An attribute set which must be used with a `generator` to convert it to a path or string

        Note that any environment variable will be escaped. For example, `value = "$HOME"`
        will be converted to the literal `$HOME`, with its dollar sign.
      '';
    };

    generator = mkOption {
      type = let
        inherit (types) either functionTo nullOr path str;
      in
        nullOr (functionTo (either path str));
      description = ''
        Function that when applied to `value` returns a path or string.
        Required if `value` is an attribute set.
      '';
      default = null;
    };

    force = mkOption {
      type = types.bool;
      description = ''
        Whether the value should be always set to the specified value.
        If set to `true`, the program will not inherit the value of the variable
        if it's already present in the environment.

        Setting it to false when unsetting a variable (value = null)
        will make the option have no effect.
      '';
      default = config.value == null;
      defaultText = lib.literalMD "true if `value` is null, otherwise false";
    };
  };
}
