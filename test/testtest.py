import os
#import sys

#sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),'python'))

from test import helloworld

import pytest

class TestCalculator(object):

    def setup_method(self):
        self.h = helloworls()

    def teardown_method(self):
        self.h = None

    def test_hello(self):

        res = self.h.hello()
        assert res == "Hello World"
