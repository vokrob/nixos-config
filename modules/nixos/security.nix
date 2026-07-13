{
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.login1.reboot" ||
          action.id == "org.freedesktop.login1.power-off") {
        return polkit.Result.YES;
      }
    });
  '';
}
