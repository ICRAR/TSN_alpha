class TheSkyMap::MessagesController < TheSkyMap::ApplicationController

  respond_to :json

  def index
    page = params[:page].to_i || 1
    per_page = params[:per_page].to_i || 10
    @messages = current_player_object.messages.page(page).per(per_page).for_show
    meta = pagination_meta(@messages).merge(tag_list: TheSkyMap::Message.tag_list)
    if params[:tag_filter] && params[:tag_filter] != ''
      if params[:tag_filter] == 'unread'
        @messages = @messages.where{ack == false}
      else
        @messages = @messages.tagged_with(params[:tag_filter])
      end
      meta[:pagination][:count] = @messages.count
    end

    render :json =>  @messages, :each_serializer => TheSkyMap::MessageIndexSerializer, meta: meta
  end

  def update
    player = current_player_object
    @message = player.messages.find(params[:id])
    @message.update_attributes(params[:message].slice(:ack))
    PostToFaye.ack_msg(player.id,@message.id,player.unread_msg_count, player.game_map_id)
    render json:  @message, serializer: TheSkyMap::MessageIndexSerializer, root: 'message'
  end

  def ack_all
    player = current_player_object
    messages = player.messages.where{ack == false}
    msg_ids = messages.pluck(:id)
    messages.update_all(ack: true)
    @messages = player.messages.where{id.in msg_ids}
    PostToFaye.ack_all_msgs(player.id, player.game_map_id)
    render :json =>  @messages.for_show, :each_serializer => TheSkyMap::MessageIndexSerializer, meta: pagination_meta(@messages)
  end

  def show
    @message = current_player_object.messages.find(params[:id])
    render json:  @message, serializer: TheSkyMap::MessageIndexSerializer, root: 'message'
  end
end
