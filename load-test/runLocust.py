import datetime
import os
import random
import subprocess
import sys
import time
import getopt
import json
from datetime import datetime

config = {
  "high": {
    "clients": 20,
    "num_requests": 10000,
  },

  "middle": {
    "clients": 7,
    "num_requests": 10000,
  },

  "low": {
    "clients": 3,
    "num_requests": 10000,
  }
}

def usage():
    print("Usage: python " + sys.argv[0] + " ")
    print("    -i --host: Ip-address to the webpage (required)")
    print("    -t --tests: How many tests that will be executed. default: 10")
    print("    -f --config-file: Location to an external config file")
    print("    -l --locust-file: Location to an external locust task file")
    print("    -h --help: Displays this text")

"""
  Runs test
"""
def run_load_test(clients, num_request, target_host, locust_file = "/config/locustfile.py"):
    hatch_rate = str(3)
    no_web = True
    only_summary = True

    arguments = ["locust", "--host=http://" + target_host, "-f", locust_file, "--clients=" + str(clients), "--hatch-rate=" + hatch_rate, "--num-request=" + str(num_request)]

    if no_web: arguments.append("--no-web")
    if only_summary : arguments.append("--only-summary")

    return subprocess.call(arguments, stdout=open(os.devnull, "w"), stderr=subprocess.STDOUT)

"""
  A random state from the available states
"""
def get_next_state():
    return random.choice(list(config.items()))

if len(sys.argv) < 2:
  print "ERROR: not enough parameters"
  sys.exit(1)

target = sys.argv[1]

try:
    opts, args = getopt.getopt(sys.argv[1:], 'hi:t:f:l:', ["help", "host=", "tests=", "config-file=", "locust-file="])
except getopt.GetoptError as err:
    print(err)
    usage()
    sys.exit(1)

target = ""
tests = 10
config_file = ""
locust_file = "/config/locustfile.py"
for o, a in opts:
  if o in ("-i", "--host"):
    target = a
  elif o in ("-t", "--tests"):
    tests = int(a)
  elif o in ("-f", "--config-file"):
    config_file = a
  elif o in ("-l", "--locust-file"):
    locust_file = a
  elif o in ("-h", "--help"):
    usage()
    exit()

if not target:
  usage()
  exit(1)

if config_file:
  with open(config_file) as file:
    config = json.load(file)

for _ in range(tests):
  level, test_config = get_next_state()
  print datetime.now().strftime("[%Y-%m-%d %H:%M:%S]") + " Running test on " + level + " settings"
  sys.stdout.flush()
  code = run_load_test(test_config["clients"], test_config["num_requests"], target, locust_file = locust_file)