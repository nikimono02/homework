def add(a, b):
    return a + b


def calculate_result():
    return add(2, 2)


if __name__ == "__main__":
    result = calculate_result()
    print(f"2 + 2 = {result}")
