# computer

my computer setup, mostly using brewfile.

feel free to fork this and swap out the `Brewfile` for your own setup!

**[read more about how it works with my blog post.](https://7.dev/brewfile/)**

## usage

### starting with a new computer

```sh
$ ./install       # install packages
```

> Note: ./install is a very lightweight wrapper around `brew bundle`, and transparently passes all arguments to it. This is useful in situations where you're moving an _existing_ computer with _existing_ applications to this setup: use `./install --force` (be careful!) to force install any applications and theoretically update them to the brew-managed version.

### install new brews/casks

```sh
$ ./add-brew brew-name
$ ./add-cask cask-name
```

## file management/utils

```sh
$ ./sort-brewfile # sort Brewfile
$ ./commit        # generate new commit based on timestamp
```
