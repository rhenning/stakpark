# `stakpark`

`stakpark` is an opinionated, clone-and-go environment template for local cloud
infrastructure development on macs. package management is handled by homebrew,
container runtime by docker, compose, and kind, and it includes other odds and
ends like localstack, golang, and terraform, tfenv, terragrunt, tgswitch, and
terratest.

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
