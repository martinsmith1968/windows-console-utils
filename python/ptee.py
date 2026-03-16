# Source : https://gist.github.com/tomer/2a502c607e3c702580bf9236953c8ebe

import argparse
import sys
from contextlib import ExitStack

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('filename', nargs='*')
    parser.add_argument('--append', '-a', action='store_true')
    args = parser.parse_args()

    print(args)

    with ExitStack() as stack:
        files = [stack.enter_context(
            open(fname, 'a' if args.append else 'w')) for fname in args.filename]
        print(files)
        for line in sys.stdin:
            print(line.rstrip())
            for fh in files:
                fh.write(line)
