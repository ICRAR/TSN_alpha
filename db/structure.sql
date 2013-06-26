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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2425 DEFAULT CHARSET=latin1;

CREATE TABLE `alliances` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `ranking` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `credit` int(11) DEFAULT NULL,
  `RAC` int(11) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `desc` text,
  `country` varchar(255) DEFAULT NULL,
  `old_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=523 DEFAULT CHARSET=latin1;

CREATE TABLE `boinc_stats_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `boinc_id` int(11) DEFAULT NULL,
  `credit` int(11) DEFAULT NULL,
  `RAC` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `general_stats_item_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1859 DEFAULT CHARSET=latin1;

CREATE TABLE `bonus_credits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount` int(11) DEFAULT NULL,
  `reason` text,
  `general_stats_item_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2970 DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9012 DEFAULT CHARSET=latin1;

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5800 DEFAULT CHARSET=latin1;

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `content` text,
  `slug` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9012 DEFAULT CHARSET=latin1;

CREATE TABLE `profiles_trophies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trophy_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_profiles_trophies_on_trophy_id_and_profile_id` (`trophy_id`,`profile_id`),
  KEY `index_profiles_trophies_on_profile_id_and_trophy_id` (`profile_id`,`trophy_id`)
) ENGINE=InnoDB AUTO_INCREMENT=103050 DEFAULT CHARSET=latin1;

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

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `site_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `current_value` varchar(255) DEFAULT NULL,
  `previous_value` varchar(255) DEFAULT NULL,
  `change_time` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB AUTO_INCREMENT=1046 DEFAULT CHARSET=latin1;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=868 DEFAULT CHARSET=latin1;

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=latin1;

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
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_username` (`username`),
  UNIQUE KEY `index_users_on_invitation_token` (`invitation_token`),
  KEY `index_users_on_invited_by_id` (`invited_by_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9012 DEFAULT CHARSET=latin1;

CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(255) NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) NOT NULL,
  `whodunnit` varchar(255) DEFAULT NULL,
  `object` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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