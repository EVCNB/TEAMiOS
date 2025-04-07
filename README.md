# How to build

Building this app is not fun. My opinion on whether or not an app is fun to build is based on some important criteria that this app fails to meet:

1. Dependency versions should be managed in a single git-committed file, or at least 

## Dependencies

1. XCode

Install XCode from the App Store, and then install the iOS support after opening it.

1. Pyenv

```zsh
brew install openssl@3
brew install pyenv
brew install pyenv-virtualenv
CONFIGURE_OPTS="--with-openssl=$(brew --prefix openssl@3)" pyenv install 3.9
pyenv virtualenv -f 3.9 venv-TEAMiOS
```

3. Ruby / Cocoapods

add these 2 lines to $HOME/.zshrc:

```zsh
export GEM_HOME="${HOME}/.gem"
export PATH="${GEM_HOME}/bin:${PATH}"
```

```zsh
brew install ruby-install rbenv
ruby-install 3.4.1
rbenv init
mkdir -p "${HOME}/.rbenv/versions"
ln -s "${HOME}/.rbenv/versions/ruby-3.4.1" "${HOME}/.rubies/ruby-3.4.1"
rbenv global 3.4.1
```

4. Flutter / TEAM

```zsh
git clone https://github.com/EVCNB/TEAM ../TEAM
brew install flutter
./build-flutter.sh
```

3. Upload IPA

For `TEAM.app`

```zsh
./upload-ipa.sh
```

For `TEAM Blue.app`

```bash
./upload-ipa.sh -a blueteam
```

