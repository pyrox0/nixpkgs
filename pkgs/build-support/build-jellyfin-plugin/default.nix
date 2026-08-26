{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  yq-go,
  jellyfin,
}:

lib.extendMkDerivation {
  # Wrap this function so this can benefit from the Dotnet module building infrastructure.
  constructDrv = buildDotnetModule;

  extendDrvArgs =
    finalAttrs:
    {
      nativeBuildInputs ? [ ],
      # The name of the plugin, used for moving the DLL to $out
      pluginName,
      # The metadata file normally used by `jprm`(jellyfin plugin repository manager) to generate `meta.json`.
      # Because of how it's designed, we can just convert it to json and install it.
      # This probably needs to be manually generated when it doesn't exist,
      # but most plugins appear to use it so this is fine for now.
      metadataFile ? "build.yaml",
      # The version of Jellyfin that this plugin supports. Defaults to the latest, and use it to mark plugins broken if they
      # don't work with nixpkgs' current version of Jellyfin. If non-default, no need to set this.
      # Ideally it would pull from `meta.json` but this can't be done because it would trigger IFD.
      jellyfinVersion ? jellyfin.version,
      ...
    }@args:

    {
      nativeBuildInputs = nativeBuildInputs ++ [ yq-go ];

      strictDeps = true;

      # Needs to be upped whenever jellyfin updates its dotnet SDK version.
      dotnet-sdk = dotnetCorePackages.sdk_9_0;
      dontDotnetFixup = true;

      # Override the normal `buildDotnetModule` install phase to just install the jellyfin plugin.
      installPhase = ''
        runHook preInstall

        mkdir $out
        # This line also needs to update its version when the dotnet SDK gets updated.
        mv ${pluginName}/bin/Release/net9.0/${pluginName}.dll $out/

        yq -o=json '.' ./${metadataFile} > $out/meta.json

        runHook postInstall
      '';

      meta = (args.meta or { }) // {
        broken = lib.versionOlder jellyfin.version jellyfinVersion;
      };
    };
}
