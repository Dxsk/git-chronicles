# Security Policy

## Supported versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

Only the latest version deployed on [git.learning.dxscloud.fr](https://git.learning.dxscloud.fr) is supported.

## Reporting a vulnerability

If you discover a security vulnerability, **please do not open a public issue**.

Instead, report it privately by emailing **daihyxsk+security.github@pm.me**.

Please include:
- A description of the vulnerability
- Steps to reproduce it
- The potential impact
- A suggested fix (if you have one)

## Response timeline

- **Acknowledgment**: within 72 hours
- **Assessment**: within 1 week
- **Fix or mitigation**: as soon as reasonably possible

## Scope

This is a static educational website with no user accounts, databases, or server-side processing. The main security concerns are:

- XSS vulnerabilities in the generated static site
- Malicious content in verification scripts (Bash/PowerShell)
- Supply chain issues in npm dependencies
- GitHub Actions workflow security

## Disclosure

We follow coordinated disclosure. Once a fix is deployed, we will credit the reporter (unless they prefer to remain anonymous).
