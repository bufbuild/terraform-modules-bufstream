# Bufstream Terraform Modules

> [!NOTE]
> Using the Terraform Modules in this repository requires a Bufstream key. If you don't have one, [contact us](https://buf.build/contact) to start a trial.

This repository compliments [Bufstream's documentation](https://buf.build/docs/bufstream/).

Within, you'll find a collection of modules that assist with deploying a Kubernetes cluster in
Amazon Web Services (AWS), Google Cloud Platform (GCP) or Microsoft Azure. These modules generate necessary resources
and then deploy Bufstream. The cluster created is meant to be used as a demo environment for those who would like
to test Bufstream but don't have an existing Kubernetes cluster.

The repo includes a convenience wrapper, `install.sh`, that requires you to set some environment variables.
To run it, you need to create a `tfvars` file that includes the required Terraform variables and any desired overrides.
See below for the required variables. There is a README for each module with more details on the
variables that can be set.

The install script relies on the following dependencies:

* [Terraform](https://developer.hashicorp.com/terraform/install)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Helm](https://helm.sh/docs/intro/install/)

For AWS with Postgres:

* [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* [jq](https://jqlang.org/download/)

Note that you'll also need to include a provider under the folder of the desired cloud.

Required environment variables:

| Variable            | Description                                                              |
| -----------------   | ------------------------------------------------------------------------ |
| BUFSTREAM_KEYFILE   | Path to file containing Bufstream base64 encoded key from Buf            |
| BUFSTREAM_VERSION   | The version of Bufstream to deploy                                       |
| BUFSTREAM_CLOUD     | Which cloud to deploy to. Must be `aws` or `gcp`                         |
| BUFSTREAM_TFVARS    | Path to the `tfvars` file                                                |
| BUFSTREAM_METADATA  | Which database to use for metadata storage. Must be `etcd` or `postgres` |

> [!WARNING]
> Postgres is only supported in AWS at this time.

Example of running the install script, you will need to replace the `<latest-version>` string with the version of Bufstream you are planning to deploy:

```bash
BUFSTREAM_KEYFILE=$PWD/keyfile \
BUFSTREAM_VERSION= <latest-version> \
BUFSTREAM_CLOUD=gcp \
BUFSTREAM_TFVARS=$PWD/bufstream.tfvars \
BUFSTREAM_METADATA=postgres \
install.sh
```

Because the script doesn't auto-apply the Terraform, you can review the Terraform plan before
the resources are deployed. As part of the deployment, the script generates a `kubeconfig` file in the `gen/` directory.
Use it to inspect the deployment or for troubleshooting.

```bash
# Assuming the namespace Bufstream was deployed to is "bufstream"
kubectl --kubeconfig gen/kubeconfig.yaml get pods -n bufstream
```

## AWS

By default, the module creates all resources necessary to deploy an auto mode Kubernetes cluster to the desired
account. It also creates some specific resources required for Bufstream: an S3 bucket and a role that the
Bufstream service account can assume to access the bucket using EKS Pod Identity.

If Postgres is selected for the metadata storage, an RDS instance and a Secrets Manager secret for the Postgres user password are also created.

Required variables in `tfvars`:

| Variable    | Description                                |
| ----------- | ------------------------------------------ |
| region      | Which region to deploy resources in        |
| vpc_name    | Name of the VPC to create (or use)         |
| bucket_name | Name of s3 bucket, must be globally unique |
| profile     | AWS profile to use for Terraform           |

Recommended variables in `tfvars`:

| Variable            | Description                |
| ------------------- | -------------------------- |
| eks_cluster_name    | Name for the EKS cluster   |
| eks_cluster_version | Version of the EKS cluster |

## GCP

By default, the module creates all resources necessary to deploy a Kubernetes cluster to the desired project.
It also creates some specific resources required for Bufstream: a storage bucket and a role that the service
account can assume to access the bucket.

Required variables in `tfvars`:

| Variable    | Description                                        |
| ----------- | -------------------------------------------------- |
| project_id  | ID of the project to deploy to                     |
| region      | Which region to deploy resources to                |
| bucket_name | Name of the bucket to use, must be globally unique |

Recommended variables in `tfvars`:

| Variable     | Description              |
| ------------ | ------------------------ |
| cluster_name | Name for the GKE cluster |

## Azure

By default, the module creates all resources necessary to deploy a Kubernetes cluster to the desired project.
It also creates some specific resources required for Bufstream: a storage account and container, a virtual network
and required subnets, and the bufstream identity with its required role assignment to access storage.

Required variables in `tfvars`:

| Variable | Description                                                                           |
| -------- | ------------------------------------------------------------------------------------- |
| location | Where to deploy the resources. A region that supports availability zones is required. |

Recommended variables in `tfvars`:

| Variable     | Description              |
| ------------ | ------------------------ |
| cluster_name | Name for the AKS cluster |

Note that due to Azure limitations, the plan will always show a diff because we include resources to find the current
tenant_id being worked on.
