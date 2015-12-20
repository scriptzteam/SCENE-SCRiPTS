-- Base de données: `TopClient`
--

-- --------------------------------------------------------

--
-- Structure de la table `COVER`
--

CREATE TABLE IF NOT EXISTS `COVER` (
  `Release_ID` int(10) NOT NULL,
  `Content` longtext character set latin1 collate latin1_bin NOT NULL,
  `Filename` varchar(255) NOT NULL,
  PRIMARY KEY  (`Release_ID`),
  UNIQUE KEY `Primaire` (`Release_ID`,`Filename`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `indexInCache`
--

CREATE TABLE IF NOT EXISTS `indexInCache` (
  `type` varchar(255) NOT NULL,
  `release` varchar(255) NOT NULL,
  `time` datetime NOT NULL,
  `user` varchar(255) NOT NULL,
  `channel` varchar(255) NOT NULL,
  `bot` varchar(255) NOT NULL,
  `network` varchar(255) NOT NULL,
  KEY `type_rel_net` (`type`(5),`release`(10),`network`(5))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `Index_Adding`
--

CREATE TABLE IF NOT EXISTS `Index_Adding` (
  `Release_ID` int(10) NOT NULL,
  `ADDOLD` enum('0','1') NOT NULL default '0',
  `NEWDIR` enum('0','1') NOT NULL default '0',
  `SITEPRE` enum('0','1') NOT NULL default '0',
  `TOPNEWDIR` enum('0','1') NOT NULL default '0',
  `TOPSITEPRE` enum('0','1') NOT NULL default '0',
  PRIMARY KEY  (`Release_ID`),
  KEY `ADDOLD` (`ADDOLD`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `Infos`
--

CREATE TABLE IF NOT EXISTS `Infos` (
  `Release_ID` int(10) NOT NULL,
  `Release_File` varchar(10) NOT NULL,
  `Release_Size` varchar(10) NOT NULL,
  PRIMARY KEY  (`Release_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `JPG`
--

CREATE TABLE IF NOT EXISTS `JPG` (
  `Release_ID` int(10) NOT NULL,
  `Content` longtext character set latin1 collate latin1_bin NOT NULL,
  `Filename` varchar(255) NOT NULL,
  PRIMARY KEY  (`Release_ID`),
  UNIQUE KEY `Primaire` (`Release_ID`,`Filename`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `M3U`
--

CREATE TABLE IF NOT EXISTS `M3U` (
  `Release_ID` int(10) NOT NULL,
  `Content` longtext character set latin1 collate latin1_bin NOT NULL,
  `Filename` varchar(255) NOT NULL,
  PRIMARY KEY  (`Release_ID`),
  UNIQUE KEY `Primaire` (`Release_ID`,`Filename`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `NFO`
--

CREATE TABLE IF NOT EXISTS `NFO` (
  `Release_ID` int(10) NOT NULL,
  `Content` longtext character set latin1 collate latin1_bin NOT NULL,
  `Filename` varchar(255) NOT NULL,
  PRIMARY KEY  (`Release_ID`),
  UNIQUE KEY `Primaire` (`Release_ID`,`Filename`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `ReleaseTime`
--

CREATE TABLE IF NOT EXISTS `ReleaseTime` (
  `Release_ID` int(10) unsigned NOT NULL auto_increment,
  `Release_Name` varchar(255) NOT NULL,
  `Release_Time` int(10) NOT NULL,
  `Release_Section` varchar(255) NOT NULL default 'Other',
  PRIMARY KEY  (`Release_Name`),
  KEY `Release_ID` (`Release_ID`),
  KEY `Release_Time` (`Release_Time`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `SFV`
--

CREATE TABLE IF NOT EXISTS `SFV` (
  `Release_ID` int(10) NOT NULL,
  `Content` longtext character set latin1 collate latin1_bin NOT NULL,
  `Filename` varchar(255) NOT NULL,
  PRIMARY KEY  (`Release_ID`),
  UNIQUE KEY `Primaire` (`Release_ID`,`Filename`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `Styles`
--

CREATE TABLE IF NOT EXISTS `Styles` (
  `Release_ID` int(10) NOT NULL,
  `Release_Style` varchar(255) NOT NULL,
  UNIQUE KEY `Release_ID` (`Release_ID`,`Release_Style`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
