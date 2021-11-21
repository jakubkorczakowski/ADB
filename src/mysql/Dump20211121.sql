CREATE DATABASE  IF NOT EXISTS `ml_test` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `ml_test`;
-- MySQL dump 10.13  Distrib 8.0.27, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: ml_testing
-- ------------------------------------------------------
-- Server version	8.0.27

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `comment`
--

DROP TABLE IF EXISTS `comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `hypothesis_id` int DEFAULT NULL,
  `evaluation_id` int DEFAULT NULL,
  `comment` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `comment_idx` (`comment`),
  KEY `comment_hypothesis_id_fkey` (`hypothesis_id`),
  KEY `comment_evaluation_id_fkey` (`evaluation_id`),
  CONSTRAINT `comment_evaluation_id_fkey` FOREIGN KEY (`evaluation_id`) REFERENCES `evaluation` (`id`),
  CONSTRAINT `comment_hypothesis_id_fkey` FOREIGN KEY (`hypothesis_id`) REFERENCES `hypothesis` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment`
--

LOCK TABLES `comment` WRITE;
/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
INSERT INTO `comment` VALUES (1,1,1,'Invalid jump word handling'),(2,2,1,'No errors'),(3,3,1,'Invalid jump word handling'),(4,4,1,'Invalid jump word handling');
/*!40000 ALTER TABLE `comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `component`
--

DROP TABLE IF EXISTS `component`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `component` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `details` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `component_name_idx` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `component`
--

LOCK TABLES `component` WRITE;
/*!40000 ALTER TABLE `component` DISABLE KEYS */;
INSERT INTO `component` VALUES (1,'fixer','{\"input\": \"standard\"}'),(2,'normalizer','{\"input\": \"standard\"}'),(3,'acoustic model','{\"input\": \"standard\"}'),(4,'neural net','{\"input\": \"normalized\"}');
/*!40000 ALTER TABLE `component` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `corpus`
--

DROP TABLE IF EXISTS `corpus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `corpus` (
  `id` int NOT NULL AUTO_INCREMENT,
  `domain_id` int DEFAULT NULL,
  `lang_id` int DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `major_version` smallint DEFAULT NULL,
  `minor_version` smallint DEFAULT NULL,
  `bugfix_version` smallint DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `corpus_name_idx` (`name`),
  KEY `corpus_versions_idx` (`major_version`,`minor_version`,`bugfix_version`),
  KEY `corpus_created_at_idx` (`created_at`),
  KEY `corpus_domain_id_fkey` (`domain_id`),
  KEY `corpus_lang_id_fkey` (`lang_id`),
  CONSTRAINT `corpus_domain_id_fkey` FOREIGN KEY (`domain_id`) REFERENCES `domain` (`id`),
  CONSTRAINT `corpus_lang_id_fkey` FOREIGN KEY (`lang_id`) REFERENCES `lang` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `corpus`
--

LOCK TABLES `corpus` WRITE;
/*!40000 ALTER TABLE `corpus` DISABLE KEYS */;
INSERT INTO `corpus` VALUES (1,1,2,'mozilla-voice-general-corpora-en-gb',1,3,34,'2021-01-20'),(2,1,2,'voice-institute-am34-corpora-en-gb',21,4,0,'2021-08-21'),(3,3,4,'twitter-dev-corpora-pt-pt',123,6,1,'2021-05-06'),(4,3,1,'twitter-dev-corpora-de-de',125,6,1,'2021-05-06'),(5,2,1,'android-wakeup-corpora-de-de',125,6,1,'2020-11-12');
/*!40000 ALTER TABLE `corpus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `corpus_row`
--

DROP TABLE IF EXISTS `corpus_row`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `corpus_row` (
  `corpus_id` int NOT NULL,
  `row_id` int NOT NULL,
  PRIMARY KEY (`corpus_id`,`row_id`),
  KEY `corpus_row_row_id_fkey` (`row_id`),
  CONSTRAINT `corpus_row_corpus_id_fkey` FOREIGN KEY (`corpus_id`) REFERENCES `corpus` (`id`),
  CONSTRAINT `corpus_row_row_id_fkey` FOREIGN KEY (`row_id`) REFERENCES `row` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `corpus_row`
--

LOCK TABLES `corpus_row` WRITE;
/*!40000 ALTER TABLE `corpus_row` DISABLE KEYS */;
INSERT INTO `corpus_row` VALUES (1,1),(1,2),(2,3),(3,4),(3,5),(3,6),(5,7),(5,8),(4,9),(4,10);
/*!40000 ALTER TABLE `corpus_row` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domain`
--

DROP TABLE IF EXISTS `domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `domain` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `domain_name_idx` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domain`
--

LOCK TABLES `domain` WRITE;
/*!40000 ALTER TABLE `domain` DISABLE KEYS */;
INSERT INTO `domain` VALUES (3,'APP'),(1,'GENERAL'),(2,'GREETING'),(4,'PHONE');
/*!40000 ALTER TABLE `domain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evaluation`
--

DROP TABLE IF EXISTS `evaluation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evaluation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `model_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `report` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `is_completed_flag` bit(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `report_idx` (`report`),
  KEY `evaluation_model_id_fkey` (`model_id`),
  KEY `evaluation_user_id_fkey` (`user_id`),
  CONSTRAINT `evaluation_model_id_fkey` FOREIGN KEY (`model_id`) REFERENCES `model` (`id`),
  CONSTRAINT `evaluation_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evaluation`
--

LOCK TABLES `evaluation` WRITE;
/*!40000 ALTER TABLE `evaluation` DISABLE KEYS */;
INSERT INTO `evaluation` VALUES (1,1,1,'Model seems to do a bad job regarding number handling',_binary ''),(2,1,2,NULL,_binary '\0'),(3,1,3,NULL,_binary '\0'),(4,1,4,NULL,_binary '\0');
/*!40000 ALTER TABLE `evaluation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hypothesis`
--

DROP TABLE IF EXISTS `hypothesis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hypothesis` (
  `id` int NOT NULL AUTO_INCREMENT,
  `row_id` int DEFAULT NULL,
  `model_component_id` int DEFAULT NULL,
  `text` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `score` float(4,0) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `score_idx` (`score`),
  KEY `text_idx` (`text`),
  KEY `hypothesis_row_id_fkey` (`row_id`),
  KEY `hypothesis_model_component_id_fkey` (`model_component_id`),
  CONSTRAINT `hypothesis_model_component_id_fkey` FOREIGN KEY (`model_component_id`) REFERENCES `model_component` (`id`),
  CONSTRAINT `hypothesis_row_id_fkey` FOREIGN KEY (`row_id`) REFERENCES `row` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hypothesis`
--

LOCK TABLES `hypothesis` WRITE;
/*!40000 ALTER TABLE `hypothesis` DISABLE KEYS */;
INSERT INTO `hypothesis` VALUES (1,1,4,'quick brown fox jump over that lazy dog',1),(2,1,1,'quick brown fox jumps over the lazy dog',1),(3,1,2,'quick brown fox jumper over that lazy dog',1),(4,1,3,'quicker browner fox jump over that lazy dog',1);
/*!40000 ALTER TABLE `hypothesis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lang`
--

DROP TABLE IF EXISTS `lang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lang` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `name` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `is_essential_flag` bit(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `lang_idx` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lang`
--

LOCK TABLES `lang` WRITE;
/*!40000 ALTER TABLE `lang` DISABLE KEYS */;
INSERT INTO `lang` VALUES (1,'de-DE','german',_binary ''),(2,'es-ES','spanish',_binary ''),(3,'en-GB','english',_binary ''),(4,'pt-PT','portuguese',_binary '\0'),(5,'pl-PL','polish',_binary '\0');
/*!40000 ALTER TABLE `lang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model`
--

DROP TABLE IF EXISTS `model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `model` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int DEFAULT NULL,
  `type_id` int DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `major_version` smallint NOT NULL,
  `minor_version` smallint NOT NULL,
  `bugfix_version` smallint NOT NULL,
  `created_at` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `model_name_idx` (`name`),
  KEY `model_created_at_idx` (`created_at`),
  KEY `model_versions_idx` (`major_version`,`minor_version`,`bugfix_version`),
  KEY `model_type_id_fkey` (`type_id`),
  KEY `model_product_id_fkey` (`product_id`),
  CONSTRAINT `model_product_id_fkey` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  CONSTRAINT `model_type_id_fkey` FOREIGN KEY (`type_id`) REFERENCES `model_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model`
--

LOCK TABLES `model` WRITE;
/*!40000 ALTER TABLE `model` DISABLE KEYS */;
INSERT INTO `model` VALUES (1,1,1,'General ASR model',1,0,12,'2021-01-20'),(2,1,1,'General ASR model',2,0,12,'2021-11-20'),(3,1,2,'Lite ASR model',1,0,52,'2021-01-20'),(4,1,2,'Lite ASR model',4,0,67,'2021-09-24');
/*!40000 ALTER TABLE `model` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_component`
--

DROP TABLE IF EXISTS `model_component`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_component` (
  `id` int NOT NULL AUTO_INCREMENT,
  `model_id` int DEFAULT NULL,
  `component_id` int DEFAULT NULL,
  `order_number` smallint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_idx` (`order_number`),
  KEY `model_component_component_id_fkey` (`component_id`),
  KEY `model_component_model_id_fkey` (`model_id`),
  CONSTRAINT `model_component_component_id_fkey` FOREIGN KEY (`component_id`) REFERENCES `component` (`id`),
  CONSTRAINT `model_component_model_id_fkey` FOREIGN KEY (`model_id`) REFERENCES `model` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_component`
--

LOCK TABLES `model_component` WRITE;
/*!40000 ALTER TABLE `model_component` DISABLE KEYS */;
INSERT INTO `model_component` VALUES (1,1,1,4),(2,1,2,2),(3,1,3,1),(4,1,4,3);
/*!40000 ALTER TABLE `model_component` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_type`
--

DROP TABLE IF EXISTS `model_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `model_type_idx` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_type`
--

LOCK TABLES `model_type` WRITE;
/*!40000 ALTER TABLE `model_type` DISABLE KEYS */;
INSERT INTO `model_type` VALUES (1,'ASR'),(2,'ASR-lite'),(3,'MT'),(4,'TTS');
/*!40000 ALTER TABLE `model_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product_name_idx` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (2,'lite voice assistant'),(4,'android system'),(3,'twitter app'),(1,'voice assistant');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `can_view_analytics_flag` bit(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,'admin',_binary ''),(2,'developer',_binary ''),(3,'linguist',_binary '\0'),(4,'manager',_binary ''),(5,'data manager',_binary '\0');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `row`
--

DROP TABLE IF EXISTS `row`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `row` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reference` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `speaker_age` smallint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reference_idx` (`reference`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `row`
--

LOCK TABLES `row` WRITE;
/*!40000 ALTER TABLE `row` DISABLE KEYS */;
INSERT INTO `row` VALUES (1,'quick brown fox jumps over the lazy dog',40),(2,'slow white fox jumps over the crazy dog',40),(3,'lion is a king of the animal kingdom',40),(4,'*Es freut mich, dich kennenzulernen.',23),(5,'Wie geht''s?',23),(6,'Ich möchte ein Bier.',40),(7,'Guten Morgen. ',16),(8,'Guten Tag.',56),(9,'Elas comem batatas. ',22),(10,'Eu saí do parque.',23);
/*!40000 ALTER TABLE `row` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_id` int DEFAULT NULL,
  `name` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `surname` varchar(80) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `hourly_rate` decimal(19,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name_surname_idx` (`name`,`surname`),
  KEY `user_role_id_fkey` (`role_id`),
  CONSTRAINT `user_role_id_fkey` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,2,'jakub','korczakowski',100.00),(2,1,'jan','korczakowski',50.00),(3,3,'maciej','ciepelko',10.00),(4,3,'kacper','branicki',25.00),(5,3,'rafał','korsarz',45.00);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_lang`
--

DROP TABLE IF EXISTS `user_lang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_lang` (
  `user_id` int NOT NULL,
  `lang_id` int NOT NULL,
  `proficiency_level` smallint DEFAULT NULL,
  PRIMARY KEY (`user_id`,`lang_id`),
  KEY `user_lang_lang_id_fkey` (`lang_id`),
  CONSTRAINT `user_lang_lang_id_fkey` FOREIGN KEY (`lang_id`) REFERENCES `lang` (`id`),
  CONSTRAINT `user_lang_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_lang`
--

LOCK TABLES `user_lang` WRITE;
/*!40000 ALTER TABLE `user_lang` DISABLE KEYS */;
INSERT INTO `user_lang` VALUES (1,2,3),(1,3,1),(3,1,3),(3,2,1),(4,2,3),(4,4,3),(5,5,3);
/*!40000 ALTER TABLE `user_lang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_time`
--

DROP TABLE IF EXISTS `work_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_time` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `start_time` timestamp NOT NULL,
  `finish_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `start_time_idx` (`start_time`),
  KEY `finish_time_idx` (`finish_time`),
  KEY `work_time_user_id_fkey` (`user_id`),
  CONSTRAINT `work_time_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_time`
--

LOCK TABLES `work_time` WRITE;
/*!40000 ALTER TABLE `work_time` DISABLE KEYS */;
INSERT INTO `work_time` VALUES (1,1,'2021-10-08 04:05:07','2021-10-08 05:05:07'),(2,1,'2021-10-09 04:05:07','2021-10-09 04:56:07'),(3,1,'2021-10-09 10:20:05','2021-10-09 12:20:05'),(4,2,'2021-10-10 12:45:56','2021-10-10 14:45:56'),(5,3,'2021-10-09 08:13:03',NULL),(6,2,'2021-10-08 09:56:05','2021-10-08 10:15:05'),(7,5,'2021-10-08 15:44:57',NULL);
/*!40000 ALTER TABLE `work_time` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-11-21 15:04:57
