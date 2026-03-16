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


def print_error(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs, flush=True)


def print_output(*args, **kwargs):
    print(*args, **kwargs, flush=True)


def indent_text(level, *text, indent_size=2):
    return str(' ' * (indent_size * level)) + ' '.join(str(x) for x in text)


class RunConfig:
    DefaultPrimaryBranches = ["main", "master", "wikiMaster", "primary"]
    DefaultRemotes = ["origin", "azure", "devops"]


class RunSummary:
    all_repos                                = []
    repos_printed                            = []
    non_git_directories                      = []
    repos_in_error                           = []
    repos_with_issues                        = []
    repos_with_local_branches_over_threshold = []
    repos_not_on_primary_branch              = []
    repos_with_uncommitted                   = []
    repos_ahead                              = []
    repos_behind                             = []
    repos_pulled                             = []
    repos_fetched                            = []


class MyParser(ArgumentParser):
    def error(self, message):
        self.print_help()
        print_error('\nERROR: %s\n' % message)
        sys.exit(2)


class CustomProgressPrinter(git.RemoteProgress):

    def __init__(self, activity_message=""):
        self.progress = Progress()
        self.downloadTask = self.progress.add_task(f"[yellow]{activity_message}...", total=100)
        self.updatesMade = 0
        super().__init__()

    # noinspection PyUnusedLocal
    def update(self, op_code, cur_count, max_count=None, message=""):
        percent_complete = min(cur_count / (max_count or 100.0), 100.00)
        self.progress.update(self.downloadTask, completed=percent_complete)


@contextlib.contextmanager
def push_directory(new_dir):
    previous_dir = os.getcwd()
    os.chdir(new_dir)
    try:
        yield
    finally:
        os.chdir(previous_dir)


# noinspection PyBroadException
def is_git_repo(dir_name):
    try:
        git.Repo(dir_name)
    except:
        return False
    else:
        return True


def get_repo_name(repo):
    path = repo.working_dir
    return os.path.basename(path)


# noinspection PyBroadException
def does_git_branch_exist(repo, branch_name):
    try:
        repo.heads[branch_name]
    except:
        return False
    else:
        return True


def get_git_remotes(repo):
    return repo.remotes


# noinspection PyBroadException
def does_git_remote_exist(repo, remote_name):
    try:
        repo.remotes[remote_name]
    except:
        return False
    else:
        return True


def is_git_remote_valid(repo, remote_name):
    if not does_git_remote_exist(repo, remote_name):
        return False

    remote = repo.remotes[remote_name]

    return remote.exists()


def get_git_current_branch(repo):
    return repo.head.ref.name


def get_git_primary_branch(repo):
    for primaryBranchName in RunConfig.DefaultPrimaryBranches:
        if does_git_branch_exist(repo, primaryBranchName):
            return repo.heads[primaryBranchName]

    return None


def is_git_branch_primary(branch_name):
    for primaryBranchName in RunConfig.DefaultPrimaryBranches:
        if branch_name == primaryBranchName:
            return True

    return False


def get_git_primary_remote(repo):
    for remote_name in RunConfig.DefaultRemotes:
        if does_git_remote_exist(repo, remote_name):
            return repo.remotes[remote_name]

    return None


def get_git_local_branches(repo):
    return repo.branches


def get_local_non_primary_branches(repo):
    local_non_primary_branches = []
    for branch in get_git_local_branches(repo):
        if not is_git_branch_primary(branch.name):
            local_non_primary_branches.append(branch.name)

    return local_non_primary_branches


def read_csv_file(file_name, delimiter=",", quote_char='"'):
    records = []
    with open(file_name) as csvFile:
        csv_reader = csv.reader(csvFile, delimiter=delimiter, quotechar=quote_char)
        for row in csv_reader:
            records.append(row)

    return records


def read_notes(dir_name, notes_file_name):
    notes = {}

    if notes_file_name:
        with push_directory(dir_name):
            file_name = os.path.join(dir_name, notes_file_name)
            if os.path.exists(file_name):
                records = read_csv_file(file_name)
                for record in records:
                    notes[record[0]] = record[1]

    return notes


def process_all_repos_under_dir_from_dir(dir_name, args, indent=0):
    with push_directory(dir_name):
        container_dirs = glob.glob(args.directory_wildcard)
        print_output(indent_text(indent, "Found", len(container_dirs), "container directories"))

        index = 0
        for container_dir in container_dirs:
            if os.path.isdir(container_dir):
                print_output(indent_text(indent, "Container:", container_dir))
                index += 1
                process_all_repos_under_dir(container_dir, args, indent + 1)


def process_all_repos_under_dir(dir_name, args, indent=0):
    with push_directory(dir_name):
        notes = read_notes(dir_name, args.notes_csv_filename)
        sub_dirs = glob.glob(args.directory_wildcard)
        print_output(indent_text(indent, "Found", len(sub_dirs), "directories"))

        index = 0
        for sub_dir in sub_dirs:
            if os.path.isdir(sub_dir):
                index += 1
                process_dir(sub_dir, args, index=index, indent=indent + 1, notes=notes)


def process_tree(dir_name, args, indent=0):
    with push_directory(dir_name):
        notes = read_notes(dir_name, args.notes_csv_filename)
        sub_dirs = glob.glob(args.directory_wildcard)
        print_output(indent_text(indent, "Found", len(sub_dirs), "directories"))

        index = 0
        for sub_dir in sub_dirs:
            if os.path.isdir(sub_dir):
                if is_git_repo(sub_dir):
                    index += 1
                    process_dir(sub_dir, args, index=index, indent=indent + 1, notes=notes)
                else:
                    process_tree(sub_dir, args, indent=indent + 1)


def process_dir(dir_name, args, index=0, indent=1, notes=None):
    if notes is None:
        notes = {}
    with push_directory(dir_name):
        if not is_git_repo("."):
            RunSummary.non_git_directories.append(dir_name)
            return

        output_lines = []

        repo_text = f"{dir_name}"
        if args.showRepoIndex and index > 0:
            repo_text = f"{index}: {dir_name}"

        repo_identifier = indent_text(indent, f"{repo_text}")

        # Access repo
        repo_name = dir_name
        repo = git.Repo(".")
        RunSummary.all_repos.append(repo)

        # Determine current state
        primary_branch = get_git_primary_branch(repo)
        current_branch = get_git_current_branch(repo)
        primary_remote = get_git_primary_remote(repo)

        # Determine Notes
        note_wip = None
        if repo_name in notes.keys():
            note_wip = notes[repo_name]

        # Determine Primary Branch status
        is_on_primary_branch = is_git_branch_primary(current_branch)
        ahead = 0
        behind = 0
        local_non_primary_branches = get_local_non_primary_branches(repo)
        if len(local_non_primary_branches) == 1 and local_non_primary_branches[0] == current_branch:
            local_non_primary_branches = []

        # Determine Repo status
        repo_status = ""
        try:
            repo_status = repo.git.status(porcelain="v2", branch=True)
        except Exception as ex:
            RunSummary.repos_with_issues.append(repo)
            print_error("WARNING: Error accessing repo: %s - %s" % repo_name, ex)
            repo_status = ""
        ahead_behind_match = re.search(r"#\sbranch\.ab\s\+(\d+)\s-(\d+)", repo_status)

        # Determine if Ahead or Behind
        if ahead_behind_match:
            ahead = int(ahead_behind_match.group(1))
            behind = int(ahead_behind_match.group(2))

        if ahead:
            RunSummary.repos_ahead.append(repo)
        if behind:
            RunSummary.repos_ahead.append(repo)

        if args.warnLocalNonPrimaryBranches and len(local_non_primary_branches) > args.warnLocalNonPrimaryBranches:
            RunSummary.repos_with_local_branches_over_threshold.append(repo)

        ##############################
        ## Display

        # Show Notes ?
        if args.showNotes:
            if note_wip:
                output_lines.append(indent_text(indent + 1, f"Note: {note_wip}"))

        # Show Branch on Primary ?
        show_branch = (is_on_primary_branch and args.showOnPrimary)
        if show_branch:
            output_lines.append(indent_text(indent + 1, f"Current: {current_branch}"))

        show_branch = (not is_on_primary_branch and args.showOnNonPrimary)
        if show_branch:
            RunSummary.repos_not_on_primary_branch.append(repo)
            output_lines.append(indent_text(indent + 1, f"Current: {current_branch}"))

        # Show Out of Date (Ahead / Behind) ?
        if args.showOutOfDate:
            if ahead:
                output_lines.append(indent_text(indent + 1, f"Ahead by {ahead} commits"))
            if behind:
                output_lines.append(indent_text(indent + 1, f"Behind by {behind} commits"))

        # Show Untracked / uncommitted
        if args.showUncommittedFiles:
            untracked_output = []

            if repo.index.diff(None):
                for file in repo.index.diff(None):
                    if file.a_path == file.b_path:
                        untracked_output.append(indent_text(indent + 2, f"Not Staged: {file.b_path}"))
                    else:
                        untracked_output.append(indent_text(indent + 2, f"Not Staged: {file.a_path} -> {file.b_path}"))

            if repo.untracked_files:
                for file in repo.untracked_files:
                    untracked_output.append(indent_text(indent + 2, f"Untracked: {file}"))

            if untracked_output:
                RunSummary.repos_with_uncommitted.append(repo)
                for line in untracked_output:
                    output_lines.append(line)

        # Show Local Branches ?
        if args.showLocalNonPrimaryBranches:
            for branchName in local_non_primary_branches:
                output_lines.append(indent_text(indent + 1, f"Branch: {branchName}"))

        ##############################
        # Actions

        # Pull from remote ?
        remote = None
        pulling = False
        fetch_specs = {}

        if (args.pullOnPrimary or args.pullOnNonPrimary) and behind:
            remote = get_git_primary_remote(repo)
            if remote:
                if not is_git_remote_valid(repo, remote.name):
                    output_lines.append(indent_text(indent + 1, "ERROR: Remote not accessible"))
                else:
                    primary_branch_name = get_git_primary_branch(repo)
                    if primary_branch_name:
                        primary_branch_name = primary_branch_name.name

                if args.pullOnPrimary and repo.head.ref.name == primary_branch_name:
                    pulling = True

                if args.pullOnNonPrimary and repo.head.ref.name != primary_branch_name:
                    pulling = True

        if args.fetchPrimary:
            remote = get_git_primary_remote(repo)
            if remote:
                primary_branch_names = RunConfig.DefaultPrimaryBranches
                if args.primary_branch:
                    primary_branch_names.clear()
                    primary_branch_names.append(args.primary_branch)

                for primary_branch_name in primary_branch_names:
                    if does_git_branch_exist(repo, primary_branch_name):
                        current_branch = get_git_current_branch(repo)
                        if primary_branch_name != current_branch:
                            fetch_specs[primary_branch_name] = primary_branch_name

        # If there is output for this repo, then print it now
        if output_lines:
            RunSummary.repos_printed.append(repo)
            print_output(repo_identifier)
            for line in output_lines:
                print_output(line)

        # Pull commits from remote
        if pulling:
            try:
                RunSummary.repos_pulled.append(repo)
                print_output(indent_text(indent + 1, "Pulling..."))
                remote.pull(progress=CustomProgressPrinter("Pulling"))
            except Exception as e:
                output_lines.append(indent_text(indent + 1, f"ERROR: {e}"))
                RunSummary.repos_in_error.append(repo)

        # Fetch commits from remote branches
        if fetch_specs:
            try:
                for key, value in fetch_specs.items():
                    print_output(indent_text(indent + 1, f"Fetching {key} -> {value}"))
                    fetch_infos = remote.fetch(progress=CustomProgressPrinter("Fetching"), refspec=f"{key}:{value}")
                    for fetchInfo in fetch_infos:
                        if not (fetchInfo.flags & fetchInfo.HEAD_UPTODATE):
                            RunSummary.repos_fetched.append((repo, key))
                            break

            except Exception as e:
                output_lines.append(indent_text(indent + 1, f"ERROR: {e}"))
                RunSummary.repos_in_error.append(repo)


def _main():
    processing_modes = ['repo', 'dir_of_repos', 'dir_of_dir_of_repos', 'tree']
    show_notes_modes = ['no', 'primary', 'always']

    parser = MyParser(description="Analyse GIT repos")
    parser.add_argument("-v",   "--version",            action='version',           version='%(prog)s 1.2')
    parser.add_argument("-d",   "--directory",          dest="directory",           required=True,
                        help="The directory to analyze")
    parser.add_argument("-m",   "--mode",               dest="mode",                default='repo',     choices=processing_modes,
                        help="The processing mode")
    parser.add_argument("-w",   "--directory-wildcard", dest="directory_wildcard",  default="*",
                        help="The wildcard directory pattern to use for repo directory selection")
    parser.add_argument("-b", "--primary-branch",       dest="primary_branch",
                        help="The branch name to use as primary")
    parser.add_argument("-o", "--default-origins",      dest="default_origins",
                        help="The origin names to use by default")
    parser.add_argument("-nfn", "--notes-csv-filename", dest="notes_csv_filename",
                        help="The filename containing notes for each repo (in the parent directory)")

    group = parser.add_argument_group('Processing Options')
    group.add_argument("-sri",  "--show-repo-index",                    dest="showRepoIndex",       default=False,      action='store_true',
                        help="Show index number of Repo")
    group.add_argument("-sop", "--show-on-primary-branch",              dest="showOnPrimary",       default=False, action='store_true',
                       help="Show details if on primary branch")
    group.add_argument("-sonp", "--show-on-non-primary-branch",         dest="showOnNonPrimary",    default=False,
                       action='store_true', help="Show details if on non-primary branch")
    group.add_argument("-sood", "--show-out-of-date",                   dest="showOutOfDate",       default=False, action='store_true',
                       help="Show Out of Date commits")
    group.add_argument("-pop", "--pull-on-primary-branch",              dest="pullOnPrimary",       default=False, action='store_true',
                       help="Pull if on primary branch")
    group.add_argument("-ponp", "--pull-on-non-primary-branch",         dest="pullOnNonPrimary",    default=False,
                       action='store_true', help="Pull if on non-primary branch")
    group.add_argument("-fpb", "--fetch-primary-branches",              dest="fetchPrimary",        default=False, action='store_true',
                       help="Fetch any local primary branch(es)")
    group.add_argument("-suc", "--show-uncommitted-files",              dest="showUncommittedFiles", default=False,
                       action='store_true', help="Show any uncommitted files (WIP)")
    group.add_argument("-slnpb", "--show-local-non-primary-branches",   dest="showLocalNonPrimaryBranches", default=False,
                       action='store_true', help="Show any local non-Primary branches")
    group.add_argument("-wlnpb", "--warn-local-non-primary-branches",   dest="warnLocalNonPrimaryBranches", default=0,
                       type=int, choices=range(0, 11),
                       help="Warn if count of local non-Primary branches exceeds threshold")
    group.add_argument("-snpr", "--show-non-primary-remotes", dest="showNonPrimaryRemotes", default=False,
                       action='store_true', help="Show any non-Primary remotes")
    group.add_argument("-sn", "--show-notes", dest="showNotes", default='always', choices=show_notes_modes,
                       help="Show any supporting notes")
    group.add_argument("-ns", "--no-summary", dest="showSummary", default=True, action='store_false',
                       help="Show a summary of processing")

    # Parse
    args = parser.parse_args()

    # Process
    match args.mode:
        case 'repo':
            process_dir(args.directory, args)
        case 'dir_of_repos':
            process_all_repos_under_dir(args.directory, args)
        case 'dir_of_dir_of_repos':
            process_all_repos_under_dir_from_dir(args.directory, args)
        case 'tree':
            process_tree(args.directory, args)
        case _:
            raise Exception(f"Unexpected or currently unsupported 'mode': {args.mode}")

    if args.showSummary:
        print_output("")
        print_output("Summary")
        print_output("=======")
        print_output("Total Repos :", len(RunSummary.all_repos))

        if RunSummary.repos_printed:
            print_output("")
            print_output("Repos printed :", len(RunSummary.repos_printed))

        if RunSummary.non_git_directories:
            print_output("")
            print_output("Non-git Directories :", len(RunSummary.non_git_directories))
            for dir_name in RunSummary.non_git_directories:
                print_output("  ", dir_name)

        if RunSummary.repos_in_error:
            print_output("")
            print_output("Repos in Error :", len(RunSummary.repos_in_error))
            for repo in RunSummary.repos_in_error:
                print_output(indent_text(1, get_repo_name(repo)))

        if RunSummary.repos_with_issues:
            print_output("")
            print_output("Repos with Issues:", len(RunSummary.repos_with_issues)),
            for repo in RunSummary.repos_with_issues:
                print_output(indent_text(1, get_repo_name(repo)))

        if RunSummary.repos_with_local_branches_over_threshold:
            threshold = args.warnLocalNonPrimaryBranches
            print_output("")
            print_output(f"Repos with Local Branches over Threshold ({threshold}) :",
                         len(RunSummary.repos_with_local_branches_over_threshold))
            for repo in RunSummary.repos_with_local_branches_over_threshold:
                print_output(indent_text(1, get_repo_name(repo)))

        if RunSummary.repos_not_on_primary_branch:
            print_output("")
            print_output("Repos not on Primary Branch :", len(RunSummary.repos_not_on_primary_branch))
            for repo in RunSummary.repos_not_on_primary_branch:
                print_output(indent_text(1, get_repo_name(repo)))

        if RunSummary.repos_with_uncommitted:
            print_output("")
            print_output("Repos with uncommitted files :", len(RunSummary.repos_with_uncommitted))
            for repo in RunSummary.repos_with_uncommitted:
                print_output(indent_text(1, get_repo_name(repo)))

        if RunSummary.repos_ahead:
            print_output("")
            print_output("Repos ahead of remote :", len(RunSummary.repos_ahead))
            for repo in RunSummary.repos_ahead:
                print_output(indent_text(1, get_repo_name(repo)))

        if RunSummary.repos_behind:
            print_output("")
            print_output("Repos behind remote :", len(RunSummary.repos_ahead))
            for repo in RunSummary.repos_behind:
                print_output(indent_text(1, get_repo_name(repo)))

        if RunSummary.repos_pulled:
            print_output("")
            print_output("Repos pulled :", len(RunSummary.repos_pulled))
            for repo in RunSummary.repos_pulled:
                print_output(indent_text(1, get_repo_name(repo)))

        if RunSummary.repos_fetched:
            print_output("")
            print_output("Repos fetched :", len(RunSummary.repos_fetched))
            for kvp in RunSummary.repos_fetched:
                repo = kvp[0]
                branch_name = kvp[1]
                print_output(indent_text(1, get_repo_name(repo), ":", branch_name))


if __name__ == '__main__':
    _main()
