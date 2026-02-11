import os
import pickle

# セキュリティ問題: ハードコードされた認証情報
API_KEY = "sk-1234567890abcdef"
PASSWORD = "admin123"

def unsafe_deserialize(data):
    # セキュリティ問題: 安全でないデシリアライゼーション
    return pickle.loads(data)

def sql_injection_vulnerable(user_input):
    # セキュリティ問題: SQLインジェクション
    query = "SELECT * FROM users WHERE name = '" + user_input + "'"
    return query

def unused_variable_example():
    # コード品質問題: 未使用変数
    x = 10
    y = 20
    z = 30
    return x + y

def complex_function(a, b, c, d, e, f):
    # コード品質問題: 複雑度が高い
    if a > 0:
        if b > 0:
            if c > 0:
                if d > 0:
                    if e > 0:
                        if f > 0:
                            return a + b + c + d + e + f
                        else:
                            return a + b + c + d + e
                    else:
                        return a + b + c + d
                else:
                    return a + b + c
            else:
                return a + b
        else:
            return a
    else:
        return 0

def duplicate_code_1():
    # コード品質問題: 重複コード
    result = 0
    for i in range(10):
        result += i * 2
    return result

def duplicate_code_2():
    # コード品質問題: 重複コード
    result = 0
    for i in range(10):
        result += i * 2
    return result

# コード品質問題: デッドコード
def never_called_function():
    print("This is never called")
    return None
