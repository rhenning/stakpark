PYPACKAGER = poetry
AWSCLI = awslocal
TERRAGRUNT = terragrunt
TGSWITCH = tgswitch
DEEPCLEAN = .terragrunt-cache .terraform __pycache__
TERRATEST_BASE_DIR = test
TERRATEST_ENVS_DIR = $(TERRATEST_BASE_DIR)/envs
TERRATEST_ENV_NAME = _example
GOTEST_FLAGS = -v -timeout 15m
GOLANGCI_LINT = golangci-lint

# literal space hack
space :=
space +=

# $(call join-with,<JOIN_STRING>,<SPACE_SEPARATED_OPERANDS>)
join-with = $(subst $(space),$(1),$(strip $(2)))

# @$(call log-<name>,<message>,)
log = printf '\n%s  %s\n\n' '$(1)' '$(2)'
log-target = $(call log,🎯,$(1))
log-info = $(call log,ℹ️,$(1))
log-ok = $(call log,✅,$(1))
log-wait = $(call log,🕐,$(1))
log-warn = $(call log,⚠️,$(1))
log-fail = $(call log,💩,$(1))
log-nuke = $(call log,💣,$(1))
log-sec = $(call log,🔒,$(1))
log-clean = $(call log,🧹,$(1))

.PHONY: clean dep test tinit up down check

default: dep lint
	@$(call log-target,$@)
	@$(call log-ok,$@)

clean:
	@$(call log-target,$@)
	@$(call log-info,deep cleaning cache + state dirs...)
	find . -type d -name \
		$(call join-with,$(space)-o$(space)-name$(space),$(DEEPCLEAN)) \
		| xargs rm -rf
	@$(call log-clean,$@)

dep:
	@$(call log-target,$@)
	@$(call log-wait,installing base dependency collection...)
	brew bundle --file Brewfile
	@$(call log-wait,setting up python dependencies)
	$(PYPACKAGER) install
	@$(call log-info,switching terragrunt version. restart your shell if this fails.)
	$(TGSWITCH)
	@$(call log-info,switching terraform version. restart your shell if this fails.)
	tfenv install
	@$(call log-ok,$@)

lint:
	@$(call log-target,$@)
	@$(call log-info,linting go code...)
	cd $(TERRATEST_BASE_DIR) && $(GOLANGCI_LINT) run
	@$(call log-ok,$@)

test: lint tfvalidate
	@$(call log-target,$@)
	@$(call log-info,running terragrunt...)
	cd $(TERRATEST_ENVS_DIR)/$(TERRATEST_ENV_NAME) && $(TERRAGRUNT) init
	@$(call log-info,running terratest...)
	cd $(TERRATEST_BASE_DIR) && go test $(GOTEST_FLAGS)
	@$(call log-ok,$@)

tfinit: creds
	@$(call log-target,$@)
	@$(call log-info,templating and initializing terraform...)
	cd $(TERRATEST_ENVS_DIR)/$(TERRATEST_ENV_NAME) && $(TERRAGRUNT) init
	@$(call log-ok,$@)

tfvalidate:
	@$(call log-target,$@)
	@$(call log-wait,validating terraform...)
	cd $(TERRATEST_ENVS_DIR)/$(TERRATEST_ENV_NAME) && $(TERRAGRUNT) validate
	@$(call log-ok,$@)


tfplan:
	@$(call log-target,$@)
	@$(call log-wait,planning terraform...)
	cd $(TERRATEST_ENVS_DIR)/$(TERRATEST_ENV_NAME) && $(TERRAGRUNT) plan
	@$(call log-ok,$@)

tfapply: 
	@$(call log-target,$@)
	@$(call log-wait,applying terraform...)
	cd $(TERRATEST_ENVS_DIR)/$(TERRATEST_ENV_NAME) && $(TERRAGRUNT) apply
	@$(call log-ok,$@)

tfdestroy: 
	@$(call log-target,$@)
	@$(call log-wait,destroying terraform...)
	cd $(TERRATEST_ENVS_DIR)/$(TERRATEST_ENV_NAME) && $(TERRAGRUNT) destroy
	@$(call log-nuke,$@)

# might be old non-functional copy-pasta atm
newstage:
	@$(call log-target,$@)
	@cd $(TERRAFORM_STAGES_DIR) \
		&& read -p '⩼  enter desired stage name: ' TFSTAGE \
		&& printf '\n' \
		&&	if [[ -d $$TFSTAGE ]]; then \
				printf '\n\n⚠️  stage already exists. (re)move it first.\n\n'; \
				exit 1; \
			fi \
		&& rsync -av --exclude=".*" $(TFSKEL)/ $$TFSTAGE
	@$(call log-ok,$@)

up:
	@$(call log-target,$@)
	@$(call log-wait,starting local test env with docker-compose...)
	docker-compose up

check:
	@$(call log-target,$@)
	@$(call log-wait,testing localstack AWS API access...)
	$(PYPACKAGER) run $(AWSCLI) sts get-caller-identity
	@$(call log-ok,$@)

down:
	@$(call log-target,$@)
	@$(call log-wait,stopping local test env with docker-compose...)
	docker-compose down
	@$(call log-ok,$@)
