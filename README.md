
# windows-console-utils

A collection of scripts, apps and tools for Windows command line to :

- simplify tasks that cannot easily be accomplished via other menas
- establish a common command line experience 

## Setup

Installtion steps :

1. Clone this repo to a folder of your choice
   - Historically, this has been `%SYSTEMDRIVE%\Utils` but somewhere under your profile folder for security works equally well (E.g. `%APPDATA%\Utils`)
2. Execute the setup script
   - Execute from a terminal or double-click the `Setup.cmd` file from the root of where you cloned it to
3. Enjoy a host of new commands, tools and apps at the command prompt
   - Some examples below

## Components

| Folder | Description |
|:---|:---|
| \ (root) | Setup scripts
| cmd      | Batch scripts (.cmd, .bat) to perform the majority of tasks
| bin      | Binary executables from a variety of sources
| gnuwin32 | Windows builds of *nix binaries (from the old GetGnuWin32 library). Many of the scripts rely on these to work
| msbin    | Binary executables I've built (from my other repo(s))
| js       | JavaScript scripts for various tasks (executed via NodeJS)
| pwsh     | PowerShell scripts for various tasks
| py       | Python scripts for various tasks (compatible with python 3)

## Examples

### Open a file (or set of files) in an installed application (E.g. Notepad++)

There are all sorts of App that I install and use on almost every Windows system I use, but often launching these apps or getting the files I want
into them isn't always straightforward, or requires more pointing and clicking than I would like.

So, I created some shortcut scripts to launch these apps with the files (and parameters) that I want :

1. Open a file in [Notepad++](https://notepad-plus-plus.org/) quickly and easily
```cmd
C:\Windows> npp system.ini
```

2. Open a file in [Notepad++](https://notepad-plus-plus.org/) with the cursor at a specific line / column
```cmd
C:\Windows> npp system.ini -l 20 -c 5
```

3. Compare 2 files in [WinMerge](https://winmerge.org/)
```cmd
C:\MyFolder> winmerge file_a.txt file_b.txt
```
