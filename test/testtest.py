import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),'Food-Reader','python'))

from Helloworld import Helloworld

import pytest

class TestHelloworld(object):

    def setup_method(self):
        self.h = Helloworls()

    def teardown_method(self):
        self.h = None

    def test_hello(self):
        ans = "Hello World"
        res = self.h.hello()
        assert res == ans
