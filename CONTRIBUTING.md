# Contributing to Foundation Layer

Thank you for your interest in contributing to the Foundation Layer project! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a professional and respectful environment.

## Getting Started

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git
- GitHub CLI (optional)

### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/foundation-layer.git
   cd foundation-layer
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/project-buniyan-stream-foundation/foundation-layer.git
   ```

4. Create environment files:
   ```bash
   cp .env.example .env
   # Copy and configure tier-specific .env files
   ```

## Branching Strategy

### Main Branches

- **`main`** - Production-ready code, stable releases only
- **`develop`** - Integration branch for all features

### Feature Branches

Create feature branches from `develop`:

```bash
git checkout develop
git pull upstream develop
git checkout -b feature/your-feature-name
```

### Branch Naming Convention

- `feature/<tier-name>` - Tier-specific features (e.g., `feature/tier1-security`)
- `feature/<description>` - General features (e.g., `feature/add-backup-script`)
- `bugfix/<description>` - Bug fixes (e.g., `bugfix/fix-vault-health-check`)
- `hotfix/<description>` - Urgent production fixes
- `docs/<description>` - Documentation updates

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

### Scopes

- `tier1`: Security layer
- `tier2`: Proxy layer
- `tier3`: Registry layer
- `tier4`: Management layer
- `tier5`: Observability layer
- `tier6`: AI-MCP layer
- `scripts`: Deployment/automation scripts
- `docs`: Documentation
- `config`: Configuration files

### Examples

```bash
# Feature
feat(tier1): add postgresql backup script

# Bug fix
fix(tier2): correct traefik routing for keycloak

# Documentation
docs(readme): update deployment instructions

# Breaking change
feat(tier5): migrate prometheus to v3

BREAKING CHANGE: Prometheus configuration format changed
```

## Pull Request Process

### 1. Before Creating PR

- Ensure all tests pass
- Update documentation
- Follow code style guidelines
- Add/update CHANGELOG.md

### 2. Create Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name

# Create PR using gh CLI
gh pr create --base develop --head feature/your-feature-name \
  --title "feat(scope): description" \
  --body "Description of changes"
```

### 3. PR Requirements

- [ ] Descriptive title following conventional commits
- [ ] Clear description of changes
- [ ] Updated CHANGELOG.md
- [ ] Updated README.md if applicable
- [ ] All containers tested
- [ ] No secrets or credentials committed
- [ ] .env files not committed

### 4. Review Process

- At least one maintainer review required
- All CI checks must pass
- Address review comments
- Squash commits if needed

### 5. Merging

- PRs are merged to `develop` first
- After testing in develop, merged to `main`
- Maintainers handle releases and tags

## Development Workflow

### Working on a Tier

1. **Create feature branch**:
   ```bash
   git checkout develop
   git checkout -b feature/tier1-enhancement
   ```

2. **Make changes**:
   ```bash
   cd tier1-security
   # Edit docker-compose.yml, configs, etc.
   ```

3. **Test locally**:
   ```bash
   ./scripts/04-deploy-all-tiers.sh
   ./scripts/07-verify-env-quick.sh
   ./scripts/08-health-check-quick.sh
   ```

4. **Commit changes**:
   ```bash
   git add .
   git commit -m "feat(tier1): add backup automation"
   ```

5. **Push and create PR**:
   ```bash
   git push origin feature/tier1-enhancement
   gh pr create --base develop
   ```

## Code Style Guidelines

### Docker Compose Files

- Use consistent indentation (2 spaces)
- Group related configurations
- Add comments for complex configurations
- Use environment variables (no hardcoded values)
- Include health checks where applicable

### Environment Files

- Alphabetical order within sections
- Group by service
- Include comments for each variable
- Use descriptive variable names
- Document expected values

### Shell Scripts

- Use `#!/bin/bash` shebang
- Add script description header
- Use `set -e` for error handling
- Include help/usage information
- Add comprehensive comments

### Documentation

- Use Markdown format
- Include code examples
- Add table of contents for long docs
- Keep line length under 100 characters
- Use proper heading hierarchy

## Testing

### Before Committing

```bash
# Verify all containers start
./scripts/04-deploy-all-tiers.sh

# Check environment variables
./scripts/07-verify-env-quick.sh

# Verify health
./scripts/08-health-check-quick.sh

# Check logs for errors
docker logs <container-name>
```

### Testing Changes

- Test your tier in isolation
- Test inter-tier dependencies
- Test on clean environment
- Verify .env variable loading
- Check health checks pass

## Security Guidelines

### Never Commit

- `.env` files (use `.env.example`)
- Passwords or API keys
- SSL certificates
- Vault keys
- Database dumps with sensitive data

### Always

- Use environment variables for secrets
- Update .env.example with new variables
- Review .gitignore before committing
- Scan for secrets before pushing
- Use minimal Docker socket permissions

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Creating a Release

1. **Update version** in files:
   - CHANGELOG.md
   - README.md

2. **Create release branch**:
   ```bash
   git checkout develop
   git checkout -b release/v2.1.0
   ```

3. **Prepare release**:
   - Update CHANGELOG.md
   - Run full test suite
   - Update documentation

4. **Merge to main**:
   ```bash
   git checkout main
   git merge release/v2.1.0 --no-ff
   git tag -a v2.1.0 -m "Release v2.1.0"
   git push origin main --tags
   ```

5. **Merge back to develop**:
   ```bash
   git checkout develop
   git merge release/v2.1.0 --no-ff
   git push origin develop
   ```

## Questions?

- Open an issue for questions
- Join discussions in GitHub Discussions
- Check existing documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
