# terraform-skeleton-aws
Terraform skeleton for AWS projects

- [terraform-skeleton-aws](#terraform-skeleton-aws)
  - [Projects](#projects)
    - [Starting a New Project](#starting-a-new-project)
      - [Create a new repo from this template](#create-a-new-repo-from-this-template)
      - [Initialise the Statefile](#initialise-the-statefile)
  - [Makefile](#makefile)
  - [Terraform Files](#terraform-files)
  - [Git Hooks](#git-hooks)
    - [Requirements](#requirements)
    - [Installation](#installation)
    - [Run Hooks Manually](#run-hooks-manually)
    - [Updating Hooks](#updating-hooks)

## Projects

- The projects directory stores the .tfvars file for each project.
- The skeleton repo contains two directories.
- The globals directory is run each time Terraform is run and contains variables that are constant across deployments.
- The template directory is an example of an individual project file.
- When you use Makefile to run the Terraform command, it will run with the global variables as well as the variables of the - defined project.
- A project as an individual instantiation of the Terraform state - It could be an environment (`development`/`staging`/`production`), accounts (`aws1`, `aws2`, etc), or even regions (`ap-southeast-2`, `us-east-1`, etc).

### Starting a New Project

#### Create a new repo from this template

This command will output the SSH URL that you can use to clone the newly created repo.

```shell
curl -s -X POST https://api.github.com/repos/sammcj/terraform-skeleton-aws/generate \
-H "Accept: application/vnd.github.baptiste-preview+json" \
-H "Authorization: token $GIT_TOKEN" \
-d @<(cat <<EOF
{
  "owner": "sammcj",
  "name": "my-new-repo",
  "description": "My Test Repo",
  "private": true
}
EOF
)|jq -r .ssh_url
```

#### Initialise the Statefile

In order to avoid the chicken and the egg issue with terraform, we create the S3 storage and DynamoDB using a local statefile, and then once the resources exist we transfer the statefile to S3 bucket.

```shell
make stateinit
make stateplan
make stateapply
```

Uncomment the S3 backend in backends.tf file and then run the following command:

```
make init
```

## Makefile

- The `BUCKET` variable is used in the  terraform init command to set the S3 bucket used to store state.
- The `PROJECT` variable is the project that you want to run the terraform for - this variable is used in the name of the Terraform state file as well as to choose which project variables to run.

## Terraform Files

- `backend.tf` - Contains information about which backend to use (S3 in my case).
- `provider.tf` - Contains which provider to use.  Defaults to AWS.
- `main.tf` - Where modules are defined.
- `variables.tf` - Used to initialise all the variables to be passed in via the projects file.
- `outputs.tf` - For storing any outputs that you may want to make available to other Terraform projects at a later time.
- `statefile.tf` - For creating the resources needed to create the S3 bucket and DynamoDB used for the statefile.

## Git Hooks

Git pre-commit hooks are managed using pre-commit and pre-commit-terraform and provide linting and security tests.

### Requirements

- [pre-commit](https://pre-commit.com)
- [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)

### Installation

```shell
brew install pre-commit tfsec tflint gawk terraform-docs
pre-commit install
```

### Run Hooks Manually

```shell
pre-commit
```

### Updating Hooks

```shell
pre-commit update
```
