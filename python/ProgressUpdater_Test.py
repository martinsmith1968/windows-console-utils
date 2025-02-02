import time

from rich.progress import Progress


with Progress() as progress:

    task1 = progress.add_task("[red]Downloading...", total=1000)
    task2 = progress.add_task("[green]Processing...", total=1000)
    task3 = progress.add_task("[cyan]Cooking...", total=1000)
    task4 = progress.add_task("[yellow]Buffering...", total=1000)
    task5 = progress.add_task("[blue]Percent...", total=100)

    percent = 0.0

    while not progress.finished:
        percent += 0.1
        progress.update(task1, advance=0.5)
        progress.update(task2, advance=0.3)
        progress.update(task3, advance=0.9)
        progress.update(task4, advance=0.2)
        progress.update(task5, completed=percent)
        time.sleep(0.02)
