-- phpMyAdmin SQL Dump
-- version 3.3.7deb7
-- http://www.phpmyadmin.net
--
-- Serveur: localhost
-- Généré le : Mar 12 Mars 2013 à 16:25
-- Version du serveur: 5.1.66
-- Version de PHP: 5.3.3-7+squeeze14

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `predb`
--

-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `releases` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `rlsname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `grp` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `section` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `time` int(11) unsigned NOT NULL DEFAULT '0',
  `files` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `size` decimal(7,2) unsigned NOT NULL DEFAULT '0.00',
  `genre` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rlsname` (`rlsname`),
  KEY `grp` (`grp`),
  KEY `section` (`section`),
  KEY `time` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `spam` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `rlsname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `grp` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `section` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `time` int(11) unsigned NOT NULL DEFAULT '0',
  `files` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `size` decimal(7,2) unsigned NOT NULL DEFAULT '0.00',
  `genre` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rlsname` (`rlsname`),
  KEY `grp` (`grp`),
  KEY `section` (`section`),
  KEY `time` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `nukelog` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `rlsname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `time` int(11) unsigned NOT NULL DEFAULT '0',
  `reason` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `network` varchar(25) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` tinyint(1) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `rlsstatus` (`rlsname`,`reason`),
  KEY `time` (`time`),
  KEY `network` (`network`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `added` int(11) unsigned NOT NULL,
  `lastseen` int(11) unsigned NOT NULL,
  `passhash` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `secret` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `enabled` enum('yes','no') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'yes',
  `ip` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `enabled` (`enabled`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;