{
  lib,
  stdenvNoCC,
  git,
  git-lfs,
  cacert,
}:

let
  urlToName =
    url: rev:
    let
      shortRev = lib.sources.shortRev rev;
      appendShort = lib.optionalString ((builtins.match "[a-f0-9]*" rev) != null) "-${shortRev}";
    in
    "${lib.sources.urlToName url}${appendShort}";
in

lib.makeOverridable (
  lib.fetchers.withNormalizedHash { } (
    # NOTE Please document parameter additions or changes in
    #   ../../../doc/build-helpers/fetchers.chapter.md
    {
      url,
      tag ? null,
      rev ? null,
      name ? urlToName url (lib.revOrTag rev tag),
      leaveDotGit ? deepClone || fetchTags,
      outputHash ? lib.fakeHash,
      outputHashAlgo ? null,
      fetchSubmodules ? true,
      deepClone ? false,
      branchName ? null,
      sparseCheckout ? [ ],
      nonConeMode ? false,
      nativeBuildInputs ? [ ],
      # Shell code executed before the file has been fetched.  This, in
      # particular, can do things like set NIX_PREFETCH_GIT_CHECKOUT_HOOK to
      # run operations between the checkout completing and deleting the .git
      # directory.
      preFetch ? "",
      # Shell code executed after the file has been fetched
      # successfully. This can do things like check or transform the file.
      postFetch ? "",
      preferLocalBuild ? true,
      fetchLFS ? false,
      # Shell code to build a netrc file for BASIC auth
      netrcPhase ? null,
      # Impure env vars (https://nixos.org/nix/manual/#sec-advanced-attributes)
      # needed for netrcPhase
      netrcImpureEnvVars ? [ ],
      meta ? { },
      allowedRequisites ? null,
      # fetch all tags after tree (useful for git describe)
      fetchTags ? false,
    }:

    /*
      NOTE:
      fetchgit has one problem: git fetch only works for refs.
      This is because fetching arbitrary (maybe dangling) commits creates garbage collection risks
      and checking whether a commit belongs to a ref is expensive. This may
      change in the future when some caching is added to git (?)
      Usually refs are either tags (refs/tags/*) or branches (refs/heads/*)
      Cloning branches will make the hash check fail when there is an update.
      But not all patches we want can be accessed by tags.

      The workaround is getting the last n commits so that it's likely that they
      still contain the hash we want.

      for now : increase depth iteratively (TODO)

      real fix: ask git folks to add a
      git fetch $HASH contained in $BRANCH
      facility because checking that $HASH is contained in $BRANCH is less
      expensive than fetching --depth $N.
      Even if git folks implemented this feature soon it may take years until
      server admins start using the new version?
    */

    assert nonConeMode -> (sparseCheckout != [ ]);
    assert fetchTags -> leaveDotGit;

    let
      revWithTag =
        let
          warningMsg = "fetchgit requires one of either `rev` or `tag` to be provided (not both).";
          otherIsNull = other: lib.assertMsg (other == null) warningMsg;
        in
        if tag != null then
          assert (otherIsNull rev);
          "refs/tags/${tag}"
        else if rev != null then
          assert (otherIsNull tag);
          rev
        else
          # FIXME fetching HEAD if no rev or tag is provided is problematic at best
          "HEAD";
    in

    if builtins.isString sparseCheckout then
      # Changed to throw on 2023-06-04
      throw
        "Please provide directories/patterns for sparse checkout as a list of strings. Passing a (multi-line) string is not supported any more."
    else
      stdenvNoCC.mkDerivation {
        inherit name;

        builder = ./builder.sh;
        fetcher = ./nix-prefetch-git;

        nativeBuildInputs = [
          git
          cacert
        ]
        ++ lib.optionals fetchLFS [ git-lfs ]
        ++ nativeBuildInputs;

        inherit outputHash outputHashAlgo;
        outputHashMode = "recursive";

        # git-sparse-checkout(1) says:
        # > When the --stdin option is provided, the directories or patterns are read
        # > from standard in as a newline-delimited list instead of from the arguments.
        sparseCheckout = builtins.concatStringsSep "\n" sparseCheckout;

        inherit
          url
          leaveDotGit
          fetchLFS
          fetchSubmodules
          deepClone
          branchName
          nonConeMode
          preFetch
          postFetch
          fetchTags
          ;
        rev = revWithTag;

        postHook =
          if netrcPhase == null then
            null
          else
            ''
              ${netrcPhase}
              # required that git uses the netrc file
              mv {,.}netrc
              export NETRC=$PWD/.netrc
              export HOME=$PWD
            '';

        impureEnvVars =
          lib.fetchers.proxyImpureEnvVars
          ++ netrcImpureEnvVars
          ++ [
            "GIT_PROXY_COMMAND"
            "NIX_GIT_SSL_CAINFO"
            "SOCKS_SERVER"
          ];

        inherit preferLocalBuild meta allowedRequisites;

        passthru = {
          gitRepoUrl = url;
          inherit tag;
        };
      }
  )
)
