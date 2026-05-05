self: super: {
  capacities = (import ./my-app-update.nix self super).capacities;
}
