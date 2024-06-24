{ config, pkgs, ... }:
let
  lock-false = {
    Value = false;
    Status = "unlocked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
  {
    programs.firefox = {
      enable = true;
      languagePacks = [ "en-GB" ];
      /* Policies */
      DisableTelemetry = lock-true;
      DisableFirefoxStudies = lock-true;
      EnableTrackingProtection = {
	Value = lock-true;
	Locked = lock-true;
	Cryptomining = lock-true;
	Fingerprinting = lock-true;
      };
      DisablePocket = lock-true;
      DisableFirefoxAccounts = lock-true;
      DisableAccounts = lock-true;
      DisableFirefoxScreenshots = lock-true;
      DontCheckDefaultBrowser = lock-true;
      DisplayBookmarksToolbar = "always"; # Otherwise: "newtab"
      DisplayMenuBar = "default-off"; # Otherwise: "always", "never", "default-on"
      SearchBar = "unified"; # Otherwise "seperate"
      ExtensionSettings = {
      };
  }
