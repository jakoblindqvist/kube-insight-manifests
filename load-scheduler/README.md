# Load scheduler

## Usage

Run the load-scheduler with the command:
`python run_locust.py`

## Config file

The config file is responsible for keeping track of network information and locust parameters.
The config file should contain the following information:
```
{
    "target": 192.168.1.1,
    "hatch_rate": 1,
    "log_name": my_log,
    "period": 5m
}
```
With this config file each new process would run for 5 minutes.

## Schedule file

A schedule file is used to define the load at a particular time.
It should be a list containing [<timestamp>, <clients>, <variation>]. 
The timestamps are assumed to be ordered from first to last.
When a new process is started it will start with the number of clients 

A schedule should look like this:
```
[
['2018-07-19 08:00:00.000000', 10, 2],
['2018-07-19 12:00:00.000000', 2, 1] 
]
```
A process starting at `2018-07-19 08:50:00.000000` would use between 8 and 12 clients.
