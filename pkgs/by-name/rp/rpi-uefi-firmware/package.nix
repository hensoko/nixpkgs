{
  bash,
  curl,
  edk2,
  fetchgit,
  fetchurl,
  gcc,
  lib,
  openssl,
  python3,
  stdenv
}:

let
  msKek1 = fetchurl {
    url = "https://go.microsoft.com/fwlink/?LinkId=321185";
    hash = "sha256-oRF/UWoyzvy6Py0azhCoeXL9a76P4NC5luCeZdgCpQM=";
    name = "mskek1";
  };
  msKek2 = fetchurl {
    url = "https://go.microsoft.com/fwlink/?LinkId=2239775";
    hash = "sha256-PNPwMJ7a4ih2epdt1A2fSv/E+9Uhjy6Mw8ndl+isb50=";
    name = "mskek2";
  };
  msDb1 = fetchurl {
    url = "https://go.microsoft.com/fwlink/?LinkId=321192";
    hash = "sha256-6OlfBzOlXoute+ChQT7iPFH86mSzyPpqeGk1/dzHGWE=";
    name = "msdb1";
  };
  msDb2 = fetchurl {
    url = "https://go.microsoft.com/fwlink/?LinkId=321194";
    hash = "sha256-SOmbmR9X/FL3YUlZm/8KWMRxVCKbn41gOsQNNQAkhQc=";
    name = "msdb2";
  };
  msDb3 = fetchurl {
    url = "https://go.microsoft.com/fwlink/?LinkId=2239776";
    hash = "sha256-B28f6pCsKRVev3fBdoL3Xx/dG+GW2jAtyEYeNQqa4zA=";
    name = "msdb3";
  };
  msDb4 = fetchurl {
    url = "https://go.microsoft.com/fwlink/?LinkId=2239872";
    hash = "sha256-9hJONBJb7j/m15pXTqp7kcDnvZ2SnBoyEXjv1hHa2QE=";
    name = "msdb4";
  };
  uefiDbxUpdate = fetchurl {
    url = "https://uefi.org/sites/default/files/resources/dbxupdate_arm64.bin";
    hash = "sha256-9CwYf4sBtJf4H7BFkWSyfRbKKvC5XHMxqCwaJ6cxqIU=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rpi-uefi-firmware";
  version = "1.42";

  src = fetchgit {
    url = "https://github.com/pftf/RPi4.git";
    fetchSubmodules = true;
    rev = "5bdb5f31a0bd0b8ff413ac02a1f1cc5392c818bb";
    sha256 = "sha256-itVJFv/lFaeP3n6zidFnucVV15BTwLcvwOp+7dIcw9U=";
  };

  buildInputs = [ bash curl gcc openssl python3 ];

  buildPhase = ''
    # adapted from https://github.com/pftf/RPi4/blob/master/.github/workflows/linux_edk2.yml
    export PROJECT_URL="https://github.com/pftf/RPi4"
    export RPI_FIRMWARE_URL="https://github.com/raspberrypi/firmware/"
    export ARCH="AARCH64"
    export COMPILER="GCC5"
    export GCC5_AARCH64_PREFIX=""
    export # The following should usually be set to 'master' but, in case"
    export # of a regression, a specific SHA-1 can be specified."
    export START_ELF_VERSION="master"
    export # Set to pre HDMI/Audio changes per https://github.com/pftf/RPi4/issues/252"
    export DTB_VERSION="b49983637106e5fb33e2ae60d8c15a53187541e4"
    export DTBO_VERSION="master"

    # We don't really need a usable PK, so just generate a public key for it and discard the private key
    mkdir keys
    openssl req -quiet -new -x509 -newkey rsa:2048 -subj "/CN=Raspberry Pi Platform Key/" -keyout /dev/null -outform DER -out keys/pk.cer -days 7300 -nodes -sha256

    export WORKSPACE=$PWD
    export PACKAGES_PATH=${edk2}:''${src}/edk2:''${src}/edk2-non-osi:''${src}/edk2-platforms
    export BUILD_FLAGS="-D SECURE_BOOT_ENABLE=TRUE -D INCLUDE_TFTP_COMMAND=TRUE -D NETWORK_ISCSI_ENABLE=TRUE -D SMC_PCI_SUPPORT=1"
    export TLS_DISABLE_FLAGS="-D NETWORK_TLS_ENABLE=FALSE -D NETWORK_ALLOW_HTTP_CONNECTIONS=TRUE"
    export DEFAULT_KEYS="-D DEFAULT_KEYS=TRUE -D PK_DEFAULT_FILE=$WORKSPACE/keys/pk.cer -D KEK_DEFAULT_FILE1=${msKek1} -D KEK_DEFAULT_FILE2=${msKek2} -D DB_DEFAULT_FILE1=${msDb1} -D DB_DEFAULT_FILE2=${msDb2} -D DB_DEFAULT_FILE3=${msDb3} -D DB_DEFAULT_FILE4=${msDb4} -D DBX_DEFAULT_FILE1=${uefiDbxUpdate}"

    echo $WORKSPACE

    set -x

    mkdir Conf

    # EDK2's 'build' command doesn't play nice with spaces in environmnent variables, so we can't move the PCDs there...
    . ${edk2}/edksetup.sh --reconfig
    for BUILD_TYPE in DEBUG RELEASE; do
      bash build -a $ARCH -t $COMPILER -b $BUILD_TYPE \
        -p edk2-platforms/Platform/RaspberryPi/RPi4/RPi4.dsc \
        --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVendor=L"$PROJECT_URL" \
        --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVersionString=L"UEFI Firmware 1.42" \
        ''${BUILD_FLAGS} ''${DEFAULT_KEYS} ''${TLS_DISABLE_FLAGS}
      TLS_DISABLE_FLAGS=""
    done

    mkdir $out/share
    cp Build/RPi4/RELEASE_$COMPILER/FV/RPI_EFI.fd $out/share/
  '';

  meta = {
    homepage = "https://github.com/pftf/RPi4";
    description = "UEFI Firmware for Raspberry Pi 4";
    longDescription = ''
    '';
    license = lib.licenses.bsd2Patent;
    maintainers = with lib.maintainers; [
      hensoko
    ];
    platforms = lib.platforms.linux;
  };
})
