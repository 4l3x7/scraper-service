

## AL - Scraper Service

[![Push, Deploy and Test](https://github.com/4l3x7/scraper-service/actions/workflows/push-and-deploy.yml/badge.svg)](https://github.com/4l3x7/scraper-service/actions/workflows/build.yml)
[

### Description

Write a web service (let's call it scraper_service) to grab the HTTP GET code of a given URL and expose a Prometheus metric.

The scraper_service listens on port 8080 and receives the following JSON POST request:

    ./scraper_service --listen=:8080 &
    curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"url": "http://phaidra.ai"}' \
    localhost:8080

The scraper_service exposes a prometheus (prometheus-client) service on port 9095 under path /metrics and a counter for every HTTP GET it performs. The counter metric exposed is http_get with labels url and code . The metric value is increased on every request.

    curl --header "Content-Type: application/json" \ 
    --request POST \ 
    --data '{"url": "http://phaidra.ai"}' \ 
    localhost:8080 
    curl localhost:9095/metrics 
    ... 
    http_get{"url"="http://phaidra.ai","code"="301"} 1 
    curl localhost:9095/metrics 
    ... 
    http_get{"url"="http://phaidra.ai","code"="301"} 2 


#### Requirements

- Write scraper_service in Python or Golang ideally (but use any other language you are comfortable with)
- Provide a Dockerfile to run scraper_service
- Provide a README.md with instructions on how to build and run scraper_service
- A couple of functional tests

#### Good to have

- A Kubernetes Deployment (or other resources as you see fit) definition A script to regularly request scraper_service
- A simple Prometheus configuration setup to query scraper_service Write a PromQL query and document its usage in README.md

### Tools selected

The tools used in this exercise are

#### For the application

 - PHP
 - [Slim framework](https://www.slimframework.com/) for the REST API
	 - Built-in web server
 - [PHP Prometheus client](https://github.com/PromPHP/prometheus_client_php)
 - [APCu](https://www.php.net/manual/en/book.apcu.php) for in-memory storage

#### For infrastructure and deployment

- Kubernetes
- GKE to host the kubernetes cluster
	- NGINX Ingress Controller manager
- Terraform for the cluster creation with IaC approach
- [Hadolint](https://github.com/hadolint/hadolint) to lint the DockerFile
- Prometheus and Grafana for the monitoring
- GitHub repository with GitHub Actions enabled to use CI/CD approach
- [DockerHub public respository](https://hub.docker.com/r/usagre90/scraper-service)
	- It has been made public to facilitate evaluation
 -   Kustomize to generate and customize deployment manifest files
 - ArgoCD to deploy using GitOps Approach

### The webservice

There is a Dockerfile in the root directory. It consist in:

 - [php:8-0-alpine base image](https://hub.docker.com/layers/php/library/php/8.0-alpine/images/sha256-21ca0d03f3c7fc8e0ffed3fadaae8868d0a14467112c6f01891d54c101b95ea2?context=explore)
 - Slim framework depencies installation with composer
 - APCu dependencies installation and configuration
 - Source file copying (see scraper-service/scraper-service/app/routes.php mainly)
 - Expose ports 8080 and 8095

It is a simple REST API with no authentication or authorization. Slim framework supports it natively ,so it will be easy to add

It has 3 endpoints.

#### Ping Endpoint (/ping)

To check the health of the app. Returns 200 OK and some basic information

    curl http://localhost:8080/ping

Response

    {
	    "res": "pong",
	    "ts": 1649686269,
	    "copyright": "Alex Lopez 1989 - 2022",
	    "date": "2022-04-11 14:11:09.720023"
    }

#### Root endpoint (/)

Use it to grab the HTTP response code of a given URL

    curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"url": "http://phaidra.ai"}' \
    http://localhost:8080

The HTTP response must be always 201 if the endpoint is working. The response contains the URL that has been called and the HTTP response code

    {
	    "url": "http://www.google.cat",
	    "code": 200
	}

A prometheus metric counter is fed every time the endpoint is used

#### Metrics endpoint (/metrics)

It exposes a prometheus format metrics called http_gets with the number of times a URL has been passed to the / endpoint and the HTTP response obtained

    curl http://localhost:8080/metrics

Response

    # HELP http_gets Incremental Counter
    # TYPE http_gets counter
    http_gets{url="http://notexist.forsure",code="0"} 8
    http_gets{url="http://phaidra.ai",code="308"} 5
    http_gets{url="http://www.google.cat",code="200"} 1
    http_gets{url="https://www.google.com/notexisting",code="404"} 8
    http_gets{url="https://www.google.com",code="200"} 6

### Testing

For local testing, you can use the last version of the docker image

    docker run -d -p 8080:8080 -p 9095:8080 usagre90/scraper-service:latest

A script is provided which make some tests on all endpoints. You must pass as a parameter the service URL, in this local environment http://localhost:8080

    sh /tests/curl.sh http://localhost:8080

Output of the script

     [INFO] # Testing the ping endpoint for health check
    /ping paths is returning the code 200 as expected 
     [INFO] # Testing scraper service
     [INFO] # Testing for URL https://www.google.com and code 200
    Expected code 200 matched received code 200 :)
    Expected URL https://www.google.com matched received URL https://www.google.com :)
     [INFO] # Testing for URL https://www.google.com and code 200
    Expected code 200 matched received code 200 :)
    Expected URL https://www.google.com matched received URL https://www.google.com :)
     [INFO] # Testing for URL https://www.google.com and code 200
    Expected code 200 matched received code 200 :)
    Expected URL https://www.google.com matched received URL https://www.google.com :)
     [INFO] # Testing for URL http://phaidra.ai and code 308
    Expected code 308 matched received code 308 :)
    Expected URL http://phaidra.ai matched received URL http://phaidra.ai :)
     [INFO] # Testing for URL http://phaidra.ai and code 308
    Expected code 308 matched received code 308 :)
    Expected URL http://phaidra.ai matched received URL http://phaidra.ai :)
     [INFO] # Testing for URL http://notexist.forsure and code 0
    Expected code 0 matched received code 0 :)
    Expected URL http://notexist.forsure matched received URL http://notexist.forsure :)
     [INFO] # Testing for URL http://notexist.forsure and code 0
    Expected code 0 matched received code 0 :)
    Expected URL http://notexist.forsure matched received URL http://notexist.forsure :)
     [INFO] # Testing for URL http://notexist.forsure and code 0
    Expected code 0 matched received code 0 :)
    Expected URL http://notexist.forsure matched received URL http://notexist.forsure :)
     [INFO] # Testing for URL http://notexist.forsure and code 0
    Expected code 0 matched received code 0 :)
    Expected URL http://notexist.forsure matched received URL http://notexist.forsure :)
     [INFO] # Testing for URL https://www.google.com/notexisting and code 404
    Expected code 404 matched received code 404 :)
    Expected URL https://www.google.com/notexisting matched received URL https://www.google.com/notexisting :)
     [INFO] # Testing for URL https://www.google.com/notexisting and code 404
    Expected code 404 matched received code 404 :)
    Expected URL https://www.google.com/notexisting matched received URL https://www.google.com/notexisting :)
     [INFO] # Testing for URL https://www.google.com/notexisting and code 404
    Expected code 404 matched received code 404 :)
    Expected URL https://www.google.com/notexisting matched received URL https://www.google.com/notexisting :)
     [INFO] # Testing for URL https://www.google.com/notexisting and code 404
    Expected code 404 matched received code 404 :)
    Expected URL https://www.google.com/notexisting matched received URL https://www.google.com/notexisting :)
     [INFO] # Testing the metrics endpoint
    /metrics paths is returning the code 200 as expected 
    Result of the metrics endpoint
    
    # HELP http_gets Incremental Counter 
    # TYPE http_gets counter 
    http_gets{url="http://notexist.forsure",code="0"} 24 
    http_gets{url="http://phaidra.ai",code="308"} 13 
    http_gets{url="http://www.google.cat",code="200"} 1 
    http_gets{url="https://www.google.com/notexisting",code="404"} 24
    http_gets{url="https://www.google.com",code="200"} 18  
    
    [OK] # 15 tests passed
    [OK] # 0 tests failed

The same script is used in the **unit testing** in the pipeline and the **E2E test** in the 'production' environment.

### Kubernetes deployment

#### IaC with Terraform

You can find these terraform manifests in the infrastructure/terraform folder

 - 00-iam-roles > Enables the API's need in GCP
 - 02-network > Created the VPC and the subnets needed
 - 09-gke-cluster > Create the kubernetes cluster and the node pools
	 - main pool with 1 node 
	 - secondary pool with 0 to 4 autoscaling nodes for horizontal autoscaling, if needed
- output, provider, variables and state files as usual

If you want to create the cluster by yourself you can do it, you will need to create a project first of all and **add the name and id in the variables file**. You will be prompted also for the service account GCP key file with the correct permissions. 

    terraform apply

#### Manifests with GitOps approach with ArgoCD

The kubernetes manifests can be found int the /infrastructure directory and are organized as listed below, using kustomize.

 - scraper-service > The webservice itself
 - monitoring > prometheus and grafana instances, with the scraper-service pre-added in the configMap configuration
 - argocd > ArgoCD configuration and apps
	 - argocd app > **meta-app** containing the apps below
	 - ingress-nginx > pointing to **nginx ingress controller** helm chart
	 - monitoring app > Grafana and Prometheus
	 - scraper-service app > scraper-service app

![See ArgoCD applications running](https://github.com/4l3x7/scraper-service/images/argocd.png)

ArgoCD grabes the manifests files from the main branch of the repository. To deploy the solution by yourself go to infrastructure/argocd directory, add your key to `secret.yaml` file and apply the contents of the directory.

    kubectl apply -k .

The meta-argocd-app will create the other apps

### CI/CD 

2 Github action Workflows has been set to make CI/CD

- scraper-service/.github/workflows/build-and-test.yml in PR's to main branch
	- Linting with hadolint
	- Build of the docker image
	- Running of the Docker image and testing with the script provided
- scraper-service/.github/workflows/push-and-deploy.yml in merging to main
	- Building and tagging of the image
	- Pushing the image the dockerhub repository
	- Editing the kustomize files with the last version of the docker image (tagged as the commit hash)
	- Commit and push of the kustomize changed files that will be grabbed by ArgoCD

### Monitoring (Prometheus and Grafana)

The kubernetes cluster is designed to host:

- A Prometheus instance (with the scraper-service like a data source prepopulated)
- A Grafana instance for metrics visualization

#### PromQL queries to get scraper-service metrics

A basic PromQL query to see the evolution of the counter by the HTTP code obtained can be:

    sum(http_gets{}) by (code)

Which will plot something like that

![Plot for sum(http_gets{}) by (code)](https://github.com/4l3x7/scraper-service/images/simpleplot.png)

We can also graph average number of gets per time interval per HTTP code received. In this case we can get the gets per hour, averaged for the last 5 minutes if each point.

    sum(rate(http_gets[5m]) * 60) by (code)

Which results in:

![Plot for sum(rate(http_gets[5m]) * 60) by (code)](https://github.com/4l3x7/scraper-service/images/rateplot.png)

With Grafana, we can also show a pie chart. With this we can see easily the increase in the counter in an interval of time. In this image, for the last 6 hours.

    sum(increase(http_gets{}[$__range])) by (code)

![enter image description here](https://github.com/4l3x7/scraper-service/images/piechart.png)

### Production deployment 

Once you have deployed the kubernetes cluster as explained in the 'kubernetes deployment' section , you can get the public IP of your cluster and map it with a DNS. Also add HTTPS with cert-manager if needed.

    terraform output -raw kubernetes_cluster_host

To make the E2E test work in GitHub actions, add it as a repository secret with the name "PUBLIC_IP".