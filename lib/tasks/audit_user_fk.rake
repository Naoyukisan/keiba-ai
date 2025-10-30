# lib/tasks/audit_user_fk.rake
namespace :audit do
  desc "List FK/NULL constraints referencing users.id"
  task user_fk: :environment do
    conn = ActiveRecord::Base.connection

    puts "== Columns referencing users.id =="
    conn.tables.sort.each do |tbl|
      next if tbl == "schema_migrations" || tbl == "ar_internal_metadata"

      # 1) user_id カラムの NULL 制約を調べる
      if conn.column_exists?(tbl, :user_id)
        col = conn.columns(tbl).find { |c| c.name == "user_id" }
        null_ok = col.null
        puts "- #{tbl}.user_id: NULL #{null_ok ? 'OK' : 'NG (NOT NULL)'}"
      end

      # 2) 外部キーの on_delete 動作を調べる
      begin
        fks = conn.foreign_keys(tbl)
      rescue NotImplementedError
        fks = []
      end

      fks.select { |fk| fk.to_table.to_s == "users" }.each do |fk|
        action = fk.options[:on_delete] || :restrict
        puts "    FK(#{fk.options[:name] || 'no_name'}) on_delete: #{action}  column: #{fk.options[:column] || 'user_id'}"
      end
    end

    puts "\nTips: NOT NULL や on_delete: :restrict が残っているテーブルをマイグレーションで 'NULL許可 + on_delete: :nullify' に直してください。"
  end
end
