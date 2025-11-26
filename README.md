Steps already completed
et-user, et-audio, et-radio

1.) VarAC installer downloaded into the ~/add-ons/wine folder
    (This script looks for something starting with VarAC_Installer....) so
    it should work with most versions that follow that naming.
2.) 10-install_all.sh downloaded into the ~/add-ons/wine folder and
    chmod +x 10-install_all.sh
3.) etc-vara downloaded into /opt/emcomm-tools/bin/
    chmod +x etc-vara (sudo required for both)
4.) If your alsa utils is messed up run fix_sources.sh, it will update
    your sources list to the right repositories and install alsa.  It must
    be run as sudo.  You can run it from any directory though as long as it
    has sudo privileges.