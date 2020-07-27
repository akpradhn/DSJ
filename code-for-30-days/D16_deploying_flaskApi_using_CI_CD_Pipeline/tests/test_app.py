from app import home

def test_index():
    assert home() == "Hello, world!"