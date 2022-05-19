export VAGRANT_VAGRANTFILE=./vagrant/Vagrantfile
export VAGRANT_DEFAULT_PROVIDER=virtualbox
export VAGRANT_DOTFILE_PATH=./vagrant/.vagrant

up: post-build

pre-build:
	@echo 1. Pre-build step:
	@echo Installing Ansible roles and collections
	ansible-galaxy role install -r ansible/requirements.yml
	ansible-galaxy collection install -r ansible/requirements.yml

main-build: pre-build
	@echo 2. Build step:
	vagrant up

post-build: main-build
	@echo 3. Build requirements:
	# ansible-galaxy update -r ./ansible/requirements.yml

provision: pre-build
	vagrant provision

reload: pre-build
	vagrant reload

clean:
	vagrant destroy -f