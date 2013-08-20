-- Дамп структуры базы данных apiserver_dev
CREATE DATABASE IF NOT EXISTS `apiserver_dev` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `apiserver_dev`;


-- Дамп структуры для таблица apiserver_dev.forum
CREATE TABLE IF NOT EXISTS `forum` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.forum_post
CREATE TABLE IF NOT EXISTS `forum_post` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `threadId` int(10) NOT NULL,
  `content` varchar(50) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `thread_id_FK1` (`threadId`),
  CONSTRAINT `thread_id_FK1` FOREIGN KEY (`threadId`) REFERENCES `forum_thread` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.forum_section
CREATE TABLE IF NOT EXISTS `forum_section` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `forumId` int(10) NOT NULL,
  `title` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `forum_id_FK1` (`forumId`),
  CONSTRAINT `forum_id_FK1` FOREIGN KEY (`forumId`) REFERENCES `forum` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.forum_thread
CREATE TABLE IF NOT EXISTS `forum_thread` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `sectionId` int(10) NOT NULL,
  `title` varchar(50) NOT NULL,
  `content` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `section_id_FK1` (`sectionId`),
  CONSTRAINT `section_id_FK1` FOREIGN KEY (`sectionId`) REFERENCES `forum_section` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.item
CREATE TABLE IF NOT EXISTS `item` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `material` int(10) NOT NULL,
  `title` varchar(50) NOT NULL,
  `price` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `material_id_FK1` (`material`),
  CONSTRAINT `material_id_FK1` FOREIGN KEY (`material`) REFERENCES `material` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.material
CREATE TABLE IF NOT EXISTS `material` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `materialId` varchar(50) NOT NULL,
  `title` varchar(50) DEFAULT NULL,
  `enchantability` int(3) DEFAULT NULL,
  PRIMARY KEY (`id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.permissions
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `permission` varchar(200) NOT NULL,
  `world` varchar(50) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique` (`name`,`permission`,`world`,`type`),
  KEY `user` (`name`,`type`),
  KEY `world` (`world`,`name`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.permissions_entity
CREATE TABLE IF NOT EXISTS `permissions_entity` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `prefix` varchar(255) NOT NULL,
  `suffix` varchar(255) NOT NULL,
  `default` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `default` (`default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.permissions_inheritance
CREATE TABLE IF NOT EXISTS `permissions_inheritance` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `child` varchar(50) NOT NULL,
  `parent` varchar(50) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `world` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `child` (`child`,`parent`,`type`,`world`),
  KEY `child_2` (`child`,`type`),
  KEY `parent` (`parent`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.player
CREATE TABLE IF NOT EXISTS `player` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `pass` varchar(50) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `balance` int(11) DEFAULT '0',
  `email` varchar(50) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `pass_INDEX` (`pass`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.player_log
CREATE TABLE IF NOT EXISTS `player_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL,
  `event` varchar(50) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.player_payment
CREATE TABLE IF NOT EXISTS `player_payment` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `playerId` int(10) NOT NULL,
  `amount` int(5) NOT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `closedAt` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payment_player_idx` (`playerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.player_subscription
CREATE TABLE IF NOT EXISTS `player_subscription` (
  `playerId` int(10) NOT NULL,
  `subscriptionId` int(10) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expiredAt` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `score` int(5) NOT NULL DEFAULT '0',
  PRIMARY KEY (`playerId`,`subscriptionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.player_subscriptions
CREATE TABLE IF NOT EXISTS `player_subscriptions` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `playerId` int(10) NOT NULL,
  `subscriptionId` int(10) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expiredAt` timestamp NOT NULL DEFAULT '2038-01-19 03:14:07',
  PRIMARY KEY (`id`),
  KEY `subscription_player_fk_idx` (`playerId`),
  KEY `player_subscription_subscription_fk_idx` (`subscriptionId`),
  CONSTRAINT `player_subscription_player_fk` FOREIGN KEY (`playerId`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `player_subscription_subscription_fk` FOREIGN KEY (`subscriptionId`) REFERENCES `subscription` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.server
CREATE TABLE IF NOT EXISTS `server` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  `key` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.server_instance
CREATE TABLE IF NOT EXISTS `server_instance` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `serverId` int(10) NOT NULL,
  `title` varchar(50) DEFAULT NULL,
  `host` varchar(50) DEFAULT NULL,
  `port` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `server_id_instance_FK1` (`serverId`),
  CONSTRAINT `server_id_instance_FK1` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.server_secret
CREATE TABLE IF NOT EXISTS `server_secret` (
  `serverId` int(10) NOT NULL,
  `key` varchar(50) NOT NULL,
  PRIMARY KEY (`serverId`),
  KEY `serverId` (`serverId`),
  CONSTRAINT `server_FK1` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.server_stat
CREATE TABLE IF NOT EXISTS `server_stat` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `serverId` int(10) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `numplayers` int(10) unsigned NOT NULL DEFAULT '0',
  `maxplayers` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `serverId_FK1` (`serverId`),
  CONSTRAINT `serverId_FK1` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.storage_item
CREATE TABLE IF NOT EXISTS `storage_item` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `itemId` int(10) NOT NULL,
  `playerId` int(10) NOT NULL,
  `serverId` int(10) NOT NULL,
  `amount` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`,`itemId`),
  KEY `storage_item_player` (`playerId`),
  KEY `storage_item_server` (`serverId`),
  KEY `storage_item_id` (`itemId`),
  CONSTRAINT `storage_item_id` FOREIGN KEY (`itemId`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `storage_item_player` FOREIGN KEY (`playerId`) REFERENCES `player` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `storage_item_server` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.storage_item_enchantments
CREATE TABLE IF NOT EXISTS `storage_item_enchantments` (
  `itemId` int(10) NOT NULL,
  `enchantmentId` int(10) NOT NULL,
  `level` int(3) NOT NULL,
  `order` int(3) DEFAULT NULL,
  PRIMARY KEY (`itemId`,`enchantmentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.storage_shipment
CREATE TABLE IF NOT EXISTS `storage_shipment` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `playerId` int(10) NOT NULL,
  `serverId` int(10) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `closedAt` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `storage_shipment_player_index` (`playerId`),
  KEY `storage_shipment_server_index` (`serverId`),
  CONSTRAINT `shipment_server_FK2` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `shipment_player_FK1` FOREIGN KEY (`playerId`) REFERENCES `player` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.storage_shipment_item
CREATE TABLE IF NOT EXISTS `storage_shipment_item` (
  `shipmentId` int(10) NOT NULL,
  `itemId` int(10) NOT NULL,
  `amount` int(5) NOT NULL,
  PRIMARY KEY (`shipmentId`,`itemId`),
  KEY `storage_item_shipment_fk_idx` (`shipmentId`),
  KEY `storage_shipment_item_fk_idx` (`itemId`),
  CONSTRAINT `storage_shipment_item_fk` FOREIGN KEY (`itemId`) REFERENCES `storage_item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `storage_item_shipment_fk` FOREIGN KEY (`shipmentId`) REFERENCES `storage_shipment` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.store_enchantment
CREATE TABLE IF NOT EXISTS `store_enchantment` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `identity` varchar(50) NOT NULL,
  `levelmax` int(3) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.store_item
CREATE TABLE IF NOT EXISTS `store_item` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `imageUrl` text NOT NULL,
  `material` varchar(50) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `price` float NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.store_item_enchantments
CREATE TABLE IF NOT EXISTS `store_item_enchantments` (
  `itemId` int(10) NOT NULL,
  `enchantmentId` int(10) NOT NULL,
  `level` int(3) NOT NULL,
  `order` int(3) DEFAULT NULL,
  PRIMARY KEY (`itemId`,`enchantmentId`),
  KEY `store_enchantment_item_FK_idx` (`itemId`),
  KEY `store_item_enchantment_FK_idx` (`enchantmentId`),
  CONSTRAINT `store_enchantment_item_FK` FOREIGN KEY (`itemId`) REFERENCES `store_item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `store_item_enchantment_FK` FOREIGN KEY (`enchantmentId`) REFERENCES `store_enchantment` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.store_item_servers
CREATE TABLE IF NOT EXISTS `store_item_servers` (
  `itemId` int(10) NOT NULL,
  `serverId` int(10) NOT NULL,
  PRIMARY KEY (`itemId`,`serverId`),
  KEY `store_item_server` (`serverId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.store_order
CREATE TABLE IF NOT EXISTS `store_order` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `playerId` varchar(50) NOT NULL,
  `price` float NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.store_order_items
CREATE TABLE IF NOT EXISTS `store_order_items` (
  `orderId` int(10) NOT NULL,
  `itemId` int(10) NOT NULL,
  `serverId` int(10) NOT NULL,
  `amount` int(10) NOT NULL,
  PRIMARY KEY (`orderId`,`itemId`,`serverId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.subscription
CREATE TABLE IF NOT EXISTS `subscription` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `enabledAt` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.subscription_price
CREATE TABLE IF NOT EXISTS `subscription_price` (
  `subscriptionId` int(10) NOT NULL,
  `score` int(5) NOT NULL DEFAULT '0',
  `price` int(5) NOT NULL,
  PRIMARY KEY (`subscriptionId`,`score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.users_permission
CREATE TABLE IF NOT EXISTS `users_permission` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.users_role
CREATE TABLE IF NOT EXISTS `users_role` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.users_role_permissions
CREATE TABLE IF NOT EXISTS `users_role_permissions` (
  `roleId` int(10) NOT NULL,
  `permissionId` int(10) NOT NULL,
  PRIMARY KEY (`roleId`,`permissionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.users_session
CREATE TABLE IF NOT EXISTS `users_session` (
  `id` varchar(255) NOT NULL,
  `data` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.users_user
CREATE TABLE IF NOT EXISTS `users_user` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `pass` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver_dev.users_user_roles
CREATE TABLE IF NOT EXISTS `users_user_roles` (
  `userId` int(10) NOT NULL,
  `roleId` int(10) NOT NULL,
  PRIMARY KEY (`userId`,`roleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
