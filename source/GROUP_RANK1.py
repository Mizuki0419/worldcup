#########################################
#  グループステージの順位付け　STEP2
#  当該チーム間の試合の勝点
#  当該チーム間の試合の得失点差
#  当該チーム間の試合の最高得点
#  ※順位がつかなくなるまで繰り返し
#########################################

import sqlite3
from pathlib import Path

# パス設定
script_dir = Path(__file__).parent # スクリプトのフォルダ
project_root = script_dir.parent # プロジェクトのルートフォルダ
sql_path = script_dir / "GROUP_RANK0_SELECT.sql" # スクリプトと同じフォルダに置いてあるGROUP_RANK0_SELECT.sqlのフルパス
db_path = project_root / "db" / "worldcup.sqlite3" # DBファイルのフルパス

# -----------------------------
# 1. SQLファイルを読み込む
# -----------------------------
with open(sql_path, "r", encoding="utf-8") as f:
    select_sql = f.read()

# -----------------------------
# 1. SQLite に接続
# -----------------------------
con = sqlite3.connect(db_path)
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