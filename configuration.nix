# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:
let
nvidia-offload = pkgs.wirteShellScriptBin "nvidia-offlaod" ''
export __NV_PRIME_RENDER_OFFLOAD = 1
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA_G0
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus = NVIDIA_only 
exec "$@" ''; 
in
{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "m42";# Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };
nix.settings.experimental-features = ["nix-command" "flakes"];
  services.xserver={
	  layout="br";
	  xkbVariant="";
	  enable=true;
	  windowManager.qtile = {
		  enable=true; #extraPackages = python3Packages: with python3Packages; [ (qtile-extras.overridePythonAttrs(old: { disabledTestPaths = [ "test/widget/test_strava.py" ]; }))];
		  extraPackages = p: with p; [qtile-extras];
				
	};
	videoDrivers=["nvidia"];
  };
# COLO xserver NVIDIA AQUI =>


  # Configure console keymap
  console={
	  keyMap = "br-abnt2";
	  packages=[pkgs.terminus_font];
	  font="${pkgs.terminus_font}/share/consoleffonts/ter-i22.psf.gz";
  };

#FONTS
  fonts = {
	  packages = with pkgs; [
		  noto-fonts
			  noto-fonts-cjk
			  noto-fonts-emoji
			  fira-code
			  fira-code-symbols
			  mplus-outline-fonts.githubRelease
			  dina-font
			  proggyfonts
			  (nerdfonts.override{fonts=["FiraCode" "DroidSansMono"];})
	  ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  #services.pipewire = { enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true;
# If you want to use JACK applications, uncomment this
#jack.enable = true;

# use the example session manager (no others are packaged yet so this is enabled by default,
# no need to redefine it in your config for now)
#media-session.enable = true;};

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.m42 = {
    isNormalUser = true;
    description = "m42";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
	    firefox
		    terminator
		    thunderbird
		    chromium
		    discord
		    arandr
		    xfce.thunar
		    xfce.tumbler
		    mupdf
		    spotify
		    flameshot
		    pavucontrol
		    emacs

    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	wget
	virtualglLib
	glxinfo
	pciutils
	mesa
	lshw
	neovim
	neofetch
	gcc
	ripgrep
	emacs
	#nvtop
	btop
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  time.hardwareClockInLocalTime = true;
  hardware.opengl ={
  	enable=true;
	driSupport=true;
	driSupport32Bit = true;
	extraPackages = with pkgs; [vaapiVdpau nvidia-vaapi-driver intel-media-driver];
  };
  hardware.nvidia={
  	modesetting.enable = true;
	powerManagement.enable = true;
	powerManagement.finegrained = false;
	open = false;
	nvidiaSettings = true;
	package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.nvidia.prime = {
  	offload = {enable = true;
	enableOffloadCmd = true;
	};
	intelBusId = "PCI:0:2:0";
	nvidiaBusId = "PCI:1:0:0";
  };
  services.thermald.enable = true;
  services.tlp = {
  enable = true;
  settings = {
  CPU_MIN_PERF_ON_AC = 0;
  CPU_MAX_PERF_ONAC  = 80;
};
};
environment.interactiveShellInit = ''
alias semacs='sudo -E emacs' 
alias svim='sudo -E nvim' 
'';
programs.git = {enable = true;};

}
