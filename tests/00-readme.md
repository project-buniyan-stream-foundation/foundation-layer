# Foundation Layer - Test Suite

**Version**: 1.0.0  
**Status**: Active Development  
**Last Updated**: 2025-12-23

---

## Overview

This directory contains the comprehensive test suite for the Foundation Layer infrastructure. Tests are organized by tier and functionality, following GitOps best practices for maintainability and future updates.

---

## Test Structure

```
tests/
├── 00-readme.md                    # This file
├── 01-changelog.md                 # Test suite changelog
├── 02-test-plan.md                 # Overall test plan
├── issues/
│   ├── open/                       # Open test implementation issues
│   └── closed/                     # Completed test issues
├── unit/                           # Unit tests per tier
│   ├── tier1-security/
│   ├── tier2-proxy/
│   ├── tier3-registry/
│   ├── tier4-management/
│   ├── tier5-observability/
│   └── tier6-ai-mcp/
├── integration/                    # Integration tests
│   ├── tier1-tier2/               # Cross-tier integration
│   ├── tier1-tier5/
│   └── full-stack/
├── e2e/                           # End-to-end tests
│   ├── deployment/
│   ├── authentication/
│   └── monitoring/
├── scripts/                       # Test execution scripts
│   ├── run-all-tests.sh
│   ├── run-tier-tests.sh
│   └── run-integration-tests.sh
└── reports/                       # Test reports (gitignored)
```

---

## Test Categories

### Unit Tests
- **Purpose**: Test individual service configurations and functionality
- **Scope**: Single container/service validation
- **Location**: `tests/unit/`

### Integration Tests
- **Purpose**: Test interactions between tiers
- **Scope**: Cross-tier communication and dependencies
- **Location**: `tests/integration/`

### End-to-End Tests
- **Purpose**: Test complete workflows
- **Scope**: Full system validation
- **Location**: `tests/e2e/`

---

## Test Execution

### Run All Tests
```bash
./tests/scripts/run-all-tests.sh
```

### Run Tier-Specific Tests
```bash
./tests/scripts/run-tier-tests.sh tier1-security
```

### Run Integration Tests
```bash
./tests/scripts/run-integration-tests.sh
```

---

## Test Requirements

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+
- bash 4.0+
- curl
- jq (for JSON parsing)

### Running Containers
Tests assume foundation containers are running. Deploy first:
```bash
./scripts/04-deploy-all-tiers.sh
```

---

## Test Development

### Adding New Tests

1. **Create Issue**: Document test requirements in `tests/issues/open/`
2. **Implement Test**: Create test script in appropriate category
3. **Update Changelog**: Document changes in `tests/01-changelog.md`
4. **Update Documentation**: Update this README if needed

### Test Script Template

```bash
#!/bin/bash
# Test: [Test Name]
# Category: [unit|integration|e2e]
# Tier: [tier number or cross-tier]

set -e

TEST_NAME="[Test Name]"
PASSED=0
FAILED=0

# Test implementation
test_function() {
    # Test logic here
    if [ condition ]; then
        echo "✅ PASS: Test description"
        ((PASSED++))
    else
        echo "❌ FAIL: Test description"
        ((FAILED++))
    fi
}

# Run tests
test_function

# Summary
echo "Summary: ✅ $PASSED passed, ❌ $FAILED failed"
exit $FAILED
```

---

## GitOps Practices

### Issue Tracking
- All test development tracked in `tests/issues/open/`
- Completed tests moved to `tests/issues/closed/`
- Issues reference GitHub issue numbers

### Version Control
- All test changes committed with descriptive messages
- Changelog updated for each release
- Test results NOT committed (in .gitignore)

### Documentation
- README updated for structural changes
- Test plan updated for new test categories
- Inline comments for complex test logic

---

## Current Status

### Implemented
- Test directory structure
- Documentation framework
- Issue tracking system

### In Progress
- Unit tests for all tiers
- Integration tests
- E2E tests

### Planned
- CI/CD integration
- Automated test reporting
- Performance tests
- Security tests

---

## Contributing

See main repository CONTRIBUTING.md for contribution guidelines.

### Test-Specific Guidelines
1. Follow test script template
2. Include clear test descriptions
3. Use consistent exit codes (0=pass, non-zero=fail)
4. Document test assumptions
5. Update changelog for test changes

---

## Related Documentation

- [Test Plan](./02-test-plan.md)
- [Test Changelog](./01-changelog.md)
- [Open Issues](./issues/open/)
- [Main README](../README.md)
