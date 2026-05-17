import os
import socket
import sys

import decman

from modules import cachyos
from modules.home.default import apply as apply_home
from modules.local import current_minimal_baseline
from modules.system.default import apply as apply_system
from shared.config import HOSTS
from shared.helpers import Helpers

decman.aur.ignored_packages |= {"decman", "yay"}

ROOT = os.path.dirname(__file__)
sys.path.insert(0, ROOT)

host = os.environ.get("DEC_HOST") or socket.gethostname()
if host not in HOSTS:
    raise RuntimeError(f"Unknown DEC_HOST/hostname: {host}. Known: {', '.join(HOSTS)}")
conf = HOSTS[host]
helpers = Helpers(conf)

current_minimal_baseline.apply(conf, helpers)

cachyos.apply(conf, helpers)
apply_system(conf, helpers)
apply_home(conf, helpers)
