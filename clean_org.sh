#!/bin/bash
if [ -z "$1" ]; then
  echo "Error: No org was provided."
  echo "Usage: $0 <org name>"
  exit 1
fi

DELETE=false
# Get the Org MOID
ORG_MOID=`isctl get organization organization --filter "Name eq '$1'" -o jsonpath="[*].Moid"`

# Get All Server Profiles in the Org
ALL_SP=`isctl get server profile --filter "Organization.Moid eq '${ORG_MOID}'"  -o jsonpath="[*].Name"`

#Unassign all server profiles 
while read SP; do
    # Check if the line is empty (can happen with some outputs or trailing newlines)
    # Skip empty lines to prevent trying to process them
    if [ -z "$SP" ]; then
        continue
    fi

    echo -n "Attempting to unassign profile ${SP}..."
    # Unassign the Server profile
    isctl update server profile name "$SP" --Action Unassign > /dev/null

    # Optional: Add a confirmation message
    if [ $? -eq 0 ]; then
        echo "Success."
    else
        echo "Error" >&2 # Send error to stderr
    fi

done <<< "$ALL_SP"


# Wait for Workflows to finish
total_lines=$(echo "$ALL_SP" | wc -l)
array_ALL_SP=$(echo "$ALL_SP" | awk -v total_lines="$total_lines" 'BEGIN { ORS=""; print "(" } { printf "'\''%s'\''%s", $0, (NR==total_lines?"":",") } END { print ")" }')

echo ""
echo -n "Wait for running workflows..."
# Loop indefinitely until explicitly broken out
while true; do
    # Execute the command and capture the output (the count)
    # Note: Assuming the filter syntax requires the list in parentheses: in (...)
    count=$(isctl get workflow workflowinfo --filter "WorkflowCtx.InitiatorCtx.InitiatorName in ${array_ALL_SP} AND WorkflowStatus eq 'InProgress'" --count 2>/dev/null)

    # Basic check if the output is a number and not empty
    # If isctl fails or outputs non-numeric, this helps prevent errors in the (( )) comparison
    if [[ -z "$count" ]] || ! [[ "$count" =~ ^[0-9]+$ ]]; then
         echo "Warning: isctl command output was unexpected or empty: '$count'. Retrying in 5 seconds..."
         sleep 5
         continue # Skip to the next iteration
    fi
    
    # Check if the count is zero using arithmetic comparison
    if (( count == 0 )); then
        echo "done"
        break # Exit the while loop
    else
        # If count is not zero, report it and wait
        echo -n "."
        sleep 3 # Wait for 3 seconds
    fi
done

#Delete all server profiles 
while read SP; do
    # Skip empty lines to prevent trying to process them
    if [ -z "$SP" ]; then
        continue
    fi

    echo -n "Attempting to delete profile ${SP}..."
    # Unassign the Server profile
    isctl delete server profile name "$SP" > /dev/null

    # Optional: Add a confirmation message
    if [ $? -eq 0 ]; then
        echo "Success."
    else
        echo "Error" >&2 # Send error to stderr
    fi
done <<< "$ALL_SP"


# Get All Chassis Profiles in the Org
ALL_CP=`isctl get chassis profile --filter "Organization.Moid eq '${ORG_MOID}'"  -o jsonpath="[*].Name"`

#Unassign all server profiles 
while read CP; do
    # Check if the line is empty (can happen with some outputs or trailing newlines)
    # Skip empty lines to prevent trying to process them
    if [ -z "$CP" ]; then
        continue
    fi

    echo -n "Attempting to unassign chassis profile ${CP}..."
    # Unassign the chassis profile
    isctl update chassis profile name "$CP" --Action Unassign > /dev/null

    # Optional: Add a confirmation message
    if [ $? -eq 0 ]; then
        echo "Success."
    else
        echo "Error" >&2 # Send error to stderr
    fi

done <<< "$ALL_CP"


# Wait for Workflows to finish
total_lines=$(echo "$ALL_CP" | wc -l)
array_ALL_CP=$(echo "$ALL_CP" | awk -v total_lines="$total_lines" 'BEGIN { ORS=""; print "(" } { printf "'\''%s'\''%s", $0, (NR==total_lines?"":",") } END { print ")" }')

echo ""
echo -n "Wait for running workflows..."
# Loop indefinitely until explicitly broken out
while true; do
    # Execute the command and capture the output (the count)
    # Note: Assuming the filter syntax requires the list in parentheses: in (...)
    count=$(isctl get workflow workflowinfo --filter "WorkflowCtx.InitiatorCtx.InitiatorName in ${array_ALL_SP} AND WorkflowStatus eq 'InProgress'" --count 2>/dev/null)

    # Basic check if the output is a number and not empty
    # If isctl fails or outputs non-numeric, this helps prevent errors in the (( )) comparison
    if [[ -z "$count" ]] || ! [[ "$count" =~ ^[0-9]+$ ]]; then
         echo "Warning: isctl command output was unexpected or empty: '$count'. Retrying in 5 seconds..."
         sleep 5
         continue # Skip to the next iteration
    fi
    
    # Check if the count is zero using arithmetic comparison
    if (( count == 0 )); then
        echo "done"
        break # Exit the while loop
    else
        # If count is not zero, report it and wait
        echo -n "."
        sleep 3 # Wait for 3 seconds
    fi
done

#Delete all server profiles 
while read CP; do
    # Skip empty lines to prevent trying to process them
    if [ -z "$CP" ]; then
        continue
    fi

    echo -n "Attempting to delete profile ${CP}..."
    # Unassign the Server profile
    isctl delete chassis profile name "$CP" > /dev/null

    # Optional: Add a confirmation message
    if [ $? -eq 0 ]; then
        echo "Success."
    else
        echo "Error" >&2 # Send error to stderr
    fi
done <<< "$ALL_CP"






# Get All Doman Profiles in the Org
ALL_DP=`isctl get fabric switchclusterprofile --filter "Organization.Moid eq '${ORG_MOID}'"  -o jsonpath="[*].Name"`

#Unassign all domain profiles 
while read DP; do
    # Check if the line is empty (can happen with some outputs or trailing newlines)
    # Skip empty lines to prevent trying to process them
    if [ -z "$DP" ]; then
        continue
    fi

    echo -n "Attempting to unassign domain profile ${DP}..."
    # Unassign the domain profile
    isctl update fabric switchclusterprofile name "$DP" --Action Unassign > /dev/null

    # Optional: Add a confirmation message
    if [ $? -eq 0 ]; then
        echo "Success."
    else
        echo "Error" >&2 # Send error to stderr
    fi

done <<< "$ALL_DP"


# Wait for Workflows to finish
total_lines=$(echo "$ALL_DP" | wc -l)
array_ALL_DP=$(echo "$ALL_DP" | awk -v total_lines="$total_lines" 'BEGIN { ORS=""; print "(" } { printf "'\''%s'\''%s", $0, (NR==total_lines?"":",") } END { print ")" }')

echo ""
echo -n "Wait for running workflows..."
# Loop indefinitely until explicitly broken out
while true; do
    # Execute the command and capture the output (the count)
    # Note: Assuming the filter syntax requires the list in parentheses: in (...)
    count=$(isctl get workflow workflowinfo --filter "WorkflowCtx.InitiatorCtx.InitiatorName in ${array_ALL_SP} AND WorkflowStatus eq 'InProgress'" --count 2>/dev/null)

    # Basic check if the output is a number and not empty
    # If isctl fails or outputs non-numeric, this helps prevent errors in the (( )) comparison
    if [[ -z "$count" ]] || ! [[ "$count" =~ ^[0-9]+$ ]]; then
         echo "Warning: isctl command output was unexpected or empty: '$count'. Retrying in 5 seconds..."
         sleep 5
         continue # Skip to the next iteration
    fi
    
    # Check if the count is zero using arithmetic comparison
    if (( count == 0 )); then
        echo "done"
        break # Exit the while loop
    else
        # If count is not zero, report it and wait
        echo -n "."
        sleep 3 # Wait for 3 seconds
    fi
done

#Delete all domain profiles 
while read DP; do
    # Skip empty lines to prevent trying to process them
    if [ -z "$DP" ]; then
        continue
    fi

    echo -n "Attempting to delete domain profile ${DP}..."
    # delete the domain profile
    if $DELETE; then
        isctl delete fabric switchprofile name "$DP" > /dev/null
    else 
        echo isctl delete fabric switchprofile name "$DP"
    fi

    # Optional: Add a confirmation message
    if [ $? -eq 0 ]; then
        echo "Success."
    else
        echo "Error" >&2 # Send error to stderr
    fi
done <<< "$ALL_DP"

