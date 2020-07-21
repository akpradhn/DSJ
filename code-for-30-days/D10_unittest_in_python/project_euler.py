"""
If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9.
The sum of these multiples is 23.

Find the sum of all the multiples of 3 or 5 below 1000.
"""


def get_sum_of_multiples(input_integer):
    count = 0
    sum_value = 0
    multiple_list = []
    if type(input_integer) != int:
        raise ValueError('Input number is not an integer')
    while count < input_integer:
        if count % 3 == 0 or count % 5 == 0:
            multiple_list.append(count)
            sum_value = sum_value + count
        else:
            pass
        count = count + 1
    # print('Multiples of ',input_integer,'are ',multiple_list)
    return sum_value
# result = get_sum_of_multiples(10)
#
# print(result)
