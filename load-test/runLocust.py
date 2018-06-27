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

LOG_FILE_TYPE = "log"
LABEL_FILE_TYPE = "labels"

def usage():
    print("Usage: python " + sys.argv[0] + " ")
    print("    -i --host: Ip-address to the webpage (required)")
    print("    -t --tests: How many tests that will be executed (-1 will make it run infinitely). default: 10")
    print("    -f --config-file: Location to an external config file")
    print("    -l --locust-file: Location to an external locust task file")
    print("    -h --help: Displays this text")

"""
  Runs test
"""
def run_load_test(clients, num_request, target_host, log_name, locust_file = "/config/locustfile.py"):
    hatch_rate = str(3)
    no_web = True
    only_summary = True

    arguments = ["locust", "--host=http://" + target_host, "-f", locust_file, "--clients=" + str(clients), "--hatch-rate=" + hatch_rate, "--num-request=" + str(num_request)]

    if no_web: arguments.append("--no-web")
    if only_summary : arguments.append("--only-summary")

    with open("/output/" + log_name, "a") as file:
      code = subprocess.call(arguments, stdout=file, stderr=subprocess.STDOUT)

    return code

"""
  A random state from the available states
"""
def get_next_state():
    return random.choice(list(config.items()))

"""
  Writes the object label to /outout/<label_name>
"""
def writeResult(label_name, label):
  print "Exit time: ", int(datetime.now().strftime("%s"))
  with open("/output/" + label_name, "w") as file:
    print >> file, label

"""
  Executes tests
"""
def runTests(tests, label_name, label, log_name):
  i = 0
  while i != int(tests):
    i += 1
    level, test_config = get_next_state()
    time = datetime.now()
    intTime = int(time.strftime("%s"))
    label.append([intTime, level])
    print time.strftime("[%Y-%m-%d %H:%M:%S]") + " Running test on " + level + " settings"
    sys.stdout.flush()
    run_load_test(test_config["clients"], test_config["num_requests"], target, log_name, locust_file = locust_file)

  writeResult(label_name, label)

if __name__ == '__main__':
  try:
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

    # Empty old log and label file
    startTime = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    log_name = startTime + "." + LOG_FILE_TYPE
    label_name = startTime + "." + LABEL_FILE_TYPE
    label = []

    runTests(tests, label_name, label, log_name)
  except KeyboardInterrupt:
    try:
      print >> sys.stderr, "Interrupt detected, Saving data to file"
      writeResult(label_name, label)
      sys.stdout.flush()
      sys.exit(0)
    except SystemExit:
      os._exit(0)