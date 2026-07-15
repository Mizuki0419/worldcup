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


# SQLファイルを実行する関数
def sql_kick(sql_path, arg_list):
    # SQLファイルを読み込む
    with open(sql_path, "r", encoding="utf-8") as f:
        sql_read = f.read()

    # SQL実行
    cur.execute(sql_read, arg_list)
    return(cur.fetchall())

# SQLite に接続
con = sqlite3.connect(db_path)
cur = con.cursor()

# GROUP_RANK1を初期化
cur.execute("DELETE FROM GROUP_RANK1;")
print("GROUP_RANK1を初期化")

# グループの一覧
grouplist = [x[0] for x in sql_kick(giselect, ())]

# グループの数だけSTEP1の判定
for i in grouplist:
    gr0list = sql_kick(gr0select, (i,))
    counts = Counter(x[0] for x in gr0list)
    print(gr0list, end="")
    print(counts)
    
    sliderank = 0
    for conrank,concount in counts.items():
        sliderank += 1
        if concount == 1: # 単独の順位（同率のチームがいない）ならGROUP_RANK1にINSERT
            cur.execute("INSERT INTO GROUP_RANK1 "
                        "SELECT * "
                        "FROM GROUP_RANK0 "
                        "WHERE team_id = ?;",
                        (gr0list[conrank-1][1],)) #関数化する
        else: # 同率がいたら決着がつかなくなるまでSTEP1を続ける
            tiedlist = [item[1] for item in gr0list if item[0] == conrank]
            
            flg = True
            z = 0
            while flg or z > 100:
                z += 1 #無限ループ防止

                # SQLファイルを読み込む
                with open(tiedselect, "r", encoding="utf-8") as f:
                    sql_read = f.read()

                # 抽出条件の設定
                tiedin = ",".join(f"'{t}'" for t in tiedlist)
                sql = sql_read.replace("{tiedin}", tiedin)

                # SQL実行
                cur.execute(sql)
                stp1list = cur.fetchall()
                print(stp1list)
                
                countsstp1 = Counter(x[0] for x in stp1list)
                
                for conrankstp1,concountstp1 in countsstp1.items():
                    if concountstp1 == 1: # 単独の順位（同率のチームがいない）ならGROUP_RANK1にINSERT
                        cur.execute("INSERT INTO GROUP_RANK1 "
                                    "SELECT "
                                        "group_id,"
                                        "? AS rank,"
                                        "team_id,"
                                        "played,"
                                        "win,"
                                        "draw,"
                                        "loss,"
                                        "goal_scored,"
                                        "goal_allowed,"
                                        "goal_difference,"
                                        "conduct_score,"
                                        "points,"
                                        "fifarank "
                                    "FROM GROUP_RANK0 "
                                    "WHERE team_id = ?;",
                                    (sliderank,stp1list[conrankstp1-1][1]))
                        sliderank += 1
                    else: # 同率がいたら決着がつかなくなるまでSTEP1を続ける
                        tmplist = [item[1] for item in tiedlist if item[0] == conrankstp1]
                        tiedlist = tmplist
                
                if len(countsstp1) == 1:
                    flg = False
                    cur.executemany("INSERT INTO GROUP_RANK1 "
                                "SELECT "
                                    "group_id,"
                                    "rank,"
#                                    "? AS rank,"
                                    "team_id,"
                                    "played,"
                                    "win,"
                                    "draw,"
                                    "loss,"
                                    "goal_scored,"
                                    "goal_allowed,"
                                    "goal_difference,"
                                    "conduct_score,"
                                    "points,"
                                    "fifarank "
                                "FROM GROUP_RANK0 "
                                "WHERE team_id = ?;",
                                (tiedlist,))
#                                (sliderank,tiedlist))
                else:
                    flg = True
            

            
            
    con.commit()

# ダメ押しでcommitしてクローズ
con.commit()
con.close()

print("完了")
