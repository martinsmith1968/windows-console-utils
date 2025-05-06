import git
import time
from git import RemoteProgress
from git import Repo
from rich.progress import Progress

class CloneProgress(RemoteProgress):
    def __init__(self):
        self.progress = Progress()
        self.downloadTask = self.progress.add_task("[yellow]Pulling...", total=100)
        super().__init__()

    def update(self, op_code, cur_count, max_count=None, message=""):
        percent_complete = min((cur_count / (max_count or 100.0)) * 100, 100.00)
        print(f"Percent: {percent_complete}")
        self.progress.update(self.downloadTask, completed=percent_complete)
        time.sleep(0.05)



import git
from rich import console, progress


class GitRemoteProgress(git.RemoteProgress):
    OP_CODES = [
        "BEGIN",
        "CHECKING_OUT",
        "COMPRESSING",
        "COUNTING",
        "END",
        "FINDING_SOURCES",
        "RECEIVING",
        "RESOLVING",
        "WRITING",
    ]
    OP_CODE_MAP = {
        getattr(git.RemoteProgress, _op_code): _op_code for _op_code in OP_CODES
    }

    def __init__(self) -> None:
        super().__init__()
        self.progressbar = progress.Progress(
            progress.SpinnerColumn(),
            # *progress.Progress.get_default_columns(),
            progress.TextColumn("[progress.description]{task.description}"),
            progress.BarColumn(),
            progress.TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
            "eta",
            progress.TimeRemainingColumn(),
            progress.TextColumn("{task.fields[message]}"),
            console=console.Console(),
            transient=False,
        )
        self.progressbar.start()
        self.active_task = None

    def __del__(self) -> None:
        # logger.info("Destroying bar...")
        self.progressbar.stop()

    @classmethod
    def get_curr_op(cls, op_code: int) -> str:
        """Get OP name from OP code."""
        # Remove BEGIN- and END-flag and get op name
        op_code_masked = op_code & cls.OP_MASK
        return cls.OP_CODE_MAP.get(op_code_masked, "?").title()

    def update(
        self,
        op_code: int,
        cur_count: str | float,
        max_count: str | float | None = None,
        message: str | None = "",
    ) -> None:
        #print(f"cur: {cur_count}, max: {max_count}, message: {message}")
        # Start new bar on each BEGIN-flag
        if op_code & self.BEGIN:
            self.curr_op = self.get_curr_op(op_code)
            # logger.info("Next: %s", self.curr_op)
            self.active_task = self.progressbar.add_task(
                description=self.curr_op,
                total=max_count,
                message=message,
            )

        self.progressbar.update(
            task_id=self.active_task,
            completed=cur_count,
            message=message,
        )

        # End progress monitoring on each END-flag
        if op_code & self.END:
            # logger.info("Done: %s", self.curr_op)
            self.progressbar.update(
                task_id=self.active_task,
                message=f"[bright_black]{message}",
            )




local_repo = Repo.clone_from("https://github.com/martinsmith1968/DNX.Helpers.git", "DNX.Helpers", progress=GitRemoteProgress())

exit()



repo = git.Repo(".")
currentBranch = repo.head.ref.name
print(f"Current branch: {currentBranch}")

remote = repo.remotes["origin"]

list = []
list.append(None)
#list.append("main:main")
list.append("master:master")

for refSpec in list:
    print(f"Pulling: {refSpec}")
    remote.pull(progress=CloneProgress(), refspec=refSpec)
