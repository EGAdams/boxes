import sys
import re

def de_minify(input_file):
    with open(input_file, 'r') as f:
        content = f.read()

    # Add newline after import statements
    content = re.sub(r'(import[^;]+;)', r'\1\n', content)

    # Add newline after class, struct, enum, and protocol definitions
    content = re.sub(r'((class|struct|enum|protocol)[^:]+:)', r'\1\n', content)

    # Add newline after loops and if statements
    content = re.sub(r'((for|while|if|else)[^:]+:)', r'\1\n', content)

    # Add newline after closing brackets
    content = re.sub(r'([\]\}\)])', r'\1\n', content)

    # Add indentation
    indented_content = ""
    indentation_level = 0
    for line in content.splitlines():
        if line.startswith(('}', ']', ')')):
            indentation_level -= 1
        indented_content += ' ' * (4 * indentation_level) + line + '\n'
        if line.endswith(('{', '[', '(')):
            indentation_level += 1

    return indented_content

if __name__ == '__main__':
    input_file = sys.argv[1]
    de_minified_content = de_minify(input_file)
    
    with open(f'de_minified_{input_file}', 'w') as f:
        f.write(de_minified_content)
