s3_bucket="${PROJECT}-tf"
key="terraform-skeleton"
dynamodb_table="terraform-${PROJECT}-lock"
region="ap-southeast-2"

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## Initialises the bucket and dynamodb for state
stateinit:
	@if [ -z $(PROJECT) ]; then echo "PROJECT was not set" ; exit 10 ; fi
	@terraform init

## Shows the plan
stateplan: stateinit
	@terraform plan -input=false -refresh=true -var 'tf_project=${PROJECT}'

## Applies the state
stateapply: stateinit
	@terraform apply -input=true -refresh=true -var 'tf_project=${PROJECT}'

## Initialises the terraform remote state backend and pulls the correct projects state
init:
	@if [ -z $(PROJECT) ]; then echo "PROJECT was not set" ; exit 10 ; fi
	@rm -rf .terraform/*.tf*
	@terraform init \
        -backend-config="bucket=${s3_bucket}" \
        -backend-config="key=${key}.tfstate" \
        -backend-config="dynamodb_table=${dynamodb_table}" \
        -backend-config="region=${region}"

## Gets any module updates
update:
	@terraform get -update=true &>/dev/null

## Runs a plan
plan: init update
	@terraform plan -input=false -refresh=true -var-file=projects/$(PROJECT)/inputs.tfvars

## Shows what a destroy would do
plan-destroy: init update
	@terraform plan -input=false -refresh=true -module-depth=-1 -destroy -var-file=projects/$(PROJECT)/inputs.tfvars

## Shows a module
show: init
	@terraform show -module-depth=-1

## Runs the terraform grapher
graph:
	@rm -f graph.png
	@terraform graph -draw-cycles -module-depth=-1 | dot -Tpng > graph.png
	@open graph.png

## Applies a new state
apply: init update
	@terraform apply -input=true -refresh=true -var-file=projects/$(PROJECT)/inputs.tfvars

## Show outputs of a module or the entire state
output: update
	@if [ -z $(MODULE) ]; then terraform output ; else terraform output -module=$(MODULE) ; fi

## Destroys targets
destroy: init update
	@terraform destroy -var-file=projects/$(PROJECT)/inputs.tfvars
