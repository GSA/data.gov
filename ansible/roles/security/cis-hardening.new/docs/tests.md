# Tests

We provide a simple way to evaluate the effective code coverage of our tool ([see the issue](https://github.com/awailly/cis-ubuntu-ansible/issues/25)).

## Travis

The travis-ci environment gives an isolated Ubuntu 12.04 to perform two run of cis-ubuntu-ansible.

## Drone.io

The drone environment is close to travis, but provides Ubuntu 14.04 and the ability to export files. [@pchaigno](https://github.com/pchaigno) created the settings and the dynamic code coverage badge with [this PR](https://github.com/awailly/cis-ubuntu-ansible/pull/28).

# Code coverage

All sections cannot be tested given the strong impact on the testing systems, and our rights. Note that the current document focus on the drone.io build where the badge is generated. If you have a creative way to do the same on travis, contact us or open an issue.

## Section 01 - Patching and Sofware Updates

The section tests for new packages and require a long time. Given our ephemeral travis and drone builds, we skip this step.

[![Status: Skipped](https://img.shields.io/badge/Status-Skipped-red.svg)]

## Section 02 - Filesystem configuration

This section deals with current filesystem mounts and we are not able to perform such modifications on the CI environments.

[![Status: Skipped](https://img.shields.io/badge/Status-Skipped-red.svg)]

## Section 03 - Secure boot settings

This section hardens the grub related files, which is not available on the testing system.

[![Status: Skipped](https://img.shields.io/badge/Status-Skipped-red.svg)]

## Section 04 - Additional process hardening

This section looks for potential leaks and fix them. The build environment prohibid us from modifying some variables (such as *fs.suid_dumpable*).

[![Status: Partially Tested](https://img.shields.io/badge/Status-Partially tested-yellow.svg)]

## Section 05 - OS services

This section disables unneeded services on the system to reduce the attack surface. There is no restriction here.

[![Status: Tested](https://img.shields.io/badge/Status-Tested-brightgreen.svg)]

## Section 06 - Special purposes services

This section extends section 05 with other services.

[![Status: Partially Tested](https://img.shields.io/badge/Status-Partially tested-yellow.svg)]

## Section 07

This section forces sysctl values to correctly setup network and IPv6.

[![Status: Tested](https://img.shields.io/badge/Status-Tested-brightgreen.svg)]

## Section 08

This section configures logs and rights.

[![Status: Partially Tested](https://img.shields.io/badge/Status-Partially tested-yellow.svg)]

## Section 09

[![Status: Skipped](https://img.shields.io/badge/Status-Skipped-red.svg)]

## Section 010

[![Status: Skipped](https://img.shields.io/badge/Status-Skipped-red.svg)]

## Section 011

[![Status: Skipped](https://img.shields.io/badge/Status-Skipped-red.svg)]

## Section 012

[![Status: Skipped](https://img.shields.io/badge/Status-Skipped-red.svg)]

## Section 013

[![Status: Skipped](https://img.shields.io/badge/Status-Skipped-red.svg)]

