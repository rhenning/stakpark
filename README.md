# `stakpark`

`stakpark` is an opinionated, clone-and-go environment template for local cloud
infrastructure development on macs. package management is handled by homebrew,
container runtime by docker, compose, and kind, and it includes other odds and
ends like [localstack]("https://localstack.cloud"), golang, and terraform, tfenv, terragrunt, tgswitch, and
terratest.

<img style="width:300px" src="https://raw.githubusercontent.com/localstack/.github/main/assets/localstack-readme-banner.svg" />
<img style="width:300px" src="https://camo.githubusercontent.com/2b507540e2681c1a25698f246b9dca69c30548ed66a7323075b0224cbb1bf058/68747470733a2f2f676f6c616e672e6f72672f646f632f676f706865722f6669766579656172732e6a7067" />
<img style="width:300px" src="https://camo.githubusercontent.com/1a4ed08978379480a9b1ca95d7f4cc8eb80b45ad47c056a7cfb5c597e9315ae5/68747470733a2f2f7777772e6461746f636d732d6173736574732e636f6d2f323838352f313632393934313234322d6c6f676f2d7465727261666f726d2d6d61696e2e737667" />

*Gopher image by [Renee French][rf], licensed under [Creative Commons 4.0 Attributions license][cc4-by].*


## motivation

i've grown tired of creating this structure from scratch each time i'd like
an aws development sandbox.

## up and running

_psst..._ did you catch that first paragraph where i said this was an
_opinionated_ template? it installs a bunch of stuff with homebrew. i
strongly suggest eyeballing the brewfile before continuing and making
adjustments if you're not crazy about something there. that said...

```bash
: install dependencies
make dep

: start localstack
make up

: smoke test (from another terminal)
make check

: run legit tests (from same terminal as previous)
make test
```

more targets:

```bash
make tfinit
make tfvalidate
make tfplan
make tfapply
make tfdestroy
```

start a shell and use the AWS CLI against the local test environment:

```bash
poetry shell
awslocal sts get-caller-identity
awslocal ec2 describe-vpcs
```

## what now?

feel free to copy `test/envs/_example` to a new directory and adjust as
desired to create your own environment. `a_test.go` and `Makefile`
contain references to `_example`, so be sure to update those.

have fun.

## faq

Q: __i have purchased a localstack pro license. how can i use it?__
A: `make up LOCALSTACK_API_KEY="t0ps3<r37"`

[rf]: https://reneefrench.blogspot.com/
[cc4-by]: https://creativecommons.org/licenses/by/4.0/