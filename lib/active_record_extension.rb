module ActiveRecordExtension

  extend ActiveSupport::Concern

  # add your instance methods here


  # add your static(class) methods here
  module ClassMethods
    ### my_batch_offset works in the same manor or find_in_batches
    ### my batch yeilds a active record relation
    ### the batch size and offset is controlled by using the limit and offset SQL commands
    ### empty state determinded using active::relations.empty?
    ### this allows batchs to be run against queiers that do not provide a unique ID or are dynmaiclly generated
    ### it is important to note that this is far less effciant that the standerd find_in_batchs as the database must load all the rows for every query
    def my_batch_offset(opts = {}, &blk)
      batch_size = opts[:batch_size] || 1000
      offset = opts[:offset] || 0
      i = offset;
      loop do
        batch = self.limit(batch_size).offset(i)
        blk.call(batch)
        i = i + batch_size
        break if batch.empty?
      end
    end
    #my_batch_id works works in the same manor or find_in_batches
    #however it yeilds an array of ids
    def my_batch_id(opts = {}, &blk)
      batch_size = opts[:batch_size] || 1000
      relation = self.reorder("#{quoted_table_name}.#{quoted_primary_key} ASC").limit(batch_size)
      ids = relation.pluck(quoted_primary_key)
      while ids.any?
        ids_size = ids.size
        primary_key_offset = ids.last
        blk.call(ids)
        break if ids_size < batch_size
        ids = relation.where("#{quoted_table_name}.#{quoted_primary_key} > ?", primary_key_offset).pluck(quoted_primary_key)
      end
    end
  end

end
ActiveRecord::Base.send(:include, ActiveRecordExtension)