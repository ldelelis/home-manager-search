{ pkgs , lib ? (import <nixpkgs> {}).lib }:
with builtins;
with lib;
let
  nixpkgs = import <nixpkgs> { };

  isModule = attrs: isAttrs attrs && attrs ? "enable";
  moduleKey = mod: concatStringsSep "/" (lists.init mod.enable.loc);
  buildParsedModule = mod: {${moduleKey mod} = mod;};

  # Keys breakdown:
  ## derivations and functions break json serialization
  ## functor contains a cyclic graph that errors on recursion
  ## definitions sometimes contain lists of functions, which are useless for this module

  ## sessionVariableSetter is a special case that breaks in some cases, and can't be tryEvaled out
  ## getSubModules: same as above

  ## FIXME: hie is a special case in the vscode haskell plugins sections. it's supposed to require hie-nix
  ## to be overlayed manually on nixpkgs, but due to some lazy evaluation issues, it breaks regardless
  ## of the overlay's existence
  isValidAttrset = n: v: !(attrsets.isDerivation v || isFunction v || typeOf v == "lambda" || strings.hasSuffix "functor" n || strings.hasSuffix "definitions" n || strings.hasSuffix "sessionVariableSetter" n || strings.hasSuffix "getSubModules" n || strings.hasSuffix "hie" n);
  isNotError = x: let evaled = tryEval x; in evaled.success;

  filteredModules = root: attrsets.filterAttrsRecursive isValidAttrset root;
  # This is basically lib.attrsets.mapAttrsRecursiveCond, except I flipped the order of
  # the conditional checks, since isAttrs pops some errors before they're conditioned out
  mapAttrsRecursiveCond' = cond: f: set:
  let
    recurse = path: set:
      let
        g =
          name: value:
          if cond value && isAttrs value
            then recurse (path ++ [name]) value
            else f (path ++ [name]) value;
      in mapAttrs g set;
  in recurse [] set;
in
nixpkgs.writeText "modules.json" (toJSON
  (mapAttrsRecursiveCond' isNotError (_: v: (tryEval v).value)
    (lists.foldr (as: base: base // (buildParsedModule as)) {}
      (attrsets.collect isModule
        (builtins.removeAttrs (filteredModules pkgs) ["_module" "meta" "lib"])))))
