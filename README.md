# ISC-operationaldashboard
This Github contains sample code for InterSystems Operational Analytics Dashboard.   
Detailed description can be found on InterSystems Developer Community ([click here](https://community.intersystems.com/post/developing-operational-analytics-dashboards)).
## Docker   

### Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.
### Installation
Clone/git pull the repo into any local directory
```
$ git clone https://github.com/rcemper/PR_ISC-operationaldashboard.git
```
```
$ docker compose up -d && docker compose logs -f
```

To open IRIS Terminal do:
```
$ docker-compose exec iris iris session iris 
USER>
```
or using **WebTerminal**     
http://localhost:42773/terminal/      

To access IRIS System Management Portal   
http://localhost:42773/csp/sys/UtilHome.csp    

