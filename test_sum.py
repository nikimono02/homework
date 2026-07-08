import unittest

from sum import add


class TestSum(unittest.TestCase):
    def test(self):
        self.assertEqual(add(2, 2), 4)


if __name__ == "__main__":
    unittest.main(verbosity=2)
