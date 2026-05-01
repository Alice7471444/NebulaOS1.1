# NebulaOS Kernel Configuration

NebulaOS uses the standard Debian stable kernel (`linux-image-amd64`) with
additional configuration optimizations for desktop performance and VM
compatibility.

## Kernel Parameters

The following kernel parameters are set via GRUB for optimal desktop
performance:

```
quiet splash loglevel=3 vt.global_cursor_default=0
mitigations=auto
iommu=pt
```

## VM-Specific Parameters

For VMware:
```
video=hyperv_fb:1920x1080
```

For VirtualBox:
```
video=VGA-1:1920x1080@60
```

## Recommended Kernel Modules

Loaded at boot for VM support:
- `vmw_vmci` (VMware)
- `vmw_balloon` (VMware memory management)
- `vmw_pvscsi` (VMware paravirtual SCSI)
- `vboxguest` (VirtualBox)
- `vboxsf` (VirtualBox shared folders)
- `vboxvideo` (VirtualBox video)

## Performance Tuning

### Sysctl Optimizations (`/etc/sysctl.d/99-nebula.conf`)
```ini
# Reduce swappiness for desktop use
vm.swappiness=10

# Increase inotify watches for file managers and IDEs
fs.inotify.max_user_watches=524288

# Network performance
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# Dirty page writeback tuning
vm.dirty_ratio=15
vm.dirty_background_ratio=5
```

### I/O Scheduler
Uses `mq-deadline` for SSDs and `bfq` for HDDs via udev rules.

## Security Hardening

- AppArmor enabled by default
- Kernel lockdown mode: integrity
- ASLR enabled
- ptrace scope: 1 (restricted)
