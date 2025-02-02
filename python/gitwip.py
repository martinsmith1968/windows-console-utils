import sys
import contextlib
import os
import glob
import git
import re
import csv
from argparse import ArgumentParser
from rich.progress import Progress

################################
# TODO: Remaining Features
# - Implement forcePullPrimary 
# - Fix progress bar : https://stackoverflow.com/questions/51045540/python-progress-bar-for-git-clone
#
#
################################


# Useful Links:
#  https://stackoverflow.com/questions/43037807/find-out-if-changes-were-pushed-to-origin-in-gitpython

DefaultPrimaryBranches  = [ "main", "master", "wikiMaster", "primary" ]
DefaultRemotes          = [ "origin", "azure", "devops" ]

AllRepos                            = [ ]
ReposPrinted                        = [ ]
NonGitDirectories                   = [ ]
ReposInError                        = [ ]
ReposWithIssues                     = [ ]
ReposWithLocalBranchesOverThreshold = [ ]
ReposNotOnPrimaryBranch             = [ ]
ReposWithUncommitted                = [ ]
ReposAhead                          = [ ]
ReposBehind                         = [ ]
ReposPulled                         = [ ]
ReposFetched                        = [ ]


def PrintError(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs, flush=True)

def PrintOutput(*args, **kwargs):
    print(*args, **kwargs, flush=True)

def indentText(level, *text, indentSize = 2):
    return str(' ' * (indentSize * level)) + ' '.join(str(x) for x in text)


class MyParser(ArgumentParser):
    def error(self, message):
        self.print_help()
        PrintError('\nERROR: %s\n' % message)
        sys.exit(2)


class CustomProgressPrinter(git.RemoteProgress):

    def __init__(self, activityMessage=""):
        self.progress = Progress()
        self.downloadTask = self.progress.add_task(f"[yellow]{activityMessage}...", total=100)
        self.updatesMade = 0
        super().__init__()

    def update(self, op_code, cur_count, max_count=None, message=""):
        percent_complete = min(cur_count / (max_count or 100.0), 100.00)
        self.progress.update(self.downloadTask, completed=percent_complete)


@contextlib.contextmanager
def pushDirectory(new_dir):
    previous_dir = os.getcwd()
    os.chdir(new_dir)
    try:
        yield
    finally:
        os.chdir(previous_dir)


def isGitRepo(dir):
    try:
        git.Repo(dir)
    except:
        return False
    else:
        return True


def getRepoName(repo):
    path = repo.working_dir
    return os.path.basename(path)


def doesGitBranchExist(repo, branchName):
    try:
        repo.heads[branchName]
    except:
        return False
    else:
        return True


def getGitRemotes(repo):
    return repo.remotes


def doesGitRemoteExist(repo, remoteName):
    try:
        repo.remotes[remoteName]
    except:
        return False
    else:
        return True


def isGitRemoteValid(repo, remoteName):
    if not doesGitRemoteExist(repo, remoteName):
        return False
    
    remote = repo.remotes[remoteName]

    return remote.exists()


def getGitCurrentBranch(repo):
    return repo.head.ref.name


def getGitPrimaryBranch(repo):
    for primaryBranchName in DefaultPrimaryBranches:
        if doesGitBranchExist(repo, primaryBranchName):
            return repo.heads[primaryBranchName]

    return None


def isGitBranchPrimary(branchName):
    for primaryBranchName in DefaultPrimaryBranches:
        if branchName == primaryBranchName:
            return True

    return False


def getGitPrimaryRemote(repo):
    for remoteName in DefaultRemotes:
        if doesGitRemoteExist(repo, remoteName):
            return repo.remotes[remoteName]

    return None


def getGitLocalBranches(repo):
    return repo.branches


def getLocalNonPrimaryBranches(repo):
    localNonPrimaryBranches = []
    for branch in getGitLocalBranches(repo):
        if not isGitBranchPrimary(branch.name):
            localNonPrimaryBranches.append(branch.name)

    return localNonPrimaryBranches


def readCSVFile(fileName, delimiter=",", quoteChar='"'):
    records = [ ]
    with open(fileName) as csvFile:
        csvReader = csv.reader(csvFile, delimiter=delimiter, quotechar=quoteChar)
        for row in csvReader:
            records.append(row)

    return records


def readNotes(dir, notesFilename):
    notes = { }

    if notesFilename:
        with pushDirectory(dir):
            fileName = os.path.join(dir, notesFilename)
            if os.path.exists(fileName):
                records = readCSVFile(fileName)
                for record in records:
                    notes[record[0]] = record[1]

    return notes


def processAllReposUnderDirFromDir(dir, args, indent = 0):
    with pushDirectory(dir):
        container_dirs = glob.glob(args.directory_wildcard)
        PrintOutput(indentText(indent, "Found", len(container_dirs), "container directories"))

        index = 0
        for container_dir in container_dirs:
            if os.path.isdir(container_dir):
                PrintOutput(indentText(indent, "Container:", container_dir))
                index += 1
                processAllReposUnderDir(container_dir, args, indent + 1)


def processAllReposUnderDir(dir, args, indent = 0):
    with pushDirectory(dir):
        notes = readNotes(dir, args.notes_csv_filename)
        sub_dirs = glob.glob(args.directory_wildcard)
        PrintOutput(indentText(indent, "Found", len(sub_dirs), "directories"))

        index = 0
        for sub_dir in sub_dirs:
            if os.path.isdir(sub_dir):
                index += 1
                processDir(sub_dir, args, index = index, indent = indent + 1, notes = notes)


def processTree(dir, args, indent = 0):
    with pushDirectory(dir):
        notes = readNotes(dir, args.notes_csv_filename)
        sub_dirs = glob.glob(args.directory_wildcard)
        PrintOutput(indentText(indent, "Found", len(sub_dirs), "directories"))

        index = 0
        for sub_dir in sub_dirs:
            if os.path.isdir(sub_dir):
                if isGitRepo(sub_dir):
                    index += 1
                    processDir(sub_dir, args, index = index, indent = indent + 1, notes = notes)
                else:
                    processTree(sub_dir, args, index = index, indent = indent + 1, notes = notes)
        

def processDir(dir, args, index = 0, indent = 1, notes = { }):
    with pushDirectory(dir):
        if not isGitRepo("."):
            NonGitDirectories.append(dir)
            return
        
        repo_identifier = ""
        output_lines = [ ]

        if index > 0 and args.showRepoIndex:
            repo_identifier = indentText(indent, f"{index}: {dir}")
        else:
            repo_identifier = indentText(indent, f"{dir}")


        ##############################
        # Access repo
        repo = git.Repo(".")
        repoName = dir
        AllRepos.append(repo)


        ##############################
        # Determine current state
        primaryBranch = getGitPrimaryBranch(repo)
        currentBranch = getGitCurrentBranch(repo)
        primaryRemote = getGitPrimaryRemote(repo)
        
        noteWIP = None
        if repoName in notes.keys():
            noteWIP = notes[repoName]

        isOnPrimaryBranch = isGitBranchPrimary(currentBranch)
        ahead = 0
        behind = 0
        localNonPrimaryBranches = getLocalNonPrimaryBranches(repo)
        if len(localNonPrimaryBranches) == 1 and localNonPrimaryBranches[0] == currentBranch:
            localNonPrimaryBranches = []

        repo_status = ""
        try:
            repo_status = repo.git.status(porcelain="v2", branch=True)
        except Exception as ex:
            ReposWithIssues.append(repo)
            PrintError("WARNING: Error accessing repo: %s - %s" % repoName, ex)
            repo_status = ""
        ahead_behind_match = re.search(r"#\sbranch\.ab\s\+(\d+)\s-(\d+)", repo_status)

        if ahead_behind_match:
            ahead = int(ahead_behind_match.group(1))
            behind = int(ahead_behind_match.group(2))

        if ahead:
            ReposAhead.append(repo)
        if behind:
            ReposAhead.append(repo)

        if args.warnLocalNonPrimaryBranches and len(localNonPrimaryBranches) > args.warnLocalNonPrimaryBranches:
            ReposWithLocalBranchesOverThreshold.append(repo)


        ##############################
        ## Display

        # Show Notes ?
        if args.showNotes:
            if noteWIP:
                output_lines.append(indentText(indent + 1, f"Note: {noteWIP}"))

        # Show Branch on Primary ?
        showBranch = (isOnPrimaryBranch and args.showOnPrimary)
        if showBranch:
            output_lines.append(indentText(indent + 1, f"Current: {currentBranch}"))

        showBranch = (not isOnPrimaryBranch and args.showOnNonPrimary)
        if showBranch:
            ReposNotOnPrimaryBranch.append(repo)
            output_lines.append(indentText(indent + 1, f"Current: {currentBranch}"))

        # Show Out of Date (Ahead / Behind) ?
        if args.showOutOfDate:
            if ahead:
                output_lines.append(indentText(indent + 1, f"Ahead by {ahead} commits"))
            if behind:
                output_lines.append(indentText(indent + 1, f"Behind by {behind} commits"))

        # Show Untracked / uncommitted
        if (args.showUncommittedFiles):
            untrackedOutput = []

            if repo.index.diff(None):
                for file in repo.index.diff(None):
                    if file.a_path == file.b_path:
                        untrackedOutput.append(indentText(indent + 2, f"Not Staged: {file.b_path}"))
                    else:
                        untrackedOutput.append(indentText(indent + 2, f"Not Staged: {file.a_path} -> {file.b_path}"))

            if repo.untracked_files:
                for file in repo.untracked_files:
                    untrackedOutput.append(indentText(indent + 2, f"Untracked: {file}"))

            if untrackedOutput:
                ReposWithUncommitted.append(repo)
                for line in untrackedOutput:
                    output_lines.append(line)


        # Show Local Branches ?
        if args.showLocalNonPrimaryBranches:
            for branchName in localNonPrimaryBranches:
                output_lines.append(indentText(indent + 1, f"Branch: {branchName}"))


        ##############################
        # Actions

        # Pull from remote ?
        remote = None
        pulling = False
        fetchSpecs = { }

        if (args.pullOnPrimary or args.pullOnNonPrimary) and behind:
            remote = getGitPrimaryRemote(repo)
            if remote:
                if not isGitRemoteValid(repo, remote.name):
                    output_lines.append(indentText(indent + 1, "ERROR: Remote not accessible"))
                else:
                    primaryBranchName = getGitPrimaryBranch(repo)
                    if (primaryBranchName):
                        primaryBranchName = primaryBranchName.name

                if args.pullOnPrimary and repo.head.ref.name == primaryBranchName:
                    pulling = True

                if args.pullOnNonPrimary and repo.head.ref.name != primaryBranchName:
                    pulling = True
        
        if (args.fetchPrimary):
            remote = getGitPrimaryRemote(repo)
            if remote:
                primaryBranchNames = DefaultPrimaryBranches
                if (args.primary_branch):
                    primaryBranchNames.clear()
                    primaryBranchNames.append(args.primary_branch)

                for primaryBranchName in primaryBranchNames:
                    if doesGitBranchExist(repo, primaryBranchName):
                        currentBranch = getGitCurrentBranch(repo)
                        if primaryBranchName != currentBranch:
                            fetchSpecs[primaryBranchName] = primaryBranchName

        # If there is output for this repo, then print it now
        if output_lines:
            ReposPrinted.append(repo)
            PrintOutput(repo_identifier)
            for line in output_lines:
                PrintOutput(line)

        # Pull commits from remote
        if pulling:
            try:
                ReposPulled.append(repo)
                PrintOutput(indentText(indent + 1, "Pulling..."))
                remote.pull(progress=CustomProgressPrinter("Pulling"))
            except Exception as e:
                output_lines.append(indentText(indent + 1, f"ERROR: {e}"))
                ReposInError.append(repo)
        
        # Fetch commits from remote branches
        if fetchSpecs:
            try:
                for key, value in fetchSpecs.items():
                    PrintOutput(indentText(indent + 1, f"Fetching {key} -> {value}"))
                    fetchInfos = remote.fetch(progress=CustomProgressPrinter("Fetching"), refspec=f"{key}:{value}")
                    for fetchInfo in fetchInfos:
                        if not (fetchInfo.flags & fetchInfo.HEAD_UPTODATE):
                            ReposFetched.append((repo, key))
                            break

            except Exception as e:
                output_lines.append(indentText(indent + 1, f"ERROR: {e}"))
                ReposInError.append(repo)


def _main():
    processing_modes = ['repo', 'dir_of_repos', 'dir_of_dir_of_repos', 'tree']
    showNotes_modes  = ['no', 'primary', 'always']
    
    parser = MyParser(description="Analyse a GIT repo")
    parser.add_argument("-v",   "--version",                                                                                    action='version',       version='%(prog)s 1.2')
    parser.add_argument("-d",   "--directory",                          dest="directory",                   required=True,                                                          help="The directory to analyze")
    parser.add_argument("-m",   "--mode",                               dest="mode",                        default='repo',                             choices=processing_modes,   help="The processing mode")
    parser.add_argument("-w",   "--directory-wildcard",                 dest="directory_wildcard",          default="*",                                                            help="The wildcard directory pattern to use for repo directory selection")
    parser.add_argument("-b",   "--primary-branch",                     dest="primary_branch",                                                                                      help="The branch name to use as primary")
    parser.add_argument("-o",   "--default-origins",                    dest="default_origins",                                                                                     help="The origin names to use by default")
    parser.add_argument("-nfn", "--notes-csv-filename",                 dest="notes_csv_filename",                                                                                  help="The filename containing notes for each repo (in the parent directory)")

    group = parser.add_argument_group('Processing Options')
    group.add_argument("-sri",   "--show-repo-index",                   dest="showRepoIndex",               default=False,      action='store_true',                                help="Show index number of Repo")
    group.add_argument("-sop",   "--show-on-primary-branch",            dest="showOnPrimary",               default=False,      action='store_true',                                help="Show details if on primary branch")
    group.add_argument("-sonp",  "--show-on-non-primary-branch",        dest="showOnNonPrimary",            default=False,      action='store_true',                                help="Show details if on non-primary branch")
    group.add_argument("-sood",  "--show-out-of-date",                  dest="showOutOfDate",               default=False,      action='store_true',                                help="Show Out of Date commits")
    group.add_argument("-pop",   "--pull-on-primary-branch",            dest="pullOnPrimary",               default=False,      action='store_true',                                help="Pull if on primary branch")
    group.add_argument("-ponp",  "--pull-on-non-primary-branch",        dest="pullOnNonPrimary",            default=False,      action='store_true',                                help="Pull if on non-primary branch")
    group.add_argument("-fpb",   "--fetch-primary-branches",            dest="fetchPrimary",                default=False,      action='store_true',                                help="Fetch any local primary branch(es)")
    group.add_argument("-suc",   "--show-uncommitted-files",            dest="showUncommittedFiles",        default=False,      action='store_true',                                help="Show any uncommitted files (WIP)")
    group.add_argument("-slnpb", "--show-local-non-primary-branches",   dest="showLocalNonPrimaryBranches", default=False,      action='store_true',                                help="Show any local non-Primary branches")
    group.add_argument("-wlnpb", "--warn-local-non-primary-branches",   dest="warnLocalNonPrimaryBranches", default=0,          type=int,               choices=range(0, 11),       help="Warn if count of local non-Primary branches exceeds threshold")
    group.add_argument("-snpr",  "--show-non-primary-remotes",          dest="showNonPrimaryRemotes",       default=False,      action='store_true',                                help="Show any non-Primary remotes")
    group.add_argument("-sn",    "--show-notes",                        dest="showNotes",                   default='always',                           choices=showNotes_modes,    help="Show any supporting notes")
    group.add_argument("-ns",    "--no-summary",                        dest="showSummary",                 default=True,       action='store_false',                               help="Show a summary of processing")

    # Parse
    args = parser.parse_args()

    # Process
    match args.mode:
        case 'repo':
            processDir(args.directory, args)
        case 'dir_of_repos':
            processAllReposUnderDir(args.directory, args)
        case 'dir_of_dir_of_repos':
            processAllReposUnderDirFromDir(args.directory, args)
        case 'tree':
            processTree(args.directory, args)
        case _:
            raise Exception(f"Unexpected or currently unsupported 'mode': {args.mode}")
        

    if args.showSummary:
        PrintOutput("")
        PrintOutput("Summary")
        PrintOutput("=======")
        PrintOutput("Total Repos :", len(AllRepos))

        if ReposPrinted:
            PrintOutput("")
            PrintOutput("Repos printed :", len(ReposPrinted))

        if NonGitDirectories:
            PrintOutput("")
            PrintOutput("Non-git Directories :", len(NonGitDirectories))
            for dir in NonGitDirectories:
                PrintOutput("  ", dir)

        if ReposInError:
            PrintOutput("")
            PrintOutput("Repos in Error :", len(ReposInError))
            for repo in ReposInError:
                PrintOutput(indentText(1, getRepoName(repo)))

        if ReposWithIssues:
            PrintOutput("")
            PrintOutput("Repos with Issues:", len(ReposWithIssues)),
            for repo in ReposWithIssues:
                PrintOutput(indentText(1, getRepoName(repo)))

        if ReposWithLocalBranchesOverThreshold:
            threshold = args.warnLocalNonPrimaryBranches
            PrintOutput("")
            PrintOutput(f"Repos with Local Branches over Threshold ({threshold}) :", len(ReposWithLocalBranchesOverThreshold))
            for repo in ReposWithLocalBranchesOverThreshold:
                PrintOutput(indentText(1, getRepoName(repo)))

        if ReposNotOnPrimaryBranch:
            PrintOutput("")
            PrintOutput("Repos not on Primary Branch :", len(ReposNotOnPrimaryBranch))
            for repo in ReposNotOnPrimaryBranch:
                PrintOutput(indentText(1, getRepoName(repo)))

        if ReposWithUncommitted:
            PrintOutput("")
            PrintOutput("Repos with uncommitted files :", len(ReposWithUncommitted))
            for repo in ReposWithUncommitted:
                PrintOutput(indentText(1, getRepoName(repo)))

        if ReposAhead:
            PrintOutput("")
            PrintOutput("Repos ahead of remote :", len(ReposAhead))
            for repo in ReposAhead:
                PrintOutput(indentText(1, getRepoName(repo)))

        if ReposBehind:
            PrintOutput("")
            PrintOutput("Repos behind remote :", len(ReposAhead))
            for repo in ReposBehind:
                PrintOutput(indentText(1, getRepoName(repo)))

        if ReposPulled:
            PrintOutput("")
            PrintOutput("Repos pulled :", len(ReposPulled))
            for repo in ReposPulled:
                PrintOutput(indentText(1, getRepoName(repo)))

        if ReposFetched:
            PrintOutput("")
            PrintOutput("Repos fetched :", len(ReposFetched))
            for kvp in ReposFetched:
                repo = kvp[0]
                branchName = kvp[1]
                PrintOutput(indentText(1, getRepoName(repo), ":", branchName))


if __name__ == '__main__':
    _main()
