
'''
Binary Search :
In computer science, binary search, also known as half-interval search,[1] logarithmic search,[2] or binary chop,[3]
is a search algorithm that finds the position of a target value within a sorted array.[4][5] Binary search compares
the target value to the middle element of the array. If they are not equal, the half in which the target cannot lie
is eliminated and the search continues on the remaining half, again taking the middle element to compare to the target
value, and repeating this until the target value is found. If the search ends with the remaining half being empty, the
target is not in the array.
'''


# Returns index of x in arr if present, else -1
def binary_search(arr, low, high, x):
    # Check base case
    if high >= low:

        mid = (high + low) // 2

        # If element is present at the middle itself
        if arr[mid] == x:
            return mid

            # If element is smaller than mid, then it can only
        # be present in left subarray
        elif arr[mid] > x:
            return binary_search(arr, low, mid - 1, x)

            # Else the element can only be present in right subarray
        else:
            return binary_search(arr, mid + 1, high, x)

    else:
        # Element is not present in the array
        return -1


# Test array
arr = [2, 3, 4, 10, 40]
x = 10

# Function call
result = binary_search(arr, 0, len(arr) - 1, x)
print(result)


