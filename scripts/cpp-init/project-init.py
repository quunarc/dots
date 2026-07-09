#!/usr/bin/env python3
import argparse
import json
import os
import shutil
import sys
from pathlib import Path

# Global configuration file pointer
CONFIG_DIR = Path.home() / ".config" / "project-init"
CONFIG_FILE = CONFIG_DIR / "config.json"
DB_NAME = "templates.json"

# ==========================================
# EXTENSION POINT: AUTO-DETECT LANGUAGES
# Add or modify names here to restrict or expand auto-detection behavior.
# ==========================================
DEFAULT_LANGUAGES = {
    "cpp",
    "cpp-minimal",
    "rust",
    "java",
    "python",
    "go",
    "node",
    "zig"
}

def load_global_config():
    """Loads the root configuration pointing to the template directory."""
    if not CONFIG_FILE.exists():
        return {}
    try:
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    except json.JSONDecodeError:
        print(f"Error: Global configuration file at {CONFIG_FILE} is corrupted.", file=sys.stderr)
        sys.exit(1)

def save_global_config(config):
    """Saves the root configuration."""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=4)

def get_template_dir():
    """Returns the template directory Path object or exits if not set."""
    config = load_global_config()
    template_dir_str = config.get("template-dir")
    if not template_dir_str:
        print("Error: Template directory is not set.", file=sys.stderr)
        print("Please initialize it using: project-init set template-dir <path>", file=sys.stderr)
        sys.exit(1)

    path = Path(template_dir_str)
    if not path.exists():
        print(f"Error: Configured template directory does not exist: {path}", file=sys.stderr)
        sys.exit(1)
    return path

def load_template_db(template_dir):
    """Loads the local template database JSON within the template directory."""
    db_path = template_dir / DB_NAME
    if not db_path.exists():
        return {}
    try:
        with open(db_path, "r") as f:
            return json.load(f)
    except json.JSONDecodeError:
        print(f"Warning: Database at {db_path} was corrupted. Re-initializing empty database.", file=sys.stderr)
        return {}

def save_template_db(template_dir, db_data):
    """Saves the local template database JSON."""
    db_path = template_dir / DB_NAME
    with open(db_path, "w") as f:
        json.dump(db_data, f, indent=4)

def safely_resolve_path(path_str):
    """
    Handles path resolution with robust edge-case checks for Linux/NixOS.
    Resolves symlinks, ensures path existence, and checks permissions.
    """
    path = Path(path_str).expanduser().absolute()

    # Check for broken symlinks or recursive loops
    try:
        resolved = path.resolve(strict=True)
    except FileNotFoundError:
        if path.is_symlink():
            print(f"Error: Path '{path_str}' is a broken symlink.", file=sys.stderr)
        else:
            print(f"Error: Path '{path_str}' does not exist.", file=sys.stderr)
        sys.exit(1)
    except RuntimeError:
        print(f"Error: Symlink loop detected targeting '{path_str}'.", file=sys.stderr)
        sys.exit(1)

    if not resolved.is_dir():
        print(f"Error: Target path '{path_str}' must be a directory.", file=sys.stderr)
        sys.exit(1)

    return resolved

def auto_detect_templates(template_dir):
    """Scans the template directory and syncs with the DB file."""
    db = load_template_db(template_dir)
    updated = False

    # Scan the directory safely using standard iterdir
    try:
        for entry in template_dir.iterdir():
            if entry.name == DB_NAME or entry.name.startswith("."):
                continue

            # Resolve directory while respecting symlinks point to directories
            try:
                resolved_entry = entry.resolve(strict=True)
                if resolved_entry.is_dir():
                    # If it's one of our targeted patterns, or you can drop the 'in DEFAULT_LANGUAGES' check
                    # to auto-detect *every* single folder found there.
                    if entry.name in DEFAULT_LANGUAGES or not DEFAULT_LANGUAGES:
                        if entry.name not in db:
                            db[entry.name] = str(resolved_entry)
                            updated = True
            except (FileNotFoundError, RuntimeError):
                continue # Skip broken symlinks during automated scanning
    except PermissionError:
        print(f"Error: Missing permissions to scan {template_dir}", file=sys.stderr)
        sys.exit(1)

    if updated:
        save_template_db(template_dir, db)
    return db

# ==========================================
# COMMAND HANDLERS
# ==========================================

def handle_set(args):
    target = args.target
    path_str = args.path

    if target == "template-dir":
        # Global configuration setup
        resolved_path = safely_resolve_path(path_str)
        config = load_global_config()
        config["template-dir"] = str(resolved_path)
        save_global_config(config)
        print(f"Success: Template root directory set to {resolved_path}")

        # Build the initial DB right away on configuration setup
        auto_detect_templates(resolved_path)
        print("Database initialized & scanned successfully.")
    else:
        # Language/nickname specific mapping
        template_dir = get_template_dir()
        resolved_path = safely_resolve_path(path_str)

        db = load_template_db(template_dir)
        db[target] = str(resolved_path)
        save_template_db(template_dir, db)
        print(f"Success: Mapped '{target}' -> {resolved_path} in database.")

def handle_create(args):
    lang = args.lang
    template_dir = get_template_dir()

    # Always pull latest updates if directories have been shifted/added manually
    db = auto_detect_templates(template_dir)

    if lang not in db:
        print(f"Error: Language/Template '{lang}' is not registered in the database.", file=sys.stderr)
        print("Available options: " + ", ".join(db.keys()), file=sys.stderr)
        sys.exit(1)

    src_path = Path(db[lang])
    if not src_path.exists():
        print(f"Error: Source template path for '{lang}' no longer exists: {src_path}", file=sys.stderr)
        sys.exit(1)

    # Process destination path logic
    if args.path:
        dest_path = Path(args.path).expanduser().absolute()
    else:
        dest_path = Path.cwd() / lang

    if dest_path.exists() and any(dest_path.iterdir()):
        print(f"Error: Target directory {dest_path} already exists and is not empty.", file=sys.stderr)
        sys.exit(1)

    print(f"Initializing {lang} project...")
    try:
        shutil.copytree(src_path, dest_path, dirs_exist_ok=True, symlinks=True)
        # Dynamic placeholder feature application (optional bonus execution step)
        apply_placeholders(dest_path, dest_path.name)
        print(f"Success: Project generated cleanly at {dest_path}")
    except Exception as e:
        print(f"Error transferring files: {e}", file=sys.stderr)
        sys.exit(1)

def handle_list(args):
    """BONUS FEATURE: Easily check current configuration mappings."""
    template_dir = get_template_dir()
    db = auto_detect_templates(template_dir)
    print(f"\n--- Template Root: {template_dir} ---")
    if not db:
        print(" No registered templates found.")
        return
    for lang, path in sorted(db.items()):
        print(f"  {lang:<15} ->  {path}")
    print()

def apply_placeholders(project_path, project_name):
    """
    BONUS FEATURE: Iterates through files in the newly generated project and
    swaps out simple text anchors dynamically. (e.g., replaces {{PROJECT_NAME}})
    """
    for root, _, files in os.walk(project_path):
        for file in files:
            file_path = Path(root) / file
            # Avoid processing large binaries or heavy objects
            if file_path.suffix in ['.png', '.jpg', '.ico', '.so', '.a', '.o', '.bin']:
                continue
            try:
                content = file_path.read_text(encoding='utf-8', errors='ignore')
                if "{{PROJECT_NAME}}" in content:
                    updated = content.replace("{{PROJECT_NAME}}", project_name)
                    file_path.write_text(updated, encoding='utf-8')
            except Exception:
                pass # Silently pass if file read fails due to encoding checks

# ==========================================
# MAIN PARSER ENGINE
# ==========================================

def main():
    parser = argparse.ArgumentParser(
        description="A lightweight boilerplate template initiator tool.",
        prog="project-init"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # 'set' Parser
    set_parser = subparsers.add_parser("set", help="Set template directories or individual mappings.")
    set_parser.add_file = set_parser.add_argument("target", help="Either 'template-dir' or the target language identifier.")
    set_parser.add_argument("path", help="The absolute or relative path to bind to the target target.")

    # 'create' Parser
    create_parser = subparsers.add_parser("create", help="Instantiate a project template boilerplate.")
    create_parser.add_argument("lang", help="The template identifier framework/language database target.")
    create_parser.add_argument("path", nargs="?", default=None, help="Output destination folder path. Defaults to ./<lang>.")

    # 'list' Parser
    subparsers.add_parser("list", help="List all actively registered boilerplate templates.")

    args = parser.parse_args()

    if args.command == "set":
        handle_set(args)
    elif args.command == "create":
        handle_create(args)
    elif args.command == "list":
        handle_list(args)

if __name__ == "__main__":
    main()
