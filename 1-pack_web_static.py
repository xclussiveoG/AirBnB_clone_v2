#!/usr/bin/python3

"""This fabric script generates a .tgz archive from the contents of the
web_static folder of the AirBnB Clone repo."""

import os
from datetime import datetime
from fabric.api import local


def do_pack():
    """Generates a .tgz archive from the contents of the web_static folder."""
    local("mkdir -p versions")
    date = datetime.now().strftime("%Y%m%d%H%M%S")
    file_path = f"versions/web_static_{date}.tgz"
    if os.path.exists('web_static') is False:
        return None

    local(f"tar -cvzf {file_path} web_static")
    return file_path
