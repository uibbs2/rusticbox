# rusticbox
Rustic commands in bash script and/or awk for compact system, as a 'rustic' alternative to busybox

Originally based on the script "gateway" with rustic implementations of some commands, available on [muLinux by Michele Andreoli](https://micheleandreoli.org/public/Software/mulinux/)

I've find out other ways to implement commands in pure bash script

## prerequisites
* Bash 4
* Awk
* Sed

## use
* put the binary into /bin or /sbin
* use symlinks with the name of the required bin
* launch rusticbox.sh to see the list of available commands
