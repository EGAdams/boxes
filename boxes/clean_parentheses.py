import sys
import re

def process_line(line):
    # Add a space after the opening parenthesis of non-empty function calls
    line = re.sub(r'\((\w)', r'( \1', line)
    # Add a space before the closing parenthesis of non-empty function calls
    line = re.sub(r'(\w)\)', r'\1 )', line)
    return line

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <filename>")
        return

    file_name = sys.argv[1]

    try:
        with open(file_name, 'r') as file:
            lines = file.readlines()

        modified_lines = [process_line(line) for line in lines]

        with open(file_name, 'w') as file:
            file.writelines(modified_lines)

        print(f"Successfully modified the file: {file_name}")

    except FileNotFoundError:
        print(f"Error: File '{file_name}' not found.")
    except IOError as e:
        print(f"Error: Cannot read/write the file '{file_name}'. Reason: {e}")

if __name__ == "__main__":
    main()
