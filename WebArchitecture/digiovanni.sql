CREATE DATABASE  IF NOT EXISTS `digiovanni` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `digiovanni`;
-- MySQL dump 10.13  Distrib 5.7.17, for macos10.12 (x86_64)
--
-- Host: localhost    Database: digiovanni
-- ------------------------------------------------------
-- Server version	8.0.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Dipendente`
--

DROP TABLE IF EXISTS `Dipendente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Dipendente` (
  `nome` varchar(45) DEFAULT NULL,
  `cognome` varchar(45) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `password` char(32) DEFAULT NULL,
  `tipoDipendente` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`email`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Dipendente`
--

LOCK TABLES `Dipendente` WRITE;
/*!40000 ALTER TABLE `Dipendente` DISABLE KEYS */;
/*!40000 ALTER TABLE `Dipendente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Lettino`
--

DROP TABLE IF EXISTS `Lettino`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Lettino` (
  `prezzo` double DEFAULT NULL,
  `isOccupato` varchar(5) DEFAULT NULL,
  `fila` varchar(45) NOT NULL,
  `numero` int(11) NOT NULL,
  PRIMARY KEY (`fila`,`numero`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Lettino`
--

LOCK TABLES `Lettino` WRITE;
/*!40000 ALTER TABLE `Lettino` DISABLE KEYS */;
INSERT INTO `Lettino` VALUES (7,'false','prima',1),(7,'false','prima',2),(7,'false','prima',3),(7,'false','prima',4),(5,'false','seconda',1),(5,'false','seconda',2),(5,'false','seconda',3),(5,'false','seconda',4),(2.5,'false','terza',1),(2.5,'false','terza',2),(2.5,'false','terza',3),(2.5,'false','terza',4);
/*!40000 ALTER TABLE `Lettino` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Prenotazione`
--

DROP TABLE IF EXISTS `Prenotazione`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Prenotazione` (
  `idPrenotazione` int(11) NOT NULL,
  `refUtente` varchar(100) DEFAULT NULL,
  `isPagata` varchar(5) DEFAULT NULL,
  `refFila` varchar(45) DEFAULT NULL,
  `refNumero` int(11) DEFAULT NULL,
  PRIMARY KEY (`idPrenotazione`),
  KEY `refUtente_idx` (`refUtente`),
  KEY `refFila, refNumero_idx` (`refFila`,`refNumero`),
  CONSTRAINT `refFila, refNumero` FOREIGN KEY (`refFila`, `refNumero`) REFERENCES `lettino` (`fila`, `numero`),
  CONSTRAINT `refUtente` FOREIGN KEY (`refUtente`) REFERENCES `utente` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Prenotazione`
--

LOCK TABLES `Prenotazione` WRITE;
/*!40000 ALTER TABLE `Prenotazione` DISABLE KEYS */;
/*!40000 ALTER TABLE `Prenotazione` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Utente`
--

DROP TABLE IF EXISTS `Utente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Utente` (
  `nome` varchar(45) DEFAULT NULL,
  `cognome` varchar(45) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `dataNascita` date DEFAULT NULL,
  `password` char(32) DEFAULT NULL,
  `tipoUtente` int(11) DEFAULT NULL,
  PRIMARY KEY (`email`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Utente`
--

LOCK TABLES `Utente` WRITE;
/*!40000 ALTER TABLE `Utente` DISABLE KEYS */;
INSERT INTO `Utente` VALUES ('Alessandro','Di Giovanni','alebros@hotmail.it','1997-09-11','96666',1),('Carlo','Bianchi','carlo.bianchi@gmail.com','2014-12-29','94431319',2),('Carlo','Neri','carlo.neri@gmail.com','2014-12-29','94431319',3),('Leo','Messi','lionel-messi@gmail.com','2019-11-26','1102633533',1),('Mario','Rossi','mario.rossi@gmail.com','2014-12-29','103666436',2),('Roberto','Bianchi','roberto.bianchi@gmail.com','1997-12-30','1262646515',1);
/*!40000 ALTER TABLE `Utente` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-09-08 11:09:00
