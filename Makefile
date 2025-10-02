SHELL := /bin/bash
ENV="development"
APP_NAME_SERVICE="my_project_name-$(ENV)"
APP_NAME="terapia-chat-$(ENV)"
APP_VERSION="v1.0.0"
APP_NAME_SECRET="my_project_name-$(ENV)-secret:latest"
PROJECT="my_project_name"
MAX_INSTANCES=10
MIN_INSTANCES=1
MEMORY=512Mi
CPU=1


# Sets the maximum number of instances based on the environment.
ifeq ($(ENV), production)
  MAX_INSTANCES = 10
  MIN_INSTANCES = 2
  MEMORY = 1Gi
  CPU = 1
else ifeq ($(ENV), development)
  MAX_INSTANCES = 11
  MIN_INSTANCES = 1
  MEMORY = 512Mi
  CPU = 1
else
  MAX_INSTANCES = 1
endif

download: ## Download go dependencies 
	go mod tidy

doc: ## generate swagger documentation	
	swag init --parseDependency -parseInternal -g main.go -td "[[,]]"

up: ## Start with docker compose
	docker-compose up --build

down: ## Stop with docker compose
	docker-compose down

clean-go:
	 go clean -modcache

clean: ## Clean all containers from application and networks
	docker system prune

run: ## Start withoud docker
	go run main.go

test: ## Run unit test without race detection 
	go test -v ./...

test-race: ## Run unit test with race detection
	go test -v -race  ./...

login: # make login in your account in gcp
	gcloud auth login

list-project: # shows what project is in use right now
	gcloud config list

set-project: # define wich project you are using now
	gcloud config set project $(PROJECT)

set-quota-project: # set which project should be charged and which quotas should be checked for the operations carried out.
	gcloud auth application-default set-quota-project $(PROJECT)

build: # mount app's image	
	docker build -t gcr.io/$(PROJECT)/$(APP_NAME_SERVICE):$(APP_VERSION) .

auth:
	gcloud auth configure-docker

build-upload: # send your image to google repository
	docker push gcr.io/$(PROJECT)/$(APP_NAME_SERVICE):$(APP_VERSION)

deploy: # make a deploy from your last image version in google repo
	gcloud run deploy $(APP_NAME_SERVICE) --image gcr.io/$(PROJECT)/$(APP_NAME_SERVICE):$(APP_VERSION) \
	--platform managed \
	--set-secrets SECRET_MANAGER_TERAPIA=$(APP_NAME_SECRET) \
	--region=us-east1 \
	--allow-unauthenticated \
	--max-instances=$(MAX_INSTANCES) \
	--min-instances=$(MIN_INSTANCES) \
	--memory=$(MEMORY) \
	--cpu=$(CPU) \

update: # just update your app's image
	gcloud run services update $(APP_NAME_SERVICE) --set-secrets SECRET_MANAGER_TERAPIA=$(APP_NAME_SECRET)	 

instances: # increase or decrease the number of instances
	gcloud run services update $(APP_NAME_SERVICE) --min-instances=$(MIN_INSTANCES) --max-instances=$(MAX_INSTANCES)  --region=us-east1 

	
infra: # just to config infra's resources
	gcloud run services update $(APP_NAME_SERVICE) \
    --image=gcr.io/$(PROJECT)/$(APP_NAME_SERVICE):$(APP_VERSION) \
    --memory=2Gi \
    --cpu=2 \
    --min-instances=2 \
    --max-instances=60 \
    --port=8080 \
    --platform=managed \
    --region=us-east1 

