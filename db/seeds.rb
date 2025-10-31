# db/seeds.rb
# 各テーブルを最低5件以上にする
require "securerandom"

MIN = 5

def say(section)
  puts "\n== #{section} =="
end

def need_count(klass, min = MIN)
  [min - klass.count, 0].max
end

ActiveRecord::Base.transaction do
  # ===== Users =====
  say "Users"
  if defined?(User)
    # 既存保持、足りない分だけ作成
    need = need_count(User)
    need.times do
      pwd = SecureRandom.urlsafe_base64(12)
      User.create!(
        email: "user_#{SecureRandom.hex(4)}@example.com",
        password: pwd,
        password_confirmation: pwd,
        admin: false
      )
    end

    # ゲスト系があれば作成
    User.guest_admin if User.respond_to?(:guest_admin)
    User.guest_user  if User.respond_to?(:guest_user)

    # 念のため管理者0人なら1人追加
    if User.column_names.include?("admin") && User.where(admin: true).count.zero?
      pwd = SecureRandom.urlsafe_base64(16)
      User.create!(
        email: ENV.fetch("GUEST_ADMIN_EMAIL", "guest_admin@example.com"),
        password: pwd, password_confirmation: pwd,
        admin: true
      )
    end
    puts "User.count = #{User.count}"
  end

  # ===== Rooms =====
  say "Rooms"
  if defined?(Room)
    need = need_count(Room)
    need.times do |i|
      Room.create!(name: "Room #{i + 1}")
    end
    puts "Room.count = #{Room.count}"
  end

  # ===== PredictionMethods =====
  say "PredictionMethods"
  if defined?(PredictionMethod)
    need = need_count(PredictionMethod)
    need.times do |i|
      PredictionMethod.create!(
        name: "メソッド#{PredictionMethod.count + 1}",
        body: "Seeded body #{SecureRandom.hex(4)}",
        active: false
      )
    end

    # 1つを有効化（activate!があれば使う）
    if PredictionMethod.respond_to?(:activate!)
      target = PredictionMethod.order(:id).first
      PredictionMethod.activate!(target.id) if target && !target.active?
    else
      # フォールバック：最古をactiveにし、他はfalse
      target = PredictionMethod.order(:id).first
      if target
        PredictionMethod.where.not(id: target.id).update_all(active: false, activated_at: nil)
        target.update!(active: true, activated_at: Time.current)
        PredictionMethodSwitch.create!(prediction_method_id: target.id) if defined?(PredictionMethodSwitch)
      end
    end

    # activate履歴をMIN件程度まで増やしておく（見栄え用）
    if defined?(PredictionMethodSwitch)
      need_sw = need_count(PredictionMethodSwitch)
      methods = PredictionMethod.order(:id).to_a
      need_sw.times do
        pm = methods.sample
        if PredictionMethod.respond_to?(:activate!)
          PredictionMethod.activate!(pm.id)
        else
          PredictionMethod.where.not(id: pm.id).update_all(active: false, activated_at: nil)
          pm.update!(active: true, activated_at: Time.current)
          PredictionMethodSwitch.create!(prediction_method_id: pm.id)
        end
        sleep 0.05 # created_atの時系列が全部同時刻にならないよう軽く間隔
      end
      puts "PredictionMethodSwitch.count = #{PredictionMethodSwitch.count}"
    end

    puts "PredictionMethod.count = #{PredictionMethod.count}, active=#{PredictionMethod.where(active: true).count}"
  end

  # ===== PredictionHistories =====
  say "PredictionHistories"
  if defined?(PredictionHistory)
    need = need_count(PredictionHistory)
    users = defined?(User) ? User.all.to_a : []
    need.times do |i|
      PredictionHistory.create!(
        race_name: "ダミーレース#{PredictionHistory.count + 1}",
        race_date: Date.today - rand(0..14),
        predicted_at: Time.current - rand(0..7).days,
        result: "結果#{SecureRandom.hex(2)}",
        user: (users.sample if rand < 0.7) # 7割はユーザー紐付け
      )
    end
    puts "PredictionHistory.count = #{PredictionHistory.count}"
  end

  # ===== Messages =====
  say "Messages"
  if defined?(Message)
    # messagesはroom_idはNOT NULL、user_idはNULL許可（削除時にSET NULL）
    room  = defined?(Room) ? (Room.first || Room.create!(name: "General")) : nil
    users = defined?(User) ? (User.limit(MIN).to_a) : []
    if room && users.any?
      need = need_count(Message)
      need.times do |i|
        Message.create!(
          room_id: room.id,
          user_id: users[i % users.size].id,
          content: "メッセージ#{Message.count + 1}（seed）"
        )
      end
      puts "Message.count = #{Message.count}"
    else
      puts "[SKIP] Messages: rooms/usersが不足しています"
    end
  end

  # ===== Blogs =====
  # Blog は user_id（NULL許可）を持つ。必要に応じてユーザーに紐付けても良い。
  say "Blogs"
  if defined?(Blog)
    need = need_count(Blog)
    if need > 0
      rows = Array.new(need) do
        {
          title: "ブログ#{Blog.count + 1 + rand(1000)}",
          description: "Seeded blog #{SecureRandom.hex(4)}",
          created_at: Time.current,
          updated_at: Time.current
        }
      end
      Blog.insert_all(rows)
    end
    puts "Blog.count = #{Blog.count}"
  end
end

puts "\n== done =="
puts "Users:               #{User.count}"              if defined?(User)
puts "Rooms:               #{Room.count}"              if defined?(Room)
puts "Messages:            #{Message.count}"           if defined?(Message)
puts "PredictionMethods:   #{PredictionMethod.count}"  if defined?(PredictionMethod)
puts "PM Switches:         #{PredictionMethodSwitch.count}" if defined?(PredictionMethodSwitch)
puts "PredictionHistories: #{PredictionHistory.count}" if defined?(PredictionHistory)
puts "Blogs:               #{Blog.count}"              if defined?(Blog)
