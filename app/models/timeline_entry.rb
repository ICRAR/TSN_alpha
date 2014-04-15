class TimelineEntry < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  attr_accessible  :timelineable, :timelineable_id, :timelineable_type, :posted_at, :aggregate_text, :aggregate_type, :aggregate_type_2,
                   :more, :more_aggregate,
                   :subject, :subject_aggregate

  belongs_to :timelineable, polymorphic: true

  def self.post_to(timelineables, opts = {})
    opts.symbolize_keys!()
    more = opts[:more] || ''
    more_aggregate = opts[:more] || more
    subject = opts[:subject] || 'did something'
    subject_aggregate = opts[:subject_aggregate] || subject
    aggregate_text = opts[:aggregate_text] || nil
    aggregate_type = opts[:aggregate_type] || nil
    aggregate_type_2 = opts[:aggregate_type_2] || nil

    if timelineables.class == ActiveRecord::Relation || timelineables.class == Array
      aggregate_text ||= "%profile_name%</br> \n"
      entires = []
      cols = [:timelineable_id,:timelineable_type, :more,:more_aggregate,:subject,:subject_aggregate,:aggregate_type,:aggregate_type_2,:aggregate_text,:posted_at]
      time_now = Time.now
      timelineables.each do |timelineable|
        profile = timelineable
        link_profile = ActionController::Base.helpers.link_to(profile.name, Rails.application.routes.url_helpers.profile_path(profile.id))
        aggregate_text_each = aggregate_text.sub('%profile_name%', link_profile)
        entires << [profile.id,profile.class.to_s, more, more_aggregate,subject,subject_aggregate,aggregate_type,aggregate_type_2,aggregate_text_each,time_now]
      end
      TimelineEntry.import cols, entires
    else
      aggregate_text ||= "#{timelineables.name} </br> \n"
      self.create ({
          timelineable: timelineables,
          more: more,
          more_aggregate: more_aggregate,
          subject: subject,
          subject_aggregate: subject_aggregate,
          aggregate_type: aggregate_type,
          aggregate_type_2: aggregate_type_2,
          aggregate_text: aggregate_text,
          posted_at: Time.now,
      })
    end


  end

  def self.get_timeline(timelineables)
    TimelineEntry.connection.execute 'SET SESSION group_concat_max_len = 1024000;'
    where_strings = []
    timelineables.each do |key, ids|
      type_e = Mysql2::Client.escape(key)
      ids_e = Mysql2::Client.escape(ids.join(', '))
      where_strings << "(timelineable_type = '#{type_e}' AND timelineable_id IN (#{ids_e}) )" unless ids.empty?
    end
    where_string = where_strings.join(' OR ')

    self.where(where_string).
      group{[aggregate_type,TO_DAYS(posted_at)]}.
      order{posted_at.desc}.
      select("#{self.table_name}.*").
      select{'count(*) as aggregate_count'}.
      select{'count(distinct aggregate_type_2) as type_count'}.
      select{'count(distinct CONCAT(timelineable_type,timelineable_id)) as distinct_aggregate_count'}.
      select('GROUP_CONCAT(aggregate_text SEPARATOR \'\') as aggregate_texts').
      includes{timelineable}
  end
  def self.get_timeline_all
    TimelineEntry.connection.execute 'SET SESSION group_concat_max_len = 1024000;'
    TimelineEntry.
        group{[aggregate_type,TO_DAYS(posted_at)]}.
        order{posted_at.desc}.
        select("#{TimelineEntry.table_name}.*").
        select{'count(*) as aggregate_count'}.
        select{'count(distinct aggregate_type_2) as type_count'}.
        select{'count(distinct CONCAT(timelineable_type,timelineable_id)) as distinct_aggregate_count'}.
        select('GROUP_CONCAT(aggregate_text SEPARATOR \'\') as aggregate_texts').
        includes{timelineable}
  end


  #we use the aggregate subject and more if multiple actions have taken place ie type_count > 1
  #if more the one user was involved distinct_aggregate_count > 1 then we sub 'was' with 'were'
  def get_subject
    out = ''
    if aggregate_count > 1 #multiple records of any type
      if  type_count > 1 #multiple types of records
        if distinct_aggregate_count > 1 #multiple profiles
          others = (distinct_aggregate_count-1)
          out << "and #{pluralize(others, 'other')} "
          out << subject_aggregate.sub('was ','were ')
          out << " #{type_count} times"
        else
          out << subject_aggregate
          out << " #{type_count} times"
        end
      else
        if distinct_aggregate_count > 1 #multiple profiles
          others = (distinct_aggregate_count-1)
          out << "and #{pluralize(others, 'other')} "
          out << subject.sub('was ','were ')
        else
          out << subject
        end
      end
    else
      out << subject
    end
    return out.html_safe
  end
  #if more than one action as occurred by any number of profiles then append the aggregate_texts
  def get_more
    out = ''
    if aggregate_count > 1 #multiple records of any type
      if  type_count > 1 #multiple types of records
        if distinct_aggregate_count > 1
          out << more_aggregate.sub('was ','were ')
        else
          out << more_aggregate
        end
      else
        out << more
      end
      out << '<br />'
      out << aggregate_texts
    else
      out << more
    end
    return out.html_safe
  end

  def has_more?
    aggregate_count > 1 ?
        ((more_aggregate != '' && more_aggregate != nil) || (aggregate_texts != '' && aggregate_texts != nil)) :
        (more != '' && more != nil)
  end

  def timelineable_name
    t = timelineable
    if t.respond_to? :name
      out = t.name
    elsif t.respond_to? :title
      out = t.title
    else
      out = ''
    end
    out
  end
end
