class TheSkyMap::ActionsController < TheSkyMap::ApplicationController

  respond_to :json
  def index
    if params[:ids]
      @actions = actionable.actions.where{id.in my{params[:ids]}}
    else
      @actions = actionable.actions
    end

    not_found unless actionable.the_sky_map_player_id == current_player_id
    render :json =>  @actions, :each_serializer => ActionSerializer
  end
  def player_index
    page = params[:page].to_i || 1
    per_page = params[:per_page].to_i || 10
    actor = current_player_object
    @actions = actor.actions.page(page).per(per_page).includes(:actionable, :actor).order{updated_at.desc}
    if params[:only_running] == 'true'
      @actions = @actions.current_action
    end
    render :json =>  @actions, :each_serializer => ActionSerializer, meta: pagination_meta(@actions)
  end
  def create
    actor = current_player_object
    @action = actionable.perform_action(actor, params[:action_name])

    action_serialized = ActionSerializer.new(@action)
    current_player_object.reload
    output = current_player_hash.merge( ActiveSupport::JSON.decode(action_serialized.to_json))
    render json: output.to_json
  end
  def show
    @action = Action.find(params[:id])
    actor = current_player_object
    not_found unless @action.actor == actor
    @action.check_and_run
    @actions = @action.self_and_other_queued
    render :json =>  @actions, :each_serializer => ActionSerializer
  end
  def run_special
    action = Action.find(params[:id]) || not_found
    actor = current_player_object
    not_found unless action.actor == actor && !action.actionable.nil?
    action.run_special
    @actions = action.self_and_other_queued
    actions_json = ActiveModel::ArraySerializer.new(@actions, each_serializer: ActionSerializer)
    current_player_object.reload
    output = current_player_hash.merge({actions: actions_json })
    render json: output.to_json
  end

  private
  def actionable_type
    %w[TheSkyMap::Ship TheSkyMap::Base].include?(params[:actionable]) ? params[:actionable] : nil
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
