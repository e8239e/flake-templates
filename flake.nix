{
  inputs = { };

  outputs = { ... }: rec {
    defaultTemplate = templates.generic;
    templates = builtins.mapAttrs
      (k: v:
        let
          descriptionFromPath = path:
            let
              words = builtins.filter (builtins.isString) (builtins.split "_" path);
            in
            builtins.concatStringsSep " " words;
        in
        {
          path = ./templates + "/${k}";
          description = descriptionFromPath k;
        })
      (builtins.readDir ./templates);
  };
}
