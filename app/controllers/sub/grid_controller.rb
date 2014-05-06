class Sub::GridController < Sub::ApplicationController

  respond_to :json

  def index
    board = Sub::Grid.where{z == 1}.where{(y >= 0) & (y <= 2)}.where{(x >= 0) & (x <= 2)}.order([:z,:y,:x])
    rows = board.group_by(&:y)
    grids_json = ActiveModel::ArraySerializer.new(board, each_serializer: Sub::GridSerializer)
    rows_json = rows.map{|k,v| {'id' => k, 'y' => k, 'grid_ids' => v.map(&:id)}}

    respond_with ({grids: grids_json, rows: rows_json}).to_json

  end

end
