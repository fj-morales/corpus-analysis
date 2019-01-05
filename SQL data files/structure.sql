-- MySQL dump 10.13  Distrib 5.7.17, for macos10.12 (x86_64)
--
-- Host: localhost    Database: AWA
-- ------------------------------------------------------
-- Server version	5.7.18

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ANNOTATION`
--

DROP TABLE IF EXISTS ANNOTATION;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE ANNOTATION (
  annotation_id int(11) NOT NULL,
  annotation_label varchar(50) DEFAULT NULL,
  tool_id int(11) DEFAULT NULL,
  PRIMARY KEY (annotation_id),
  KEY tool_id (tool_id),
  CONSTRAINT annotation_ibfk_1 FOREIGN KEY (tool_id) REFERENCES TOOL (tool_id)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CORPUS`
--

DROP TABLE IF EXISTS CORPUS;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE CORPUS (
  corpus_id int(11) NOT NULL,
  corpus_label varchar(50) DEFAULT NULL,
  corpus_license tinyint(1) DEFAULT NULL,
  corpus_license_detail varchar(250) DEFAULT NULL,
  PRIMARY KEY (corpus_id)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `DOCUMENT`
--

DROP TABLE IF EXISTS DOCUMENT;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE DOCUMENT (
  document_label varchar(100) NOT NULL,
  document_category varchar(50) DEFAULT NULL,
  corpus_id int(11) NOT NULL,
  PRIMARY KEY (document_label,corpus_id),
  KEY corpus_id (corpus_id),
  CONSTRAINT document_ibfk_1 FOREIGN KEY (corpus_id) REFERENCES CORPUS (corpus_id)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SENTENCE`
--

DROP TABLE IF EXISTS SENTENCE;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE SENTENCE (
  sentence_id bigint(20) NOT NULL,
  sentence_detail varchar(2500) DEFAULT NULL,
  sentence_label varchar(350) DEFAULT NULL,
  document_label varchar(100) DEFAULT NULL,
  corpus_id int(11) DEFAULT NULL,
  PRIMARY KEY (sentence_id),
  KEY index_sentence_detail (sentence_detail),
  KEY index_sentence_document_id (document_label,corpus_id),
  CONSTRAINT sentence_ibfk_1 FOREIGN KEY (document_label, corpus_id) REFERENCES DOCUMENT (document_label, corpus_id)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SENTENCE_ANNOTATION`
--

DROP TABLE IF EXISTS SENTENCE_ANNOTATION;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE SENTENCE_ANNOTATION (
  sentence_id bigint(20) NOT NULL,
  tool_id int(11) NOT NULL,
  sentence_date date NOT NULL,
  annotation_id int(11) NOT NULL,
  prob_value float DEFAULT '0',
  PRIMARY KEY (sentence_id,tool_id,sentence_date,annotation_id),
  KEY tool_id (tool_id),
  KEY annotation_id (annotation_id),
  CONSTRAINT sentence_annotation_ibfk_1 FOREIGN KEY (sentence_id) REFERENCES SENTENCE (sentence_id),
  CONSTRAINT sentence_annotation_ibfk_2 FOREIGN KEY (tool_id) REFERENCES TOOL (tool_id),
  CONSTRAINT sentence_annotation_ibfk_3 FOREIGN KEY (annotation_id) REFERENCES ANNOTATION (annotation_id)
);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TOOL`
--

DROP TABLE IF EXISTS TOOL;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE TOOL (
  tool_id int(11) NOT NULL,
  tool_name varchar(50) DEFAULT NULL,
  tool_annotation varchar(50) DEFAULT NULL,
  PRIMARY KEY (tool_id)
);
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
