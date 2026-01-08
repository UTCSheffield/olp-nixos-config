{ config, pkgs, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
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
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "always"; # Otherwise: "newtab"
      DisplayMenuBar = "default-off"; # Otherwise: "always", "never", "default-on"
      SearchBar = "unified"; # Otherwise "seperate"
      ExtensionSettings = {
        "*".installation_mode = "blocked";
      };
    };
    preferences = {
      "extensions.pocket.enabled" = false;
    };
  };
}