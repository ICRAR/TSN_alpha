CREATE TABLE `activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profile_id` int(11) DEFAULT NULL,
  `num_profiles` int(11) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `trackable_id` int(11) DEFAULT NULL,
  `trackable_type` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `profile_name` varchar(255) DEFAULT NULL,
  `item_name` varchar(255) DEFAULT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_activities_on_profile_id` (`profile_id`),
  KEY `index_activities_on_trackable_id` (`trackable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=81556 DEFAULT CHARSET=latin1;

CREATE TABLE `alliance_invites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invited_by_id` int(11) DEFAULT NULL,
  `redeemed_by_id` int(11) DEFAULT NULL,
  `alliance_id` int(11) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `used` tinyint(1) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `invited_on` datetime DEFAULT NULL,
  `redeemed_on` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id_index` (`invited_by_id`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=180 DEFAULT CHARSET=latin1;

CREATE TABLE `alliance_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `join_date` datetime DEFAULT NULL,
  `leave_date` datetime DEFAULT NULL,
  `start_credit` int(11) DEFAULT NULL,
  `leave_credit` int(11) DEFAULT NULL,
  `alliance_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `log` text,
  PRIMARY KEY (`id`),
  KEY `profile_id_index` (`profile_id`),
  KEY `alliance_id_index` (`alliance_id`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12779 DEFAULT CHARSET=latin1;

CREATE TABLE `alliances` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ranking` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `credit` int(11) DEFAULT NULL,
  `RAC` int(11) DEFAULT NULL,
  `tags` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `desc` text COLLATE utf8_unicode_ci,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `old_id` int(11) DEFAULT NULL,
  `invite_only` tinyint(1) DEFAULT NULL,
  `is_boinc` tinyint(1) DEFAULT '0',
  `pogs_team_id` int(11) DEFAULT '0',
  `pogs_update_time` int(11) DEFAULT NULL,
  `duplicate_id` int(11) DEFAULT NULL,
  `current_members` int(11) DEFAULT NULL,
  `comments_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `credit_desc` (`credit`),
  KEY `ranking_asc` (`ranking`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1264 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `boinc_stats_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `boinc_id` int(11) DEFAULT NULL,
  `credit` int(11) DEFAULT NULL,
  `RAC` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `general_stats_item_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `report_count` int(11) DEFAULT NULL,
  `save_value` int(11) DEFAULT NULL,
  `challenge` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `general_stats_item_index` (`general_stats_item_id`),
  KEY `boinc_id_index` (`boinc_id`)
) ENGINE=InnoDB AUTO_INCREMENT=126890 DEFAULT CHARSET=latin1;

CREATE TABLE `bonus_credits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount` int(11) DEFAULT NULL,
  `reason` text,
  `general_stats_item_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `general_stats_item_index` (`general_stats_item_id`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5059 DEFAULT CHARSET=latin1;

CREATE TABLE `challenge_data` (
  `measurable_id` int(11) DEFAULT NULL,
  `measurable_type` varchar(255) DEFAULT NULL,
  `metric_key` int(11) NOT NULL DEFAULT '0',
  `value` int(11) NOT NULL,
  `datetime` datetime NOT NULL,
  UNIQUE KEY `challenge_data_primary_index` (`measurable_type`,`measurable_id`,`metric_key`,`datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `challengers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `score` int(11) DEFAULT NULL,
  `save_value` int(11) DEFAULT NULL,
  `start` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `challenge_id` int(11) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `entity_type` varchar(255) DEFAULT NULL,
  `joined_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `handicap` float NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_challengers_on_challenge_id_and_rank` (`challenge_id`,`rank`),
  KEY `index_challengers_on_entity_type_and_entity_id` (`entity_type`,`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24265 DEFAULT CHARSET=latin1;

CREATE TABLE `challenges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `desc` text,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `invite_only` tinyint(1) DEFAULT NULL,
  `join_while_running` tinyint(1) DEFAULT NULL,
  `challenger_type` varchar(255) DEFAULT NULL,
  `challenge_system` varchar(255) DEFAULT NULL,
  `project` varchar(255) DEFAULT NULL,
  `manager_id` int(11) DEFAULT NULL,
  `started` tinyint(1) DEFAULT NULL,
  `finished` tinyint(1) DEFAULT NULL,
  `challengers_count` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `next_update_time` datetime DEFAULT NULL,
  `hidden` tinyint(1) NOT NULL DEFAULT '0',
  `handicap_type` varchar(255) DEFAULT NULL,
  `comments_count` int(11) DEFAULT NULL,
  `invite_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_challenges_on_start_date` (`start_date`),
  KEY `index_challenges_on_end_date` (`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=latin1;

CREATE TABLE `ckeditor_assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_file_name` varchar(255) NOT NULL,
  `data_content_type` varchar(255) DEFAULT NULL,
  `data_file_size` int(11) DEFAULT NULL,
  `assetable_id` int(11) DEFAULT NULL,
  `assetable_type` varchar(30) DEFAULT NULL,
  `type` varchar(30) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ckeditor_assetable_type` (`assetable_type`,`type`,`assetable_id`),
  KEY `idx_ckeditor_assetable` (`assetable_type`,`assetable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=latin1;

CREATE TABLE `comment_hierarchies` (
  `ancestor_id` int(11) NOT NULL,
  `descendant_id` int(11) NOT NULL,
  `generations` int(11) NOT NULL,
  UNIQUE KEY `comment_anc_desc_udx` (`ancestor_id`,`descendant_id`,`generations`),
  KEY `comment_desc_idx` (`descendant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text,
  `moderated` tinyint(1) DEFAULT '0',
  `moderated_at` datetime DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `commentable_id` int(11) DEFAULT NULL,
  `commentable_type` varchar(255) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `comment_id` (`id`),
  KEY `comment_parent_id` (`parent_id`),
  KEY `comment_profile_id` (`profile_id`),
  KEY `comment_commentable` (`commentable_type`,`commentable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1620 DEFAULT CHARSET=latin1;

CREATE TABLE `conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `daily_alliance_credit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `alliance_id` int(11) DEFAULT NULL,
  `old_alliance_id` int(11) DEFAULT NULL,
  `day` int(11) DEFAULT NULL,
  `current_members` int(11) DEFAULT NULL,
  `daily_credit` int(11) DEFAULT NULL,
  `total_credit` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=565951 DEFAULT CHARSET=latin1;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text COLLATE utf8_unicode_ci,
  `last_error` text COLLATE utf8_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `queue` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB AUTO_INCREMENT=529721 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `follows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `follower_type` varchar(255) DEFAULT NULL,
  `follower_id` int(11) DEFAULT NULL,
  `followable_type` varchar(255) DEFAULT NULL,
  `followable_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_follows` (`follower_id`,`follower_type`),
  KEY `fk_followables` (`followable_id`,`followable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=413 DEFAULT CHARSET=latin1;

CREATE TABLE `galaxy_mosaics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `display` tinyint(1) DEFAULT NULL,
  `galaxy_hash` text,
  `options` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `image_file_name` varchar(255) DEFAULT NULL,
  `image_content_type` varchar(255) DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=latin1;

CREATE TABLE `general_stats_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `total_credit` int(11) DEFAULT NULL,
  `recent_avg_credit` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `last_trophy_credit_value` int(11) NOT NULL DEFAULT '0',
  `power_user` tinyint(1) NOT NULL DEFAULT '0',
  `start_of_challenge` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id_index` (`profile_id`),
  KEY `total_credit_index_desc` (`total_credit`),
  KEY `rank_asc` (`rank`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=136451 DEFAULT CHARSET=latin1;

CREATE TABLE `leaders_science_portals` (
  `leader_id` int(11) DEFAULT NULL,
  `science_portal_id` int(11) DEFAULT NULL,
  KEY `index_leaders_science_portals_on_leader_id_and_science_portal_id` (`leader_id`,`science_portal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `liker_type` varchar(255) DEFAULT NULL,
  `liker_id` int(11) DEFAULT NULL,
  `likeable_type` varchar(255) DEFAULT NULL,
  `likeable_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_likes` (`liker_id`,`liker_type`),
  KEY `fk_likeables` (`likeable_id`,`likeable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2121 DEFAULT CHARSET=latin1;

CREATE TABLE `members_science_portals` (
  `member_id` int(11) DEFAULT NULL,
  `science_portal_id` int(11) DEFAULT NULL,
  KEY `index_members_science_portals_on_member_id_and_science_portal_id` (`member_id`,`science_portal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mentions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mentioner_type` varchar(255) DEFAULT NULL,
  `mentioner_id` int(11) DEFAULT NULL,
  `mentionable_type` varchar(255) DEFAULT NULL,
  `mentionable_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_mentions` (`mentioner_id`,`mentioner_type`),
  KEY `fk_mentionables` (`mentionable_id`,`mentionable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=408 DEFAULT CHARSET=latin1;

CREATE TABLE `nereus_stats_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nereus_id` int(11) DEFAULT NULL,
  `credit` int(11) DEFAULT '0',
  `daily_credit` int(11) DEFAULT '0',
  `rank` int(11) DEFAULT '0',
  `general_stats_item_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `network_limit` bigint(20) DEFAULT '0',
  `monthly_network_usage` bigint(20) DEFAULT '0',
  `paused` int(11) DEFAULT '0',
  `active` int(11) DEFAULT NULL,
  `online_today` int(11) DEFAULT NULL,
  `online_now` int(11) DEFAULT NULL,
  `mips_now` int(11) DEFAULT NULL,
  `mips_today` int(11) DEFAULT NULL,
  `last_checked_time` datetime DEFAULT NULL,
  `report_time_sent` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `general_stats_item_index` (`general_stats_item_id`),
  KEY `nerues_id_index` (`nereus_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17381 DEFAULT CHARSET=latin1;

CREATE TABLE `news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `short` text,
  `long` text,
  `published` tinyint(1) DEFAULT NULL,
  `published_time` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `image_file_name` varchar(255) DEFAULT NULL,
  `image_content_type` varchar(255) DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `notify` tinyint(1) DEFAULT '0',
  `comments_count` int(11) DEFAULT NULL,
  `use_disqus` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `pubished_time_index_asc` (`published_time`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=latin1;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `body` text,
  `subject` varchar(255) DEFAULT '',
  `sender_id` int(11) DEFAULT NULL,
  `sender_type` varchar(255) DEFAULT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  `draft` tinyint(1) DEFAULT '0',
  `updated_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `notified_object_id` int(11) DEFAULT NULL,
  `notified_object_type` varchar(255) DEFAULT NULL,
  `notification_code` varchar(255) DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `global` tinyint(1) DEFAULT '0',
  `expires` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_notifications_on_conversation_id` (`conversation_id`),
  CONSTRAINT `notifications_on_conversation_id` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=82442 DEFAULT CHARSET=latin1;

CREATE TABLE `page_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_id` int(11) DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_page_translations_on_page_id` (`page_id`),
  KEY `index_page_translations_on_locale` (`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=latin1;

CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `science_portal_id` int(11) DEFAULT NULL,
  `preview` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;

CREATE TABLE `profile_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profile_id` int(11) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `body` text,
  `read` tinyint(1) DEFAULT NULL,
  `aggregatable` tinyint(1) DEFAULT NULL,
  `aggregator_count` int(11) DEFAULT NULL,
  `aggregation_text` text,
  `aggregation_type` varchar(255) DEFAULT NULL,
  `notifier_id` int(11) DEFAULT NULL,
  `notifier_type` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_aggrigate_index` (`profile_id`,`read`,`aggregatable`,`notifier_type`,`notifier_id`,`aggregation_type`),
  KEY `profile_read_index` (`profile_id`,`read`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2742056 DEFAULT CHARSET=latin1;

CREATE TABLE `profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `second_name` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `alliance_id` int(11) DEFAULT NULL,
  `alliance_leader_id` int(11) DEFAULT NULL,
  `alliance_join_date` datetime DEFAULT NULL,
  `new_profile_step` int(11) NOT NULL DEFAULT '0',
  `nickname` varchar(255) DEFAULT NULL,
  `use_full_name` tinyint(1) DEFAULT '1',
  `announcement_time` datetime DEFAULT NULL,
  `old_site_user` tinyint(1) DEFAULT NULL,
  `advent_notify` tinyint(1) DEFAULT NULL,
  `advent_last_day` int(11) DEFAULT NULL,
  `description` text,
  `comments_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id_index` (`user_id`),
  KEY `alliance_leader_id_index` (`alliance_leader_id`),
  KEY `alliance_id_index` (`alliance_id`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=136451 DEFAULT CHARSET=latin1;

CREATE TABLE `profiles_trophies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trophy_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `priority` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_profiles_trophies_on_trophy_id_and_profile_id` (`trophy_id`,`profile_id`),
  KEY `index_profiles_trophies_on_profile_id_and_trophy_id` (`profile_id`,`trophy_id`),
  KEY `profile_id_index` (`profile_id`),
  KEY `trophy_id_index` (`trophy_id`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1945397 DEFAULT CHARSET=latin1;

CREATE TABLE `rails_admin_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` text,
  `username` varchar(255) DEFAULT NULL,
  `item` int(11) DEFAULT NULL,
  `table` varchar(255) DEFAULT NULL,
  `month` smallint(6) DEFAULT NULL,
  `year` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rails_admin_histories` (`item`,`table`,`month`,`year`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `receipts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `receiver_id` int(11) DEFAULT NULL,
  `receiver_type` varchar(255) DEFAULT NULL,
  `notification_id` int(11) NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `trashed` tinyint(1) DEFAULT '0',
  `deleted` tinyint(1) DEFAULT '0',
  `mailbox_type` varchar(25) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_receipts_on_notification_id` (`notification_id`),
  KEY `index_receiver_id_is_read` (`receiver_id`,`is_read`),
  CONSTRAINT `receipts_on_notification_id` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=262939 DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `science_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `science_portal_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_science_links_on_science_portal_id` (`science_portal_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

CREATE TABLE `science_portals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `public` tinyint(1) DEFAULT NULL,
  `desc` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_science_portals_on_slug` (`slug`),
  KEY `index_science_portals_on_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE `site_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `current_value` varchar(255) DEFAULT NULL,
  `previous_value` varchar(255) DEFAULT NULL,
  `change_time` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `show_in_list` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `show_index` (`show_in_list`),
  KEY `name_index` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;

CREATE TABLE `special_days` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `annual` tinyint(1) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `start_day` int(11) DEFAULT NULL,
  `start_month` int(11) DEFAULT NULL,
  `end_day` int(11) DEFAULT NULL,
  `end_month` int(11) DEFAULT NULL,
  `url_code` varchar(255) NOT NULL,
  `url_code_only` tinyint(1) DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `features` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_content_type` varchar(255) DEFAULT NULL,
  `logo_file_size` int(11) DEFAULT NULL,
  `logo_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `taggable_type` varchar(255) DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(255) DEFAULT NULL,
  `context` varchar(128) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type_and_context` (`taggable_id`,`taggable_type`,`context`)
) ENGINE=InnoDB AUTO_INCREMENT=1189 DEFAULT CHARSET=latin1;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=903 DEFAULT CHARSET=latin1;

CREATE TABLE `timeline_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT NULL,
  `more` text,
  `subject_aggregate` varchar(255) DEFAULT NULL,
  `more_aggregate` text,
  `aggregate_type` varchar(255) DEFAULT NULL,
  `aggregate_type_2` varchar(255) DEFAULT NULL,
  `aggregate_text` varchar(255) DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `timelineable_id` int(11) DEFAULT NULL,
  `timelineable_type` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `agg_timeline_index` (`timelineable_id`,`timelineable_type`,`posted_at`,`aggregate_type`,`aggregate_type_2`)
) ENGINE=InnoDB AUTO_INCREMENT=1197751 DEFAULT CHARSET=latin1;

CREATE TABLE `trophies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `desc` text,
  `credits` int(11) DEFAULT NULL,
  `image_file_name` varchar(255) DEFAULT NULL,
  `image_content_type` varchar(255) DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `hidden` tinyint(1) DEFAULT NULL,
  `trophy_set_id` int(11) DEFAULT NULL,
  `set_type` varchar(255) DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `comments_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=199 DEFAULT CHARSET=latin1;

CREATE TABLE `trophy_sets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `set_type` varchar(255) DEFAULT NULL,
  `main` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `priority` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  `mod` tinyint(1) NOT NULL DEFAULT '0',
  `username` varchar(255) DEFAULT NULL,
  `old_site_password_salt` varchar(255) NOT NULL DEFAULT '',
  `invitation_token` varchar(60) DEFAULT NULL,
  `invitation_sent_at` datetime DEFAULT NULL,
  `invitation_accepted_at` datetime DEFAULT NULL,
  `invitation_limit` int(11) DEFAULT NULL,
  `invited_by_id` int(11) DEFAULT NULL,
  `invited_by_type` varchar(255) DEFAULT NULL,
  `boinc_id` int(11) DEFAULT NULL,
  `joined_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_username` (`username`),
  UNIQUE KEY `index_users_on_invitation_token` (`invitation_token`),
  KEY `index_users_on_invited_by_id` (`invited_by_id`),
  KEY `id_index` (`id`),
  KEY `joined_at_index` (`joined_at`)
) ENGINE=InnoDB AUTO_INCREMENT=136468 DEFAULT CHARSET=latin1;

CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(255) NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) NOT NULL,
  `whodunnit` varchar(255) DEFAULT NULL,
  `object` text,
  `created_at` datetime DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=latin1;

INSERT INTO schema_migrations (version) VALUES ('20130305062419');

INSERT INTO schema_migrations (version) VALUES ('20130305080950');

INSERT INTO schema_migrations (version) VALUES ('20130305081358');

INSERT INTO schema_migrations (version) VALUES ('20130305164432');

INSERT INTO schema_migrations (version) VALUES ('20130306024457');

INSERT INTO schema_migrations (version) VALUES ('20130306072134');

INSERT INTO schema_migrations (version) VALUES ('20130307013623');

INSERT INTO schema_migrations (version) VALUES ('20130307015620');

INSERT INTO schema_migrations (version) VALUES ('20130307054435');

INSERT INTO schema_migrations (version) VALUES ('20130308032335');

INSERT INTO schema_migrations (version) VALUES ('20130308032745');

INSERT INTO schema_migrations (version) VALUES ('20130311071230');

INSERT INTO schema_migrations (version) VALUES ('20130311071347');

INSERT INTO schema_migrations (version) VALUES ('20130314041051');

INSERT INTO schema_migrations (version) VALUES ('20130315063205');

INSERT INTO schema_migrations (version) VALUES ('20130319015844');

INSERT INTO schema_migrations (version) VALUES ('20130322062339');

INSERT INTO schema_migrations (version) VALUES ('20130422034513');

INSERT INTO schema_migrations (version) VALUES ('20130423061116');

INSERT INTO schema_migrations (version) VALUES ('20130426053056');

INSERT INTO schema_migrations (version) VALUES ('20130426055148');

INSERT INTO schema_migrations (version) VALUES ('20130506053429');

INSERT INTO schema_migrations (version) VALUES ('20130508030622');

INSERT INTO schema_migrations (version) VALUES ('20130510024703');

INSERT INTO schema_migrations (version) VALUES ('20130513015708');

INSERT INTO schema_migrations (version) VALUES ('20130522075935');

INSERT INTO schema_migrations (version) VALUES ('20130522080102');

INSERT INTO schema_migrations (version) VALUES ('20130530035510');

INSERT INTO schema_migrations (version) VALUES ('20130531015357');

INSERT INTO schema_migrations (version) VALUES ('20130606092230');

INSERT INTO schema_migrations (version) VALUES ('20130607025255');

INSERT INTO schema_migrations (version) VALUES ('20130618085314');

INSERT INTO schema_migrations (version) VALUES ('20130619043213');

INSERT INTO schema_migrations (version) VALUES ('20130624020607');

INSERT INTO schema_migrations (version) VALUES ('20130624071824');

INSERT INTO schema_migrations (version) VALUES ('20130625003519');

INSERT INTO schema_migrations (version) VALUES ('20130625051419');

INSERT INTO schema_migrations (version) VALUES ('20130626014923');

INSERT INTO schema_migrations (version) VALUES ('20130627024343');

INSERT INTO schema_migrations (version) VALUES ('20130628054051');

INSERT INTO schema_migrations (version) VALUES ('20130701081452');

INSERT INTO schema_migrations (version) VALUES ('20130711033610');

INSERT INTO schema_migrations (version) VALUES ('20130711041041');

INSERT INTO schema_migrations (version) VALUES ('20130725081919');

INSERT INTO schema_migrations (version) VALUES ('20130730062642');

INSERT INTO schema_migrations (version) VALUES ('20130801014102');

INSERT INTO schema_migrations (version) VALUES ('20130801014310');

INSERT INTO schema_migrations (version) VALUES ('20130801020956');

INSERT INTO schema_migrations (version) VALUES ('20130801021150');

INSERT INTO schema_migrations (version) VALUES ('20130805022948');

INSERT INTO schema_migrations (version) VALUES ('20130805033701');

INSERT INTO schema_migrations (version) VALUES ('20130805034616');

INSERT INTO schema_migrations (version) VALUES ('20130806003021');

INSERT INTO schema_migrations (version) VALUES ('20130823034324');

INSERT INTO schema_migrations (version) VALUES ('20130827082957');

INSERT INTO schema_migrations (version) VALUES ('20130828003127');

INSERT INTO schema_migrations (version) VALUES ('20130828043328');

INSERT INTO schema_migrations (version) VALUES ('20130902022553');

INSERT INTO schema_migrations (version) VALUES ('20130902022554');

INSERT INTO schema_migrations (version) VALUES ('20130902022555');

INSERT INTO schema_migrations (version) VALUES ('20130902022556');

INSERT INTO schema_migrations (version) VALUES ('20130902022557');

INSERT INTO schema_migrations (version) VALUES ('20130902022558');

INSERT INTO schema_migrations (version) VALUES ('20130911074607');

INSERT INTO schema_migrations (version) VALUES ('20130916034852');

INSERT INTO schema_migrations (version) VALUES ('20130919061425');

INSERT INTO schema_migrations (version) VALUES ('20131002044653');

INSERT INTO schema_migrations (version) VALUES ('20131007020303');

INSERT INTO schema_migrations (version) VALUES ('20131016070041');

INSERT INTO schema_migrations (version) VALUES ('20131024014516');

INSERT INTO schema_migrations (version) VALUES ('20131105031308');

INSERT INTO schema_migrations (version) VALUES ('20131115010933');

INSERT INTO schema_migrations (version) VALUES ('20131120023823');

INSERT INTO schema_migrations (version) VALUES ('20131121004722');

INSERT INTO schema_migrations (version) VALUES ('20131122045154');

INSERT INTO schema_migrations (version) VALUES ('20131210035825');

INSERT INTO schema_migrations (version) VALUES ('20131218020252');

INSERT INTO schema_migrations (version) VALUES ('20131218043420');

INSERT INTO schema_migrations (version) VALUES ('20140106083424');

INSERT INTO schema_migrations (version) VALUES ('20140129035940');

INSERT INTO schema_migrations (version) VALUES ('20140129061603');

INSERT INTO schema_migrations (version) VALUES ('20140204035251');

INSERT INTO schema_migrations (version) VALUES ('20140204035930');

INSERT INTO schema_migrations (version) VALUES ('20140204063822');

INSERT INTO schema_migrations (version) VALUES ('20140207070234');

INSERT INTO schema_migrations (version) VALUES ('20140212024154');

INSERT INTO schema_migrations (version) VALUES ('20140213041029');

INSERT INTO schema_migrations (version) VALUES ('20140218052156');

INSERT INTO schema_migrations (version) VALUES ('20140224041125');

INSERT INTO schema_migrations (version) VALUES ('20140225021502');

INSERT INTO schema_migrations (version) VALUES ('20140226055642');

INSERT INTO schema_migrations (version) VALUES ('20140303022212');

INSERT INTO schema_migrations (version) VALUES ('20140303024437');

INSERT INTO schema_migrations (version) VALUES ('20140303070636');

INSERT INTO schema_migrations (version) VALUES ('20140312013603');

INSERT INTO schema_migrations (version) VALUES ('20140324020537');

INSERT INTO schema_migrations (version) VALUES ('20140324020538');

INSERT INTO schema_migrations (version) VALUES ('20140324020539');

INSERT INTO schema_migrations (version) VALUES ('20140324032411');

INSERT INTO schema_migrations (version) VALUES ('20140403032948');

INSERT INTO schema_migrations (version) VALUES ('20140404081950');

INSERT INTO schema_migrations (version) VALUES ('20141111014447');

INSERT INTO schema_migrations (version) VALUES ('20141111014608');