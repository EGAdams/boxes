import sys
import re

def minify(input_file):
    with open(input_file, 'r') as f:
        content = f.read()

    # Remove single-line comments
    content = re.sub(r'//.*', '', content)

    # Remove multi-line comments
    content = re.sub(r'/\*[\s\S]*?\*/', '', content)

    # Remove extra whitespaces ( not including newlines )
    content = re.sub(r'\s+(?=[^\s])', '', content)

    # Remove whitespaces around brackets
    content = re.sub(r'\s*([\[\]\{\}\(\)])\s*', r'\1', content)

    return content

if __name__ == '__main__':
    input_file = sys.argv[1]
    minified_content = minify(input_file)
    
    with open(f'minified_{input_file}', 'w') as f:
        f.write(minified_content)
