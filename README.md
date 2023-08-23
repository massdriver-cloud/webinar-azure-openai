# Run Azure OpenAI on Massdriver Webinar

This repository contains the source code and bundle code for the Azure OpenAI on Massdriver [webinar](https://www.massdriver.cloud/webinars). The Jupyter notebook application is deployed on Kubernetes using Massdriver. Feel free to follow along the webinar or go through the steps below to deploy the Azure Open AI bundle and application on your own.

## Prerequesites

To follow along with the webinar, you will need the following:

* Fork and clone this repository to your local machine
* A Massdriver account. You can sign up for a free account [here](https://app.massdriver.cloud/register).
* Set up cloud credentials for your Massdriver account. You can find instructions [here](https://app.massdriver.cloud/organization/credentials).
* A [terminal](https://docs.massdriver.cloud/getting-started/onboarding#install-terminal) to use the Mass CLI
* The [Mass CLI](https://docs.massdriver.cloud/cli/overview) tool
* [Docker Desktop](https://docs.massdriver.cloud/getting-started/onboarding#install-docker)
* An [IDE](https://docs.massdriver.cloud/getting-started/onboarding#install-ide) or text editor to edit the application code
* Lastly, configuring [environment variables](https://docs.massdriver.cloud/cli/overview###setup) for Massdriver

**Note: This will create resources in your cloud account. Be sure to decommission the resources after you are done.**

## Add DNS to Massdriver

If you want to access your application from the public internet, you will need to add DNS to Massdriver.

Follow this [guide](https://docs.massdriver.cloud/platform/dns-zones) on how to add a registered DNS domain to Massdriver.

This is optional, but if you do not add DNS, you will not be able to access your application from the public internet.

## Configure and Deploy App Dependencies

### Deploy Kubernetes

1. Log into [Massdriver canvas](https://app.massdriver.cloud/) and create a new project
2. Create a new environment and select your cloud credentials
3. On the create application template page, select `No thanks, I'll start with infrastructure`
4. Search for `kubernetes` in the bundle marketplace and drag your cloud's Kubernetes bundle to the canvas
5. Configure and deploy infrastructure from left to right
6. If you added DNS, enable ingress and add your domain in the Kubernetes bundle configuration

### Deploy Custom Azure OpenAI Bundle

1. In your `infra` directory, run `mass bundle publish` to publish the infrastructure template to Massdriver
2. Refresh the [Massdriver canvas](https://app.massdriver.cloud/) and search for `azure-openai`
3. Drag the custom OpenAI bundle to the canvas, click `Configure`, select a region and then deploy

## Configure and Deploy App

### Set App Environment Variables

1. Open the `massdriver.yaml` located in the `app` directory in a text editor
2. On line 9 is the `envs` block. This is where you will set your environment variables

```yaml
app:
  envs: {}
    # Use jq expressions to build environment variables from input params or connections
    # LOG_LEVEL: .params.configuration.log_level
    # MONGO_DSN: .connections.mongo_authentication.data.authentication.username + ":" + .connections.mongo_authentication.data.authentication.password + "@" + .connections.mongo_authentication.data.authentication.hostname + ":" + (.connections.mongo_authentication.data.authentication.port|tostring)
```

Update the `envs` block to look like this:

```yaml
app:
  envs:
    OPENAI_API_KEY: .connections.endpoint.data.api.hostname
    OPENAI_API_ENDPOINT: .connections.endpoint.data.etc.api_key
```

[Source](https://github.com/massdriver-cloud/artifact-definitions/blob/main/definitions/artifacts/api.json)

3. On line `181` is the `connections` block. This is where you will set your connections. Add the `endpoint` connection to the block like so:

```yaml
connections:
  required:
    - kubernetes_cluster
    - endpoint
  properties:
    kubernetes_cluster:
      $ref: massdriver/kubernetes-cluster
    aws_authentication:
      $ref: massdriver/aws-iam-role
    gcp_authentication:
      $ref: massdriver/gcp-service-account
    azure_authentication:
      $ref: massdriver/azure-service-principal
    endpoint:
      $ref: massdriver/api
```

4. Run `mass bundle publish` to publish the application template to Massdriver

(If you get an error, make sure you have set your [environment variables](#prerequisites))

### Push Docker image to cloud container registry

1. Using the Mass CLI, we're going to run `mass image push massdriver/openai -r eastus -a <your-massdriver-artifact-id> -t latest`
2. Before executing, get the artifact ID from the [artifacts page](https://app.massdriver.cloud/artifacts) in Massdriver, select your credential artifact, and click `Copy Artifact ID`
3. Insert your artifact ID and run the command
4. Copy the repo URL from the output

### Configure and deploy application

1. In the Massdriver canvas, refresh and search for your application template by name, i.e. `fine-tuning`
2. Drag your application template to the canvas
3. Click `Configure` on the application template
4. Add the repo URL into the `repository` field, and remove the `:latest` tag from the URL
5. Add 1 CPU and 1 MB of memory to the `Resources` field
6. Set the container port to `8080`
7. (If you have DNS configured) enable public internet access and set your domain name to `data.<your-domain-name>.com`
8. Deploy your application