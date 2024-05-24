#!/bin/bash

# Variables
sysprompt_file="sysprompt.txt"
todo_file="todo.json"
api_url="https://api.groq.com/openai/v1/chat/completions"
model="llama3-8b-8192"

# Read the system prompt from file
if [[ -f "$sysprompt_file" ]]; then
  system_prompt=$(cat "$sysprompt_file")
else
  echo "Error: File '$sysprompt_file' not found."
  exit 1
fi

# Read the content of todo.json
if [[ -f "$todo_file" ]]; then
  todo_content=$(cat "$todo_file")
else
  echo "Error: File '$todo_file' not found."
  exit 1
fi

# Read the user prompt and current date
read -p "Enter your task: " user_input
current_date=$(date "+%Y-%m-%d")

# Construct the user prompt including the content of todo.json, current date, and potential id
user_prompt="$todo_content Current Date: $current_date Potential id: $(date +%s) $user_input"

# Construct the cURL request JSON data with proper escaping
curl_data=$(jq -nc --arg system_prompt "$system_prompt" --arg user_prompt "$user_prompt" --arg model "$model" '{
    messages: [
        {role: "system", content: $system_prompt},
        {role: "user", content: $user_prompt}
    ],
    model: $model
}')

# Send the cURL request and capture the response
response=$(curl -s -X POST "$api_url" \
     -H "Authorization: Bearer $GROQ_API_KEY" \
     -H "Content-Type: application/json" \
     -d "$curl_data")


# Extract and print the message
result=$(echo "$response" | jq -r '.choices[0].message.content')

message=$(echo "$result" | jq -r '.message')
todo_list=$(echo "$result" | jq -r '.todo_list')

# Print the message
echo "AI: $message"

# Save the todo_list to todolist.json
echo "$todo_list" > todo.json 

# Print the response
echo "Response saved to todo.json:"


# add a task to finish the project tomorrow in the library
