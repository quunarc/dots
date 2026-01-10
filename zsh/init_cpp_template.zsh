init_cpp_flake() {
    local script_name="init_cpp_flake"
    local version="1.0.0"
    
    # Default paths
    local default_minimal_template="${HOME}/Development/Templates/cpp-template-minimal"
    local default_full_template="${HOME}/Development/Templates/cpp-template"
    local default_flake_only="${HOME}/Development/Templates/cpp-template/flake.nix"
    local default_envrc_only="${HOME}/Development/Templates/cpp-template/.envrc"
    
    # Colors for output
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local NC='\033[0m' # No Color
    
    # Function to print colored output
    print_msg() {
        local color=$1
        shift
        echo -e "${color}$*${NC}"
    }
    
    # Function to print usage
    print_usage() {
        cat << EOF
${GREEN}${script_name} v${version}${NC}
Initialize C++ project with Nix flake support.

Usage:
  ${script_name} [OPTIONS] [PROJECT_NAME]

Options:
  -h, --help           Show this help message
  -v, --version        Show version information
  -d, --dir            Create project in a directory (requires PROJECT_NAME)
  -m, --minimal        Use minimal template instead of full template
  -t, --template PATH  Use custom template directory
  -f, --flake-only     Only copy flake.nix file
  -l, --list-templates List available templates
  -y, --yes            Skip confirmation prompts
  --dry-run            Show what would be done without making changes

Examples:
  ${script_name}                      # Copy only flake.nix to current directory
  ${script_name} -d my-project        # Create full project in 'my-project' directory
  ${script_name} -d -m simple-project # Create minimal project in 'simple-project' directory
  ${script_name} --dry-run -d test    # Show what would be created for 'test' project
EOF
    }
    
    # Function to check if directory exists and is readable
    check_template_dir() {
        local dir=$1
        local name=$2
        
        if [[ ! -d "$dir" ]]; then
            print_msg "$RED" "Error: ${name} template directory not found: $dir"
            return 1
        fi
        
        if [[ ! -r "$dir" ]]; then
            print_msg "$RED" "Error: Cannot read ${name} template directory: $dir"
            return 1
        fi
        
        return 0
    }
    
    # Function to list available templates
    list_templates() {
        print_msg "$BLUE" "Available templates:"
        
        if [[ -d "$default_minimal_template" ]]; then
            local min_files=$(find "$default_minimal_template" -type f | wc -l)
            print_msg "$GREEN" "  minimal: $default_minimal_template ($min_files files)"
        else
            print_msg "$YELLOW" "  minimal: Not found at $default_minimal_template"
        fi
        
        if [[ -d "$default_full_template" ]]; then
            local full_files=$(find "$default_full_template" -type f | wc -l)
            print_msg "$GREEN" "  full:    $default_full_template ($full_files files)"
        else
            print_msg "$YELLOW" "  full:    Not found at $default_full_template"
        fi
        
        if [[ -f "$default_flake_only" ]]; then
            print_msg "$GREEN" "  flake:   $default_flake_only"
        else
            print_msg "$YELLOW" "  flake:   Not found at $default_flake_only"
        fi
    }
    
    # Parse command line arguments
    local create_dir=false
    local use_minimal=false
    local flake_only=false
    local skip_confirm=false
    local dry_run=false
    local custom_template=""
    local project_name=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_usage
                return 0
                ;;
            -v|--version)
                print_msg "$GREEN" "${script_name} v${version}"
                return 0
                ;;
            -d|--dir)
                create_dir=true
                shift
                ;;
            -m|--minimal)
                use_minimal=true
                shift
                ;;
            -f|--flake-only)
                flake_only=true
                shift
                ;;
            -t|--template)
                if [[ -z "$2" ]]; then
                    print_msg "$RED" "Error: --template requires a path argument"
                    return 1
                fi
                custom_template="$2"
                shift 2
                ;;
            -l|--list-templates)
                list_templates
                return 0
                ;;
            -y|--yes)
                skip_confirm=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -*)
                print_msg "$RED" "Error: Unknown option $1"
                print_usage
                return 1
                ;;
            *)
                if [[ -n "$project_name" ]]; then
                    print_msg "$RED" "Error: Multiple project names specified: '$project_name' and '$1'"
                    return 1
                fi
                project_name="$1"
                shift
                ;;
        esac
    done
    
    # Validate arguments
    if [[ "$create_dir" == true ]] && [[ -z "$project_name" ]]; then
        print_msg "$RED" "Error: --dir option requires a project name"
        print_usage
        return 1
    fi
    
    if [[ "$flake_only" == true ]] && [[ "$create_dir" == true ]]; then
        print_msg "$YELLOW" "Warning: --flake-only ignored when used with --dir"
        flake_only=false
    fi
    
    # Set template path based on options
    local template_path=""
    
    if [[ -n "$custom_template" ]]; then
        template_path="$custom_template"
        if ! check_template_dir "$template_path" "custom"; then
            return 1
        fi
    elif [[ "$flake_only" == true ]]; then
        if [[ ! -f "$default_flake_only" ]]; then
            print_msg "$RED" "Error: Flake template not found at $default_flake_only"
            return 1
        fi
        template_path="$default_flake_only"
    elif [[ "$use_minimal" == true ]]; then
        if ! check_template_dir "$default_minimal_template" "minimal"; then
            return 1
        fi
        template_path="$default_minimal_template"
    else
        if ! check_template_dir "$default_full_template" "full"; then
            return 1
        fi
        template_path="$default_full_template"
    fi
    
    # Show what will be done
    print_msg "$BLUE" "=== C++ Project Initialization ==="
    
    if [[ "$dry_run" == true ]]; then
        print_msg "$YELLOW" "DRY RUN - No changes will be made"
    fi
    
    if [[ "$create_dir" == true ]]; then
        print_msg "$GREEN" "Action:    Create new project directory"
        print_msg "$GREEN" "Name:      $project_name"
        print_msg "$GREEN" "Template:  $(basename "$template_path")"
        print_msg "$GREEN" "Type:      $([[ "$use_minimal" == true ]] && echo "minimal" || echo "full")"
    elif [[ "$flake_only" == true ]]; then
        print_msg "$GREEN" "Action:    Copy flake.nix only"
        print_msg "$GREEN" "Location:  Current directory"
    else
        print_msg "$GREEN" "Action:    Copy template to current directory"
    fi
    
    # Confirm with user (unless skipped)
    if [[ "$skip_confirm" == false ]] && [[ "$dry_run" == false ]]; then
        echo
        printf "Continue? (y/N): "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_msg "$YELLOW" "Operation cancelled"
            return 0
        fi
    fi
    
    # Execute actions
    if [[ "$dry_run" == false ]]; then
        echo
        
        if [[ "$create_dir" == true ]]; then
            # Check if target directory already exists
            if [[ -d "$project_name" ]]; then
                print_msg "$RED" "Error: Directory '$project_name' already exists"
                return 1
            fi
            
            # Create project directory
            print_msg "$BLUE" "Creating project directory: $project_name"
            mkdir -p "$project_name"
            
            if [[ $? -ne 0 ]]; then
                print_msg "$RED" "Error: Failed to create directory '$project_name'"
                return 1
            fi
            
            # Copy template
            print_msg "$BLUE" "Copying template from: $(basename "$template_path")"
            
            if [[ -d "$template_path" ]]; then
                cp -r "$template_path"/* "$project_name"/
                
                # Check for hidden files (like .gitignore)
                if [[ -f "$template_path/.gitignore" ]]; then
                    cp "$template_path/.gitignore" "$project_name"/
                fi
                if [[ -f "$template_path/.clang-format" ]]; then
                    cp "$template_path/.clang-format" "$project_name"/
                fi
                if [[ -d "$template_path/.vscode" ]]; then
                    cp -r "$template_path/.vscode" "$project_name"/
                fi
            else
                print_msg "$RED" "Error: Template path is not a directory: $template_path"
                return 1
            fi

            print_msg "$GREEN" "✓ Project created successfully in '$project_name/'"

            # Show next steps
            echo
            print_msg "$YELLOW" "Next steps:"
            print_msg "$NC" "  cd $project_name"
            if [[ -f "$project_name/README.md" ]]; then
                print_msg "$NC" "  cat README.md"
            fi

        elif [[ "$flake_only" == true ]]; then
            # Copy only flake.nix
            if [[ -f "$template_path" ]]; then
                print_msg "$BLUE" "Copying flake.nix to current directory"
                cp "$template_path" ./flake.nix
                cp "$default_envrc_only" ./.envrc

                if [[ $? -eq 0 ]]; then
                    print_msg "$GREEN" "✓ flake.nix copied successfully"
                else
                    print_msg "$RED" "Error: Failed to copy flake.nix"
                    return 1
                fi
            else
                print_msg "$RED" "Error: Flake template not found at $template_path"
                return 1
            fi

        else
            # Copy template to current directory
            print_msg "$BLUE" "Copying template to current directory"

            # Check if current directory is empty (excluding hidden files)
            local existing_files=$(find . -maxdepth 1 -type f -name '[!.]*' | wc -l)
            if [[ $existing_files -gt 0 ]] && [[ "$skip_confirm" == false ]]; then
                print_msg "$YELLOW" "Warning: Current directory is not empty"
                printf "Overwrite existing files? (y/N): "
                read -r overwrite_confirm
                if [[ ! "$overwrite_confirm" =~ ^[Yy]$ ]]; then
                    print_msg "$YELLOW" "Operation cancelled"
                    return 0
                fi
            fi

            if [[ -d "$template_path" ]]; then
                cp -r "$template_path"/* ./

                # Check for hidden files
                if [[ -f "$template_path/.gitignore" ]]; then
                    cp "$template_path/.gitignore" ./
                fi

                print_msg "$GREEN" "✓ Template copied successfully"
            else
                print_msg "$RED" "Error: Template path is not a directory: $template_path"
                return 1
            fi
        fi

        # Final message
        echo
        print_msg "$GREEN" "Done! C++ project initialized successfully."

    else
        # Dry run completed
        echo
        print_msg "$GREEN" "Dry run completed. No changes were made."
    fi

    return 0
}

# If the script is being executed directly (not sourced),
# call the function with all arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    init_cpp_flake "$@"
fi
