#!/usr/bin/python3
import json
import os

from catalog_validation.items.catalog import get_items_in_trains, retrieve_train_names, retrieve_trains_data


def get_trains() -> dict:
    location: str = os.getcwd()
    preferred_trains: list = []

    trains_to_traverse = retrieve_train_names(location)
    items = get_items_in_trains(trains_to_traverse, location)

    return retrieve_trains_data(items, location, preferred_trains, trains_to_traverse)[0]


if __name__ == '__main__':
    with open('catalog.json', 'w') as f:
        f.write(json.dumps(get_trains(), indent=4))
