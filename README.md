<img src="https://github.com/opa334/Dopamine/assets/52459150/ed04dd3e-d879-456d-9aa3-d4ed44819c7e" width="64" />

## Changes in this Dopamine fork

- **Code signature bypass:** Inserts cdhashes temporarily into a reusable trustcache, attaches signatures to the file’s vnode, then releases the cache for reuse.
- **Hooking:** Litehook now installs hooks by signing replacement code pages. Invalid pages are now requested before ``mach_vm_protect`` calls with ``PROT_EXEC`` or ``PROT_COPY``.

Tested only on arm64.

# Dopamine

A rootless semi-untethered jailbreak for iOS 15.0 - 17.3.1 (arm64e), iOS 15.0 - 18.7.1, 26.0 - 26.0.1 (A12/A13) and iOS 15.0 - 18.7.1 (arm64). More details will follow here soon.

Please note that all issues related to version support will be deleted without response.

Official website / download: https://ellekit.space/dopamine/
