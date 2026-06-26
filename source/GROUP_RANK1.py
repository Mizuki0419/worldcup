import sqlite3

# -----------------------------
# 1. SQLファイルを読み込む
# -----------------------------
with open(r"C:\Users\naked\OneDrive\Documents\GitHub\worldcup\source\GROUP_RANK0_SELECT.sql", "r", encoding="utf-8") as f:
    select_sql = f.read()

# -----------------------------
# 1. SQLite に接続
# -----------------------------
con = sqlite3.connect(r"C:\Users\naked\OneDrive\Documents\GitHub\worldcup\db\worldcup.sqlite3")
cur = con.cursor()

# -----------------------------
# 2. データを取り出す（SELECT）
# -----------------------------
cur.execute(select_sql)
rows = cur.fetchall()
print(rows)

# # -----------------------------
# # 3. Pythonで加工する
# # -----------------------------
# processed_data = []
# for row in rows:
#     id_, value = row
#     new_value = value * 2  # ← 加工処理（好きに書き換えられる）
#     processed_data.append((id_, new_value))

# # -----------------------------
# # 4. SQLite の別テーブルへ INSERT
# # -----------------------------
# cur.executemany(
#     "INSERT INTO target_table (id, new_value) VALUES (?, ?)",
#     processed_data
# )

# # -----------------------------
# # 5. コミットして終了
# # -----------------------------
# con.commit()
# con.close()

# print("完了")