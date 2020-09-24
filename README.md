# embulk-masking-sample

## Install

```sh
# embulk: Java 1.8 is required to install this formula.
# Install AdoptOpenJDK 8 with Homebrew Cask:
brew cask install homebrew/cask-versions/adoptopenjdk8

# Install embulk
brew install embulk
```

## Example

[Official example](https://www.embulk.org/)

```sh
embulk example ./try1
embulk guess ./try1/seed.yml -o config.yml
embulk preview config.yml
embulk run config.yml
```
