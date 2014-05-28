class TheSkyMap::ActionsController < TheSkyMap::ApplicationController

  respond_to :json
  def index
    @actions = actionable.actions
    not_found unless actionable.the_sky_map_player_id == current_user.profile.the_sky_map_player.id
    render :json =>  @actions, :each_serializer => ActionSerializer
  end
  def create
    actor = current_user.profile.the_sky_map_player
    @action = actionable.perform_action(actor, params[:action_name])

    action_serialized = ActionSerializer.new(@action)
    current_user.profile.the_sky_map_player.reload
    output = current_player_hash.merge( ActiveSupport::JSON.decode(action_serialized.to_json))
    render json: output.to_json
  end
  def show
    @action = Action.find(params[:id])
    actor = current_user.profile.the_sky_map_player
    not_found unless @action.actor == actor
    @action.check_and_run
    @action.reload
    ids=  [@action.id]
    @actions = @action.actionable.actions.where{(id.in ids) | (state < 3)}
    render :json =>  @actions, :each_serializer => ActionSerializer
  end

  private
  def actionable_type
    %w[TheSkyMap::Ship].include?(params[:actionable]) ? params[:actionable] : nil
  end
  def actionable_class
    actionable_type.classify.constantize
  end
  def actionable_id
    params[(actionable_type.demodulize.underscore + "_id").to_sym]
  end
  def actionable
    actionable_class.find(actionable_id)
  end

end
