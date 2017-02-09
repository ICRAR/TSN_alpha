
class BoincMigrateJob < Delayed::BaseScheduledJob
  run_every 24.hours

  def perform
    # BoincRemoteUser.where("total_credit > 0").each do |b|
    #   stats_item = BoincStatsItem.where("boinc_id = #{b.id}")
    # end
    # For each pogs user with credit.
    # Check for a local user that has their same email
    # If one doesn't exist, create them
    #   Create a local profile for them
    #   Create a BoincStatsItem for them
    #   Create a GeneralStatsItem for them

    # If they do exist, confirm that they have a profile, BoincStatsItem and GeneralStatsItem.
    # If they don't have one, make them.

    # Clear out any bad instances of BoincStatsItems and GeneralStatsItems (#### Confirm what a 'bad instance' is ####)
  end

  def clean_stats_items(dry_run=false)
    # Find all boinc stats items where the corresponding general stats item doesn't exist.

    # All boinc stats items
    delete_count = 0
    BoincStatsItem.each  do |boinc_stats_item|

        # find the general stats item that this boinc stats item is pointing to
      puts "Checking general stats item"
      general_item = GeneralStatsItem.where("id = #{boinc_stats_item.general_stats_item_id}")
      if general_item.nil?
        delete_count += 1
      end
    end

    puts "To delete: #{delete_count}"
    return

    if dry_run
      count = res.count
      count_boinc = BoincStatsItem.count
      count_general = GeneralStatsItem.count

      puts "To delete: #{count}."
      puts "Count General: #{count_general}. Count Boinc: #{count_boinc}"
      puts "Should be one, or zero boinc stats items for each general stats item"
      puts "After deletion: #{count_boinc - count}"
      puts "Correct? #{(count_boinc - count <= count_general)}"

      puts num_dups
    else
    end
  end
end