-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           10.4.20-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Copiando estrutura do banco de dados para vrp_base
CREATE DATABASE IF NOT EXISTS `vrp_base` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `vrp_base`;

-- Copiando estrutura para tabela vrp_base.vrp_faturas
CREATE TABLE IF NOT EXISTS `vrp_faturas` (
  `user_id` int(11) NOT NULL,
  `sender` int(11) NOT NULL,
  `valor` int(20) NOT NULL,
  `motivo` text DEFAULT NULL,
  `descricao` text DEFAULT NULL,
  `data` varchar(50) DEFAULT NULL,
  `pago` int(1) NOT NULL DEFAULT 0,
  `recebido` int(11) NOT NULL DEFAULT 0,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4;

-- Copiando dados para a tabela vrp_base.vrp_faturas: ~44 rows (aproximadamente)
/*!40000 ALTER TABLE `vrp_faturas` DISABLE KEYS */;
/*!40000 ALTER TABLE `vrp_faturas` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
