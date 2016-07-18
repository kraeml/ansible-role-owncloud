# owncloud
Ansible roles for owncloud server installation, testing and general happiness.

## Tests

### Dependencies

* Vagrant >= 1.8.4
* Virtualbox >= 5.x

Run this commands:

```bash
$ vagrant up
$ vagrant ssh
owc-test$ cd owncloud
owc-test$ serverspec-runner
```
