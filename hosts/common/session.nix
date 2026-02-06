{ ... }:
{
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.swaylock.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
}
