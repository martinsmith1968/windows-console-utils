import sys
from argparse import ArgumentParser

# python reverse.py "Hello World"
# dlroW olleH


class MyParser(ArgumentParser):
    def error(self, message):
        self.print_help()
        sys.stderr.write('\nERROR: %s\n' % message)
        sys.exit(2)

def reverse_text(txt):
    return txt[::-1]

def _main():
    parser = MyParser(description="Reverse some text")
    parser.add_argument("-v", "--version", action='version', version='%(prog)s 1.0')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("text", default='', nargs='?', help="Text to obfuscate")
    group.add_argument("-f", "--file", dest="filename", help="read Text from FILE", metavar="FILE")

    args = parser.parse_args()

    if args.text:
        print (reverse_text(args.text))
    elif args.filename:
        file1 = open(args.filename, 'r')

        while True:
            line = file1.readline()
            if not line:
                break
            print (reverse_text(line.strip()))

        file1.close()

if __name__ == '__main__':
    _main()
