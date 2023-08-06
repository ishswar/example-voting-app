
_In this branch we see howe we inject values using values.yaml file during chart installation_

---

Check out Git Repo and Deploy

_In this step we are not dot using Helm yet - we are just using Kubernetes yaml/manifest file to deploy applications to understand how all it works_

<br>

# Deploying using yaml/manifest files 

Clone my github repo :

`git clone https://github.com/ishswar/example-voting-app.git`{{exec}}

These has all the code we will use during this demo 

Change into to directory k8s-specifications `cd example-voting-app/k8s-specifications/`{{exec}}
These have all YAML files for deployment

1. Voting app - web app once vote received (via browser) - they are saved into Redis
2. Redis server
3. .NET code that scans Redis server and inserts votes into Database 
4. Database to store Votes   
5. Result app that shows votes via reading Database 

There are five apps above - which means we should have 5 Kubernetes deployment files - that is what you will find in `k8s-specifications` folder

Now we also need a stable end-point to access apps above. 
The voting app and result app are exposed outside the cluster via NodePort and DB and Redis are exposed internally using ClusterIP.

`tree ~/example-voting-app/k8s-specifications/`{{exec}}

Output 

```
|-- db-deployment.yaml
|-- db-service.yaml
|-- redis-deployment.yaml
|-- redis-service.yaml
|-- result-deployment.yaml
|-- result-service.yaml
|-- vote-deployment.yaml
|-- vote-service.yaml
`-- worker-deployment.yaml
```

## Deploy them 

We can deploy all of them in one shot using command (assuming you are in that directory ) 

`kubectl create -f ~/example-voting-app/k8s-specifications/`{{exec}} 

output should look like 

```
controlplane $ kubectl create -f .
deployment.apps/db created
service/db created
deployment.apps/redis created
service/redis created
deployment.apps/result created
service/result created
deployment.apps/vote created
service/vote created
deployment.apps/worker created
```

Ideally, we should deploy DB and Redis first , then .NET app and last voting  app and result app - but above command does not guarantee that

After few seconds you should see all pods and service up and running..

Everything gets deployed in `default` namespace.

`kubectl get pods && kubectl get svc`{{exec}} 

Sample output : 
================

```
NAME                     READY   STATUS    RESTARTS   AGE
db-989b6b476-jqw6r       1/1     Running   0          2m28s
redis-7fdbb9576f-2vqvq   1/1     Running   0          2m28s
result-f9f4fbbc7-kzz6d   1/1     Running   0          2m28s
vote-5f865477fc-fb629    1/1     Running   0          2m28s
worker-667975666-8lbkr   1/1     Running   0          2m28s
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
db           ClusterIP   10.97.51.10      <none>        5432/TCP         2m28s
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP          26d
redis        ClusterIP   10.104.196.148   <none>        6379/TCP         2m28s
result       NodePort    10.97.138.2      <none>        5001:31001/TCP   2m28s
vote         NodePort    10.96.230.143    <none>        5000:31000/TCP   2m28s
```

You should be able to access voting GUI via URL [ACCESS VOTE APP]({{TRAFFIC_HOST1_31000}}) - it will look like this : 


![](https://i.ibb.co/s5QMMtM/image.png)

Submit your vote and now you can access result page via URL like: [ACCESS RESULT APP]({{TRAFFIC_HOST1_31001}}) - it might look like this : 

![](https://i.ibb.co/r6RxLHf/image.png)

So, now it should be evidently clear to you that we have two applications which are expose to end-user - applications for voting and application for checking the result 

![](https://i.ibb.co/YXfZXG2/voterapp-1.png)

This concludes our steps of deploying multi-tier applications on kubernetes using YAML files.  

# Teardown all that we deployed 

Before we go to next step lets delete everything that we just deployed 

`kubectl delete -f ~/example-voting-app/k8s-specifications/`{{exec}} 

# Summary of this step 

- The goal is to deploy a multi-tier voting application using Kubernetes YAML manifests.
- A Git repo with the app code and YAML specs is cloned.
- There are 5 components: vote app, result app, redis, .NET worker, and database.
- Each has a Kubernetes deployment and service YAML file.
- kubectl create is used to deploy all manifests to the default namespace.
- The vote and result apps are exposed via NodePort services.
- The deployed apps can be accessed on the provided URLs.
- This demonstrates deploying a multi-tier app on Kubernetes using raw YAML manifests.
- The YAML files define the replica count, images, ports, etc for each component.
- Finally, kubectl delete is used to tear down the deployment and clean up.

In summary, the key points are:

- Cloning Git repo with YAML manifests
- Deploying YAMLs for each app component
- Exposing vote and result apps via NodePort
- Accessing the deployed application
- Deploying a multi-tier app on Kubernetes using YAML
- Tearing down deployment using kubectl delete
- Overall, it shows how to deploy a multi-tier, multi-component application on Kubernetes using raw manifest YAML files.


Create Helm charts and use them to Deploy same set of applications

<br>

# Deploy using Helm 

Next step we can deploy same application as before but this time using helm charts. 
We will create 5 charts - one for each of application. 

General steps : 

1. Create a Helm chart using `helm create` command
1. Delete YAML files created by above command 
1. Move our original Helm files for each application under `templates` subfolder 
1. Use `helm install` to install chart 

You have two choices - create charts manually (follow below steps) or check-out branch using command `git checkout with-helm` this will get you same charts that you will have if you follow below steps.

## Creates Charts 

```plain
cd ~/example-voting-app/k8s-specifications/
helm create db  
helm create vote
helm create redis
helm create worker
helm create result
```{{exec}} 


## Delete all autogenerated YAMLs 


```plain
rm -rf */templates/*.yaml
rm -rf */templates/*.txt
rm -rf */templates/tests
```{{exec}} 

Check to see YAML is there in sub folder `templates` 

```plain
ls -la */templates/*
```{{exec}} 

## Move existing YAML for each application to it's individual Helm chart 

```plain
mv db-*.yaml db/templates/
mv vote-*.yaml vote/templates/
mv redis-*.yaml redis/templates/
mv worker-*.yaml worker/templates/
mv result*.yaml result/templates/
```{{exec}} 

At the end, if you run command `ls -la */templates/*,` the output should look like below   
Make sure you are in the directory `example-voting-app/k8s-specifications`

`ls -la */templates/*`{{exec}} 

Sample output 

```plain
-rw-r--r-- 1 root root 1732 Feb 22 04:08 db/templates/_helpers.tpl
-rw-r--r-- 1 root root  634 Feb 22 04:07 db/templates/db-deployment.yaml
-rw-r--r-- 1 root root  191 Feb 22 04:07 db/templates/db-service.yaml
-rw-r--r-- 1 root root 1762 Feb 22 04:08 redis/templates/_helpers.tpl
-rw-r--r-- 1 root root  492 Feb 22 04:07 redis/templates/redis-deployment.yaml
-rw-r--r-- 1 root root  203 Feb 22 04:07 redis/templates/redis-service.yaml
-rw-r--r-- 1 root root 1772 Feb 22 04:08 result/templates/_helpers.tpl
-rw-r--r-- 1 root root  383 Feb 22 04:07 result/templates/result-deployment.yaml
-rw-r--r-- 1 root root  221 Feb 22 04:07 result/templates/result-service.yaml
-rw-r--r-- 1 root root 1752 Feb 22 04:08 vote/templates/_helpers.tpl
-rw-r--r-- 1 root root  369 Feb 22 04:07 vote/templates/vote-deployment.yaml
-rw-r--r-- 1 root root  216 Feb 22 04:07 vote/templates/vote-service.yaml
-rw-r--r-- 1 root root 1772 Feb 22 04:08 worker/templates/_helpers.tpl
-rw-r--r-- 1 root root  317 Feb 22 04:07 worker/templates/worker-deployment.yaml
```


## Install using Helm charts 

```plain
helm install db ./db 
helm install redis ./redis
helm install worker ./worker
helm install result ./result
helm install vote ./vote
```{{exec}} 

### List all charts 

`helm list`{{exec}} 

Sample output 

```plain
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
db      default         1               2023-02-22 04:10:32.109280565 +0000 UTC deployed        db-0.1.0        1.16.0     
redis   default         1               2023-02-22 04:10:34.518627295 +0000 UTC deployed        redis-0.1.0     1.16.0     
result  default         1               2023-02-22 04:10:36.716386874 +0000 UTC deployed        result-0.1.0    1.16.0     
vote    default         1               2023-02-22 04:10:38.735587035 +0000 UTC deployed        vote-0.1.0      1.16.0     
worker  default         1               2023-02-22 04:10:35.724799692 +0000 UTC deployed        worker-0.1.0    1.16.0  
```

The above shows all 5 charts are installed.   
Now you can try to access the same URLs as before to access the 
[ACCESS VOTE APP]({{TRAFFIC_HOST1_31000}})
application and 
[ACCESS RESULT APP]({{TRAFFIC_HOST1_31001}}) application.


This concludes our demo about how you can deploy same multi-tier application using Helm charts

## Tear down the setup 

`helm uninstall db redis worker result vote `{{exec}} 

Not much has changed as of now - but now in next topic we will start to externalize some of  the information so during deployment we can provide updated values. 

# Summary of this page 

- The goal is to deploy a multi-tier voting application using Helm charts.

- Helm charts are created for each component: db, vote, redis, worker, result.

- The existing Kubernetes YAML manifests are moved into the templates folder of each chart.

- The helm create and helm install commands are used to generate and deploy the charts. 

- This allows deploying the same application but now using a Helm chart per component.

- The applications can be accessed on the same endpoints as before, just deployed via Helm.

- The helm list command shows all installed releases from the charts.

- This demonstrates deploying a multi-tier app with Helm instead of raw YAML manifests. 

- Helm provides benefits like versioning, templating, managing upgrades/dependencies, etc.

- The final step is uninstalling the charts to clean up the deployment.

In summary, the key points are:

- Converting raw YAML manifests to Helm charts
- Creating a chart per application component 
- Deploying the multi-tier app using helm install
- Accessing the application on the same endpoints 
- Leveraging Helm benefits like templating, versioning, etc.
- Uninstalling charts to tear down deployment

Overall, it demonstrates using Helm and charts to deploy a multi-tier application, as an improvement over raw YAML manifests.

How to use templates to insert/provide values for application configuration

<br>

# All about HTTP Port 

In the next few sections, we will focus on techniques to provide the HTTP port value for the `vote` and `result` applications. We'll learn approaches to set these values both during chart creation and installation.

![](https://i.ibb.co/Y0KTHd0/voterapp-2.png)

# Use of values file in helm chart 

Each Helm chart has a `values.yaml` file that serves as an input file for configuration values. 

- You can define a nested structure of values in `values.yaml`. 

- The chart templates can then reference these values.

Simply defining values in `values.yaml` doesn't mean the chart uses them. You need to check the chart's YAML templates to confirm they reference the values. 

Let's look at an example to see this in action.

Checkout the `with-helm-values` branch:

You can use command 

`git checkout with-helm-values`{{exec}} 

If you go to file `k8s-specifications/vote/templates/vote-service.yaml` 

you will two changes 

![](https://i.ibb.co/kDz5ZVZ/image.png)

Value of service `type` and _nodePort_ values are now coming from `.Values` object
This is how you refer values from _value.yaml_ file 

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: vote
  name: vote
spec:
  type: {{ .Values.service.type }}
  ports:
  - name: "vote-service"
    port: 5000
    targetPort: 80
    nodePort: {{ .Values.service.nodeport }}
  selector:
    app: vote
```

And if you look at values file you will see entry like 

![](https://i.ibb.co/HxXrzrx/image.png)

```
debug:
  enabled: false

service:
  type: NodePort
  nodeport: 31004
```

You can see value.yaml also defines few more value like `debug` that is used by file `k8s-specifications/vote/templates/vote-deployment.yaml`
That means any helm chart yaml can use value from value.yaml using same format `.Values.<path-to-value>`

Now lets deploy all charts just like before 

```plain 
helm install db ./db 
helm install redis ./redis
helm install worker ./worker
helm install result ./result
helm install vote ./vote
```{{exec}}

We can now check if `nodePort` for `vote` service is indeed using port 31004 or not - using below command 

`kubectl get svc -l app=vote`{{exec}}

Sample output 

```plain
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
vote   NodePort   10.110.168.80   <none>        5000:31004/TCP   52s
```

We can confirm it is indeed using that value.

Optional : If you want you can change the value of nodePort from 31004 to 31005 - you can use vi/nano to do that or use below command 

`sed -i 's/31004/31005/g' vote/values.yaml`{{exec}} 

After that you can upgrade only `vote` chart using example and then check the port again 

`helm upgrade vote ./vote`{{exec}} 

Output of upgrade should look like this : 

```
Release "vote" has been upgraded. Happy Helming!
NAME: vote
LAST DEPLOYED: Thu Aug  3 00:29:20 2023
NAMESPACE: default
STATUS: deployed
REVISION: 2
```

And if you check the port for `vote` service it should be using port `31005`

`kubectl get svc -l app=vote`{{exec}}

Sample output 

```
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
vote   NodePort   10.110.168.80   <none>        5000:31005/TCP   101s
```
### Tear down the setup 

Remove all charts and apps using this command 

`helm uninstall db redis worker result vote `{{exec}} 

# Summery of this step 

Here is a summary of the key points from the provided Markdown text:

- The goal is to use Helm values to externalize application configuration like ports.

- The vote and result app Helm charts are modified to reference `.Values`. 

- Their service YAMLs now use `.Values.service.type` and `.Values.service.nodeport`.

- These values are defined in values.yaml for each chart.

- Helm templates can reference values using `.Values.<path>`. 

- The apps are deployed using helm install referencing the chart directories.

- The vote service nodePort is verified to be using the value from values.yaml.

- The port value is updated directly in values.yaml and vote chart upgraded. 

- The service picks up the new nodePort value from values.yaml.

- This demonstrates externalizing config like ports into values.yaml.

- Templates can then consume these values.

- Useful for customizing charts for different environments.

- Finally, all charts are uninstalled to clean up.

In summary, the key points are:

- Externalizing app config values into values.yaml
- Modifying chart templates to reference .Values
- Passing values from values.yaml to templates 
- Updating values and upgrading chart
- Consuming customized values from templates
- Uninstalling charts to cleanup

Overall, it shows how to effectively parameterize application configuration using Helm values and templates.

How to meet a need for having environment specific values 

<br>

## Different setup Different values file    

Now, for example you have Development setup and Production setup - but in Dev setup need to use one set of commands/values and production needs to use different. 
For this you can potentially come up with separate `values.yaml` and pass that value during installation . 

You can see there is one extra `values-dev.yaml` that is found under `vote` folder - if you inspect it has some extra parameters so if you want to use that you can re-run `helm` install command like 

`helm install vote ./vote -f ~/example-voting-app/k8s-specifications/vote/values-dev.yaml`{{exec}} 

So, this way you can use `/vote/values.yaml` for production but for development environment if you want to use additional or different parameters you can just have separate values.yaml file and use that for that purpose.

If you ever wanted to see what actual values that chart is using in k8s cluster you can run command like below that will fetch actual values currently used in cluster 

For example if I want to use what value chart `vote` is using I can use this command

```plain
helm get values vote
```{{exec}} 

Sample output : 

```plain
USER-SUPPLIED VALUES:
debug:
  enabled: true
  startup:
    command: '"gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile",
      "-","--log-level=DEBUG", "--workers", "4", "--keep-alive", "0"'
service:
  nodeport: 31005
  type: NodePort
```

### Giving values during helm install 

In above example we saw we can provide additional or alternative values for parameters that are defined in `values.yaml` by providing new file during install. But what if you want to just overwrite only one value - how would we do that ? For that you can use flag `--set` and give full yaml path to that parameter that you want to overwrite .

For example if I want to use different port for vote charts service
Currently it is using value `31005` as it was defined in values-dev.yaml - what if I want to update that or during install I want to change that.

```
kubectl get svc -l app=vote
NAME   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
vote   NodePort   10.98.231.89   <none>        5000:31005/TCP   5m9s
```

If you want to update on existing installed chart you can again use command upgrade and run command like below 

`helm upgrade vote ./vote -f ~/example-voting-app/k8s-specifications/vote/values-dev.yaml --set service.nodeport=31006`{{exec}} 

You can see value gets updated 

`kubectl get svc -l app=vote`{{exec}}

Sample output 

```
NAME   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
vote   NodePort   10.98.231.89   <none>        5000:31006/TCP   5m35s
```

<img src="https://www.goodfreephotos.com/albums/vector-images/info-symbol-vector-graphics.png" alt="Girl in a jacket" width="30" height="30"> You can use same `--set` flag during installed as well - above example show it in use with `upgrade` command as we already had chart `vote` installed 

# One Chart of rule all charts  

Before proceed with this - remove all old charts (`helm uninstall db redis worker result vote `) and checkout branch `with-helm-dependency`

`git checkout with-helm-dependency`{{exec}}

So far in above examples you have seen we have to install all charts one by one - what if you want to install all of them in one shot ? 
We know chart `vote` is sort of parent chart and all other charts are needed dependencies - so in that we can make them dependent chart for vote 

You do that by adding below lines to `vote/Charts.yaml`

```
dependencies:
  - name: db
    version: 0.1.0
    repository: file://../db
  - name: redis
    version: 0.1.0
    repository: file://../redis
  - name: worker
    version: 0.1.0
    repository: file://../worker
  - name: result
    version: 0.1.0
    repository: file://../result
```

What this does is - it adds all of dependent charts under "Charts" folder for `vote`
As you can see currently that folder is empty 

```
$tree vote/
vote/
├── Chart.lock
├── Chart.yaml
├── charts
├── templates
│   ├── _helpers.tpl
│   ├── tests
│   │   └── test-connection.yaml
│   ├── vote-deployment.yaml
│   └── vote-service.yaml
├── values-dev.yaml
└── values.yaml
```

Now if you run a command as shown below that will tar all charts and put them under `Charts` folder 

`helm dependency update ~/example-voting-app/k8s-specifications/vote`{{exec}}

Sample output 

```
helm dependency update ./vote
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "nfs-subdir-external-provisioner" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 4 charts
Deleting outdated charts
```

And now if you see the `charts` folder under `vote` chart has all dependent charts tar-ed and copied there 

`tree ~/example-voting-app/k8s-specifications/vote/`{{exec}}

Sample output

```
vote/
├── Chart.lock
├── Chart.yaml
├── charts
│   ├── db-0.1.0.tgz
│   ├── redis-0.1.0.tgz
│   ├── result-0.1.0.tgz
│   └── worker-0.1.0.tgz
├── templates
│   ├── _helpers.tpl
│   ├── tests
│   │   └── test-connection.yaml
│   ├── vote-deployment.yaml
│   └── vote-service.yaml
├── values-dev.yaml
└── values.yaml

3 directories, 12 files
```

Now to install all charts only thing we need to do is install chart `vote` and it will installed all dependent charts 

`helm install vote ~/example-voting-app/k8s-specifications/vote`{{exec}}

You will see `vote` chart is installed - unfortunately dependent charts are installed but `helm ls` does not list them 

`helm ls`{{exec}}

Sample output

```
NAME                            NAMESPACE REVISION  UPDATED                                 STATUS    CHART                                   APP VERSION
vote                            default   1         2023-08-03 18:49:57.765825687 +0000 UTC deployed  vote-0.1.0                              1.16.0
```

But you can see all the pods are running so that shows that all charts got installed 

`kubectl get pods`{{exec}}

Sample output 

```
NAME                                               READY   STATUS    RESTARTS      AGE
db-5595c8db95-gclq2                                1/1     Running   0             9s
redis-6986c5d458-k95xg                             1/1     Running   0             9s
result-7b598bf7b8-smf62                            1/1     Running   0             9s
vote-595ffc978b-mfphx                              1/1     Running   0             9s
worker-7594c66d85-h987r                            1/1     Running   0             9s
```

### How to overwrite values for sub charts ? 

What if you want to update provide new values for nodePort for `result` chart ? 
We know service for worker is using values and by default it gets value from it's values.yaml - but since now `result` chart is dependent chart we need to provide that updated value differently .

One of the way you can do is update the `vote/values.yaml` file like this : 

```
result:
  service:
    nodeport: 31025
```

This way when helm installs dependent charts it will pass value `service.nodeport` to `result` chart while it installs that chart 

If you want you can play with this - you can uncomment values in `vote/values.yaml` and run `helm upgrade vote ./vote` and you will see value for `result` service is now having value of `31025`

# Summary of this step 

Here is a summary of the key points from the provided Markdown text:

- Different values.yaml files can be used for different environments like dev vs prod.

- helm install can reference a specific values file using -f flag.

- helm get values displays actual runtime values for a release.

- --set allows overriding specific values during install/upgrade.

- Dependencies can be defined in Chart.yaml to install related charts.  

- helm dependency update pulls in dependent charts.

- Installing the parent chart now installs child dependencies.

- Child chart values can be overridden by setting values in parent's values.yaml.

- This allows installing a full application stack in one helm install command.

- Different values per environment and component can be provided.

In summary, the key points are:

- Using different values files for dev vs prod
- Overriding install values with --set 
- Defining chart dependencies
- Install parent chart to install dependencies
- Customize child values from parent values.yaml
- Single install for full application stack
- Override child component values as needed

This demonstrates various techniques in Helm to handle multiple environments, customize applications, and install dependencies.

Managing Kubernetes Deployments at Scale with Helmfile

<br>

# Helm files orchestrator - helmfile tool  

Reasons to use Helmfile instead of just Helm when deploying multiple charts:

## Simplified management of multiple releases

Helmfile allows deploying entire environments specified in a simple declarative YAML format. Much easier than running helm install/upgrade commands.  
Charts, values, namespaces, etc. can be specified together for the overall environment.  
Supports templating to reduce duplication across similar releases.  

## Synchronization of releases

Helmfile has primitives like hooks, wait, retries, and timeouts to handle ordering and synchronize releases.  
E.g. Wait for a database chart to be up before deploying the backend. Retry failed installations.  
Such cross-release coordination is difficult to orchestrate with just Helm.  

## Environment separation

Helmfile can maintain different files for dev, staging, prod environments.  
Switch environments easily by changing context in a single command.  
Helm needs extra scripts and flags to achieve separation between environments.  

_In summary, once you reach a certain scale, Helmfile becomes indispensable for managing the complexity of multi-release deployments, release coordination, and multi-environment workflows._

## Install Helmfile  

Installing helmfile is easy - sample steps are like below 

```shell script
wget https://github.com/helmfile/helmfile/releases/download/v0.151.0/helmfile_0.151.0_linux_amd64.tar.gz
tar -xvf helmfile_0.151.0_linux_amd64.tar.gz 
mv helmfile /usr/sbin/
```

After you installed it you can run `version` command to see if it got installed successfully or not 

`helmfile -v`{{exec}}

Sample output 

`helmfile version v0.139.9`

You can now check-out branch `with-helmfile` 

```
cd ~/example-voting-app/k8s-specifications
git checkout with-helmfile
```

Under `k8s-specifications` you will find a _new_ file named `helmfile.yaml` - if you open it is is very simple as shown below :  

```yaml

---
releases:

- name: db
  chart: db
- name: result
  chart: result
- name: redis
  chart: redis
- name: worker
  chart: worker
- name: vote
  chart: vote
```

<img src="https://www.goodfreephotos.com/albums/vector-images/info-symbol-vector-graphics.png" alt="Girl in a jacket" width="30" height="30"> File does not need to be called helmfile.yaml - but that is default file name that is expected if you want to use your own name you will need to pass flag `--file newname-helmfile.yaml` to provided new name.

What it means is it will deploy all of above charts in order they shows up.
You can also run a command `helmfile list` on helmfile to see what all chart will get installed and in what order


```shell script
cd ~/example-voting-app/k8s-specifications
helmfile list
```

Sample output : 

```
NAME    NAMESPACE ENABLED LABELS  CHART   VERSION
db                true            db
result            true            result
redis             true            redis
worker            true            worker
vote              true            vote
```

## Deploying using helmfile 

Deploying using helmfile is easy; command to initiate deployment is 

`helmfile sync`

Sample output is shown below 
You can see that it installed each helm chart in oder that we defined in `helmfile.yaml`

```
Building dependency release=db, chart=db
Building dependency release=redis, chart=redis
Building dependency release=worker, chart=worker
Building dependency release=vote, chart=vote
Building dependency release=result, chart=result
Affected releases are:
  db (db) UPDATED
  redis (redis) UPDATED
  result (result) UPDATED
  vote (vote) UPDATED
  worker (worker) UPDATED

Upgrading release=result, chart=result
Upgrading release=db, chart=db
Upgrading release=redis, chart=redis
Upgrading release=vote, chart=vote
Upgrading release=worker, chart=worker
Release "redis" does not exist. Installing it now.
NAME: redis
LAST DEPLOYED: Thu Aug  3 21:01:40 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1

Listing releases matching ^redis$
Release "worker" does not exist. Installing it now.
NAME: worker
LAST DEPLOYED: Thu Aug  3 21:01:40 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1

Listing releases matching ^worker$
Release "result" does not exist. Installing it now.
NAME: result
LAST DEPLOYED: Thu Aug  3 21:01:40 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1

Listing releases matching ^result$
Release "vote" does not exist. Installing it now.
NAME: vote
LAST DEPLOYED: Thu Aug  3 21:01:40 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1

Listing releases matching ^vote$
Release "db" does not exist. Installing it now.
NAME: db
LAST DEPLOYED: Thu Aug  3 21:01:40 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1

Listing releases matching ^db$
redis default   1         2023-08-03 21:01:40.752330859 +0000 UTC deployed  redis-0.1.0 1.16.0

worker  default   1         2023-08-03 21:01:40.771005718 +0000 UTC deployed  worker-0.1.0  1.16.0

vote  default   1         2023-08-03 21:01:40.780854103 +0000 UTC deployed  vote-0.1.0  1.16.0

result  default   1         2023-08-03 21:01:40.77468087 +0000 UTC  deployed  result-0.1.0  1.16.0

db    default   1         2023-08-03 21:01:40.777775696 +0000 UTC deployed  db-0.1.0  1.16.0


UPDATED RELEASES:
NAME     CHART    VERSION
redis    redis      0.1.0
worker   worker     0.1.0
result   result     0.1.0
vote     vote       0.1.0
db       db         0.1.0
```

## Updating value in charts 

After above deployment is succeeds you can check the nodePort used by `vote` chart - you can see it is using default value of `31004` - this value is defined in `chart/values.yaml` file 

```
kubectl get svc -l app=vote
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
vote   NodePort   10.104.56.191   <none>        5000:31004/TCP   59m
```

What if you want to update that value - now you don't have to go to that chart and update values.yaml - you can do that right from `helmfile.yaml` file 
Below is example that shows how you can provide values for each individual charts 


```yaml

---
releases:

- name: db
  chart: db
- name: result
  chart: result
- name: redis
  chart: redis
- name: worker
  chart: worker
- name: vote
  chart: vote
  values:
   - service:
      nodeport: 31009
```

If you update the value of `helmfile.yaml` with above value and run `helmfile sync`{{exec}} you will see the nodePort for `vote` service will be now using port `31009`

```
kubectl get svc -l app=vote
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
vote   NodePort   10.104.56.191   <none>        5000:31009/TCP   71m
```

### Multiple environment 

Going back to our previous example of having one `default` set of values and one for `development` environment setting - how do we do that now in `helmfile` ? 
One way of doing that is to create a 2 go template file ( it's a basically yaml file - but it is proceed by [GoLang](https://pkg.go.dev/text/template) so you can use some go formatting/conditioning there)

Let's create two files called `default.gotmpl` and `env.gotmpl` 

default.gotmpl


```

cat <<EOF > ~/example-voting-app/k8s-specifications/default.gotmpl
---
vote:
  service:
    nodeport: "31008"
EOF
```


env.gotmpl

```
cat <<EOF > ~/example-voting-app/k8s-specifications/env.gotmpl
---
vote:
  service:
    nodeport: "31008"
EOF
```

Save them in same directory as where `helmfile.yaml` is present. 

Now update the helmfile.yaml like below 

```yaml

environments:
  default:
   values:
    - default.gotmpl
  dev:
    values:
    - env.gotmpl
---

releases:

- name: db
  chart: db
- name: result
  chart: result
- name: redis
  chart: redis
- name: worker
  chart: worker
- name: vote
  chart: vote
  values:
    - service:
        type: NodePort
        nodeport: {{ .Environment.Values.vote.service.nodeport }}  
```

So - here what we are doing is - we are getting value for nodeport from `.Environment.Values` YAML object. 
Hierarchy after .Environment.Values - is founder inside *.gotmpl found . So kept the same format like before so it start with `vote` then `service` and last the value of `nodeport`

Now we can easily switch between two set of values . 

If we don't give any flag and run `helmfile sync` values will be picked up from `default.gotmpl` 

** Node ** - It is not becurse file is named `default.gotmpl` thus it gets picked up by default. It is becurse in `helmfile.yaml` under environments.default we are using that file thus it gets picked up as default values .

Now if you want to switch to using `Development` environment value we can run same command as above but with additional `-e` flag

```
helmfile -e dev sync
```

The the word `dev` comes from `helmfile.yaml` as there is additional environment is defined called `dev` and it gets values from `env.gotempl`
If you look at file `env.gotmpl` the value of vote.service.nodeport is defined to be value of 31007 and after above command succeeds if you check the nodePort of vote service it will have value of 31007 - see below 


```shell script
kubectl get svc -l app=vote
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
vote   NodePort   10.104.56.191   <none>        5000:31007/TCP   88m
```

# Summery of this step 

Here is a summary of the key points from the provided Markdown:

- Helmfile provides a declarative way to manage multiple Helm releases. Useful at scale vs raw Helm commands.

- Allows deploying whole environments defined in easy to read YAML manifests.

- Can synchronize releases with hooks for ordering (wait, retries, timeouts).

- Supports multiple environment states (dev, staging, prod). Environment separation.

- Templating reduces duplication across environments.

- Installs Helmfile and creates a sample helmfile.yaml to deploy charts.

- Charts are installed in the order defined.

- Can override chart values in helmfile.yaml without modifying charts.

- Enables multiple values files per environment. Switch with -e flag.

- Uses Go templates for dynamic values based on environment.

In summary, Helmfile brings orchestration and management capabilities at scale for multi-release, multi-environment Kubernetes applications deployed through Helm. Reduces helm commands complexity.