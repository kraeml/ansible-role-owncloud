#!/bin/bash
read -n1 -p "Test ownloud-server or ubuntu-16.04? [o,u]: " doit
case $doit in
  o|O) distribution=owncloud && version=server;;
  u|U) distribution=ubuntu && version=16.04 && run_opts="--privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro" && init=/lib/systemd/systemd;;
  *) echo dont know ;;
esac

echo
echo "Building docker image for testing"
docker build --rm=true --file=tests/Dockerfile.${distribution}-${version} --tag=${distribution}-${version}:ansible tests

echo
echo "Running Testdummy"
docker run --detach --volume="${PWD}":/etc/ansible/roles/role_under_test:ro ${run_opts} --name testcontainer ${distribution}-${version}:ansible "${init}"

cd tests/serverspec_test

#echo Install required Galaxy roles.
#docker exec --tty testcontainer env TERM=xterm ansible-galaxy install -r /etc/ansible/roles/role_under_test/tests/requirements.yml

echo Ansible syntax check.
docker exec --tty testcontainer env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/tests/test.yml --syntax-check
echo $?

echo Test role.
docker exec --tty testcontainer env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/tests/test.yml

echo
echo "Executing tests:"
TARGET_CONTAINER=testcontainer TARGET_IMAGE=${distribution}-${version}:ansible rake spec

echo
echo "Cleaning up"
docker rm -f testcontainer
#docker rmi ${distribution}-${version}:ansible
