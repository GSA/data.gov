#!/usr/bin/env python

import yaml
import json
import os.path

with open (os.path.dirname(__file__) + "/../secrets.yml", "r") as myfile:
    data = yaml.load(myfile)

print data.get('aws_secret_key')
