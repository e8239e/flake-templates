{
  inputs = { };

  outputs = { ... }: rec {
    defaultTemplate = templates.generic;
    templates = builtins.mapAttrs (k: v: { path = ./templates + "/${k}"; description = "${k}";})
      (builtins.readDir ./templates);
  };
}
