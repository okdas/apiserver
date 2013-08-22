-- Дамп структуры для таблица apiserver.bukkit_enchantment
CREATE TABLE IF NOT EXISTS `bukkit_enchantment` (
  `id` varchar(15) NOT NULL,
  `titleRu` varchar(50) NOT NULL,
  `titleEn` varchar(50) NOT NULL,
  `levelmax` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='существующие чары';



-- Дамп структуры для таблица apiserver.bukkit_material
CREATE TABLE IF NOT EXISTS `bukkit_material` (
  `id` varchar(15) NOT NULL,
  `titleRu` varchar(50) NOT NULL,
  `titleEn` varchar(50) NOT NULL,
  `imageUrl` mediumtext NOT NULL,
  `enchantability` int(3) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.server
CREATE TABLE IF NOT EXISTS `server` (
  `id` int(10) NOT NULL COMMENT 'serverId',
  `title` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='список серверов будет тут';



-- Дамп структуры для таблица apiserver.player
CREATE TABLE IF NOT EXISTS `player` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `pass` varchar(40) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_identity` (`name`),
  UNIQUE KEY `player_credentials` (`name`,`pass`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.subscription
CREATE TABLE IF NOT EXISTS `subscription` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `titleRu` varchar(45) NOT NULL,
  `titleEn` varchar(45) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enabledAt` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.subscription_price
CREATE TABLE IF NOT EXISTS `subscription_price` (
  `subscriptionId` int(10) NOT NULL AUTO_INCREMENT,
  `score` int(3) NOT NULL,
  `price` float NOT NULL,
  PRIMARY KEY (`subscriptionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- ############################### --


-- Дамп структуры для таблица apiserver.item
CREATE TABLE IF NOT EXISTS `item` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `material` varchar(15) NOT NULL,
  `titleRu` varchar(45) NOT NULL COMMENT 'Название предмета в магазине',
  `titleEn` varchar(45) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  `price` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `item_material` (`material`),
  CONSTRAINT `item_material` FOREIGN KEY (`material`) REFERENCES `bukkit_material` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.item_enchantment
CREATE TABLE IF NOT EXISTS `item_enchantment` (
  `itemId` int(10) NOT NULL,
  `enchantmentId` varchar(15) NOT NULL,
  `level` int(3) NOT NULL,
  `order` int(3) NOT NULL,
  KEY `item_enchantment_id_idx` (`enchantmentId`),
  KEY `item_id` (`itemId`),
  CONSTRAINT `item_enchantment_id` FOREIGN KEY (`enchantmentId`) REFERENCES `bukkit_enchantment` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `item_id` FOREIGN KEY (`itemId`) REFERENCES `item` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.player_item
CREATE TABLE IF NOT EXISTS `player_item` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `serverId` int(10) NOT NULL,
  `playerId` int(10) NOT NULL,
  `material` varchar(15) NOT NULL COMMENT 'Ссылка на айтем, который может иметь установленные в магазине чары',
  `titleRu` varchar(45) NOT NULL,
  `titleEn` varchar(45) NOT NULL,
  `name` varchar(45) DEFAULT NULL COMMENT 'имя предмета в игре',
  `amount` int(5) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `item_player_id` (`playerId`),
  KEY `item_server_id` (`serverId`),
  KEY `item_material_id` (`material`),
  CONSTRAINT `item_material_id` FOREIGN KEY (`material`) REFERENCES `bukkit_material` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `item_player_id` FOREIGN KEY (`playerId`) REFERENCES `player` (`id`),
  CONSTRAINT `item_server_id` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Предметы Игрока для Сервера';



-- Дамп структуры для таблица apiserver.player_item_enchantment
CREATE TABLE IF NOT EXISTS `player_item_enchantment` (
  `itemId` int(10) NOT NULL,
  `enchantmentId` varchar(45) NOT NULL,
  `level` int(3) NOT NULL,
  KEY `player_item_id` (`itemId`),
  KEY `player_item_enchantment_id` (`enchantmentId`),
  CONSTRAINT `player_item_enchantment_id` FOREIGN KEY (`enchantmentId`) REFERENCES `bukkit_enchantment` (`id`),
  CONSTRAINT `player_item_id` FOREIGN KEY (`itemId`) REFERENCES `player_item` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.player_order
CREATE TABLE IF NOT EXISTS `player_order` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `playerId` int(10) NOT NULL,
  `buyAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payAt` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_player_id` (`playerId`),
  CONSTRAINT `order_player_id` FOREIGN KEY (`playerId`) REFERENCES `player` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.player_order_items
CREATE TABLE IF NOT EXISTS `player_order_items` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `orderId` int(10) NOT NULL,
  `itemId` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`orderId`),
  KEY `order_item_id` (`itemId`),
  CONSTRAINT `order_id` FOREIGN KEY (`orderId`) REFERENCES `player_order` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_item_id` FOREIGN KEY (`itemId`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.player_payments
CREATE TABLE IF NOT EXISTS `player_payments` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `playerId` int(10) NOT NULL,
  `money` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `payments_player_id` (`playerId`),
  CONSTRAINT `payments_player_id` FOREIGN KEY (`playerId`) REFERENCES `player` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.player_server
CREATE TABLE IF NOT EXISTS `player_server` (
  `playerId` int(10) NOT NULL,
  `serverId` int(10) NOT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`playerId`,`serverId`),
  KEY `server_player_id` (`serverId`),
  CONSTRAINT `player_server_id` FOREIGN KEY (`playerId`) REFERENCES `player` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `server_player_id` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.player_shipment
CREATE TABLE IF NOT EXISTS `player_shipment` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `playerId` int(10) NOT NULL,
  `serverId` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `shipment_player_id` (`playerId`),
  KEY `shipment_server_id` (`serverId`),
  CONSTRAINT `shipment_player_id` FOREIGN KEY (`playerId`) REFERENCES `player` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `shipment_server_id` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.player_shipment_items
CREATE TABLE IF NOT EXISTS `player_shipment_items` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `plyerItemId` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `shipment_player_item_id` (`plyerItemId`),
  CONSTRAINT `shipment_player_item_id` FOREIGN KEY (`plyerItemId`) REFERENCES `player_item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.player_subscription
CREATE TABLE IF NOT EXISTS `player_subscription` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `playerId` int(10) NOT NULL,
  `subscriptionId` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `subscription_player_id` (`playerId`),
  KEY `subscription_id` (`subscriptionId`),
  CONSTRAINT `subscription_id` FOREIGN KEY (`subscriptionId`) REFERENCES `subscription` (`id`),
  CONSTRAINT `subscription_player_id` FOREIGN KEY (`playerId`) REFERENCES `player` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.server_instance
CREATE TABLE IF NOT EXISTS `server_instance` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `serverId` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `server_id_instance` (`serverId`),
  CONSTRAINT `server_id_instance` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- Дамп структуры для таблица apiserver.server_item
CREATE TABLE IF NOT EXISTS `server_item` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `serverId` int(10) NOT NULL,
  `itemId` int(10) NOT NULL,
  PRIMARY KEY (`id`,`serverId`,`itemId`),
  KEY `server_id` (`serverId`),
  KEY `server_item_id_item` (`itemId`),
  CONSTRAINT `server_id_item` FOREIGN KEY (`serverId`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `server_item_id_item` FOREIGN KEY (`itemId`) REFERENCES `item` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
