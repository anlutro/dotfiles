#!/usr/bin/env sh

if [ -z "$HOME" ]; then
    echo "\$HOME is empty, aborting"
    exit 1
fi

if [ ! -d $HOME/.local ]; then
    mkdir -p $HOME/.local
    chmod 700 $HOME/.local
fi
if [ ! -d $HOME/.local/bin ]; then
    mkdir -p $HOME/.local/bin
fi
bindir=$HOME/.local/bin
root=$(dirname "$(realpath "$0")")
configs=$root/configs
scripts=$root/scripts
vendor=$root/vendor

install() {
    name="$1"
    func="install_$(echo $1 | tr -s '-' '_')"
    cmd=${2:-$1}
    if command -v $cmd >/dev/null 2>&1; then
        printf "Setting up %s ... " "$name"
        $func
        echo "done"
    fi
}

vendor_install() {
    git_repo="$1"
    if [ -n "${2-}" ]; then
        name="$2"
    else
        name=$(basename "$git_repo")
    fi
    if [ -e "$HOME/code/$name" ]; then
        rm -rf "$vendor/$name" && ln -sfT "$HOME/code/$name" "$vendor/$name"
    elif [ -e "$HOME/code/contrib/$name" ]; then
        rm -rf "$vendor/$name" && ln -sfT "$HOME/code/contrib/$name" "$vendor/$name"
    elif [ ! -e "$vendor/$name" ]; then
        git clone "$git_repo" "$vendor/$name"
        return 0
    fi
    return 1
}

_install_fzf() {
    if [ ! -e /usr/bin/fzf ]; then
        vendor_install https://github.com/junegunn/fzf && $vendor/fzf/install --bin
        ln -sf $vendor/fzf/bin/fzf $bindir
    fi
}

install_alacritty() {
    ln -sf $configs/alacritty.yml $HOME/.config/alacritty.yml
    if [ -d $HOME/.config/alacritty ]; then
        ln -sf $configs/alacritty.yml $HOME/.config/alacritty/alacritty.yml
    fi
}

install_bash() {
    ln -sf $configs/shell/bashrc $HOME/.bashrc
    [ -f $HOME/.bash_aliases ] && rm $HOME/.bash_aliases
    [ -f $HOME/.bash_profile ] && rm $HOME/.bash_profile
    [ -f $HOME/.bash_ps1 ] && rm $HOME/.bash_ps1
    ln -sf $configs/shell/logout $HOME/.bash_logout
    _install_fzf
}

install_dropbox() {
    mkdir -p $HOME/.config/systemd/user
    ln -sf $configs/systemd/dropbox.service $HOME/.config/systemd/user
    systemctl --user enable --now dropbox.service
}

install_dunst() {
    mkdir -p $HOME/.config/dunst
    ln -sf $configs/dunstrc $HOME/.config/dunst/dunstrc
}

install_git() {
    local local_conf
    local git_version
    git_version=$(git --version | grep -oP '[\d+.]+')

    if echo $git_version | grep -q '^1'; then
        ln -sf $configs/git/config $HOME/.gitconfig
        ln -sf $configs/git/ignore_global $HOME/.gitignore_global
        local_conf=$HOME/.gitconfig.local
    else
        [ -e $HOME/.gitconfig ] && rm $HOME/.gitconfig
        [ -e $HOME/.gitignore_global ] && rm $HOME/.gitignore_global
        [ -e $HOME/.gitconfig.local ] && \
            mv $HOME/.gitconfig.local $HOME/.config/git/config.local

        local conf_path=$HOME/.config/git
        mkdir -p $conf_path
        ln -sf $configs/git/config $conf_path/config
        ln -sf $configs/git/ignore_global $conf_path/ignore
        ln -sf $configs/git/attributes_global $conf_path/attributes
        local_conf=$conf_path/config.local
    fi

    local git_config="git config --file $local_conf"

    if [ ! -f $local_conf ] || ! $git_config user.name > /dev/null; then
        $git_config user.name 'Andreas Lutro'
        $git_config user.email 'anlutro@gmail.com'
    fi

    if echo $git_version | grep -q '^1'; then
        if [ ! -f $local_conf ] || ! $git_config core.excludesfile > /dev/null; then
            $git_config core.excludesfile .gitignore_global
        fi
    else
        if [ -f $local_conf ]; then
            $git_config --unset core.excludesfile
        fi
    fi

    ln -sf $scripts/git-abort.sh $bindir/git-abort
    ln -sf $scripts/git-with-sshkey.sh $bindir/git-with-sshkey
    ln -sf $scripts/git-find-large-files.sh $bindir/git-find-large-files
    ln -sf $scripts/git-all-my-logs.sh $bindir/git-all-my-logs
}

_install_gtk_theme() {
    if [ -e "$1" ]; then
        ln -sfT "$1" "$HOME/.themes/$(basename "$1")"
        ln -sfT "$1" "$HOME/.local/share/themes/$(basename "$1")"
    else
        echo >&2 "gtk theme directory does not exit: $1"
    fi
}

install_gtk() {
    ln -sf $configs/gtk/gtk2-rc $HOME/.gtkrc-2.0

    mkdir -p $HOME/.themes
    mkdir -p $HOME/.local/share/themes

    vendor_install https://github.com/lassekongo83/zuki-themes
    _install_gtk_theme $vendor/zuki-themes/gtk/src/Zukitwo
    _install_gtk_theme $vendor/zuki-themes/gtk/src/Zukitwo-dark
    _install_gtk_theme $vendor/zuki-themes/gtk/src/Zukitre
    _install_gtk_theme $vendor/zuki-themes/gtk/src/Zukitre-dark

    if [ -d $HOME/.config/gtk-3.0 ]; then
        ln -sf $configs/gtk/gtk3-settings.ini $HOME/.config/gtk-3.0/settings.ini
    fi
}

install_i3() {
    mkdir -p $HOME/.config/i3
    ln -sf $configs/i3/i3.conf $HOME/.config/i3/config
}

install_i3blocks() {
    vendor_install https://github.com/vivien/i3blocks-contrib

    local conf_path=$HOME/.config/i3blocks
    mkdir -p $conf_path
    ln -sf $configs/i3/i3blocks.conf $conf_path/config

    [ -L $conf_path/scripts ] && rm $conf_path/scripts
    [ ! -d $conf_path/scripts ] && mkdir -p $conf_path/scripts

    ln -sf $vendor/i3blocks-contrib/memory/memory $conf_path/scripts/
    ln -sf $vendor/i3blocks-contrib/volume/volume $conf_path/scripts/

    for f in $configs/i3/block-scripts/*; do
        filepath=$(realpath $f)
        filename=$(basename $f)
        ln -sf $filepath $conf_path/scripts/$filename
    done
}

install_i3status() {
    mkdir -p $HOME/.config/i3status
    ln -sf $configs/i3/i3status.conf $HOME/.config/i3status/config
}

install_irssi() {
    mkdir -p $HOME/.irssi
    ln -sf $configs/irssi/default.theme $HOME/.irssi/default.theme
    ln -sfT $configs/irssi/scripts $HOME/.irssi/scripts
}

install_moc() {
    mkdir -p $HOME/.moc
    ln -sfT $configs/moc.conf $HOME/.moc/config
}

install_mpv() {
    mkdir -p $HOME/.config/mpv
    ln -sfT $configs/mpv-config $HOME/.config/mpv/config
}

install_mutt() {
    if [ ! -e $HOME/.muttrc ] || [ -L $HOME/.muttrc ]; then
        ln -sfT $configs/muttrc $HOME/.muttrc
    fi
}

install_nano() {
    ln -sf $configs/nanorc $HOME/.nanorc
}

install_python() {
    ln -sf $scripts/templ.py $bindir/templ
    vendor_install https://github.com/anlutro/psm
    ln -sf $vendor/psm/psm.sh $bindir/psm
    vendor_install https://github.com/anlutro/venv.sh
}

install_rg() {
    ln -sf $configs/ripgreprc $HOME/.config/ripgreprc
}

install_subl() {
    if [ -d $HOME/.config/sublime-text-3/Packages ]; then
        pkgdir=$HOME/.config/sublime-text-3/Packages
    elif [ -d "$HOME/Library/Application Support/Sublime Text/Packages" ]; then
        pkgdir="$HOME/Library/Application Support/Sublime Text/Packages"
    else
        echo "Sublime Text Packages directory not found!"
        return
    fi
    userdir="$pkgdir/User"
    mkdir -p "$pkgdir"
    if [ -d "$userdir" ] && [ ! -L "$userdir" ]; then
        mv "$userdir" "$userdir.bak"
    fi
    ln -sfT "$configs/sublime-text" "$userdir"
    ln -sf "$scripts/sublp.sh" "$bindir/sublp"
}

install_taskwarrior() {
    ln -sf $configs/taskrc $HOME/.taskrc
}

install_tmux() {
    ln -sf $configs/tmux.conf $HOME/.tmux.conf
}

_install_urxvt_perl() {
    if [ -f "$configs/urxvt-ext/$1" ]; then
        ln -sf "$configs/urxvt-ext/$1" $HOME/.urxvt/ext/$1
    elif [ -f "$vendor/urxvt-perls/$1" ]; then
        ln -sf "$vendor/urxvt-perls/$1" $HOME/.urxvt/ext/$1
    elif [ -f "$vendor/urxvt-perls/deprecated/$1" ]; then
        ln -sf "$vendor/urxvt-perls/deprecated/$1" $HOME/.urxvt/ext/$1
    fi
}

install_urxvt() {
    vendor_install https://github.com/muennich/urxvt-perls
    vendor_install https://github.com/majutsushi/urxvt-font-size

    mkdir -p $HOME/.urxvt/ext
    _install_urxvt_perl url-select
    _install_urxvt_perl clipboard
    _install_urxvt_perl keyboard-select
    ln -sf "$vendor/urxvt-font-size/font-size" $HOME/.urxvt/ext/font-size
}

vim_common() {
    # make sure this function is only called once
    [ -n "$vim_common_installed" ] && return
    vim_common_installed=1

    vendor_install https://github.com/nanotech/jellybeans.vim
    ln -sf ../../../vendor/jellybeans.vim/colors/jellybeans.vim $configs/vim/colors/jellybeans.vim

    if command -v salt >/dev/null 2>&1; then
        printf "salt-vim... "
        vendor_install https://github.com/saltstack/salt-vim
        ln -sf ../../../vendor/salt-vim/ftdetect/sls.vim $configs/vim/ftdetect/sls.vim
        ln -sf ../../../vendor/salt-vim/ftplugin/sls.vim $configs/vim/ftplugin/sls.vim
        ln -sf ../../../vendor/salt-vim/syntax/sls.vim $configs/vim/syntax/sls.vim
    fi
}

install_vim() {
    vim_common

    ln -sfT $configs/vim/init.vim $HOME/.vimrc

    mkdir -p $HOME/.vim
    for file in $configs/vim/*; do
        if [ $file != $configs/vim/init.vim ]; then
            ln -sfT $file "$HOME/.vim/$(basename "$file")"
        fi
    done
}

install_nvim() {
    vim_common

    mkdir -p $HOME/.config/nvim
    for file in $configs/vim/*; do
        ln -sfT $file "$HOME/.config/nvim/$(basename "$file")"
    done
}

install_wireplumber() {
    ln -sfT $configs/wireplumber $HOME/.config/wireplumber
}

install_xdg() {
    ln -sf $configs/user-dirs.dirs $HOME/.config/user-dirs.dirs
}

install_xorg() {
    # startx uses xinitrc. tried using startxrc but it was wonky
    [ -L $HOME/.startxrc ] && rm $HOME/.startxrc
    ln -sf $configs/xorg/xinitrc.sh $HOME/.xinitrc

    xorg_cfg_dir=$HOME/.config/xorg
    mkdir -p $xorg_cfg_dir

    # various scripts and configs
    ln -sf $configs/xorg/xrandrinit.sh $xorg_cfg_dir
    ln -sf $configs/xorg/xsettings.sh $xorg_cfg_dir
    ln -sf $configs/xorg/xprograms.sh $xorg_cfg_dir
    ln -sf $configs/xorg/xcompose $HOME/.XCompose
    ln -sf $scripts/lockscreen.sh $bindir/lockscreen
    [ -L $HOME/.xrandrinit ] && rm $HOME/.xrandrinit
    [ -L $HOME/.xsettings ] && rm $HOME/.xsettings

    # xrdb stuff
    ln -sf $configs/xorg/xdefaults $HOME/.Xdefaults

    # fontconfig
    FC_DIR=$HOME/.config/fontconfig/conf.d
    mkdir -p $FC_DIR
    ln -sf $configs/fontconfig/fonts.conf $FC_DIR/00-common.conf
    rm -f $HOME/.fonts.conf
    rm -f $HOME/.config/fontconfig/fonts.conf
    rm -f $HOME/.config/fontconfig/local.conf
}

install_zsh() {
    ln -sf $configs/shell/zshrc $HOME/.zshrc
    ln -sf $configs/shell/profile $HOME/.zprofile
    ln -sf $configs/shell/logout $HOME/.zlogout
    _install_fzf
}


if [ ! -e $root/.venv ]; then
    echo "Setting up virtual environment ..."
    python3 -m venv $root/.venv
    $root/.venv/bin/pip install --upgrade setuptools pip
    echo
fi
if [ -e $root/requirements.txt ]; then
    echo "Installing Python requirements ..."
    $root/.venv/bin/pip install --upgrade -r $root/requirements.txt
    echo
fi


printf "Linking shared configs... "
ln -sf $configs/shell/profile $HOME/.profile
ln -sf $configs/shell/inputrc $HOME/.inputrc
[ -L $HOME/.aliases ] && rm $HOME/.aliases
[ -L $HOME/.shell_aliases ] && rm $HOME/.shell_aliases
[ -L $HOME/.shell_vars ] && rm $HOME/.shell_vars
[ -L $HOME/.shrc ] && rm $HOME/.shrc
[ -L $HOME/.shrc.d ] && rm $HOME/.shrc.d
if [ ! -d $HOME/.ssh ]; then
    mkdir -p $HOME/.ssh
    chmod 700 $HOME/.ssh
fi
ln -sf $configs/ssh/rc $HOME/.ssh/rc
echo "done"


printf "Linking various bin scripts... "
ln -sf $scripts/set-brightness.sh $bindir/set-brightness
ln -sf $scripts/init-project.py $bindir/init-project
[ -L $bindir/journal ] && rm $bindir/journal
ln -sf $scripts/diary.sh $bindir/diary
ln -sf $scripts/notes.sh $bindir/notes
vendor_install https://github.com/ap/rename
ln -sf $vendor/rename/rename $bindir/
echo "done"


install alacritty
install bash
install dunst
install git
install gtk gtk-update-icon-cache
install i3
install i3blocks
install i3status
install irssi
install moc mocp
install mpv
install mutt
install nano
install python
install rg
install subl
install taskwarrior task
install tmux
install urxvt
install vim
install nvim
install wireplumber
install xorg Xorg
install xdg xdg-open
install zsh

[ -e ~/.dropbox-dist ] && install_dropbox

echo


# look for broken symlinks
echo "Looking for broken symlinks..."
find $configs -xtype l
find $scripts -xtype l
find $bindir -xtype l
[ -d $HOME/.themes ] && find $HOME/.themes -xtype l
