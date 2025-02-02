import sys
from argparse import ArgumentParser
import base64

# python based64.py "Hello World"
# SGVsbG8gV29ybGQ=
#
# python base64.py "SGVsbG8gV29ybGQ=" -m d
# Hello World


class MyParser(ArgumentParser):
    def error(self, message):
        self.print_help()
        sys.stderr.write('\nERROR: %s\n' % message)
        sys.exit(2)

def encode(text):
    result = base64.b64encode(text.encode('utf-8')).decode('utf-8')
    return result

def decode(text):
    result = base64.b64decode(text.encode('utf-8')).decode('utf-8')
    return result


def _main():
    parser = MyParser(description="Base64 Encode / Decode some text")
    parser.add_argument("-v", "--version", action='version', version='%(prog)s 1.0')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("text", default='', nargs='?', help="Text to obfuscate")
    group.add_argument("-f", "--file", dest="filename", help="read Text from FILE", metavar="FILE")
    parser.add_argument("-m", "--mode", default='e', choices=['e', 'd'], help="[e]ncode, [d]ecode")

    args = parser.parse_args()

    if args.text:
        if args.mode == 'e':
            text = encode(args.text)
            print (text)
        elif args.mode == 'd':
            text = decode(args.text)
            print (text)
    elif args.filename:
        file1 = open(args.filename, 'r')

        while True:
            line = file1.readline()
            if not line:
                break

            if args.mode == 'o':
                text = encode(line.strip())
                print (text)
            elif args.mode == 'd':
                text = decode(line.strip())
                print (text)

        file1.close()

if __name__ == '__main__':
    _main()
