import os
import json

# 修正: 環境変数から取得
API_KEY = os.environ.get('API_KEY')
PASSWORD = os.environ.get('PASSWORD')

def safe_deserialize(data):
    # 修正: JSONを使用
    return json.loads(data)

def safe_query(user_input, cursor):
    # 修正: パラメータ化クエリ
    query = "SELECT * FROM users WHERE name = ?"
    return cursor.execute(query, (user_input,))

def simple_example():
    # 修正: 未使用変数を削除
    x = 10
    y = 20
    return x + y

def simple_function(values):
    # 修正: 複雑度を下げる
    if all(v > 0 for v in values):
        return sum(values)
    return sum(v for v in values if v > 0)

def calculate_sum():
    # 修正: 重複コードを共通化
    result = 0
    for i in range(10):
        result += i * 2
    return result

def duplicate_code_1():
    return calculate_sum()

def duplicate_code_2():
    return calculate_sum()
