#!/usr/bin/python3

"""This fabric script generates a .tgz archive from the contents of the
web_static folder of the AirBnB Clone repo."""

import os
from datetime import datetime
from fabric.api import local
from fabric.api import env
from fabric.api import run
from fabric.api import put

env.hosts = ["web-01.lzcorp.tech", "web-02.lzcorp.tech"]
env.user = "ubuntu"
env.key_filename = "~/.ssh/alx-server-key.pem"


def do_pack():
    """Generates a .tgz archive from the contents of the web_static folder."""
    local("mkdir -p versions")
    date = datetime.now().strftime("%Y%m%d%H%M%S")
    file_path = f"versions/web_static_{date}.tgz"
    if os.path.exists("web_static") is False:
        return None

    local(f"tar -cvzf {file_path} web_static")
    return file_path


def do_deploy(archive_path: str) -> bool:
    """Distributes an archive to your web servers.

    Args:
        archive_path (str): Path to the archive to deploy.

    Returns:
        bool: True if all operations were successful, False otherwise.
    """
    if not archive_path:
        return False

    if os.path.exists(archive_path) is False:
        return False

    archive_name = archive_path.split("/")[-1]
    archive_name_no_ext = archive_name.split(".")[0]

    put(archive_path, "/tmp/")
    run(f"mkdir -p /data/web_static/releases/{archive_name_no_ext}/")
    run(
        f"tar -xzf /tmp/{archive_name} -C "
        f"/data/web_static/releases/{archive_name_no_ext}/"
    )
    run(f"rm /tmp/{archive_name}")
    run(
        f"mv /data/web_static/releases/{archive_name_no_ext}/web_static/* "
        f"/data/web_static/releases/{archive_name_no_ext}/"
    )
    run(f"rm -rf /data/web_static/releases/{archive_name_no_ext}/web_static")
    run("rm -rf /data/web_static/current")
    run(
        f"ln -s /data/web_static/releases/{archive_name_no_ext}/ "
        "/data/web_static/current"
    )

    print("New version deployed!")
    return True


def deploy():
    """Creates and distributes an archive to your web servers."""
    if not archive_path:
        return False

    return do_deploy(archive_path)


def do_clean(number=0) -> None:
    """Deletes out-of-date archives locally and on remote servers.

    Args:
        number (int): Number of archives to keep. If 0 or 1, keep only the most
        recent version.
    """
    number = int(number)
    if number < 0:
        return

    archives = sorted(os.listdir("versions"))
    server_archives = run("ls /data/web_static/releases").split()

    if number in (0, 1):
        _ = [local(f"rm versions/{archive}") for archive in archives[:-1]]
        _ = [
            run(f"rm -rf /data/web_static/releases/{archive}")
            for archive in server_archives[:-1]
        ]
        return

    _ = [local(f"rm versions/{archive}") for archive in archives[:-number]]
    _ = [
        run(f"rm -rf /data/web_static/releases/{archive}")
        for archive in server_archives[:-number]
    ]


archive_path = do_pack()
