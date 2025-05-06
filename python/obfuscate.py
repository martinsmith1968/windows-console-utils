import sys
from argparse import ArgumentParser
from reverse import reverse_text
import base64

# python obfuscate.py "Hello World"
# QGby92Vg8GbsVGS
#
# python obfuscate.py "QGby92Vg8GbsVGS" -m d
# Hello World


class MyParser(ArgumentParser):
    def error(self, message):
        self.print_help()
        sys.stderr.write('\nERROR: %s\n' % message)
        sys.exit(2)

def removePrefix(text, prefix):
    while text.startswith(prefix):
        text = text[len(prefix):]
    return text

def removeSuffix(text, suffix):
    while text.endswith(suffix):
        text = text[:-len(suffix)]
    return text

def padPrefixToMultiple(text, prefix, lengthMultiple):
    while len(text) % lengthMultiple:
        text = prefix + text
    return text

def obfuscate(text):
    encoded = base64.b64encode(text.encode('utf-8')).decode('utf-8')
    result = removePrefix(reverse_text(encoded), '=')
    return result

def deobfuscate(text):
    encoded = reverse_text(padPrefixToMultiple(text, '=', 4))
    result = base64.b64decode(encoded.encode('utf-8')).decode('utf-8')
    return result


def _main():
    parser = MyParser(description="Obfuscate / De-Obfuscate some text")
    parser.add_argument("-v", "--version", action='version', version='%(prog)s 1.0')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("text", default='', nargs='?', help="Text to obfuscate")
    group.add_argument("-f", "--file", dest="filename", help="read Text from FILE", metavar="FILE")
    parser.add_argument("-m", "--mode", default='o', choices=['o', 'd'], help="[o]bfuscate, [d]eobfuscate")

    args = parser.parse_args()

    if args.text:
        if args.mode == 'o':
            text = obfuscate(args.text)
            print (text)
        elif args.mode == 'd':
            text = deobfuscate(args.text)
            print (text)
    elif args.filename:
        file1 = open(args.filename, 'r')

        while True:
            line = file1.readline()
            if not line:
                break

            if args.mode == 'o':
                text = obfuscate(line.strip())
                print (text)
            elif args.mode == 'd':
                text = deobfuscate(line.strip())
                print (text)

        file1.close()

if __name__ == '__main__':
    _main()
