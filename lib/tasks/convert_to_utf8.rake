#credit for this script goes to:
# https://gist.github.com/tboyko/7680960
# and   https://gist.github.com/mperham/2045565
# http://www.mikeperham.com/2012/03/31/converting-a-mysql-database-from-latin1-to-utf8/

desc "convert a latin1 database with utf8 data into proper utf8"
task :convert_to_utf8 => :environment do
  puts Time.now
  dryrun = ENV['DOIT'] != '1'
  conn = ActiveRecord::Base.connection
  if dryrun
    def conn.run_sql(sql)
      puts(sql)
    end
  else
    def conn.run_sql(sql)
      puts(sql)
      execute(sql)
    end
  end

  database_name = Rails.configuration.database_configuration[ Rails.env ]['database']

  conn.run_sql "ALTER DATABASE #{database_name} CHARACTER SET utf8 collate utf8_unicode_ci"

  # Don't covert views
  VIEWS = /(view|_v$)/
  big = []

  # These are table_name => model_class mappings that aren't rails standard or
  # tables that we don't wish to convert (table_name => true).
  mapping = { :categories_products => true,
              :delayed_jobs => Delayed::Job,
              :ckeditor_assets => Ckeditor::Asset,
              :schema_migrations => true,
              :daily_alliance_credit => true,
              :leaders_science_portals => true,
              :members_science_portals => true,
              :rails_admin_histories => true,
              :alliance_members => AllianceMembers,
              :tags => ActsAsTaggableOn::Tag,
              :taggings => ActsAsTaggableOn::Tagging,
              :versions => true,
              :users => true
  }.with_indifferent_access
  tables = (conn.tables - big).select { |tbl| tbl !~ VIEWS }
  puts "Converting #{tables.inspect}"

  #(tables - big).each do |tbl|
  tables.each do |tbl|
    a = ['CHARACTER SET utf8 COLLATE utf8_unicode_ci']
    b = []
    model = mapping[tbl] || tbl.to_s.classify.constantize || nil
    unless model.nil?  || tbl == :users
      model.columns.each do |col|
        type = col.sql_type

        nullable = col.null ? '' : ' NOT NULL'
        default = col.default ? " DEFAULT '#{col.default}'" : ''

        case type
          when /varchar/
            a << "CHANGE #{conn.quote_column_name(col.name)} #{conn.quote_column_name(col.name)} VARBINARY(#{col.limit})"
            b << "CHANGE #{conn.quote_column_name(col.name)} #{conn.quote_column_name(col.name)} VARCHAR(#{col.limit}) CHARACTER SET utf8 COLLATE utf8_unicode_ci#{nullable}#{default}"
          when /text/
            a << "CHANGE #{conn.quote_column_name(col.name)} #{conn.quote_column_name(col.name)} BLOB"
            b << "CHANGE #{conn.quote_column_name(col.name)} #{conn.quote_column_name(col.name)} TEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci#{nullable}#{default}"
        end
      end unless model == true

      conn.run_sql "ALTER TABLE #{tbl} #{a.join(', ')}"
      conn.run_sql "ALTER TABLE #{tbl} #{b.join(', ')}" if b.present?
    end
  end

  puts Time.now
  puts 'Done!'
end