# Load test

Simulates traffic on the sock shop demo


## Run

Can be built and run with following command: `sudo docker build -t local/load-test . && sudo docker run --net=host local/load-test -i <ip>:<port>`. If the image is built and no changes are made to the code it can be started with: `sudo docker run --net=host local/load-test -i <ip>:<port>`

For help run `sudo docker run --net=host local/load-test -h`

## External config file

If other loads than the default is required then create a config file and pass it to the -f parameter

The config file should look something like this:

```json
{
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
```
Each entry needs to have clients and num_requests. The program will randomly choose one of these entries and run it until its done and randomly choose a new one until it has run 10 tests or something else if specified.

### NOTE
Remember to update the Dockerfile if a new config file is going to be used