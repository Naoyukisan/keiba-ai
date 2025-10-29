# db/seeds.rb
ActiveRecord::Base.transaction do
  template_body = <<~'TXT'
    あなたは競馬の予想ライターです。以下の入力を使い、**指定した構成とフォーマットだけ**で出力してください。
    日本語で書いてください。

    # 入力（レース情報）
    - レース名: #{h[:race_name]}
    - 日付: #{h[:date]} #{h[:time]}
    - 競馬場: #{h[:place]}
    - ラウンド: #{h[:round]}
    - クラス: #{h[:class_name]}
    - 距離: #{h[:distance]}

    # 出力要件（この順序・この見出し・このレイアウトを厳守）
    1) 「◇順位予想」セクション：
       - 見出し: `◇順位予想`
       - 直下に **Markdown表** を 1 つだけ出力。ヘッダは **「着順 | 馬番 | 馬名 | スコア」** の4列、行は 1〜11着 まで。
         - スコアは **整数 + “点”**（例: 89点）。
         - 例と同じ並び（着順→馬番→馬名→スコア）。
         **TSV（タブ区切り）** を以下のコードフェンスで出力：
         ```
         ```

    2) 「◇スコア」セクション：
       - 見出し: `◇スコア`
       - 1 行目に **（重み付け：実績#{weights[:perf]}点、血統#{weights[:pedigree]}点、調子#{weights[:cond]}点）** と書く。
       - 以降は **着順の昇順** で、各馬について下記テンプレで出力（全馬分）：
         ```
         <着順>着（<馬番>番）：<馬名> (<合計点>点)
          ・実績 (<x/#{weights[:perf]}>): 近走レベル(<n>), レース質(<n>), 適性(<n>)
          ・血統 (<y/#{weights[:pedigree]}>): コース(<n>), 馬場(<n>)
          ・調子 (<z/#{weights[:cond]}>): パフォ(<n>), 仕上(<n>), ローテ(<n>)
         ```

    3) 「◇馬毎のスコア解説」セクション：
       - 見出し: `◇馬毎のスコア解説`
       - 1 行につき 1 頭、**「<着順>着 <馬名>: ...」** の形式で簡潔に根拠を書く（全頭分）。

    4) 「◇展開予想」セクション：
       - 見出し: `◇展開予想`
       - 「スタート〜中盤」「中盤〜終盤」「ラスト」の3段落で、主導権・仕掛けのタイミング・決め手の流れを要約。

    5) 「◇予想とオッズの比較と分析」セクション：
       - 見出し: `◇予想とオッズの比較と分析`
       - 小見出し「人気と評価の一致」「妙味のある馬」「評価を下げた人気馬」「結論」をこの順に出す。

    # 厳格ルール
    - 出力は **上記5セクションのみ**。順番・見出し・記号・表形式・コードブロックを厳守。
    - 候補馬の実名・馬番が不明でも、整合の取れた仮名で構いません（後で置換可能）。ただし**行数は必ず 11 行**で固定。
  TXT

  pm = PredictionMethod.find_or_initialize_by(name: "既定テンプレ")
  pm.body = template_body
  pm.active = true
  pm.activated_at ||= Time.current
  pm.save!

  PredictionMethod.where.not(id: pm.id).update_all(active: false)

  puts "[seed] PredictionMethod ##{pm.id} name=#{pm.name} active=#{pm.active} length=#{pm.body&.bytesize}"

  admin_email = ENV.fetch("SEED_ADMIN_EMAIL", "admin@kba-ai.com")
  admin_pass  = ENV.fetch("SEED_ADMIN_PASSWORD", "AdminPass123!")

  admin = User.find_or_initialize_by(email: admin_email)
  if admin.new_record?
    admin.password = admin_pass
    admin.password_confirmation = admin_pass
    admin.admin = true
    admin.save!
    puts "[seed] Admin user created: #{admin_email}"
  else
    if !admin.admin?
      admin.update!(admin: true)
      puts "[seed] Admin privilege granted: #{admin_email}"
    else
      puts "[seed] Admin user exists: #{admin_email}"
    end
  end
end
