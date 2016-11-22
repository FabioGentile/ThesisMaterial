#!/usr/bin/env python3
from utility import *


def get_uid_detail(uid_map, uid, app_name=""):
    """
    Get an object from the uid_map, if does not exists insert it. If the parameter app_name is not specified
    the insertion step (in case the uid is not present) will not be performed
    :param uid_map: dict {uid : UidDetail}
    :param uid: int that represent the app
    :param app_name: Optional name to be used in insertion
    :return: UidDetail if found or created, None if not found while
    """
    ret = uid_map.get(uid, None)
    if (ret is None) and (app_name != ""):
        # Insert only if its not found AND an app_name is provided
        # logger.debug("Found new app: " + app_name + "[" + str(uid) + "]")
        ret = UidDetail(uid, app_name)
        uid_map[uid] = ret

    return ret


class UidDetail:

    def __init__(self, uid, app_name):
        super().__init__()
        self.uid = uid
        self.app_name = app_name

        self.all_power = 0
        self.lcd_power = 0
        self.cpu_power = 0
        self.wifi_power = 0

        # In theese lists there must be tuples (iteration#, power consumed)
        self.lcd_list = []
        self.cpu_list = []
        self.wifi_list = []

    def add_lcd_data(self, iteration, energy):
        fill_list(self.lcd_list, str_to_int(iteration))
        self.lcd_list.append((str_to_int(iteration), str_to_int(energy)))
        self.lcd_power += str_to_int(energy)
        self.all_power += str_to_int(energy)
        pass

    def add_cpu_data(self, iteration, energy):
        fill_list(self.cpu_list, str_to_int(iteration))
        self.cpu_list.append((str_to_int(iteration), str_to_int(energy)))
        self.cpu_power += str_to_int(energy)
        self.all_power += str_to_int(energy)
        pass

    def add_wifi_data(self, iteration, energy):
        fill_list(self.wifi_list, str_to_int(iteration))
        self.wifi_list.append((str_to_int(iteration), str_to_int(energy)))
        self.wifi_power += str_to_int(energy)
        self.all_power += str_to_int(energy)
        pass


