#!/usr/bin/env python3
import os
import sys
import textwrap

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODULES_DIR = os.path.join(ROOT, "carch-core", "src", "modules")
EXCLUDE = {"carch_lib", "__pycache__", "colors.sh", "detect-distro.sh", "packages.sh"}

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
CYAN = "\033[0;36m"
NC = "\033[0m"


def list_modules():
    categories = {}
    for entry in sorted(os.listdir(MODULES_DIR)):
        if entry in EXCLUDE or entry.startswith("."):
            continue
        path = os.path.join(MODULES_DIR, entry)
        if not os.path.isdir(path):
            continue
        scripts = []
        for f in sorted(os.listdir(path)):
            if f in ("desc.toml", "__pycache__"):
                continue
            if f.endswith((".sh", ".py")):
                tag = "[P]" if f.endswith(".py") else "[S]"
                scripts.append((f, tag))
        if scripts:
            categories[entry] = scripts

    for cat in sorted(categories):
        print(f"\n{CYAN}{cat}/{NC}")
        for name, tag in categories[cat]:
            color = GREEN if tag == "[P]" else YELLOW
            print(f"  {color}{tag}{NC} {name}")

    total = sum(len(v) for v in categories.values())
    print(f"\n{GREEN}Total: {len(categories)} categories, {total} scripts{NC}")


def validate():
    issues = []

    for entry in sorted(os.listdir(MODULES_DIR)):
        if entry in EXCLUDE or entry.startswith("."):
            continue
        path = os.path.join(MODULES_DIR, entry)
        if not os.path.isdir(path):
            continue

        for f in sorted(os.listdir(path)):
            if f in ("desc.toml", "__pycache__") or not f.endswith((".sh", ".py")):
                continue

            filepath = os.path.join(path, f)
            with open(filepath) as fh:
                lines = fh.readlines()

            relpath = os.path.relpath(filepath, ROOT)
            is_python = f.endswith(".py")

            if not lines or not lines[0].startswith("#!"):
                issues.append((relpath, "missing shebang"))
            elif is_python and "python3" not in lines[0]:
                issues.append(
                    (relpath, f"shebang should use python3, got: {lines[0].strip()}")
                )
            elif not is_python and "bash" not in lines[0] and "sh" not in lines[0]:
                issues.append((relpath, f"suspicious shebang: {lines[0].strip()}"))

            if is_python:
                content = "".join(lines)
                if "carch_lib" not in content and "import" in content:
                    issues.append((relpath, "Python script does not import carch_lib"))

            stem = os.path.splitext(f)[0]
            desc_path = os.path.join(path, "desc.toml")
            if os.path.isfile(desc_path):
                import tomllib

                with open(desc_path, "rb") as dh:
                    try:
                        desc = tomllib.load(dh)
                        if stem not in desc:
                            issues.append((relpath, f"no desc.toml entry for '{stem}'"))
                    except Exception as e:
                        issues.append((relpath, f"desc.toml parse error: {e}"))

    if issues:
        print(f"\n{RED}Found {len(issues)} issue(s):{NC}\n")
        for path, msg in issues:
            print(f"  {YELLOW}{path}{NC}: {msg}")
        return 1
    else:
        print(f"{GREEN}All scripts look good!{NC}")
        return 0


def generate_overview():
    import tomllib

    lines = ["## Overview:\n"]

    categories = {}
    for entry in sorted(os.listdir(MODULES_DIR)):
        if entry in EXCLUDE or entry.startswith("."):
            continue
        path = os.path.join(MODULES_DIR, entry)
        if not os.path.isdir(path):
            continue
        desc_path = os.path.join(path, "desc.toml")
        if not os.path.isfile(desc_path):
            continue
        with open(desc_path, "rb") as f:
            try:
                desc = tomllib.load(f)
            except Exception:
                continue
        items = []
        for key, val in desc.items():
            if isinstance(val, dict) and "description" in val:
                items.append((key, val["description"]))
        if items:
            categories[entry] = items

    for cat in sorted(categories):
        lines.append(f"### {cat}\n")
        for name, desc in categories[cat]:
            lines.append(f"- **{name}**: *{desc}*")
        lines.append("")

    docs_dir = os.path.join(ROOT, "docs")
    os.makedirs(docs_dir, exist_ok=True)
    out_path = os.path.join(docs_dir, "overview.md")
    with open(out_path, "w") as f:
        f.write("\n".join(lines))
    print(f"{GREEN}Generated {out_path}{NC}")


def add_module(category):
    cat_dir = os.path.join(MODULES_DIR, category)
    os.makedirs(cat_dir, exist_ok=True)

    try:
        name = input("Script name (no extension): ").strip()
    except (KeyboardInterrupt, EOFError):
        print()
        return 0
    if not name:
        print(f"{RED}No name provided.{NC}")
        return 1

    try:
        ext = input("Language (s)hell or (p)ython? [s/p]: ").strip().lower()
    except (KeyboardInterrupt, EOFError):
        print()
        return 0
    if ext not in ("s", "p"):
        print(f"{RED}Invalid choice.{NC}")
        return 1

    is_python = ext == "p"
    filename = f"{name}.{'py' if is_python else 'sh'}"
    filepath = os.path.join(cat_dir, filename)

    if os.path.exists(filepath):
        print(f"{RED}{filename} already exists.{NC}")
        return 1

    if is_python:
        template = textwrap.dedent(f"""\
            #!/usr/bin/env python3
            import os
            import sys

            sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
            from carch_lib import (
                confirm,
                detect_distro,
                install_package,
                print_info,
                print_success,
                show_menu,
                get_choice,
            )


            def main():
                # TODO: Implement {name}
                pass


            if __name__ == "__main__":
                main()
        """)
    else:
        template = textwrap.dedent(f"""\
            #!/usr/bin/env bash

            source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1
            source "$(dirname "$0")/../detect-distro.sh" > /dev/null 2>&1
            source "$(dirname "$0")/../packages.sh" > /dev/null 2>&1

            # TODO: Implement {name}
        """)

    with open(filepath, "w") as f:
        f.write(template)
    os.chmod(filepath, 0o755)

    print(f"{GREEN}Created {os.path.relpath(filepath, ROOT)}{NC}")

    desc_path = os.path.join(cat_dir, "desc.toml")
    if os.path.isfile(desc_path):
        import tomllib

        with open(desc_path, "rb") as f:
            try:
                desc = tomllib.load(f)
            except Exception:
                desc = {}
        if name not in desc:
            try:
                desc_input = input("Short description: ").strip() or f"TODO: {name}"
            except (KeyboardInterrupt, EOFError):
                print()
                return 0
            desc[name] = {"description": desc_input}
            with open(desc_path, "w") as f:
                for key in sorted(desc):
                    desc_val = desc[key]
                    if isinstance(desc_val, dict):
                        f.write(f"[{key}]\n")
                        for k, v in desc_val.items():
                            f.write(f'{k} = "{v}"\n')
                        f.write("\n")
            print(f"{GREEN}Updated desc.toml{NC}")

    return 0


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 1

    cmd = sys.argv[1]
    if cmd == "list":
        list_modules()
    elif cmd == "validate":
        return validate()
    elif cmd == "overview":
        generate_overview()
    elif cmd == "add":
        if len(sys.argv) < 3:
            print(f"{RED}Usage: module_manager.py add <category>{NC}")
            return 1
        return add_module(sys.argv[2])
    else:
        print(f"{RED}Unknown command: {cmd}{NC}")
        print(__doc__)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
