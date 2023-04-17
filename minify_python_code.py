import sys
import re

def minify(input_file):
    with open(input_file, 'r') as f:
        content = f.read()

    # Remove comments
    content = re.sub(r'#[^\n]*', '', content)

    # Remove extra whitespaces
    content = re.sub(r'\s+', ' ', content)

    # Remove whitespaces around brackets
    content = re.sub(r'\s*([\[\]\{\}\(\)])\s*', r'\1', content)

    return content

if __name__ == '__main__':
    input_file = sys.argv[1]
    minified_content = minify(input_file)
    
    with open(f'minified_{input_file}', 'w') as f:
        f.write(minified_content)
