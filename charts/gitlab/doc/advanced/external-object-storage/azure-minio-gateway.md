---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Azure MinIO Gateway

[MinIO](https://min.io/) is an object storage server that exposes S3-compatible APIs and it has a gateway feature that allows proxying requests to Azure Blob Storage. To setup our gateway, we will make use of Azure's Web App on Linux.

To get started, make sure you have installed Azure CLI and you are logged in (`az login`). Proceed to create a [Resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview#resource-groups), if you don't have one already:

```shell
az group create --name "gitlab-azure-minio" --location "WestUS"
```

## Storage Account

Create a Storage account in your resource group, the name of the storage account must be globally unique:

```shell
az storage account create \
    --name "gitlab-azure-minio-storage" \
    --kind BlobStorage \
    --sku Standard_LRS \
    --access-tier Cool \
    --resource-group "gitlab-azure-minio" \
    --location "WestUS"
```

Retrieve the account key for the storage account:

```shell
az storage account show-connection-string \
    --name "gitlab-azure-minio-storage" \
    --resource-group "gitlab-azure-minio"
```

The output should be in the format:

```json
{
    "connectionString": "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=gitlab-azure-minio-storage;AccountKey=h0tSyeTebs+..."
}
```

## Deploy MinIO to Web App on Linux

First, we need to create an App Service Plan in the same resource group.

```shell
az appservice plan create \
    --name "gitlab-azure-minio-app-plan" \
    --is-linux \
    --sku B1 \
    --resource-group "gitlab-azure-minio" \
    --location "WestUS"
```

Create a Web app configured with the [`minio/minio`](https://hub.docker.com/r/minio/minio) Docker container, the name you specify will be used in the URL of the web app:

```shell
az webapp create \
    --name "gitlab-minio-app" \
    --deployment-container-image-name "minio/minio" \
    --plan "gitlab-azure-minio-app-plan" \
    --resource-group "gitlab-azure-minio"
```

The Web app should now be accessible at `https://gitlab-minio-app.azurewebsites.net`.

Lastly, we need to set up the startup command and create environment variables that will store our storage account name and key for use by the web app, MINIO_ACCESS_KEY & MINIO_SECRET_KEY.

```shell
az webapp config appsettings set \
    --settings "MINIO_ACCESS_KEY=gitlab-azure-minio-storage" "MINIO_SECRET_KEY=h0tSyeTebs+..." "PORT=9000" \
    --name "gitlab-minio-app" \
    --resource-group "gitlab-azure-minio"

# Startup command
az webapp config set \
    --startup-file "gateway azure" \
    --name "gitlab-minio-app" \
    --resource-group "gitlab-azure-minio"
```

## Conclusion

You can proceed to use this gateway with any client with s3-compability. Your web application URL will be the `s3 endpoint`, storage account name will be your `accesskey`, and storage account key will be your `secretkey`.

## Reference

<!-- vale gitlab.Spelling = NO -->

This guide was adapted for posterity from [Alessandro Segala's blog post on same topic.](https://withblue.ink/2017/10/29/how-to-use-s3cmd-and-any-other-amazon-s3-compatible-app-with-azure-blob-storage.html)

<!-- vale gitlab.Spelling = YES -->
