#!/bin/bash

for name in $(find templates/ | grep .j2); do
  postfx=".j2"
  new_name=${name%$postfx}
  python convert.py $name $new_name
  rm -f $name
done
