import unittest
import project_euler


class TestProjectEuler(unittest.TestCase):

    def test_get_sum_of_multiples(self):
        self.assertEqual(project_euler.get_sum_of_multiples(10), 23)
        self.assertEqual(project_euler.get_sum_of_multiples(0), 0)
        self.assertEqual(project_euler.get_sum_of_multiples(-1), 0)
        # self.assertEqual(project_euler.get_sum_of_multiples('100'), 0)

        # self.assertEqual(ValueError, project_euler.get_sum_of_multiples('100'))



if __name__ == '__main__':
    unittest.main()
