CREATE TABLE `hosts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `hostname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ttl` int(11) DEFAULT NULL,
  `cname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `live_cname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hosts_on_host` (`hostname`),
  KEY `index_hosts_on_site_id` (`site_id`)
) ENGINE=InnoDB AUTO_INCREMENT=543 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `path` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `path_hash` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `http_status` varchar(3) COLLATE utf8_unicode_ci NOT NULL,
  `new_url` text COLLATE utf8_unicode_ci,
  `suggested_url` text COLLATE utf8_unicode_ci,
  `archive_url` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mappings_on_site_id_and_path_hash` (`site_id`,`path_hash`),
  KEY `index_mappings_on_site_id` (`site_id`),
  KEY `index_mappings_on_site_id_and_http_status` (`site_id`,`http_status`)
) ENGINE=InnoDB AUTO_INCREMENT=285591 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `organisations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `launch_date` date DEFAULT NULL,
  `homepage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `furl` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `css` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `manages_own_redirects` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_organisations_on_abbr` (`abbr`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organisation_id` int(11) DEFAULT NULL,
  `abbr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `query_params` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tna_timestamp` datetime DEFAULT NULL,
  `homepage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `global_http_status` varchar(3) COLLATE utf8_unicode_ci DEFAULT NULL,
  `global_new_url` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sites_on_site` (`abbr`),
  KEY `index_sites_on_organisation_id` (`organisation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=214 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20130416185911');

INSERT INTO schema_migrations (version) VALUES ('20130416190316');

INSERT INTO schema_migrations (version) VALUES ('20130416190835');

INSERT INTO schema_migrations (version) VALUES ('20130417094719');

INSERT INTO schema_migrations (version) VALUES ('20130417181816');

INSERT INTO schema_migrations (version) VALUES ('20130427181103');

INSERT INTO schema_migrations (version) VALUES ('20130508110907');

INSERT INTO schema_migrations (version) VALUES ('20130514140920');

INSERT INTO schema_migrations (version) VALUES ('20130530095123');

INSERT INTO schema_migrations (version) VALUES ('20130530140724');

INSERT INTO schema_migrations (version) VALUES ('20130603131922');

INSERT INTO schema_migrations (version) VALUES ('20130604085432');

INSERT INTO schema_migrations (version) VALUES ('20130704104036');

INSERT INTO schema_migrations (version) VALUES ('20130705151553');