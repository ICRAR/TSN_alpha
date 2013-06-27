class AddIndexes < ActiveRecord::Migration
  def change
    add_index :general_stats_items, :profile_id, {name: 'profile_id_index'}
    add_index :alliance_members, :profile_id, {name: 'profile_id_index'}
    add_index :profiles_trophies, :profile_id, {name: 'profile_id_index'}
    add_index :alliance_invites, :invited_by_id, {name: 'profile_id_index'}

    add_index :profiles, :user_id, {name: 'user_id_index'}
    add_index :profiles, :alliance_leader_id, {name: 'alliance_leader_id_index'}
    add_index :profiles, :alliance_id, {name: 'alliance_id_index'}


    add_index :nereus_stats_items, :general_stats_item_id, {name: 'general_stats_item_index'}
    add_index :boinc_stats_items, :general_stats_item_id, {name: 'general_stats_item_index'}
    add_index :bonus_credits, :general_stats_item_id, {name: 'general_stats_item_index'}

    add_index :profiles_trophies, :trophy_id, {name: 'trophy_id_index'}

    add_index :alliance_members, :alliance_id, {name: 'alliance_id_index'}

    add_index :news, :published_time, {name: 'pubished_time_index_asc', order: {published_time: :asc}}
    add_index :general_stats_items, :total_credit, {name: 'total_credit_index_desc', order: {total_credit: :desc}}
    add_index :general_stats_items, :rank, {name: 'rank_asc', order: {rank: :asc}}
    add_index :alliances, :credit, {name: 'credit_desc', order: {credit: :desc}}
    add_index :alliances, :ranking, {name: 'ranking_asc', order: {ranking: :asc}}




    add_index :alliances, :id, {name: 'id_index'}
    add_index :alliance_invites, :id, {name: 'id_index'}
    add_index :alliance_members, :id, {name: 'id_index'}
    add_index :boinc_stats_items, :id, {name: 'id_index'}
    add_index :bonus_credits, :id, {name: 'id_index'}
    add_index :general_stats_items, :id, {name: 'id_index'}
    add_index :nereus_stats_items, :id, {name: 'id_index'}
    add_index :news, :id, {name: 'id_index'}
    add_index :pages, :id, {name: 'id_index'}
    add_index :profiles, :id, {name: 'id_index'}
    add_index :profiles_trophies, :id, {name: 'id_index'}
    add_index :trophies, :id, {name: 'id_index'}
    add_index :users, :id, {name: 'id_index'}








  end
end
