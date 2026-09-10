import glob, os, re

# Fix gradle files for AGP and compileSdk 34
for g in glob.glob(os.path.expanduser('~/.pub-cache/hosted/pub.dev/*/android/build.gradle')):
    with open(g, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        if "apply plugin:" in line and "kotlin" in line:
            new_lines.append("// removed kotlin plugin\n")
        elif "compileSdkVersion" in line:
            new_lines.append("    compileSdkVersion 34\n")
        elif "compileSdk " in line and "compileSdkVersion" not in line:
            new_lines.append("    compileSdk 34\n")
        else:
            new_lines.append(line)

    txt = "".join(new_lines)
    txt = re.sub(r"kotlinOptions\s*\{[^}]*\}", "// removed kotlinOptions", txt)

    with open(g, 'w', encoding='utf-8') as f:
        f.write(txt)
    print("Patched gradle:", g)
