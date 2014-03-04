module ActiveRecordExtension

  extend ActiveSupport::Concern

  # add your instance methods here


  # add your static(class) methods here
  module ClassMethods
    ### my_batch works in the same manor or find_in_batchs
    ### my batch yeilds a active record relation
    ### the batch size and offset is controlled by using the limit and offset SQL commands
    ### empty state determinded using active::relations.empty?
    ### this allows batchs to be run against queiers that do not provide a unique ID or are dynmaiclly generated
    ### it is important to note that this is far less effciant that the standerd find_in_batchs as the database must load all the rows for every query
    def my_batch(opts = {}, &blk)
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
  end

end
ActiveRecord::Base.send(:include, ActiveRecordExtension)