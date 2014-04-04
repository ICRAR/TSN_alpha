class TimelineEntry < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  attr_accessible  :profile_id, :posted_at, :aggregate_text, :aggregate_type, :aggregate_type_2,
                   :more, :more_aggregate,
                   :subject, :subject_aggregate

  belongs_to :profile

  def self.post_to(profiles, opts = {})
    opts.symbolize_keys!()
    more = opts[:more] || ''
    more_aggregate = opts[:more] || more
    subject = opts[:subject] || 'did something'
    subject_aggregate = opts[:subject_aggregate] || subject
    aggregate_text = opts[:aggregate_text] || "#{profile.name} </br> \n"
    aggregate_type = opts[:aggregate_type] || nil
    aggregate_type_2 = opts[:aggregate_type_2] || nil

    if profiles.class == Profile
      self.create ({
          profile_id: profiles.id,
          more: more,
          more_aggregate: more_aggregate,
          subject: subject,
          subject_aggregate: subject_aggregate,
          aggregate_type: aggregate_type,
          aggregate_type_2: aggregate_type_2,
          aggregate_text: aggregate_text,
          posted_at: Time.now,
      })
    elsif profiles.class == ActiveRecord::Relation || profiles.class == Array

      entires = []
      cols = [:profile_id,:more,:more_aggregate,:subject,:subject_aggregate,:aggregate_type,:aggregate_type_2,:aggregate_text,:posted_at]
      time_now = Time.now
      profiles.each do |profile|
        link_profile = ActionController::Base.helpers.link_to(profile.name, Rails.application.routes.url_helpers.profile_path(profile.id))
        aggregate_text_each = aggregate_text.sub('%profile_name%', link_profile)
        entires << [profile.id, more, more_aggregate,subject,subject_aggregate,aggregate_type,aggregate_type_2,aggregate_text_each,time_now]
      end
      TimelineEntry.import cols, entires
    end


  end

  def self.get_timeline(profile_ids)
    ProfileNotification.connection.execute 'SET SESSION group_concat_max_len = 1024000;'
    self.where{profile_id.in profile_ids}.
      group{[aggregate_type,TO_DAYS(posted_at)]}.
      order{posted_at.desc}.
      select("#{self.table_name}.*").
      select{'count(*) as aggregate_count'}.
      select{'count(distinct aggregate_type_2) as type_count'}.
      select{'count(distinct profile_id) as distinct_aggregate_count'}.
      select('GROUP_CONCAT(aggregate_text SEPARATOR \'\') as aggregate_texts').
      includes{profile.user}
  end
  def self.get_timeline_all
    ProfileNotification.connection.execute 'SET SESSION group_concat_max_len = 1024000;'
    self.
        group{[aggregate_type,TO_DAYS(posted_at)]}.
        order{posted_at.desc}.
        select("#{self.table_name}.*").
        select{'count(*) as aggregate_count'}.
        select{'count(distinct aggregate_type_2) as type_count'}.
        select{'count(distinct profile_id) as distinct_aggregate_count'}.
        select('GROUP_CONCAT(aggregate_text SEPARATOR \'\') as aggregate_texts').
        includes{profile.user}
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
end
