SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `TapTalk` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `TapTalk` ;

-- -----------------------------------------------------
-- Table `TapTalk`.`businessCustomers`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `TapTalk`.`businessCustomers` (
  `name` VARCHAR(32) NOT NULL ,
  `businessID` INT NOT NULL ,
  `picture` VARCHAR(45) NULL ,
  `dateJoined` DATETIME NULL ,
  `dateDeleted` DATETIME NULL ,
  `active` INT NULL ,
  `description` VARCHAR(256) NULL ,
  `activities` VARCHAR(1024) NULL ,
  `products` BLOB NOT NULL ,
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) ,
  PRIMARY KEY (`name`, `businessID`) ,
  UNIQUE INDEX `businessID_UNIQUE` (`businessID` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TapTalk`.`businessCustomersRatings`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `TapTalk`.`businessCustomersRatings` (
  `businessID` INT NOT NULL ,
  `service` INT ZEROFILL NULL ,
  `products` INT ZEROFILL NULL ,
  `ambiance` INT ZEROFILL NULL ,
  `avg` VARCHAR(45) NULL ,
  PRIMARY KEY (`businessID`) ,
  UNIQUE INDEX `businessID_UNIQUE` (`businessID` ASC) ,
  INDEX `businessID` (`businessID` ASC) ,
  CONSTRAINT `businessID`
    FOREIGN KEY (`businessID` )
    REFERENCES `TapTalk`.`businessCustomers` (`businessID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TapTalk`.`businessCategories`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `TapTalk`.`businessCategories` (
  `name` VARCHAR(24) NOT NULL ,
  `businessID` INT NULL ,
  `icon` BLOB NULL ,
  `description` VARCHAR(1024) NULL ,
  PRIMARY KEY (`name`) ,
  INDEX `businessID` (`businessID` ASC) ,
  CONSTRAINT `businessID`
    FOREIGN KEY (`businessID` )
    REFERENCES `TapTalk`.`businessCustomers` (`businessID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
