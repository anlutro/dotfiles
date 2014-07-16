install:
	ln -sf $(shell pwd)/bash/aliases $$HOME/.bash_aliases
	ln -sf $(shell pwd)/bash/rc $$HOME/.bashrc
	ln -sf $(shell pwd)/git/config $$HOME/.gitconfig
	ln -sf $(shell pwd)/git/ignore_global $$HOME/.gitignore_global
	ln -sf $(shell pwd)/conkyrc $$HOME/.conkyrc
	ln -sf $(shell pwd)/tmux.conf $$HOME/.tmux.conf
	ln -sf $(shell pwd)/colordiffrc $$HOME/.colordiffrc
	ln -sfT $(shell pwd)/openbox $$HOME/.config/openbox

remove:
	rm -f $$HOME/.bash_aliases
	rm -f $$HOME/.bashrc
	rm -f $$HOME/.gitconfig
	rm -f $$HOME/.gitignore_global
	rm -f $$HOME/.conkyrc
	rm -f $$HOME/.config/openbox
	rm -f $$HOME/.tmux.conf
	rm -f $$HOME/.colordiffrc