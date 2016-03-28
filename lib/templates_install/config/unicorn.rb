# -*- coding: utf-8 -*-

ROOT = File.dirname(File.dirname(__FILE__))
PROJECT_NAME = ENV['PROJECT_NAME']

# Nginx との通信用 socket
# 絶対パスで指定しなければならない
listen "/var/run/#{PROJECT_NAME}/unicorn/unicorn.sock"

# プロセス停止等で使用する pid を保存するファイルの位置を指定する
pid "/var/run/#{PROJECT_NAME}/unicorn/unicorn.pid"


# ワーカーの数を指定する
worker_processes 2

# リクエストのタイムアウト秒を指定する
timeout 15

# ダウンタイムをなくすため、アプリをプレロード
preload_app true

# Unicorn のログ出力先を指定
stdout_path "/var/log/#{PROJECT_NAME}/unicorn/stdout.log"
stderr_path "/var/log/#{PROJECT_NAME}/unicorn/stderr.log"

# before_fork、after_fork では、Unicorn のプロセスがフォークする前後の
# 挙動を指定できる。以下のおまじないの詳細は
# ドキュメントも参考すること
before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"
  unless old_pid == server.pid
    begin
      Process.kill :QUIT, File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
