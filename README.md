# ToDosh

## Overview

This bash script, `todo.sh`, manages a simple todo list. Each task has a unique identifier, title, description, location, due date, and completion marker. The script allows users to create, update, delete, search for tasks, and list tasks based on their completion status and due date.

## Design Choices

### Data Storage

- **JSON File**: Tasks are stored in a JSON file named `todo.json`. This format is chosen for its simplicity and ease of use with `jq`, a lightweight and flexible command-line JSON processor.
- **Fields**: Each task in the JSON file has the following fields:
  - `id`: Unique identifier for the task.
  - `title`: Title of the task.
  - `description`: Description of the task.
  - `location`: Location where the task is to be performed.
  - `due_date`: Due date of the task in `YYYY-MM-DD` format.
  - `completed`: Boolean indicating whether the task is completed.

### Code Organization

- **Initialization**: If the `todo.json` file does not exist, it is initialized as an empty JSON array (`[]`).
- **Options**: The script uses various options to perform different actions:
  - `-a`: Add a new task.
  - `-s`: Search for a task by title.
  - `-r`: Remove a task by title or ID.
  - `-u`: Update a task by title or ID.
  - `-d`: Display tasks due on a specific date, categorized into completed and uncompleted tasks.
  - `-c`: Mark a task as completed by title or ID.

### Functions

- **print_task**: This function takes a task as an argument and prints its details in a clean and formatted way, skipping any empty fields.

## Usage

### Adding a Task

To add a new task, use the `-a` option:

```bash
./todo.sh -a
```

You will be prompted to enter the task details.

### Searching for a Task

To search for a task by title, use the `-s` option:

```bash
./todo.sh -s "task title"
```

If you do not provide a title, you will be prompted to enter one.

### Removing a Task

To remove a task by title or ID, use the `-r` option:

```bash
./todo.sh -r "task title"
# or
./todo.sh -r task_id
```

If you do not provide a title or ID, you will be prompted to enter one.

### Updating a Task

To update a task by title or ID, use the `-u` option:

```bash
./todo.sh -u "task title"
# or
./todo.sh -u task_id
```

You will be prompted to enter the new details for the task.

### Displaying Tasks for a Specific Date

To display tasks due on a specific date, use the `-d` option:

```bash
./todo.sh -d YYYY-MM-DD
```

If you do not provide a date, you will be prompted to enter one. The tasks will be displayed in two sections: uncompleted tasks and completed tasks.

### Marking a Task as Completed

To mark a task as completed by title or ID, use the `-c` option:

```bash
./todo.sh -c "task title"
# or
./todo.sh -c task_id
```

If you do not provide a title or ID, you will be prompted to enter one.

## Example

Here is an example of adding a task, searching for it, updating it, marking it as completed, and then displaying tasks for a specific date:

```bash
./todo.sh -a
# Follow prompts to add a task with title "Buy groceries"

./todo.sh -s "Buy groceries"
# Displays the details of the task with title "Buy groceries"

./todo.sh -u "Buy groceries"
# Follow prompts to update the task details

./todo.sh -c "Buy groceries"
# Marks the task with title "Buy groceries" as completed

./todo.sh -d 2024-05-22
# Displays tasks due on 2024-05-22, categorized into uncompleted and completed tasks
```

## Requirements

- `jq`: Ensure `jq` is installed on your system. You can install it using your package manager, e.g., `sudo apt-get install jq` on Debian-based systems.

## Notes

- The script uses a timestamp to generate unique IDs for tasks.
- Dates should be entered in `YYYY-MM-DD` format.
- When updating a task, fields can be left empty to retain their current values.

