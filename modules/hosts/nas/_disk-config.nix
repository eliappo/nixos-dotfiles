# Disko disk layout for nixos-nas.
# Single GPT disk with:  EFI  |  swap  |  btrfs (subvolumes)
#
# Disko generates all fileSystems.* and swapDevices entries automatically.
# Do NOT add them to _hardware-configuration.nix.
#
# To change the target disk, update `device` below (e.g. "/dev/sdb").
# Check on the target: lsblk

{ ... }:

{
  disko.devices.disk.main = {
    type   = "disk";
    device = "/dev/sda"; # ← adjust if the NAS disk is sdb/nvme0n1/etc.
    content = {
      type = "gpt";
      partitions = {

        ESP = {
          size  = "512M";
          type  = "EF00"; # EFI System Partition
          content = {
            type        = "filesystem";
            format      = "vfat";
            mountpoint  = "/boot";
            mountOptions = [ "fmask=0022" "dmask=0022" ];
          };
        };

        swap = {
          size    = "4G";
          content = {
            type         = "swap";
            discardPolicy = "both";
            resumeDevice  = true; # enable hibernate-to-swap if desired
          };
        };

        root = {
          size    = "100%"; # rest of the disk
          content = {
            type   = "btrfs";
            extraArgs = [ "-f" ]; # force if disk was previously used
            subvolumes = {
              "@"     = { mountpoint = "/";     mountOptions = [ "compress=zstd" "noatime" ]; };
              "@home" = { mountpoint = "/home";  mountOptions = [ "compress=zstd" "noatime" ]; };
              "@nix"  = { mountpoint = "/nix";   mountOptions = [ "compress=zstd" "noatime" ]; };
              "@srv"  = { mountpoint = "/srv";   mountOptions = [ "compress=zstd" "noatime" ]; };
              "@var"  = { mountpoint = "/var";   mountOptions = [ "compress=zstd" "noatime" ]; };
            };
          };
        };

      };
    };
  };
}
