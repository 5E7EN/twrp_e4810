# twrp_e4810

TWRP device tree for the Kyocera E4810 (Extreme)

NOTE: To use the generated boot.img without issues, your bootloader must be unlocked.  
There are guides for that on the internet for this particular device.

### A Note on Navigation

As per [this issue](https://github.com/TeamWin/Team-Win-Recovery-Project/issues/1485), TWRP doesn't support touchless devices. As such, it's recommended to use an OTG mouse instead.  
Or, once in TWRP, connect via adb and execute OpenRecoveryScript [commands](https://twrp.me/faq/openrecoveryscript.html).  
Lots can be accomplished with this alone.

# Building TWRP

Here's my curated bash history dump that yielded a successful build and boot.  
Built within a fresh Ubuntu 22 docker container.  
You can ignore most of the BoardConfig and device.mk edits since they're shipped with this repo.

````bash
# on host
docker volume create twrp-build
docker run --platform linux/amd64 -it --name twrp-e4810 -v twrp-build:/twrp ubuntu:22.04 bash

# in container
apt update && apt install -y git curl python3 python-is-python3 python3-pip bc bison \
  build-essential ccache flex g++-multilib gcc-multilib gnupg gperf \
  libncurses5-dev libssl-dev libxml2-utils lzop rsync zip zlib1g-dev \
  openjdk-11-jdk libncurses6 cpio file locales nano libtinfo5 libncurses5

pip3 install twrpdtgen

mkdir /twrp && cd /twrp (might already exist so just cd)

# on host
docker cp <path-to-stock-boot.img> twrp-e4810:/twrp/stock-boot.img

# in container
python3 -m twrpdtgen stock-boot.img

mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod +x ~/bin/repo
export PATH=~/bin:$PATH

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0

apt install -y python2
python2 --version (confirm it says version 2)
export PYTHON=python2

mv output device
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh

# fixes lunch spec not found error
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

lunch omni_E4810-eng

# modify default board configs
nano device/kyocera/E4810/BoardConfig.mk
    # remove AVB flag
    - change `BOARD_AVB_ENABLE := true` to `BOARD_AVB_ENABLE := false`
    # disable OTA (since missing bootctrl.msm8937 and minimal omni TWRP doesn't support)
    - change `AB_OTA_UPDATER := true` to `AB_OTA_UPDATER := false`

# modify default device config
nano device/kyocera/E4810/device.mk
replace entire file with:
\```
LOCAL_PATH := device/kyocera/E4810
# Minimal without OTA and bootctrl (since omni minimal doesn't support out of the box)
\```

# use python 2
alias python=python2

mka bootimage -j$(nproc)

# copy compiled twrp boot.img to host
docker cp twrp-e4810:/twrp/out/target/product/E4810/boot.img <path-on-host-for-safekeeping>/twrp-boot.img

# flash it via fastboot
fastboot flash boot twrp-boot.img
fastboot reboot recovery (may not work, use adb)
````

# Booting to TWRP

As of current, I've only had success booting into TWRP via `adb reboot recovery`.

I've also tried:

- `fastboot reboot recovery` (worked once but couldn't reproduce)
- Vol Down + End/Power (worked for stock recovery)  
  ...to no avail.

I didn't try `fastboot boot <path-to-twrp-boot.img>` since I'm under the impression it only works on non A/B partitioned systems.

# Notes

- This is a minimal (omni) configuration
- AVB flag has been disabled (see BoardConfig.mk)
- Uses the prebuilt kernel from stock boot.img
- OTA logic has been removed (will eventually implement but couldn't build initially due to missing deps)
- This TWRP boot.img should not be flashed to the device if the userdata is pending format right after unlocking/locking the bootloader since it is not equipped to handle the erase flag.
