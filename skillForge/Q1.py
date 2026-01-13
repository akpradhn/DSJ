"""
Q1. Can Make Arithmetic Progression From Sequence

A sequence of numbers is called an arithmetic progression if the difference between any two consecutive elements is the same.
Given an array of numbers arr, return true if the array can be rearranged to form an arithmetic progression. Otherwise, 
return false.

Example 1:
------------
Input: arr = [3,5,1]
Output: true
Explanation: We can reorder the elements as [1,3,5] or [5,3,1] with differences 2 and -2 respectively, between each consecutive elements.

Example 2:
------------
Input: arr = [1,2,4]
Output: false
Explanation: There is no way to reorder the elements to obtain an arithmetic progression.
 

Constraints:

2 <= arr.length <= 1000
-106 <= arr[i] <= 106
"""



def canMakeArithmeticProgression(arr) -> bool:
    """
    Check if array can be rearranged to form an arithmetic progression.
    
    Approach:
    1. Sort the array
    2. Calculate the common difference from first two elements
    3. Check if all consecutive differences are the same
    """
    n = len(arr)
    
    # Edge case: arrays with 2 or fewer elements are always arithmetic progressions
    if n <= 2:
        return True
    
    # Sort the array to check if it forms an arithmetic progression
    arr.sort()
    
    # Calculate the common difference from the first two elements
    common_diff = arr[1] - arr[0]
    
    # Check if all consecutive pairs have the same difference
    for i in range(2, n):
        if arr[i] - arr[i-1] != common_diff:
            return False
    
    return True
    


print(canMakeArithmeticProgression([3,5,1]))
print(canMakeArithmeticProgression([1,2,4]))
