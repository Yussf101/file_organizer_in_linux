#!/bin/bash

# Language translations
declare -A EN=(
    ["welcome"]="Welcome to the File Organizer!"
    ["prompt_dir"]="Enter the path of the folder you want to clean up (type 'exit' to quit):"
    ["dir_not_found"]="Oops! The folder doesn't exist. Try again!"
    ["creating_folders"]="Creating folders for your files..."
    ["organizing_files"]="Alright, let's move those files around!"
    ["moved"]="Moved"
    ["skipped"]="Hmm, I don't know where to put this one:"
    ["summary"]="All done! Here's the summary:"
    ["files_moved"]="I moved %d files into their folders."
)

declare -A FR=(
    ["welcome"]="Bienvenue dans l'Organisateur de Fichiers !"
    ["prompt_dir"]="Entrez le chemin du dossier que vous souhaitez organiser (tapez 'exit' pour quitter) :"
    ["dir_not_found"]="Oups ! Le dossier n'existe pas. Réessayez !"
    ["creating_folders"]="Création des dossiers pour vos fichiers..."
    ["organizing_files"]="D'accord, organisons ces fichiers !"
    ["moved"]="Déplacé"
    ["skipped"]="Je ne sais pas où mettre celui-ci :"
    ["summary"]="Terminé ! Voici le résumé :"
    ["files_moved"]="J'ai déplacé %d fichiers dans leurs dossiers."
)

# Prompt the user to choose a language
echo "Choose your language / Choisissez votre langue:"
echo "1. English"
echo "2. Français"
read -p "Enter the number (1/2): " LANG_CHOICE

# Set the language based on the user's choice
case $LANG_CHOICE in
    1) declare -n MESSAGES=EN ;;
    2) declare -n MESSAGES=FR ;;
    *) echo "Invalid choice. Defaulting to English."
       declare -n MESSAGES=EN ;;
esac

# Welcome message
echo "${MESSAGES[welcome]}"

# Loop until a valid directory is provided or the user types 'exit'
while true; do
    # Prompt the user for the directory path
    read -p "${MESSAGES[prompt_dir]} " DIR_PATH

    # Check if the user wants to exit
    if [[ "$DIR_PATH" == "exit" ]]; then
        echo "Exiting the program. Goodbye!"
        exit 0
    fi

    # Check if the directory exists
    if [ -d "$DIR_PATH" ]; then
        break
    else
        echo "${MESSAGES[dir_not_found]}"
    fi
done

# Define file categories and extensions
declare -A FILE_TYPES=(
    ["Images"]="jpg jpeg png gif bmp"
    ["Documents"]="pdf doc docx txt odt"
    ["Videos"]="mp4 mkv avi mov"
    ["Music"]="mp3 wav flac"
    ["Archives"]="zip tar gz rar"
)

# Create folders for each category
echo "${MESSAGES[creating_folders]}"
for CATEGORY in "${!FILE_TYPES[@]}"; do
    mkdir -p "$DIR_PATH/$CATEGORY"
done

# Start organizing files
echo "${MESSAGES[organizing_files]}"
MOVED_COUNT=0

for FILE in "$DIR_PATH"/*; do
    # Skip directories
    if [ -d "$FILE" ]; then
        continue
    fi

    # Get the file extension and convert to lowercase
    EXTENSION="${FILE##*.}"
    EXTENSION=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')

    # Find the right category for the file
    FOUND_CATEGORY=""
    for CATEGORY in "${!FILE_TYPES[@]}"; do
        for EXT in ${FILE_TYPES[$CATEGORY]}; do
            if [[ "$EXT" == "$EXTENSION" ]]; then
                FOUND_CATEGORY="$CATEGORY"
                break 2
            fi
        done
    done

    # Move the file to its folder
    if [ -n "$FOUND_CATEGORY" ]; then
        mv "$FILE" "$DIR_PATH/$FOUND_CATEGORY/"
        echo "${MESSAGES[moved]}: $FILE -> $DIR_PATH/$FOUND_CATEGORY/"
        MOVED_COUNT=$((MOVED_COUNT + 1))
    else
        echo "${MESSAGES[skipped]} $FILE"
    fi
done

# Show a summary of what happened
echo "${MESSAGES[summary]}"
printf "${MESSAGES[files_moved]}\n" "$MOVED_COUNT"
