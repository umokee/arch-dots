from shared.lib import add_packages


def apply(conf, helpers):
    add_packages(
        "linux",
        "linux-headers",
        "nvidia-open",
    )
