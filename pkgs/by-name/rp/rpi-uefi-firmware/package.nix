{
  fetchzip,
  lib,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rpi-uefi-firmware";
  version = "1.42";

  src = fetchzip {
    url = "https://github.com/pftf/RPi4/releases/download/v1.42/RPi4_UEFI_Firmware_v1.42.zip";
    hash = "sha256-oDhGnwRODYFye0Mya0Q3kzEYgGt/qDuFFkqUAHuqINw=";
    stripRoot = false;
  };

  buildPhase = ''
    mkdir -p $out/share
    cp -r * $out/share
  '';

  meta = {
    homepage = "https://github.com/pftf/RPi4";
    description = "UEFI Firmware for Raspberry Pi 4";
    license = lib.licenses.bsd2Patent;
    maintainers = with lib.maintainers; [
      hensoko
    ];
    platforms = lib.platforms.linux;
  };
})
