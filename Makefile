SHELL = /bin/bash

include Makefile.config
export

# --------------
# Ubuntu / based
# --------------

apt/install:
	@source $(SCRIPTS)/packages/apt.sh && apt_install

snapd/remove:
	@source $(SCRIPTS)/packages/snapd.sh && snapd_remove

# --------------
# SLE / based 
# --------------

zypper/install:
	@source $(SCRIPTS)/packages/zypper.sh && zypper_install

# --------------
# Gnome
# --------------

gnome/install:
	@source $(SCRIPTS)/desktop_environment/gnome.sh && gnome_install

gnome/setup:
	@source $(SCRIPTS)/desktop_environment/gnome.sh && gnome_setup

# --------------
# Flatpak
# --------------

flatpak/setup:
	@source $(SCRIPTS)/packages/flatpak.sh && flatpak_setup

flatpak/install:
	@source $(SCRIPTS)/packages/flatpak.sh && flatpak_install

# --------------

softwares/install:
	@source $(SCRIPTS)/misc/softwares.sh && softwares_install

softwares/config:
	@source $(SCRIPTS)/misc/softwares.sh && softwares_config
