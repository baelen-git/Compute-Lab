## Pre Requisites
Make sure you have [isctl](https://github.com/cgascoig/isctl) installed and configured.

## Steps
1. Update the yaml files with your environment settings

2. Apply the config
```
isctl apply -f .
```

3. Deploy the Server Profiles
```
for SP_ID in {01..16}; do 
    echo "Deploying IMM-RHEL-$SP_ID... "
    isctl update server profile name IMM-RHEL-${SP_ID} --ScheduledActions '[{"Action":"Deploy", "ProceedOnReboot":false},{"Action":"Activate","ProceedOnReboot":true}]' > /dev/null
done
```

## Clean up
1. Unassign & delete Server Profiles
```
for SP_ID in {01..16}; do 
    echo "Unassign IMM-RHEL-$SP_ID... "
    isctl update server profile name IMM-RHEL-$SP_ID --Action Unassign > /dev/null
done
# Wait for the undeploy workflow to finish

for SP_ID in {01..16}; do 
    echo "Deleting IMM-RHEL-$SP_ID... "
    isctl delete server profile name IMM-RHEL-$SP_ID > /dev/null
done
```

2. remove the config
To clean up just rust the `isctl apply` commands but add a `-d` at the end.
```
isctl apply -f . -d
```