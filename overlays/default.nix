final: prev: {
  swaynotificationcenter = prev.swaynotificationcenter.overrideAttrs (old: {
    patches = (old.patches or []) ++ [../patches/swaync-remove-close-button.patch];
  });
}
