# ISCTL based IMM deployments

This repository holds examples for deploying an entire IMM domain through isctl.
The examples will create all pools, policies and profiles and uses a shared organization called LAB-RESOURCES for storing the main configuration. 
The Server Pool and Profiles will be created in the organization called LTRCOM-2020, this is also the org where you should have claimed your Fabric Interconnect.
It is possible to change the code to use a single organization.

There are 4 directories in this repository

### 0_system
This will create the orgs and the IAM access rules.
There is a seperate README in this directory with more information

### 1_domain_profile
This holds all the domain required policies and the Domain profile.
There is a seperate README in this directory with more information

### 2_chassis_profile
This holds all the chassis required policies and the Chassis profile.
There is a seperate README in this directory with more information

### 3_server_profiles
This holds all the server profile required policies, the Server Profile Template and it will derivef 8 Server Profiles that will be assigned through a Server Resource Pool.
There is a seperate README in this directory with more information

All configuration is stored in yaml files and need to be updated to match your environment.

**YOU MUST EDIT ALL YAML FILES TO MATCH YOUR ENVIRONMENT**

## Pre Requisites
- Have an Intersight account (SaaS or Appliance)
- Make sure you have [isctl](https://github.com/cgascoig/isctl) installed and configured with an API key that has access to both organizations.
- OPTIONAL: Have 2 different orgs. One for storing most of the config which is called LAB-RESOURCES and is shared with the second organization called LTRCOM-2020 which is where the FI targets are claimed and we will store the Server Profiles and Resource Pool.
This is optional, you can also update the config to work with a single org.
- Claim your FI Target into the right organization 

## Quick - Steps
It is highly recommended to go directory by directory but here are all the deployment steps.
The clean up steps can be found inside each directory. 

1. Edit all the yaml files in all directories to match your environment
**GO FILE BY FILE AND CHANGE ALL IP'S, SERIALS AND CONFIG**

2. Push the system configuration
```
isctl apply -f 0_system/.
```

3. Push the domain configuration 
```
isctl apply -f 1_domain_profile/.
isctl update fabric switchprofile name IMM-Domain-01-A --Action Deploy
isctl update fabric switchprofile name IMM-Domain-01-B --Action Deploy
isctl update fabric switchprofile name IMM-Domain-02-A --Action Deploy
isctl update fabric switchprofile name IMM-Domain-02-B --Action Deploy
isctl update fabric switchprofile name IMM-Domain-03-A --Action Deploy
isctl update fabric switchprofile name IMM-Domain-03-B --Action Deploy
isctl update fabric switchprofile name IMM-Domain-04-A --Action Deploy
isctl update fabric switchprofile name IMM-Domain-04-B --Action Deploy

#wait for workflows to finish
echo -n "Waiting for workflows to finish..."
while (($(isctl get workflow workflowinfo --filter "WorkflowStatus eq 'InProgress'" --count) != 0)); do sleep 1 ; echo -n "."; done
```

4. Push the chassis configuration 
```
isctl apply -f 2_chassis_profile/.
isctl update chassis profile name IMM-Domain-01-Chassis-01 --Action Deploy
isctl update chassis profile name IMM-Domain-02-Chassis-01 --Action Deploy
isctl update chassis profile name IMM-Domain-03-Chassis-01 --Action Deploy
isctl update chassis profile name IMM-Domain-04-Chassis-01 --Action Deploy

#wait for workflows to finish
echo -n "Waiting for workflows to finish..."
while (($(isctl get workflow workflowinfo --filter "WorkflowStatus eq 'InProgress'" --count) != 0)); do sleep 1 ; echo -n "."; done
```

5. Push the server configuration
```
isctl apply -f 3_server_profiles/FI-Attached/.
```

6. Deploy the server profiles 
```
for SP_ID in {01..31}; do 
    echo "Deploy IMM-RHEL-$SP_ID... "
    isctl update server profile name IMM-RHEL-$SP_ID --ScheduledActions '[{"Action":"Deploy","ProceedOnReboot":false},{"Action":"Activate","ProceedOnReboot":true}]' > /dev/null
done
```

## Clean up

1. Unassign everything, wait 3 seconds and delete the server profiles
```
for SP_ID in {01..32}; do 
    echo "Unassign IMM-RHEL-$SP_ID... "
    isctl update server profile name IMM-RHEL-$SP_ID --Action Unassign > /dev/null
done

#wait for workflows to finish
echo -n "Waiting for workflows to finish..."
while (($(isctl get workflow workflowinfo --filter "WorkflowStatus eq 'InProgress'" --count) != 0)); do sleep 1 ; echo -n "."; done

isctl update chassis profile name IMM-Domain-01-Chassis-01 --Action Unassign
isctl update chassis profile name IMM-Domain-02-Chassis-01 --Action Unassign
isctl update chassis profile name IMM-Domain-03-Chassis-01 --Action Unassign
isctl update chassis profile name IMM-Domain-04-Chassis-01 --Action Unassign


isctl update fabric switchprofile name IMM-Domain-01-A --Action Unassign
isctl update fabric switchprofile name IMM-Domain-01-B --Action Unassign
isctl update fabric switchprofile name IMM-Domain-02-A --Action Unassign
isctl update fabric switchprofile name IMM-Domain-02-B --Action Unassign
isctl update fabric switchprofile name IMM-Domain-03-A --Action Unassign
isctl update fabric switchprofile name IMM-Domain-03-B --Action Unassign
isctl update fabric switchprofile name IMM-Domain-04-A --Action Unassign
isctl update fabric switchprofile name IMM-Domain-04-B --Action Unassign

#wait for workflows to finish
echo -n "Waiting for workflows to finish..."
while (($(isctl get workflow workflowinfo --filter "WorkflowStatus eq 'InProgress'" --count) != 0)); do sleep 1 ; echo -n "."; done

for SP_ID in {01..32}; do 
    echo "Deleting IMM-RHEL-$SP_ID... "
    isctl delete server profile name IMM-RHEL-$SP_ID > /dev/null
done
```

2. Remove all the templates, profiles, policies and pools.
```
isctl apply -f 3_server_profiles/FI-Attached/. -d
isctl apply -f 2_chassis_profile/. -d
isctl delete fabric portpolicy name IMM-6465-ports
isctl apply -f 1_domain_profile/. -d

#Delete Resource Groups, Orgs and Roles
ORG=`isctl get organization organization --filter "Name eq 'LAB-RESOURCES'" -o jsonpath="[*].Moid"`
SharingRules=`isctl get iam sharingrule --filter "SharedResource.Moid eq '${ORG}'" -o jsonpath="[*].Moid"`
while read SR; do; isctl delete iam sharingrule moid $SR >/dev/null; done <<< "$SharingRules"
isctl apply -f 0_system/. -d 
```