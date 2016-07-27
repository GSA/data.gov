#!/usr/bin/env python

import yaml
import os.path

with open (os.path.dirname(__file__) + "/../secrets.yml", "r") as myfile:
    data = yaml.load(myfile)

print data.get('ansible_vault_password')