"""
Defines how CORE will be built for installation.
"""

import glob
import os

from setuptools import setup, find_packages
from distutils.command.install import install


def recursive_files(data_path, files_path):
    data_files = []
    for path, directories, filenames in os.walk(files_path):
        directory = os.path.join(data_path, path)
        files = []
        for filename in filenames:
            files.append(os.path.join(path, filename))
        data_files.append((directory, files))
    return data_files


def glob_files(glob_path):
    return glob.glob(glob_path)


class CustomInstall(install):
    user_options = install.user_options + [
        ("service=", None, "determine which service file to include")
    ]

    def initialize_options(self):
        install.initialize_options(self)
        self.service = "sysv"

    def finalize_options(self):
        install.finalize_options(self)
        assert self.service in ("sysv", "systemd"), "must be sysv or systemd"

    def run(self):
        if self.service == "sysv":
            self.distribution.data_files.append((
                "/etc/init.d", ["../scripts/core-daemon"]
            ))
        else:
            self.distribution.data_files.append((
                "/etc/systemd/system", ["../scripts/core-daemon.service"]
            ))
        install.run(self)


setup(
    name="core",
    version="5.1",
    packages=find_packages(),
    install_requires=[
        "enum34",
    ],
    tests_require=[
        "pytest",
        "pytest-runner",
        "pytest-cov",
        "mock",
    ],
    data_files=[
        ("/etc/core", [
            "data/core.conf", 
            "data/xen.conf",
            "data/logging.conf",
        ]),
        ("/usr/local/share/man/man1", glob_files("../doc/man/**.1")),
    ] + recursive_files("/usr/local/share/core", "examples"),
    scripts=[
        "sbin/core-cleanup",
        "sbin/core-daemon",
        "sbin/core-manage",
        "sbin/coresendmsg",
        "sbin/core-xen-cleanup",
    ],
    description="Python components of CORE",
    url="http://www.nrl.navy.mil/itd/ncs/products/core",
    author="Boeing Research & Technology",
    author_email="core-dev@nrl.navy.mil",
    license="BSD",
    long_description="Python scripts and modules for building virtual emulated networks.",
    cmdclass={
        "install": CustomInstall
    }
)
