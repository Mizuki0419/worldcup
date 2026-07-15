tiedlist = ['CAN', 'BIH']


#########################################
#  グループステージの順位付け　STEP2
#  当該チーム間の試合の勝点
#  当該チーム間の試合の得失点差
#  当該チーム間の試合の最高得点
#  ※順位がつかなくなるまで繰り返し
#########################################

import sqlite3
from pathlib import Path
from collections import Counter

# パス設定
script_dir = Path(__file__).parent # スクリプトのフォルダ
project_root = script_dir.parent # プロジェクトのルートフォルダ
giselect = script_dir / "group_id_SELECT.sql" # スクリプトと同じフォルダに置いてあるGROUP_RANK0_SELECT.sqlのフルパス
gr0select = script_dir / "GROUP_RANK0_SELECT.sql" # スクリプトと同じフォルダに置いてあるGROUP_RANK0_SELECT.sqlのフルパス
tiedselect = script_dir / "tied_SELECT.sql" # スクリプトと同じフォルダに置いてあるMATCH_TEAM_SELECT.sqlのフルパス
db_path = project_root / "db" / "worldcup.sqlite3" # DBファイルのフルパス

# SQLite に接続
con = sqlite3.connect(db_path)
cur = con.cursor()

# GROUP_RANK1を初期化
cur.execute("DELETE FROM GROUP_RANK1;")
print("GROUP_RANK1を初期化")

# SQLファイルを読み込む
with open(tiedselect, "r", encoding="utf-8") as f:
    sql_read = f.read()

# 抽出条件の設定
tiedin = ",".join(f"'{t}'" for t in tiedlist)
sql = sql_read.replace("{tiedin}", tiedin)

# SQL実行
cur.execute(sql)
tmp = cur.fetchall()
print(tmp)

con.commit()
con.close()
print("完了")
