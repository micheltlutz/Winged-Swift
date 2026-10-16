# Security Policy

## Reporting a Vulnerability

At WingedSwift, we take security seriously. We welcome and appreciate responsible disclosure of security vulnerabilities.

If you discover a security vulnerability in this project, please follow these steps to report it:

1. **Privately Notify Us**: Please send an email to [michel@micheltlutz.me](mailto:michel@micheltlutz.me) with details of the vulnerability. Please do not disclose the issue publicly until we have had a chance to review and address it.

2. **Provide Information**: In your email, include a clear description of the vulnerability, steps to reproduce it, and any supporting documentation or proof-of-concept code.

3. **Cooperate with Us**: We may need to work with you to better understand the issue, so please be prepared to provide additional information or assist with testing.

4. **Responsible Disclosure**: We will work diligently to address the vulnerability and will keep you updated on our progress. Once the issue is resolved and a fix is available, we will coordinate with you to determine the appropriate time for disclosure.

## Supported Versions

Security fixes are released for the latest major version of WingedSwift (currently 3.x). If you are using an older version, update to the latest release to get security patches — [MIGRATION.md](MIGRATION.md) covers every upgrade step.

## Scope

WingedSwift generates HTML at build time; it has no runtime and serves nothing. The issues that matter most are in the rendered output:

- Text content or attribute values that render unescaped.
- A `javascript:`, `vbscript:` or `data:text/html` URL that survives the script-URL policy in `href`, `src` or another URL attribute.
- Anything in the `winged` CLI (`new`, `serve`, `deploy`) that writes outside the project, executes untrusted input, or exposes files it should not serve.

Output produced through the explicit opt-outs — `RawHTML`, `escapeContent: false` and `.trustedURL` — is the caller's responsibility and is not considered a vulnerability.

## Security Best Practices

When building a site with WingedSwift, we recommend:

- Pass raw text and let the library escape it; never pre-escape or build markup with string interpolation.
- Use `RawHTML`, `escapeContent: false` and `.trustedURL` only for markup and URLs you wrote yourself.
- Keep WingedSwift and your other dependencies up to date.

Thank you for helping us keep WingedSwift secure. Your cooperation and responsible disclosure are greatly appreciated.
