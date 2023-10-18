## AWS Infrastructure

This folder contains all the code necessary to deploy the watcher service to a brand new ECS cluster

- Fully configured load balancing, port forwarding, and TLS
- Autoscaling with ECS on [Fargate](https://aws.amazon.com/fargate/)
- Reusable Infrastructure as Code, modularized as Terraform components

## Scaffolding

```text
.github/workflows/ci.yaml    <- CI Workflow
config
 ├── main.tf                 <- Entrypoint for all the module instantiations
 ├── variables.tf            <- Required input variables
 ├── outputs.tf              <- Generated console outputs
 ├── config.tf               <- Configuration for service
 └── modules
      ├── service            <- Generic, configurable ECS service
      ├── ecs                <- ECS cluster definition
      ├── iam                <- IAM roles needed for ECS
      ├── redis              <- Redis cache configuration
      └── networking         <- VPCs, Subnets and Security Groups

```

## Requirements

### 1. Terraform

For ease of dealing with terraform, install [`tfenv`](https://github.com/tfutils/tfenv) and install `terraform`:

```
>>> tfenv install 1.4.4
>>> tfenv use 1.4.4
```

### 2. S3 State bucket

Create an s3 bucket in any region using the default configuration. This bucket will store terraform's state,
so it is really important that it is never deleted or modified manually.

Suggested names: `watcher-deploy-terraform-state`

In `main.tf`, replace the values in:

```
terraform {
  backend "s3" {
    bucket = "watcher-deploy-terraform-state" # Use the name used above
    key    = "state"                          # Can stay the same
    region = "eu-central-1"                   # use the region specified
  }
  required_version = "~> 1.4.4"
}
```

## 3. Variables

### 3.1 Non-secret Variables

These should be placed in the `tfvars.json` file. They include

**3.1.1. Base Domain** (`base_domain`) \[REQUIRED\]

The base domain, of your hosted zone e.g. `connext.ninja`

**3.1.2. Watcher docker image** (`full_image_name_watcher`) \[REQUIRED\]

Fetch it from the desired release on Connext's [Github Packages](https://github.com/connext/monorepo/pkgs/container/watcher), e.g. `ghcr.io/connext/watcher:sha-bab495d`

**3.1.3. ECS Cluster Name** (`ecs_cluster_name`) \[REQUIRED\]

Name of the cluster. Must not contain spaces. E.g. `watcher-deploy`

**3.1.4. AWS Region** (`region`) \[REQUIRED\]

Region to which the cluster will be deployed

### 3.2 Secret Variables

These need to be set in GHA secrets (or deployment secrets). They will be accessed on CI runtime here: [ci.yaml#L11](https://github.com/connext/watcher-deploy/blob/main/.github/workflows/ci.yaml#L11-L26)

These need to be set exactly as named, e.g.

Make sure to edit the `ci.yaml` accordingly, if you plan on using the optional (commented out) variables.

**To know the possible options:** Check Connext Watcher repository's README file and the `config.tf` in this repository.

## Try out your watcher

Deployment should occur only via CI/CD with Github Actions. However, it is also possible to deploy the infra from a local set up in order to test it in Tenderly Devnets. Ensure you have the right AWS credentials and `terraform 1.4.4` installed as described above.

**Pre-requirement:** Go to the watcher repository and spin up a testnet using the "How to run the Devnets" section. By default in the `tfvars-devnet.json` the private key is pointed to this address: `0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266` which is a hardhat default account.

After that, you'll need to have set the secrets to your environment:
```shell
export TF_VAR_private_key="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
export TF_VAR_server_admin_token="foo"
export TF_VAR_environment="devnet"
export TF_VAR_tenderly_access_key="<Your Tenderly access key>"
export TF_VAR_tenderly_account_id="<Your Tenderly account id>"
export TF_VAR_tenderly_project_slug="<Your Tenderly project slug>"
export TF_VAR_github_token="<Github personal access token with read:packages access>"
export TF_VAR_custom_rpc_providers="<The Devnet RPCs given by the devnet spawn command in the watcher repository>"
```

In order to setup your devnet watcher environment in AWS use:

```shell
>>> terraform init
```

Plan the changes:

```shell
>>> terraform plan -var-file=tfvars-devnet.json
```

To set custom variables, you can set them with `export TF_ENV_<variable_name>=<variable value>` or use the `tfvars-devnet.json` file.

```shell
>>> terraform apply -var-file=tfvars-devnet.json -auto-approve
```

