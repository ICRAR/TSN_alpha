class ProfileNotification < ActiveRecord::Base
  table_name = :profile_notifications
  attr_accessible :body, :read, :subject,:aggregatable, :aggregator_count, :aggregation_text, :profile, :profile_id, :notifier, :notifier_id, :notifier_type, :aggregation_type
  belongs_to :profile
  belongs_to :notifier, polymorphic: true
  scope :unread, where{read == false}.order{created_at.asc}
  def is_read?
    read?
  end
  def mark_as_read
    self.read = true
    self.save
  end
  class << self
    def notify(profile,subject,body,notifier=nil,aggregatable=false, aggregation_text = '',aggregation_type = nil)
      note = new({
          profile: profile,
          subject: subject,
          body: body,
          notifier: notifier,
          aggregatable: aggregatable,
          aggregation_text: aggregation_text,
          aggregator_count: 1,
          read: false,
          aggregation_type: aggregation_type,
            })
      note.save
    end

    #aggrigate type can be either 'class' or 'class_id'. the first aggrigates all matching notigier types the second inlcudes notifier id
    #if the notification is to be aggrigated aggregation subject and body are user
    #  all occurances of %COUNT% in subject and body are replaced with the aggregator_count
    def notify_with_aggrigation(profile,subject,body,aggregation_subject,aggregation_body,aggrigate_type,notifier, aggregation_text,aggregation_type = nil)
      #checks and deletes other similar notifications
      agg_rel = aggregation_relation(profile,notifier,aggrigate_type,aggregation_type)
      agg_count = agg_rel.sum(:aggregator_count)

      if agg_count == 0
        #first notification so just notify normally
        notify(profile,subject,body,notifier,true,aggregation_text,aggregation_type)
      else
        ProfileNotification.transaction do
          #aggregation texts is an array of all the pre existing aggregation text's stored in DB
          aggregation_texts = agg_rel.pluck(:aggregation_text)
          agg_rel.delete_all
          new_subject = aggregation_subject.sub('%COUNT%',(agg_count+1).to_s)
          aggregation_texts << aggregation_text
          aggregation_text_new = aggregation_texts.join('')
          new_body = aggregation_body.sub('%COUNT%',(agg_count+1).to_s) + '<br />' + aggregation_text_new
          note = new({
                           profile: profile,
                           subject: new_subject,
                           body: new_body,
                           notifier: notifier,
                           aggregatable: true,
                           aggregator_count: agg_count+1,
                           aggregation_text: aggregation_text_new,
                           read: false,
                           aggregation_type: aggregation_type,
                       })
          note.save
        end
      end
    end
    def aggrigate_by_class(class_name,subject,body)
      aggrigate_by_class_id(class_name,nil,subject,body)
    end

    def aggrigate_by_class_id(class_name,class_id,subject,body)
      ProfileNotification.transaction do
        ProfileNotification.connection.execute 'SET SESSION group_concat_max_len = 1024000;'
        to_be_rel = ProfileNotification.where{aggregatable == true}.
                      where{read == false}.
                      where{notifier_type == class_name}
        to_be_rel = to_be_rel.where{notifier_id == class_id} unless class_id.nil?
        to_be_data = to_be_rel.group(:profile_id).select("GROUP_CONCAT(aggregation_text SEPARATOR '') as new_aggregation_text").
                        select("GROUP_CONCAT(id SEPARATOR ', ') as ids").
                        select{sum(aggregator_count).as new_count}.select('`profile_notifications`.*').
                        having('COUNT(*) > 1').all
        cols = [:profile_id,:subject,:body,:notifier_type,:notifier_id,:aggregatable,:aggregator_count,:aggregation_text,:read]
        new_notes = []
        to_del_ids = []
        to_be_data.each do |note|
          to_del_ids = to_del_ids + note.ids.split(",").map(&:to_i)

          agg_count = note.new_count
          new_subject = subject.sub('%COUNT%',(agg_count).to_s)
          new_body = body.sub('%COUNT%',(agg_count).to_s) + '<br />' + note.new_aggregation_text
          new_notes << [note.profile_id, new_subject, new_body,note.notifier_type,note.notifier_id,true,agg_count,note.new_aggregation_text,false]
        end
        ProfileNotification.where{id.in to_del_ids}.delete_all
        ProfileNotification.import cols, new_notes
      end
    end
    def notify_all(profiles,subject,body,notifier=nil,aggregatable=false, aggregation_text = '')
      #notfies all profiles
      #improves efficacy by using direct SQL inserts
      profiles.my_batch_id do |profile_ids|
        ProfileNotification.notify_all_id_array(profile_ids,subject,body,notifier,aggregatable, aggregation_text)
      end
    end
    def notify_all_id_array(ids,subject,body,notifier=nil,aggregatable=false, aggregation_text = '')
      notes = []
      cols = [:profile_id,:subject,:body,:notifier_type,:notifier_id,:aggregatable,:aggregator_count,:aggregation_text,:read]
      notifier_type = notifier.nil? ? nil : notifier.class.to_s
      notifier_id = notifier.nil? ? nil : notifier.id
      ids.each do |id|
        notes << [id, subject, body,notifier_type,notifier_id,aggregatable,1,aggregation_text,false]
      end
      ProfileNotification.import cols, notes
    end



    #returns a relation object for all the too be aggregated notifications
    def aggregation_relation(profile,notifier,aggrigate_type,agg_type)
      relation_out = where{profile_id == my{profile.id}}.
                        where{aggregatable == true}.
                        where{read == false}.
                        where{notifier_type == my{notifier.nil? ? nil : notifier.class.to_s}}
      relation_out = relation_out.where{notifier_id == my{notifier.nil? ? nil : notifier.id}} if aggrigate_type == 'class_id'
      relation_out = relation_out.where{aggregation_type == my{agg_type}}
      relation_out
    end

  end
end
