before_install:
	sudo docker pull ubuntu:14.04 ; \
	sudo docker build --rm=true --file=Dockerfile.ubuntu-14.04 --tag=ubuntu-14.04:ansible .

script:
	container_id=/tmp/cloud_test ; \
	sudo docker run --detach --volume="$$PWD/..":/etc/ansible/roles/role_under_test:ro ubuntu-14.04:ansible /sbin/init > "$${container_id}" ; \
	# sudo docker exec --tty "$$(cat $${container_id})" env TERM=xterm ansible-galaxy install -r /etc/ansible/roles/role_under_test/tests/requirements.yml ; \
	sudo docker exec --tty "$$(cat $${container_id})" env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/tests/test.yml --syntax-check ; \
	sudo docker exec --tty "$$(cat $${container_id})" env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/tests/test.yml ; \
	sudo docker exec --tty "$$(cat $${container_id})" env TERM=xterm curl localhost ; \
	sudo docker exec "$$(cat $${container_id})" ansible-playbook /etc/ansible/roles/role_under_test/tests/test.yml \
	| grep -q 'changed=0.*failed=0' \
	&& (echo 'Idempotence test: pass' && exit 0) \
	|| (echo 'Idempotence test: fail' && exit 1) ; \
	echo "Remove docker maualy"
	# sudo docker rm -f "$$(cat $${container_id})"

.PHONY: before_install script
