# Contributing to ETC R5 VARA Tools

Thank you for your interest in contributing to this project! This guide will help you get started.

## How to Contribute

### Reporting Issues

If you encounter a bug or have a feature request:

1. Check existing issues to avoid duplicates
2. Create a new issue with a clear title and description
3. Include:
   - Your EmComm Tools R5 version
   - Ubuntu version (`lsb_release -a`)
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Any error messages or logs

### Suggesting Enhancements

We welcome suggestions! Please open an issue with:

- Clear description of the enhancement
- Use case / why it would be helpful
- Any implementation ideas you have

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Test thoroughly on ETC R5
5. Commit with clear messages
6. Push to your fork
7. Open a pull request

#### Code Guidelines

- **Shell Scripts**: Follow bash best practices
  - Use `set -euo pipefail` for error handling
  - Quote variables: `"${VARIABLE}"`
  - Check command existence before use
  - Provide helpful error messages
  
- **Formatting**: 
  - Use 2 spaces for indentation
  - Keep lines under 100 characters when practical
  - Add comments for complex logic

- **Testing**:
  - Test on a clean ETC R5 installation if possible
  - Verify all installation paths work correctly
  - Check that sudo permissions are handled properly
  - Test with different Wine/VARA configurations

#### Commit Messages

Use clear, descriptive commit messages:

```
Add feature to detect VARA version

- Checks VARA.exe version string
- Updates INI patching logic accordingly
- Adds error handling for missing executables
```

## Development Setup

### Testing Your Changes

1. Test the installer script:
```bash
bash install.sh
```

2. Test individual components:
```bash
cd ~/add-ons/wine
./10-install_all.sh
```

3. Test the launcher:
```bash
etc-vara
```

### Local Repository Structure

```
ETCR5_VARA_TOOLS/
├── README.md              # Main documentation
├── CONTRIBUTING.md        # This file
├── install.sh            # Main installation script
├── 10-install_all.sh     # VARA/Winlink installer
├── etc-vara              # VARA launcher
└── fix_sources.sh        # APT repository fix
```

## Areas for Contribution

Here are some areas where contributions would be especially valuable:

### Documentation
- Improve README clarity
- Add troubleshooting guides
- Create video tutorials or screenshots
- Document edge cases and solutions

### Features
- Better error handling and recovery
- Support for additional VARA applications
- Improved port conflict resolution
- Automatic backup/restore functionality
- Configuration migration tools

### Testing
- Test on different Ubuntu versions
- Test with different Wine configurations
- Test edge cases and error conditions
- Validate on different hardware setups

### Bug Fixes
- Fix any reported issues
- Improve compatibility
- Handle edge cases better

## Code of Conduct

This project follows standard open source etiquette:

- Be respectful and constructive
- Focus on what is best for the community
- Show empathy towards other community members
- Be patient with newcomers

## Questions?

If you have questions about contributing:

1. Check existing issues and pull requests
2. Open a new issue with your question
3. Reach out via GitHub discussions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see main README).

## Recognition

Contributors will be acknowledged in the project README. Thank you for helping make ham radio software more accessible!

73!
