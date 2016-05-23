# coding: utf-8

# overwrite db:migarate
task 'db:migrate' => :environment do
  ENV['RAILS_ENV'] ||= 'development'
  sh "bundle exec ridgepole -c config/database.yml -f db/Schemafile -E#{ENV['RAILS_ENV']} --apply"
  sh 'bin/rake db:schema:dump' # test用に schema.rb ファイルを作成しておく
end

task 'db:migrate:dryrun' => :environment do
  ENV['RAILS_ENV'] ||= 'development'
  sh "bundle exec ridgepole -c config/database.yml -f db/Schemafile -E#{ENV['RAILS_ENV']} --apply --dry-run"
end
