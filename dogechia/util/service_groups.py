from typing import KeysView, Generator

SERVICES_FOR_GROUP = {
    "all": "dogechia_harvester dogechia_timelord_launcher dogechia_timelord dogechia_farmer dogechia_full_node dogechia_wallet".split(),
    "node": "dogechia_full_node".split(),
    "harvester": "dogechia_harvester".split(),
    "farmer": "dogechia_harvester dogechia_farmer dogechia_full_node dogechia_wallet".split(),
    "farmer-no-wallet": "dogechia_harvester dogechia_farmer dogechia_full_node".split(),
    "farmer-only": "dogechia_farmer".split(),
    "timelord": "dogechia_timelord_launcher dogechia_timelord dogechia_full_node".split(),
    "timelord-only": "dogechia_timelord".split(),
    "timelord-launcher-only": "dogechia_timelord_launcher".split(),
    "wallet": "dogechia_wallet dogechia_full_node".split(),
    "wallet-only": "dogechia_wallet".split(),
    "introducer": "dogechia_introducer".split(),
    "simulator": "dogechia_full_node_simulator".split(),
}


def all_groups() -> KeysView[str]:
    return SERVICES_FOR_GROUP.keys()


def services_for_groups(groups) -> Generator[str, None, None]:
    for group in groups:
        for service in SERVICES_FOR_GROUP[group]:
            yield service


def validate_service(service: str) -> bool:
    return any(service in _ for _ in SERVICES_FOR_GROUP.values())
