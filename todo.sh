#!/bin/bash

# File to store tasks
TODO_FILE="todo.json"

# functions
print_task() {
    local task=$1
    local id=$(jq -r '.id' <<< "$task")
    local title=$(jq -r '.title' <<< "$task")
    local description=$(jq -r '.description' <<< "$task")
    local location=$(jq -r '.location' <<< "$task")
    local due_date=$(jq -r '.due_date' <<< "$task")
    local completed=$(jq -r '.completed' <<< "$task")

    echo "  ID: $id"
    echo "  Title: $title"
    if [[ ! -z $description ]]; then
        echo "  Description: $description"
    fi
    if [[ ! -z $location ]]; then
        echo "  Location: $location"
    fi
    echo "  Due Date: $due_date"
    echo "  Completed: $completed"
}



# Initialize the JSON file if it doesn't exist
if [[ ! -f $TODO_FILE ]]; then
    echo "[]" > $TODO_FILE
fi

# Check for the '-a' option
if [[ $1 == "-a" ]]; then
    shift
    echo "Adding a new task:"
    read -p "Title (required): " title
    if [[ -z $title ]]; then
        echo "Title cannot be empty. Task not added."
        exit 1
    fi

    read -p "Description: " description
    read -p "Location: " location
    read -p "Due date (YYYY-MM-DD) (required): " due_date
    if [[ -z $due_date ]]; then
        echo "Due date cannot be empty. Task not added."
        exit 1
    fi
    
    # Convert the due date to YYYY-MM-DD format
    formatted_due_date=$(date -d "$due_date" "+%Y-%m-%d")

    if [[ $? -ne 0 ]]; then
        echo "Invalid date format. Please use DD-MM-YYYY."
        exit 1
    fi

    # Generate unique identifier for the task
    id=$(date +%s)

    # Read existing tasks from the JSON file
    tasks=$(cat $TODO_FILE)

    # Create a new task in JSON format
    new_task=$(jq -n \
        --arg id "$id" \
        --arg title "$title" \
        --arg description "$description" \
        --arg location "$location" \
        --arg due_date "$formatted_due_date" \
        --argjson completed false \
        '{id: $id, title: $title, description: $description, location: $location, due_date: $due_date, completed: $completed}')

    # Append the new task to the list of tasks
    updated_tasks=$(echo $tasks | jq ". += [$new_task]")

    # Save the updated list back to the JSON file
    echo $updated_tasks > $TODO_FILE

    echo "Task added successfully."
    exit 0
fi

# Search feature
# Check for the '-s' option
if [[ $1 == "-s" ]]; then
    if [[ -z $2 ]]; then
        read -p "Enter a search term: " search_term
    else
        search_term=$2
    fi

    found_task=$(jq -r --arg search_term "$search_term" '.[] | select(.title == $search_term)' $TODO_FILE)
    if [[ -z $found_task ]]; then
        echo "No task found with title: $search_term"
    else
        echo "Task found:"
        print_task "$found_task"
    fi
    exit 0
fi

#delete a task
# Check for the '-r' option
if [[ $1 == "-r" ]]; then
    if [[ -z $2 ]]; then
        read -p "Enter the title or ID of the task to delete: " search_term
    else
        search_term=$2
    fi

    found_task=$(jq -r --arg search_term "$search_term" 'map(select(.title == $search_term or .id == $search_term)) | .[0]' $TODO_FILE)
    
    if [[ -z $found_task ]]; then
        echo "No task found with title or ID: $search_term"
    else
        echo "Task found and deleted:"
        print_task "$found_task"
        
        # Delete the found task from the file
        temp_file=$(mktemp)
        jq --arg search_term "$search_term" 'map(select(.title != $search_term and .id != $search_term))' $TODO_FILE > $temp_file
        mv $temp_file $TODO_FILE
    fi
    exit 0
fi

# Check for the '-u' option
if [[ $1 == "-u" ]]; then
    if [[ -z $2 ]]; then
        read -p "Enter the title or ID of the task to update: " search_term
    else
        search_term=$2
    fi

    found_task=$(jq -r --arg search_term "$search_term" 'map(select(.title == $search_term or .id == $search_term)) | .[0]' $TODO_FILE)
    
    if [[ -z $found_task ]]; then
        echo "No task found with title or ID: $search_term"
    else
        echo "Task found:"
        print_task "$found_task"
        
        # Prompt user for updated task details
        read -p "Enter the new title: " new_title
        read -p "Enter the new description: " new_description
        read -p "Enter the new location: " new_location
        read -p "Enter the new due date (DD-MM-YYYY): " new_due_date

        # Update the task in the file
        temp_file=$(mktemp)
        jq --arg search_term "$search_term" --arg new_title "$new_title" --arg new_description "$new_description" --arg new_location "$new_location" --arg new_due_date "$new_due_date" 'map(if .title == $search_term or .id == $search_term then .title = $new_title | .description = $new_description | .location = $new_location | .due_date = $new_due_date else . end)' $TODO_FILE > $temp_file
        mv $temp_file $TODO_FILE

        echo "Task updated successfully."
    fi
    exit 0
fi


# print tasks from a specific date
if [[ $1 == "-d" ]]; then
    if [[ -z $2 ]]; then
        read -p "Enter the date (YYYY-MM-DD): " date_to_check
    else
        date_to_check=$2
    fi

    # Get uncompleted tasks for the specified date
    uncompleted_tasks=$(jq -c --arg date_to_check "$date_to_check" 'map(select(.due_date == $date_to_check and .completed == false)) | .[]' $TODO_FILE)

    echo "Uncompleted tasks for $date_to_check:"
    if [[ -z $uncompleted_tasks ]]; then
        echo "  No uncompleted tasks for $date_to_check"
    else
        IFS=$'\n'
        for task in $uncompleted_tasks; do
            echo "  Task:"
            print_task "$task"
        done
    fi

    # Get completed tasks for the specified date
    completed_tasks=$(jq -c --arg date_to_check "$date_to_check" 'map(select(.due_date == $date_to_check and .completed == true)) | .[]' $TODO_FILE)

    echo "Completed tasks for $date_to_check:"
    if [[ -z $completed_tasks ]]; then
        echo "  No completed tasks for $date_to_check"
    else
        IFS=$'\n'
        for task in $completed_tasks; do
            print_task "$task"
        done
    fi

    exit 0
fi



# Check for the '-c' option
if [[ $1 == "-c" ]]; then
    if [[ -z $2 ]]; then
        read -p "Enter the title or ID of the task to mark as completed: " search_term
    else
        search_term=$2
    fi

    found_task=$(jq -r --arg search_term "$search_term" 'map(select(.title == $search_term or .id == $search_term)) | .[0]' $TODO_FILE)
    
    if [[ -z $found_task ]]; then
        echo "No task found with title or ID: $search_term"
    else
        echo "Task found:"
        print_task "$found_task"
        
        # Mark the task as completed in the file
        temp_file=$(mktemp)
        jq --arg search_term "$search_term" 'map(if .title == $search_term or .id == $search_term then .completed = true else . end)' $TODO_FILE > $temp_file
        mv $temp_file $TODO_FILE

        echo "Task marked as completed."
    fi
    exit 0
fi



# If no or invalid options are provided, show an error message
echo "Usage: $0 -a"
exit 1
