__author__ = 'mwvaughn'

import json
import os


HERE = os.path.dirname(os.path.abspath(__file__))
CWD = os.getcwd()


class TestData(object):
    '''Loads from tests/data/executions.json'''
    def __init__(self):

        self.dat = self.file_to_json('data/executions.json')

    def file_to_json(self, filename):
        return json.load(open(os.path.join(HERE, filename)))

    def data(self, key=None):
        if key is None:
            return self.dat
        else:
            return self.dat.get(key, None)


class Secrets(object):
    '''Loads from the top-level secrets.json file'''
    def __init__(self):

        self.dat = self.file_to_json('secrets.json')

    def file_to_json(self, filename):
        fpath = os.path.join(CWD, filename)
        if os.path.isfile(fpath):
            return json.load(open(os.path.join(CWD, filename)))
        else:
            return {}

    def data(self, key=None):
        if key is None:
            return self.dat
        else:
            return self.dat.get(key, None)
