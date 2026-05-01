# Contributing to NebulaOS

Thank you for your interest in contributing to NebulaOS!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/NebulaOS.git`
3. Create a branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Test your changes (build the ISO if possible)
6. Commit: `git commit -m "feat: description of changes"`
7. Push: `git push origin feature/your-feature`
8. Open a Pull Request

## Development Setup

### Desktop Shell (C++/Qt6)

```bash
sudo apt install qt6-base-dev qt6-declarative-dev cmake g++
cd desktop/shell
mkdir build && cd build
cmake ..
make -j$(nproc)
```

### Applications (Python/PyQt6)

```bash
pip install PyQt6
python3 apps/settings/nebula-settings.py
```

### ISO Build

Requires root on Debian 12+:
```bash
sudo apt install live-build debootstrap squashfs-tools xorriso
sudo ./build.sh
```

## Code Style

- **C++**: Follow Qt coding conventions, use C++20 features
- **Python**: PEP 8, type hints encouraged
- **QML**: Follow Qt Quick best practices
- **Shell**: Use shellcheck, set -euo pipefail
- **Commits**: Conventional commits (feat:, fix:, docs:, etc.)

## Areas to Contribute

- Desktop shell improvements (animations, effects, widgets)
- New themes and icon packs
- Application development
- Documentation improvements
- Translation and localization
- Bug fixes and testing
- Performance optimization
- Accessibility improvements

## Reporting Issues

Use GitHub Issues with:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- System information
- Screenshots if applicable

## License

By contributing, you agree that your contributions will be licensed
under the GPL-3.0 License.
