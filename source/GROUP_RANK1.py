#########################################
#  グループステージの順位付け　STEP1
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
tiedselect = script_dir / "tied_SELECT.sql" # スクリプトと同じフォルダに置いてあるtied_SELECT.sqlのフルパス
insertgr1 = script_dir / "INSERT_INTO_GROUP_RANK1.sql" # スクリプトと同じフォルダに置いてあるINSERT_INTO_GROUP_RANK1.sqlのフルパス
db_path = project_root / "db" / "worldcup.sqlite3" # DBファイルのフルパス

# SQLファイルを読み込む関数
def sql_read(sql_path):
    with open(sql_path, "r", encoding="utf-8") as f:
        return(f.read())

# SQLite に接続
con = sqlite3.connect(db_path)
cur = con.cursor()

# GROUP_RANK1を初期化
cur.execute("DELETE FROM GROUP_RANK1;")
print("GROUP_RANK1を初期化")

# グループの一覧を取得
cur.execute("SELECT group_id FROM GROUP_RANK0 GROUP BY group_id;")
grouplist = [x[0] for x in cur.fetchall()]
print("グループの一覧を取得")
print(grouplist)

# グループの数だけSTEP1の判定
for i in grouplist:
    cur.execute("SELECT rank, team_id FROM GROUP_RANK0 WHERE group_id = ? ORDER BY rank;", (i,))
    gr0list = cur.fetchall()
    counts = Counter(x[0] for x in gr0list)
    
    sliderank = 1
    for conrank,concount in counts.items():
        if concount == 1: # 単独の順位（同率のチームがいない）ならGROUP_RANK1にINSERT
            cur.execute(sql_read(insertgr1), (sliderank,gr0list[conrank-1][1]))
            sliderank += 1
        else: # 同率がいたら決着がつかなくなるまでSTEP1を続ける
            tiedlist = [item[1] for item in gr0list if item[0] == conrank]
            
            flg = True
            z = 0
            while flg:
                z += 1 #無限ループ防止

                # 抽出条件の設定
                tiedin = ",".join(f"'{t}'" for t in tiedlist)
                sql = sql_read(tiedselect).replace("{tiedin}", tiedin)

                # SQL実行
                cur.execute(sql)
                stp1list = cur.fetchall()
                
                countsstp1 = Counter(x[0] for x in stp1list)
                
                for conrankstp1,concountstp1 in countsstp1.items():
                    if concountstp1 == 1: # 単独の順位（同率のチームがいない）ならGROUP_RANK1にINSERT
                        cur.execute(sql_read(insertgr1), (sliderank,stp1list[conrankstp1-1][1]))
                        sliderank += 1
                    else: # 同率がいたら決着がつかなくなるまでSTEP1を続ける
                        tmplist = [item[1] for item in stp1list if item[0] == conrankstp1]
                        tiedlist = tmplist
                
                if len(countsstp1) == 1:
                    flg = False
                    for team in tiedlist:
                        cur.execute(sql_read(insertgr1), (sliderank,team))
                    sliderank += len(tiedlist)
                elif all(x == 1 for x in countsstp1.values()):
                    flg = False
                elif z > 10:
                    flg = False
                else:
                    flg = True
    con.commit()
    print("グループ",i,"完了")

# ダメ押しでcommitしてクローズ
con.commit()
con.close()

print("全部完了")
