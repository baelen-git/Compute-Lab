## Pre Requisites
Make sure you have [isctl](https://github.com/cgascoig/isctl) installed and configured.

## Steps
1. Update the yaml files to match your environmnet

2. Apply all the config
```
isctl apply -f .
```

3. Deploy the Chassis profiles
```
isctl update chassis profile name IMM-Domain-01-Chassis-01 --Action Deploy
isctl update chassis profile name IMM-Domain-02-Chassis-01 --Action Deploy
```

## Clean up
1. Unassign Chassis Profile
```
isctl update chassis profile name IMM-Domain-01-Chassis-01 --Action Unassign
isctl update chassis profile name IMM-Domain-01-Chassis-02 --Action Unassign
```

2. remove the config
To clean up just rust the `isctl apply` commands but add a `-d` at the end.
```
isctl apply -f . -d  
```