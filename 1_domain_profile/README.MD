## Pre Requisites
Make sure you have [isctl](https://github.com/cgascoig/isctl) installed and configured.

## Steps
1. Claim FI Targets, this is a manual UI process for now.

2. Edit all the yamls file to match your environment

3. Apply all the config
```
isctl apply -f .
isctl update fabric switchprofile name IMM-Domain-01-A --Action Deploy
isctl update fabric switchprofile name IMM-Domain-01-B --Action Deploy
isctl update fabric switchprofile name IMM-Domain-02-A --Action Deploy
isctl update fabric switchprofile name IMM-Domain-02-B --Action Deploy

#wait for workflows to finish
echo -n "Waiting for workflows to finish..."
while (($(isctl get workflow workflowinfo --filter "WorkflowStatus eq 'InProgress'" --count) != 0)); do sleep 1 ; echo -n "."; done
```

## Clean up
1. Unassign Domain Profile
```
isctl update fabric switchprofile name IMM-Domain-01-A --Action Unassign
isctl update fabric switchprofile name IMM-Domain-01-B --Action Unassign
isctl update fabric switchprofile name IMM-Domain-02-A --Action Unassign
isctl update fabric switchprofile name IMM-Domain-02-B --Action Unassign
```

2. remove the config
To clean up just rust the `isctl apply` commands but add a `-d` at the end.
```
isctl apply -f . -d
```

When you get an error that the flowcontrol policy cannot be removed because of the portpolicy, just remove the port policy manualy and run the above command again.
```
isctl delete fabric portpolicy name IMM-6465-ports
```