class TimelineEntry < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  attr_accessible  :profile_id, :posted_at, :aggregate_text, :aggregate_type,
                   :more, :more_aggregate,
                   :subject, :subject_aggregate

  belongs_to :profile

  def self.post_to(profile, opts = {})
    opts.symbolize_keys!()
    more = opts[:more] || ''
    more_aggregate = opts[:more] || more
    subject = opts[:subject] || 'did something'
    subject_aggregate = opts[:subject_aggregate] || subject
    aggregate_text = opts[:aggregate_text] || "#{profile.name} </br> \n"
    aggregate_type = opts[:aggregate_type] || nil

    self.create ({
      profile_id: profile.id,
      more: more,
      more_aggregate: more_aggregate,
      subject: subject,
      subject_aggregate: subject_aggregate,
      aggregate_type: aggregate_type,
      aggregate_text: aggregate_text,
      posted_at: Time.now,
    })
  end

  def self.get_timeline(profile_ids)
    self.where{profile_id.in profile_ids}.
      group{[aggregate_type,TO_DAYS(posted_at)]}.
      order{posted_at.desc}.
      select("#{self.table_name}.*").
      select{'count(*) as aggregate_count'}.
      select{'count(distinct profile_id) as distinct_aggregate_count'}.
      select('GROUP_CONCAT(aggregate_text SEPARATOR \'\') as aggregate_texts').
      includes{profile.user}
  end


  #we use the aggregate subject and more if multiple actions have taken place ie aggregate_count > distinct_aggregate_count
  #if more the one user was involved distinct_aggregate_count > 1 then we sub 'was' with 'were'
  def get_subject
    out = ''
    if aggregate_count > 1
      if  aggregate_count > distinct_aggregate_count
        if distinct_aggregate_count > 1
          others = (distinct_aggregate_count-1)
          out << "and #{pluralize(others, 'other')} "
          out << subject_aggregate.sub('was ','were ')
          out << " #{aggregate_count} times" unless aggregate_count == distinct_aggregate_count
        else
          out << subject_aggregate
          out << " #{aggregate_count} times" unless aggregate_count == distinct_aggregate_count
        end
      else
        out << "and #{(distinct_aggregate_count-1).to_s} others "
        out << subject.sub('was ','were ')
      end
    else
      out << subject
    end
    return out.html_safe
  end
  #if more than one action as occurred by any number of profiles then append the aggregate_texts
  def get_more
    out = ''
    if aggregate_count > 1
      if  aggregate_count > distinct_aggregate_count
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
