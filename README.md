# How to build

## Dependencies

1. Pyenv

```bash
brew install pyenv
brew install pyenv-virtualenv
pyenv install 3.9.7
pyenv virtualenv -f 3.9.7 venv-TEAMiOS
```

2. Flutter / TEAM

```bash
git clone https://github.com/EVCNB/TEAM ../TEAM
brew install flutter
./build-flutter.sh
```

3. Upload IPA

For `TEAM.app`

```bash
./upload-ipa.sh
```

For `TEAM Blue.app`

```bash
./upload-ipa.sh -a blueteam
```

