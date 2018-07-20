"""run_locust"""
import ast
import bisect
import json
import random
import subprocess
import time
from datetime import datetime

DATE_FORMAT = '%Y-%m-%d %X.%f'

def run_load_test(config, clients, locust_file="./locustfile.py"):
    """run_load_test"""
    arguments = ["locust",
                 "--host=http://" + config['target'],
                 "-f",
                 locust_file,
                 "--clients=" + str(clients),
                 "--hatch-rate=" + str(config['hatch_rate']),
                 "--run-time=" + str(config['period']),
                 "--no-web",
                 "--only-summary"]
    print str(arguments)
    code = None
    with open("./output/" + config['log_name'], "a") as log_file:
        code = subprocess.call(arguments, stdout=log_file,
                               stderr=subprocess.STDOUT)
    return code

def update_state(sched):
    """update_state"""
    times = [item[0] for item in sched]
    index = bisect.bisect_left(times, datetime.now())
    if index == len(sched):
        state = None
    else:
        state = sched[index-1]
    return state

def get_sched(path):
    """get_sched"""
    descriptor = open(path)
    sched = ast.literal_eval(descriptor.read())
    sched = [(datetime.strptime(item[0], DATE_FORMAT), item[1], item[2]) for item in sched]
    return sched

def run_tests(config):
    """run_tests"""
    sched = get_sched('./sched/sched')
    state = update_state(sched)
    while state is not None:
        random_factor = get_random_factor(state[2])
        clients = state[1] + random_factor
        print "Current clients: " + str(clients)
        print "Current time:" + str(datetime.now())
        run_load_test(config, clients)
        state = update_state(sched)

def parse_config(path):
    """parse_config"""
    with open(path, 'r') as config_file:
        config = json.load(config_file)
    return config

def get_random_factor(num):
    """get_random_factor"""
    return random.randint(-num, num)

if __name__ == '__main__':
    print "Starting program"
    try:
        run_tests(parse_config('config.json'))
    except KeyboardInterrupt:
        pass
    print "Exiting program"
