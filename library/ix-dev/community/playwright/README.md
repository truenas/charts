# Playwright

[Playwright](https://playwright.dev/) is a testing framework for end-to-end testing of web applications. Playwright can automate user interactions in Chromium, Firefox and WebKit browsers with a single API. This Docker image contains all the required dependencies to launch the browsers and a Node.js runtime to execute your tests.

> The following applies only when the storage type is set to **ixVolume**
> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Playwright` directories.
> Afterward, the `Playwright` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
