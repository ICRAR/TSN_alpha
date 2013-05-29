# app/helpers/api_helper
module JsonApiHelper
  def paginate_json(collection)
    current_page_num = collection.current_page
    last_page_num = collection.total_pages

    {
        :first => first_page,
        :previous => previous_page(current_page_num),
        :self => current_page(current_page_num),
        :next => next_page(current_page_num, last_page_num),
        :last => last_page(last_page_num),
        :sort_order => sort_column,
        :sort_direction =>sort_direction
    }
  end

  def first_page
    { :href => url_for(params.merge({:page => 1,:only_path => false})) }
  end

  def previous_page(current_page_num)
    return nil if current_page_num <= 1
    { :href => url_for(params.merge({:page => current_page_num-1,:only_path => false})) }
  end

  def current_page(current_page_num)
    { :href => url_for(params.merge({:page => current_page_num,:only_path => false})) }
  end

  def next_page(current_page_num, last_page_num)
    return nil if current_page_num >= last_page_num
    { :href => url_for(params.merge({:page => current_page_num+1,:only_path => false})) }
  end

  def last_page(last_page_num)
    { :href => url_for(params.merge({:page => last_page_num,:only_path => false})) }
  end
end