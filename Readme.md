###### Clone The Repository

    git clone https://github.com/skshukla/KubernetesSample.git

    cd KubernetesSample

    mkdir -p /tmp/postgres

    chmod +x ./scripts/*.sh



###### Run Postgres

    ./scripts/run_pg.sh


###### Run Deployment/Services and Ingress

    ./scripts/run.sh


###### Show all Services

    OBJECTS=services
  
    while clear; do date; /bin/sh -c "kubectl get $OBJECTS  -o wide --show-labels";sleep 4; done


###### Show all Deployments

    OBJECTS=deployments
  
    while clear; do date; /bin/sh -c "kubectl get $OBJECTS  -o wide --show-labels";sleep 4; done
    
###### Show all pods

    OBJECTS=pods
  
    while clear; do date; /bin/sh -c "kubectl get $OBJECTS  -o wide --show-labels";sleep 4; done        
    
    
    
    









    