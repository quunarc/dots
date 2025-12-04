import os
from ranger.api.commands import Command

class quit_and_cd(Command):
    def execute(self):
        with open("/tmp/cd_ranger", "w") as f:
            f.write(os.path.abspath(self.fm.thisdir.path))
        # same as quitall_bang (:quitall!)
        self.fm.exit()
