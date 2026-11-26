CREATE DATABASE IF NOT EXISTS `projeto` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `projeto`;

CREATE TABLE IF NOT EXISTS `atividade` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dia` date NOT NULL,
  `atividade` varchar(500) NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
