## Why Two Remediations?
I figured it was worth mentioning I have the `Machine-Wide Installer uninstaller` and `per-user instances of Teams uninstaller` as two separate remediations. This was by design and in my opinion, the best way to handle the uninstallation of classic Teams. 

I created two separate remediations because one runs in the context of the system account and the other runs in the context of the user account. This is important because Teams installs in two different locations depending on the context.

Although you _technically_ can uninstall per-user Teams instances in the system context, I ran into several issues with it not cleaning up the user profile correctly. It would leave behind shortcuts and Teams would remain in Add/Remove Programs. I would fix this programmatically, but that's a lot of work for something that can be done with a simple script.

## How to Use
With the detection scripts,
you can specify if you want to confirm that new Teams is already installed before running the uninstaller.
This is useful
if you want to ensure that you're not uninstalling Teams on a device that doesn't have the new version installed yet.
Aside from that, it is implemented the same way as any other remediation.
See the main readme for more information on how to use these scripts.
Make sure that for the per-user remediation you select to run in the user context, **or it will not work.**

If you need help understanding or implementing this, feel free to reach out to me. I'm always happy to help. My contact info can be found on the main readme.

P.S. I hate the Teams Bootstrapper with a burning passion. I have never seen a more useless piece of software in my life. Leave it to Microsoft to make something that doesn't work.