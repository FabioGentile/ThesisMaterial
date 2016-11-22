#!/usr/bin/env python3
import argparse
import pickle
import os.path
import coloredlogs
from utility import *

from uiddetail import get_uid_detail

"""
TAG USED IN LOGFILE
All energy values are in mW on a period of 1 second -> mJ
"""
# <editor-fold desc="General">
LOGFILE_NAME = "PowerTrace.log"
CACHE_FILE_NAME = "cache"
SETTINGS_FILE_NAME = "settings.ini"
CSV_FILE_NAME = "out.csv"
ITERATION_TERMINATOR = "------ END OF ITERATION ------"
ITERATION_TAG = "begin"
BATT_CURRENT_TAG = "batt_current"  # mAh
ALL_APP_TAG = "ALL"
# </editor-fold>

# <editor-fold desc="LCD">
LCD_TAG = "LCD"
LCD_BRIGHTNESS_TAG = "brightness"  # 0-255
LCD_SCREEN_STATUS_TAG = "screen-on"  # Boolean
# </editor-fold>

# <editor-fold desc="CPU">
CPU_TAG = "CPU"
CPU_USR_TAG = "usr"  # %
CPU_SYS_TAG = "sys"  # %
CPU_FREQ_TAG = "freq"  # MHz
# </editor-fold>

# <editor-fold desc="WIFI">
WIFI_TAG = "Wifi"
WIFI_STATUS_TAG = "on"  # Boolean
WIFI_PACKETS_TAG = "packets"  # Packet exchanges number
WIFI_UP_BYTES_TAG = "uplinkBytes"  # Bytes sent
WIFI_DOWN_BYTES_TAG = "downlinkBytes"  # Bytes received
WIFI_UPLINK_TAG = "uplink"  # Uplink rate Mbps
WIFI_SPEED_TAG = "speed"  # Link rate Mbps
WIFI_PWER_STATE_TAG = "state"  # Power state (LOW | HIGH)
# </editor-fold>


# Dict used to store UidDetail
uid_info = {}


def build_cache():
    iteration_number = 0
    iteration_started = False

    with open(LOGFILE_NAME, 'r') as f:
        for line in f:
            line = line.rstrip("\n")
            token = line.split('+')  # '+' is the separator used in power tutor

            # Search the iteration begin
            if not iteration_started:
                if token[0] == ITERATION_TAG:
                    # print("Inizia l'iterazione ", token[1])
                    iteration_number = token[1]
                    iteration_started = True
                    continue
                else:
                    continue

            if token[0] == LCD_TAG:
                if token[1] == LCD_BRIGHTNESS_TAG:
                    pass
                elif token[1] == LCD_SCREEN_STATUS_TAG:
                    pass
                elif token[1] == ALL_APP_TAG:
                    # Add information to UID -1
                    details = get_uid_detail(uid_info, -1, ALL_APP_TAG)
                    details.add_lcd_data(iteration_number, token[3])

                elif token[1].isdigit():
                    # Add information to generic UID
                    details = get_uid_detail(uid_info, str_to_int(token[1]), token[2])
                    details.add_lcd_data(iteration_number, token[3])

                else:
                    logger.error("String not correctly formatted: " + line)
                    sys.exit(-1)

            elif token[0] == CPU_TAG:
                if token[1] == CPU_USR_TAG:
                    pass
                elif token[1] == CPU_SYS_TAG:
                    pass
                elif token[1] == CPU_FREQ_TAG:
                    pass

                elif token[1] == ALL_APP_TAG:
                    # Add information to UID -1
                    details = get_uid_detail(uid_info, -1, ALL_APP_TAG)
                    details.add_cpu_data(iteration_number, token[3])

                elif token[1].isdigit():
                    # Add information to generic UID
                    details = get_uid_detail(uid_info, str_to_int(token[1]), token[2])
                    details.add_cpu_data(iteration_number, token[3])

                else:
                    logger.errpr("String not correctly formatted: " + line)
                    sys.exit(-1)

            elif token[0] == WIFI_TAG:
                if token[1] == WIFI_TAG:
                    pass
                elif token[1] == WIFI_STATUS_TAG:
                    pass
                elif token[1] == WIFI_PACKETS_TAG:
                    pass
                elif token[1] == WIFI_UP_BYTES_TAG:
                    pass
                elif token[1] == WIFI_DOWN_BYTES_TAG:
                    pass
                elif token[1] == WIFI_UPLINK_TAG:
                    pass
                elif token[1] == WIFI_SPEED_TAG:
                    pass
                elif token[1] == WIFI_PWER_STATE_TAG:
                    pass

                elif token[1] == ALL_APP_TAG:
                    # Add information to UID -1
                    details = get_uid_detail(uid_info, -1, ALL_APP_TAG)
                    details.add_wifi_data(iteration_number, token[3])

                elif token[1].isdigit():
                    # Add information to generic UID
                    details = get_uid_detail(uid_info, str_to_int(token[1]), token[2])
                    details.add_wifi_data(iteration_number, token[3])

                else:
                    logger.errpr("String not correctly formatted: " + line)
                    sys.exit(-1)

            # Other tag
            elif token[0] == BATT_CURRENT_TAG:
                pass
            elif line == ITERATION_TERMINATOR:
                # print("Iterazione ", iteration_number, " terminata")
                iteration_started = False

    # Save data structure in cache
    with open(CACHE_FILE_NAME, 'wb') as f:
        pickle.dump(uid_info, f)


def analyze(uid, analyze_lcd, analyze_cpu, analyze_wifi):

    detail = get_uid_detail(uid_info, uid)
    if detail is None:
        logger.warn("UID (" + str(uid) + ") is not present")
        return
    logger.info("Analyze UID (" + str(uid) + ")")

    # <editor-fold desc="Input check">
    # Check if there are data for the requested component, otherwise deactivate it
    if len(detail.lcd_list) == 0:
        analyze_lcd = False
    if len(detail.cpu_list) == 0:
        analyze_cpu = False
    if len(detail.wifi_list) == 0:
        analyze_wifi = False

    # 2592000 is how many seconds there are in 30 days, it' just to be safe
    list_end = max(len(detail.lcd_list) if analyze_lcd else 0,
                   len(detail.cpu_list) if analyze_cpu else 0,
                   len(detail.wifi_list) if analyze_wifi else 0)

    list_start = min(str_to_int(detail.lcd_list[0][0]) if analyze_lcd else 2592000,
                     str_to_int(detail.cpu_list[0][0]) if analyze_cpu else 25920000,
                     str_to_int(detail.wifi_list[0][0]) if analyze_wifi else 25920000)

    # If all component are deactivated correct the range
    if (not analyze_lcd) and (not analyze_cpu) and (not analyze_wifi):
        list_start = 0
        list_end = 0
    # </editor-fold>

    logger.debug("Analyzing range (" + str(list_start) + "," + str(list_end) + ")")
    with open('out.csv', 'w') as outfile:
        # <editor-fold desc="HEADER">
        header = "Iteration,LCD,CPU,WIFI"

        outfile.write(header + "\n")
        # </editor-fold>

        for i in range(list_start, list_end):
            # <editor-fold desc="CSV DATA">
            line = str(i)

            if analyze_lcd:
                val = 0
                if i < len(detail.lcd_list):
                    val = detail.lcd_list[i][1]
                line += "," + str(val)
            else:
                line += ",0"
            if analyze_cpu:
                val = 0
                if i < len(detail.cpu_list):
                    val = detail.cpu_list[i][1]
                line += "," + str(val)
            else:
                line += ",0"
            if analyze_wifi:
                val = 0
                if i < len(detail.wifi_list):
                    val = detail.wifi_list[i][1]
                line += "," + str(val)
            else:
                line += ",0"

            outfile.write(line + "\n")
            # </editor-fold>

    logger.info("'" + CSV_FILE_NAME + "' generated. Written "
                + str(os.path.getsize(CSV_FILE_NAME)) + " bytes.")


def main():
    global uid_info
    coloredlogs.install(level='DEBUG', fmt="%(asctime)s %(levelname)s: %(message)s")

    # <editor-fold desc="ARGPARSE">
    formatter_class = lambda prog: argparse.HelpFormatter(prog, max_help_position=200, width=120)
    parser = argparse.ArgumentParser(description='Log parser for PowerTutor',
                                     formatter_class=formatter_class)

    parser.add_argument('-p', '--print-list', action='store_true',
                        help="Print a list of uid and appname")
    parser.add_argument('-f', '--force-generation', action='store_true',
                        help="Invalid the cache and force parsing logfile")
    parser.add_argument('-u', '--uid', action='store', default=-1, type=int, metavar="UID", dest='UID',
                        help="The selected UID to analyse. "
                             "This option is ignored when the -p option is also used. (Default value is -1 wich correspond to ALL app.)")
    parser.add_argument('-c', '--cpu', action='store_true',
                        help="Analyze CPU energy data. ")
    parser.add_argument('-l', '--lcd', action='store_true',
                        help="Analyze LCD energy data. ")
    parser.add_argument('-w', '--wifi', action='store_true',
                        help="Analyze WIFI energy data. ")

    # parser.add_argument('infile', nargs='?', type=argparse.FileType('r'))
    # parser.add_argument('outfile', nargs='?', type=argparse.FileType('w'))

    args = parser.parse_args()
    # logger.debug(args)
    # </editor-fold>

    # <editor-fold desc="FILE DECISION">
    logfile_last_mtime = 0
    logfile_present = False
    # Check if log file exists
    if os.path.isfile(LOGFILE_NAME):
        logfile_last_mtime = round(os.path.getmtime(LOGFILE_NAME))
        logfile_present = True

    cache_last_mtime = 0
    cache_file_present = False
    # Check if cache exists
    if os.path.isfile(CACHE_FILE_NAME):
        cache_last_mtime = round(os.path.getmtime(CACHE_FILE_NAME))
        cache_file_present = True

    if args.force_generation:
        cache_file_present = False
    # </editor-fold>

    # <editor-fold desc="CREATE CACHE">
    # Decide which file use
    if (not logfile_present) and (not cache_file_present):
        logger.error("Log file and cache not available.")
        sys.exit(-2)
    elif logfile_present and (not cache_file_present):
        use_cache = False
    elif (not logfile_present) and cache_file_present:
        use_cache = True
    else:
        # Both file are present, use the most recent
        if cache_last_mtime > logfile_last_mtime:
            use_cache = True
        else:
            use_cache = False

    if not use_cache:
        # build up cache from scratch
        logger.info("Cache invalid, parse log file")
        build_cache()
        logger.info("Cache builded. " + str(getsize(uid_info))
                    + " B -> " + str(os.path.getsize(CACHE_FILE_NAME)) + " B")

    else:
        # Use cache file
        with open(CACHE_FILE_NAME, 'rb') as f:
            uid_info = pickle.load(f)
        logger.info("Cache restored. " + str(getsize(uid_info)) + " B")
    # </editor-fold>

    # MAIN PROGRAM HERE
    if args.print_list:
        # Print list of uid and appname
        logger.info("List of founded UID")
        for uid in uid_info:
            uid_detail = uid_info[uid]
            if uid_detail.all_power > 0:
                logger.info(str(uid_detail.uid) + " - " + uid_detail.app_name)
    else:
        # Print info only about args.UID
        analyze_lcd = False
        analyze_cpu = False
        analyze_wifi = False
        if not (args.wifi or args.cpu or args.lcd):
            # No component specified: ALL component
            analyze_lcd = True
            analyze_cpu = True
            analyze_wifi = True
        else:
            if args.wifi:
                analyze_wifi = True
            if args.cpu:
                analyze_cpu = True
            if args.lcd:
                analyze_lcd = True
        analyze(args.UID, analyze_lcd, analyze_cpu, analyze_wifi)


if __name__ == "__main__":
    main()