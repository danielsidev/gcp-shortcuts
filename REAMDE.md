# Shortcuts for GCP Cloud Run

Some shortcuts to build a pipeline to Google Cloud Platform in a Makefile

## How to Use

- In local enviroment you can copy this Makefile to inside your project and make some adjusts to config your app

- If you have gcp credntials configured locally, you can run make commands to deploy, update and config infra resources

### Run Locally

- Build
> make build ENV=development (*ENV required. Can be development or production)
- Upload the build to the artifactory registry (GCP's online Docker image repository)
> make build-upload ENV=development (*ENV required. Can be development or production)
- Publish the application: Deploy
> make deploy ENV=development (*ENV required. Can be development or production)
- Update Resources: Upgrade or Downgrade infrastructure resources
> make infra ENV=development (*ENV required. Can be development or production)

**Theses examples use the enviroment variable ENV, but you can use others enviroment variables to replace the variables inside Makefile.**

> Pipeline

- To build a pipeline, just choice your git plataform and use some theses commands in your stages