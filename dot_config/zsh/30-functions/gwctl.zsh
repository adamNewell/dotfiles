# GWCTL related functions

gwctl() {
  ~/.gwctl/gwctl --config "$GWCTL_CONFIG" "$@"
}

gwctl_set_config() {
    local file="$1"
    
    # If the path is relative and doesn't start with ./ or ../
    if [[ -n "$file" && ! "$file" =~ ^/ && ! "$file" =~ ^\.\.?/ ]]; then
        # Use the GWCTL_CONFIG_DIR environment variable
        if [[ -n "$GWCTL_CONFIG_DIR" && -f "$GWCTL_CONFIG_DIR/$file" ]]; then
            # Use the file from the config directory
            file="$GWCTL_CONFIG_DIR/$file"
        fi
    fi
    
    if [[ -z "$file" ]]; then
        echo "Error: No file path provided."
        return 1
    fi
    
    if [[ -f "$file" ]]; then
        export GWCTL_CONFIG="$file" 
        echo "GWCTL_CONFIG set to '$file'"
    else
        echo "Error: Invalid file path. '$file' does not exist or is not a file."
        return 1
    fi
} 