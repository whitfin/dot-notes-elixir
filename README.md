# dot-notes-elixir
[![Build Status](https://img.shields.io/travis/zackehh/dot-notes-elixir.svg)](https://travis-ci.org/zackehh/dot-notes-elixir) [![Coverage Status](https://img.shields.io/coveralls/zackehh/dot-notes-elixir.svg)](https://coveralls.io/github/zackehh/dot-notes-elixir) [![Hex.pm Version](https://img.shields.io/hexpm/v/dot_notes.svg)](https://hex.pm/packages/dot_notes) [![Documentation](https://img.shields.io/badge/docs-latest-yellowgreen.svg)](https://hexdocs.pm/dot_notes/)

This library is an Elixir port of [dot-notes](http://github.com/zackehh/dot-notes-js) to work with Elixir Maps/Lists. The interface is the same, but please check out the [Hexdocs](https://hexdocs.pm/dot_notes/DotNotes.html) for example usage.

Currently this library is only v1.0.0 but implements the same behaviour at v3.1 of the main JavaScript library. At some point in future there are plans to align all ports and make a specification in order to detail new features more easily.

## Installation

dot-notes-elixir is available on [Hex](https://hex.pm/). You can install the package via:

  1. Add dot-notes-elixir to your list of dependencies in `mix.exs`:

```elixir
  def deps do
    [{:dot_notes, "~> 1.0.0"}]
  end
```

## Differences to the JavaScript API

For the most part the API is the same, with minor differences due to Elixir's different types. One major difference is the addition of `DotNotes.reduce/4` which allows an accumulator alongside a `DotNotes.recurse/3` call. This is due to the fact that Elixir uses reductions to maintain state through recursion whereas in JavaScript you could just mutate variables from an outer scope.

### Contributing and Testing

If you wish to contribute (awesome!), please file an issue in the main dot-notes repo, as this is just a port (unless it's a bug in this library). All PRs should pass the Travis build and maintain 100% test coverage.

These tests can be run as follows:

```bash
$ mix test
$ mix coveralls
$ mix coveralls.html && open cover/excoveralls.html
```
