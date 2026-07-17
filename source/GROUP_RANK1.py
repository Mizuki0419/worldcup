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

# SQLファイル読み込み
tiedsel = sql_read(tiedselect)
insgr1 = sql_read(insertgr1)

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
    # 処理対象のグループを抽出しrankの数を数える
    cur.execute("SELECT rank, team_id FROM GROUP_RANK0 WHERE group_id = ? ORDER BY rank;", (i,))
    gr0list = cur.fetchall()
    counts = Counter(x[0] for x in gr0list)
    
    # rankの数分繰り返してグループ全体をSTEP1の判定に通す
    sliderank = 1 # GROUP_RANK1に設定するrank
    for conrank,concount in counts.items():
        if concount == 1: # 単独の順位（同率のチームがいない）ならGROUP_RANK1にINSERT
            cur.execute(insgr1, (sliderank,gr0list[conrank-1][1]))
            sliderank += 1
        else: # 同率がいたら決着がつかなくなるまでSTEP1を続ける
            tiedlist = [item[1] for item in gr0list if item[0] == conrank]
            
            flg = True
            while flg:
                # 抽出条件の設定（同率のチームの一覧）
                tiedin = ",".join(f"'{t}'" for t in tiedlist)
                sql = tiedsel.replace("{tiedin}", tiedin)

                # 処理対象のチームを抽出、STEP1の判定をしてrankの数を数える
                cur.execute(sql)
                stp1list = cur.fetchall()
                countsstp1 = Counter(x[0] for x in stp1list)
                
                # rankの数分繰り返して同率チームがいるか判定
                for conrankstp1,concountstp1 in countsstp1.items():
                    if concountstp1 == 1: # 単独の順位（同率のチームがいない）ならGROUP_RANK1にINSERT
                        cur.execute(insgr1, (sliderank,stp1list[conrankstp1-1][1]))
                        sliderank += 1
                    else: # 同率がいたら決着がつかなくなるまでSTEP1を続ける
                        tmplist = [item[1] for item in stp1list if item[0] == conrankstp1]
                        tiedlist = tmplist
                
                # ループ終了処理
                if len(countsstp1) == 1: # rankの数が1（種類）なら決着がつかなくなっているので、RANK1にINSERTしてループ終了
                    for team in tiedlist:
                        cur.execute(insgr1, (sliderank,team)) # 決着ついてないので同じrankでINSERT
                    sliderank += len(tiedlist)
                    flg = False
                elif all(x == 1 for x in countsstp1.values()): # 全部のrankが1つずつなら全部決着ついてるのでループ終了
                    flg = False
                elif sliderank > 5: # rankが6以上になったらループ強制終了。rankは1～4までだが、バグを検知しやすいように5までは許容する。
                    flg = False
                else: # それ以外はまだ判定の余地があるのでループ継続
                    flg = True
    con.commit()
    print("グループ",i,"完了")

# ダメ押しでcommitしてクローズ
con.commit()
con.close()

print("全部完了")
