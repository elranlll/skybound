-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 23, 2024 at 04:09 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `skybound`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ClearOldAuditRows` (IN `table_name` VARCHAR(255))   BEGIN
    SET @query = CONCAT('DELETE FROM ', table_name, ' WHERE action_timestamp < NOW() - INTERVAL 1 MONTH;');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertPassenger` (IN `passenger_id` INT, IN `first_name` VARCHAR(255), IN `last_name` VARCHAR(255), IN `email` VARCHAR(255), IN `phone_number` VARCHAR(15), IN `passport_number` VARCHAR(20), IN `nationality` VARCHAR(100), IN `passport_expiry_date` DATE, IN `timestamp` TIMESTAMP)   BEGIN
    INSERT INTO passenger_info (
        passenger_id, 
        first_name, 
        last_name, 
        email, 
        phone_number, 
        passport_number, 
        nationality, 
        passport_expiry_date, 
        `timestamp`
    ) VALUES (
        passenger_id, 
        first_name, 
        last_name, 
        email, 
        phone_number, 
        passport_number, 
        nationality, 
        passport_expiry_date, 
        `timestamp`
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `restore_deleted_data` (IN `_table_name` VARCHAR(50), IN `_audit_id` INT)   BEGIN
    DECLARE `action_type` ENUM('INSERT', 'UPDATE', 'DELETE');
    DECLARE `data` JSON;
    DECLARE `id` INT;

    -- Determine which audit table to use based on the table name
    IF _table_name = 'aircraft' THEN
        SELECT action_type, aircraft_data 
        INTO action_type, data
        FROM audit_aircraft 
        WHERE audit_id = _audit_id 
        LIMIT 1; 

        SET id = JSON_UNQUOTE(JSON_EXTRACT(data, '$.aircraft_id'));
        INSERT INTO aircraft (aircraft_id, aircraft_number, aircraft_model, timestamp) 
        VALUES (
            id,
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.aircraft_number')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.aircraft_model')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.timestamp'))
        );

    ELSEIF _table_name = 'airport' THEN
        SELECT action_type, airport_data 
        INTO action_type, data
        FROM audit_airport 
        WHERE audit_id = _audit_id 
        LIMIT 1; 

        SET id = JSON_UNQUOTE(JSON_EXTRACT(data, '$.airport_id'));
        INSERT INTO airport (airport_id, airport_name, country, airport_code, flight_type_id, timestamp) 
        VALUES (
            id,
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.airport_name')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.country')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.airport_code')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.flight_type_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.timestamp'))
        );

    ELSEIF _table_name = 'booking' THEN
        SELECT action_type, booking_data 
        INTO action_type, data
        FROM audit_booking 
        WHERE audit_id = _audit_id 
        LIMIT 1;

        SET id = JSON_UNQUOTE(JSON_EXTRACT(data, '$.booking_id'));
        INSERT INTO booking (booking_id, passenger_id, flight_id, timestamp)
        VALUES (
            id,
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.passenger_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.flight_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.timestamp'))
        );

    ELSEIF _table_name = 'flights' THEN
        SELECT action_type, flight_data 
        INTO action_type, data
        FROM audit_flights 
        WHERE audit_id = _audit_id 
        LIMIT 1;

        SET id = JSON_UNQUOTE(JSON_EXTRACT(data, '$.flight_id'));
        INSERT INTO flights (flight_id, flight_number, gate_number, flight_date, reference_number, origin_airport_id, destination_airport_id, departure_time, arrival_time, layover_id, class_id, price, aircraft_id, type_id, timestamp)
        VALUES (
            id,
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.flight_number')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.gate_number')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.flight_date')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.reference_number')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.origin_airport_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.destination_airport_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.departure_time')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.arrival_time')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.layover_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.class_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.price')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.aircraft_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.type_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.timestamp'))
        );

    ELSEIF _table_name = 'flight_duration' THEN
        SELECT action_type, duration_data 
        INTO action_type, data
        FROM audit_flight_duration 
        WHERE audit_id = _audit_id 
        LIMIT 1;

        SET id = JSON_UNQUOTE(JSON_EXTRACT(data, '$.duration_id'));
        INSERT INTO flight_duration (duration_id, origin_airport_id, destination_airport_id, base_duration, miles, timestamp)
        VALUES (
            id,
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.origin_airport_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.destination_airport_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.base_duration')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.miles')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.timestamp'))
        );

    ELSEIF _table_name = 'flight_pricing' THEN
        SELECT action_type, pricing_data 
        INTO action_type, data
        FROM audit_flight_pricing 
        WHERE audit_id = _audit_id 
        LIMIT 1;

        SET id = JSON_UNQUOTE(JSON_EXTRACT(data, '$.pricing_id'));
        INSERT INTO flight_pricing (pricing_id, origin_airport_id, destination_airport_id, base_price, haul_id, timestamp)
        VALUES (
            id,
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.origin_airport_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.destination_airport_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.base_price')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.haul_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.timestamp'))
        );

    ELSEIF _table_name = 'layover' THEN
        SELECT action_type, layover_data 
        INTO action_type, data
        FROM audit_layover 
        WHERE audit_id = _audit_id 
        LIMIT 1;

        SET id = JSON_UNQUOTE(JSON_EXTRACT(data, '$.layover_id'));
        INSERT INTO layover (layover_id, origin_airport_id, destination_airport_id, layover_status, layover_airport_id, timestamp)
        VALUES (
            id,
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.origin_airport_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.destination_airport_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.layover_status')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.layover_airport_id')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.timestamp'))
        );

    ELSEIF _table_name = 'passenger_info' THEN
        SELECT action_type, passenger_data 
        INTO action_type, data
        FROM audit_passenger_info 
        WHERE audit_id = _audit_id 
        LIMIT 1;

        SET id = JSON_UNQUOTE(JSON_EXTRACT(data, '$.passenger_id'));
        INSERT INTO passenger_info (passenger_id, first_name, last_name, email, phone_number, passport_number, nationality, passport_expiry_date, timestamp)
        VALUES (
            id,
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.first_name')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.last_name')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.email')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.phone_number')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.passport_number')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.nationality')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.passport_expiry_date')),
            JSON_UNQUOTE(JSON_EXTRACT(data, '$.timestamp'))
        );

    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_flight_status` ()   BEGIN
    UPDATE flights
    SET status = CASE
        WHEN NOW() < departure_time THEN 'Scheduled'
        WHEN NOW() BETWEEN departure_time AND departure_time + INTERVAL 15 MINUTE THEN 'Boarding'
        WHEN NOW() BETWEEN departure_time + INTERVAL 15 MINUTE AND arrival_time THEN 'In Route'
        WHEN NOW() > arrival_time THEN 'Arrived'
        ELSE 'Unknown'
    END;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `aircraft`
--

CREATE TABLE `aircraft` (
  `aircraft_id` int(11) NOT NULL,
  `aircraft_number` varchar(50) NOT NULL,
  `aircraft_model` varchar(100) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `aircraft`
--

INSERT INTO `aircraft` (`aircraft_id`, `aircraft_number`, `aircraft_model`, `timestamp`) VALUES
(1, 'A380-100', 'Airbus A380', '2024-12-13 04:54:58'),
(2, 'A380-800', 'Airbus A380', '2024-12-13 04:54:58'),
(3, 'A350-900', 'Airbus A350', '2024-12-13 04:54:58'),
(4, 'A350-1010', 'Airbus A350', '2024-12-15 20:54:46'),
(5, 'A330-300', 'Airbus A330', '2024-12-13 04:54:58'),
(6, 'A330-900neo', 'Airbus A330neo', '2024-12-13 04:54:58'),
(7, 'A320-200', 'Airbus A320', '2024-12-13 04:54:58'),
(8, 'A321-200', 'Airbus A321', '2024-12-13 04:54:58'),
(9, 'A321neo', 'Airbus A321neo', '2024-12-13 04:54:58'),
(10, 'B777-300ER', 'Boeing 777', '2024-12-13 04:54:58'),
(11, 'B777-9', 'Boeing 777X', '2024-12-13 04:54:58'),
(12, 'B787-8', 'Boeing 787 Dreamliner', '2024-12-13 04:54:58'),
(13, 'B787-9', 'Boeing 787 Dreamliner', '2024-12-13 04:54:58'),
(14, 'B787-10', 'Boeing 787 Dreamliner', '2024-12-13 04:54:58'),
(15, 'B737-800', 'Boeing 737', '2024-12-13 04:54:58'),
(16, 'B737 MAX 8', 'Boeing 737 MAX', '2024-12-13 04:54:58'),
(17, 'B737 MAX 9', 'Boeing 737 MAX', '2024-12-13 04:54:58'),
(18, 'B737 MAX 10', 'Boeing 737 MAX', '2024-12-13 04:54:58'),
(19, 'ERJ-145', 'Embraer E-Jet E2', '2024-12-13 04:54:58'),
(20, 'E190-E2', 'Embraer E-Jet E2', '2024-12-13 04:54:58'),
(21, 'E195-E2', 'Embraer E-Jet E2', '2024-12-13 04:54:58'),
(22, 'CRJ900', 'Bombardier CRJ900', '2024-12-13 04:54:58'),
(23, 'CRJ1000', 'Bombardier CRJ1000', '2024-12-13 04:54:58'),
(24, 'ATR 72-600', 'ATR 72', '2024-12-13 04:54:58'),
(25, 'ATR 42-600', 'ATR 42', '2024-12-13 04:54:58'),
(26, 'DHC-8-400', 'De Havilland Canada Dash 8', '2024-12-13 04:54:58'),
(27, 'PC-12', 'Pilatus PC-12', '2024-12-13 04:54:58'),
(28, 'Cessna Citation X', 'Cessna Citation CC-112', '2024-12-14 15:13:01'),
(29, 'Gulfstream G650', 'Gulfstream G650', '2024-12-13 04:54:58'),
(30, 'Global 7500', 'Bombardier Global 7500', '2024-12-13 04:54:58'),
(31, 'A380-200', 'Airbus A380', '2024-12-13 04:54:58'),
(32, 'A350-900ULR', 'Airbus A350', '2024-12-13 04:54:58'),
(33, 'A330-200', 'Airbus A330', '2024-12-13 04:54:58'),
(34, 'A320neo', 'Airbus A320neo', '2024-12-13 04:54:58'),
(35, 'A321LR', 'Airbus A321LR', '2024-12-13 04:54:58'),
(36, 'B777-200LR', 'Boeing 777', '2024-12-13 04:54:58'),
(37, 'B787-3', 'Boeing 787 Dreamliner', '2024-12-13 04:54:58'),
(38, 'B737-700', 'Boeing 737', '2024-12-13 04:54:58'),
(39, 'E175', 'Embraer E-Jet E2', '2024-12-13 04:54:58'),
(40, 'CRJ200', 'Bombardier CRJ200', '2024-12-13 04:54:58'),
(41, 'ATR 72-500', 'ATR 72', '2024-12-13 04:54:58'),
(42, 'DHC-8-300', 'De Havilland Canada Dash 8', '2024-12-13 04:54:58'),
(43, 'Cessna Citation Latitude', 'Cessna Citation', '2024-12-13 04:54:58'),
(44, 'Gulfstream G550', 'Gulfstream G550', '2024-12-13 04:54:58'),
(45, 'Global 6500', 'Bombardier Global 6500', '2024-12-13 04:54:58'),
(46, 'A380-800F', 'Airbus A380F', '2024-12-13 04:54:58'),
(47, 'A330-200F', 'Airbus A330F', '2024-12-13 04:54:58'),
(48, 'B777F', 'Boeing 777F', '2024-12-13 04:54:58'),
(49, 'B747-8F', 'Boeing 747-8F', '2024-12-13 04:54:58'),
(54, 'B767-350F', 'Boeing 767-300F', '2024-12-14 07:02:09');

--
-- Triggers `aircraft`
--
DELIMITER $$
CREATE TRIGGER `after_aircraft_delete` AFTER DELETE ON `aircraft` FOR EACH ROW BEGIN
    INSERT INTO audit_aircraft (action_type, aircraft_id, aircraft_data) 
    VALUES ('DELETE', OLD.aircraft_id, JSON_OBJECT('aircraft_number', OLD.aircraft_number, 'aircraft_model', OLD.aircraft_model, 'timestamp', OLD.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_aircraft_insert` AFTER INSERT ON `aircraft` FOR EACH ROW BEGIN
    INSERT INTO audit_aircraft (action_type, aircraft_id, aircraft_data) 
    VALUES ('INSERT', NEW.aircraft_id, JSON_OBJECT('aircraft_number', NEW.aircraft_number, 'aircraft_model', NEW.aircraft_model, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_aircraft_update` AFTER UPDATE ON `aircraft` FOR EACH ROW BEGIN
    INSERT INTO audit_aircraft (action_type, aircraft_id, aircraft_data) 
    VALUES ('UPDATE', NEW.aircraft_id, JSON_OBJECT('aircraft_number', NEW.aircraft_number, 'aircraft_model', NEW.aircraft_model, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `aircraft_view`
-- (See below for the actual view)
--
CREATE TABLE `aircraft_view` (
`aircraft_number` varchar(50)
);

-- --------------------------------------------------------

--
-- Table structure for table `airport`
--

CREATE TABLE `airport` (
  `airport_id` int(11) NOT NULL,
  `airport_name` varchar(255) NOT NULL,
  `country` varchar(100) NOT NULL,
  `airport_code` varchar(10) NOT NULL,
  `flight_type_id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `airport`
--

INSERT INTO `airport` (`airport_id`, `airport_name`, `country`, `airport_code`, `flight_type_id`, `timestamp`) VALUES
(1, 'Manila', 'Philippines', 'MNL', 1, '2024-12-14 11:11:53'),
(2, 'Mactan-Cebu', 'Philippines', 'CEB', 1, '2024-12-13 04:54:37'),
(3, 'Davao', 'Philippines', 'DVO', 1, '2024-12-13 04:54:37'),
(4, 'Pampanga', 'Philippines', 'CRK', 1, '2024-12-13 04:54:37'),
(5, 'Iloilo ', 'Philippines', 'ILO', 1, '2024-12-13 04:54:37'),
(6, 'Kalibo ', 'Philippines', 'KLO', 1, '2024-12-13 04:54:37'),
(7, 'Puerto Princesa', 'Philippines', 'PPS', 1, '2024-12-13 04:54:37'),
(8, 'Laguindingan ', 'Philippines', 'CGY', 1, '2024-12-13 04:54:37'),
(9, 'Bacolod-Silay ', 'Philippines', 'BCD', 1, '2024-12-13 04:54:37'),
(10, 'Tacloban', 'Philippines', 'TAC', 1, '2024-12-13 04:54:37'),
(11, 'Zamboanga ', 'Philippines', 'ZAM', 1, '2024-12-13 04:54:37'),
(12, 'Bancasi ', 'Philippines', 'BXU', 1, '2024-12-13 04:54:37'),
(13, 'Sibulan ', 'Philippines', 'DGT', 1, '2024-12-13 04:54:37'),
(14, 'Legazpi ', 'Philippines', 'LGP', 1, '2024-12-13 04:54:37'),
(15, 'Tuguegarao ', 'Philippines', 'TUG', 1, '2024-12-13 04:54:37'),
(16, 'Ozamiz ', 'Philippines', 'OZC', 1, '2024-12-13 04:54:37'),
(17, 'Siargao ', 'Philippines', 'IAO', 1, '2024-12-13 04:54:37'),
(18, 'Roxas ', 'Philippines', 'RXS', 1, '2024-12-13 04:54:37'),
(19, 'Cotabato ', 'Philippines', 'CBO', 1, '2024-12-13 04:54:37'),
(20, 'Dipolog ', 'Philippines', 'DPL', 1, '2024-12-13 04:54:37'),
(21, 'Cauayan ', 'Philippines', 'CYZ', 1, '2024-12-13 04:54:37'),
(22, 'Pagadian ', 'Philippines', 'PAG', 1, '2024-12-13 04:54:37'),
(23, 'Laoag ', 'Philippines', 'LAO', 1, '2024-12-13 04:54:37'),
(24, 'Basco ', 'Philippines', 'BSO', 1, '2024-12-13 04:54:37'),
(25, 'Sanga-Sanga ', 'Philippines', 'TWT', 1, '2024-12-13 04:54:37'),
(26, 'Akita', 'Japan', 'AXT', 2, '2024-12-13 04:54:37'),
(27, 'Alor Setar', 'Malaysia', 'AOR', 2, '2024-12-13 04:54:37'),
(28, 'Amami', 'Japan', 'ASJ', 2, '2024-12-13 04:54:37'),
(29, 'Anchorage', 'United States', 'ANC', 2, '2024-12-13 04:54:37'),
(30, 'Atlanta', 'United States', 'ATL', 2, '2024-12-13 04:54:37'),
(31, 'Auckland', 'New Zealand', 'AKL', 2, '2024-12-13 04:54:37'),
(32, 'Austin', 'United States', 'AUS', 2, '2024-12-13 04:54:37'),
(33, 'Bahrain', 'Bahrain', 'BAH', 2, '2024-12-13 04:54:37'),
(34, 'Bali', 'Indonesia', 'DPS', 2, '2024-12-13 04:54:37'),
(35, 'Bangkok', 'Thailand', 'BKK', 2, '2024-12-13 04:54:37'),
(36, 'Beijing', 'China', 'PEK', 2, '2024-12-13 04:54:37'),
(37, 'Bellingham', 'United States', 'BLI', 2, '2024-12-13 04:54:37'),
(38, 'Bintulu', 'Malaysia', 'BTU', 2, '2024-12-13 04:54:37'),
(39, 'Boise', 'United States', 'BOI', 2, '2024-12-13 04:54:37'),
(40, 'Boston', 'United States', 'BOS', 2, '2024-12-13 04:54:37'),
(41, 'Brisbane', 'Australia', 'BNE', 2, '2024-12-13 04:54:37'),
(42, 'Busan', 'South Korea', 'PUS', 2, '2024-12-13 04:54:37'),
(43, 'Calgary', 'Canada', 'YYC', 2, '2024-12-13 04:54:37'),
(44, 'Charlottetown', 'Canada', 'YYG', 2, '2024-12-13 04:54:37'),
(45, 'Chengdu', 'China', 'CTU', 2, '2024-12-13 04:54:37'),
(46, 'Chiang Mai', 'Thailand', 'CNX', 2, '2024-12-13 04:54:37'),
(47, 'Chicago', 'United States', 'ORD', 2, '2024-12-13 04:54:37'),
(48, 'Christchurch', 'New Zealand', 'CHC', 2, '2024-12-13 04:54:37'),
(49, 'Cincinnati', 'United States', 'CVG', 2, '2024-12-13 04:54:37'),
(50, 'Cleveland', 'United States', 'CLE', 2, '2024-12-13 04:54:37'),
(51, 'Columbus', 'United States', 'CMH', 2, '2024-12-13 04:54:37'),
(52, 'Corpus Christi', 'United States', 'CRP', 2, '2024-12-13 04:54:37'),
(53, 'Dallas', 'United States', 'DFW', 2, '2024-12-13 04:54:37'),
(54, 'Dammam', 'Saudi Arabia', 'DMM', 2, '2024-12-13 04:54:37'),
(55, 'Deer Lake', 'Canada', 'YDF', 2, '2024-12-13 04:54:37'),
(56, 'Denver', 'United States', 'DEN', 2, '2024-12-13 04:54:37'),
(57, 'Detroit', 'United States', 'DTW', 2, '2024-12-13 04:54:37'),
(58, 'Doha', 'Qatar', 'DOH', 2, '2024-12-13 04:54:37'),
(59, 'Dubai', 'United Arab Emirates', 'DXB', 2, '2024-12-13 04:54:37'),
(60, 'Edmonton', 'Canada', 'YEG', 2, '2024-12-13 04:54:37'),
(61, 'Eugene', 'United States', 'EUG', 2, '2024-12-13 04:54:37'),
(62, 'Fairbanks', 'United States', 'FAI', 2, '2024-12-13 04:54:37'),
(63, 'Fort Lauderdale', 'United States', 'FLL', 2, '2024-12-13 04:54:37'),
(64, 'Fukuoka', 'Japan', 'FUK', 2, '2024-12-13 04:54:37'),
(65, 'Guam', 'United States', 'GUM', 2, '2024-12-13 04:54:37'),
(66, 'Guangzhou', 'China', 'CAN', 2, '2024-12-13 04:54:37'),
(67, 'Halifax', 'Canada', 'YHZ', 2, '2024-12-13 04:54:37'),
(68, 'Hanoi', 'Vietnam', 'HAN', 2, '2024-12-13 04:54:37'),
(69, 'Ho Chi Minh City', 'Vietnam', 'SGN', 2, '2024-12-13 04:54:37'),
(70, 'Hong Kong', 'Hong Kong', 'HKG', 2, '2024-12-13 04:54:37'),
(71, 'Honolulu', 'United States', 'HNL', 2, '2024-12-13 04:54:37'),
(72, 'Houston', 'United States', 'IAH', 2, '2024-12-13 04:54:37'),
(73, 'Istanbul', 'Turkey', 'IST', 2, '2024-12-13 04:54:37'),
(74, 'Jakarta', 'Indonesia', 'CGK', 2, '2024-12-13 04:54:37'),
(75, 'Jeddah', 'Saudi Arabia', 'JED', 2, '2024-12-13 04:54:37'),
(76, 'Johor', 'Malaysia', 'JHB', 2, '2024-12-13 04:54:37'),
(77, 'Kagoshima', 'Japan', 'KOJ', 2, '2024-12-13 04:54:37'),
(78, 'Kamloops', 'Canada', 'YKA', 2, '2024-12-13 04:54:37'),
(79, 'Kuala Lumpur', 'Malaysia', 'KUL', 2, '2024-12-13 04:54:37'),
(80, 'Kuwait City', 'Kuwait', 'KWI', 2, '2024-12-13 04:54:37'),
(81, 'Las Vegas', 'United States', 'LAS', 2, '2024-12-13 04:54:37'),
(82, 'London', 'United Kingdom', 'LHR', 2, '2024-12-13 04:54:37'),
(83, 'Los Angeles', 'United States', 'LAX', 2, '2024-12-13 04:54:37'),
(84, 'Macau', 'Macau', 'MFM', 2, '2024-12-13 04:54:37'),
(85, 'Melbourne', 'Australia', 'MEL', 2, '2024-12-13 04:54:37'),
(86, 'Miami', 'United States', 'MIA', 2, '2024-12-13 04:54:37'),
(87, 'Montreal', 'Canada', 'YUL', 2, '2024-12-13 04:54:37'),
(88, 'Nagoya', 'Japan', 'NGO', 2, '2024-12-13 04:54:37'),
(89, 'New York', 'United States', 'JFK', 2, '2024-12-13 04:54:37'),
(90, 'Osaka', 'Japan', 'KIX', 2, '2024-12-13 04:54:37'),
(91, 'Paris', 'France', 'CDG', 2, '2024-12-13 04:54:37'),
(92, 'Perth', 'Australia', 'PER', 2, '2024-12-13 04:54:37'),
(93, 'Phnom Penh', 'Cambodia', 'PNH', 2, '2024-12-13 04:54:37'),
(94, 'Phuket', 'Thailand', 'HKT', 2, '2024-12-13 04:54:37'),
(95, 'Portland', 'United States', 'PDX', 2, '2024-12-13 04:54:37'),
(96, 'Riyadh', 'Saudi Arabia', 'RUH', 2, '2024-12-13 04:54:37'),
(97, 'San Francisco', 'United States', 'SFO', 2, '2024-12-13 04:54:37'),
(98, 'Seoul', 'South Korea', 'ICN', 2, '2024-12-13 04:54:37'),
(99, 'Shanghai', 'China', 'PVG', 2, '2024-12-13 04:54:37'),
(100, 'Singapore', 'Singapore', 'SIN', 2, '2024-12-13 04:54:37'),
(101, 'Sydney', 'Australia', 'SYD', 2, '2024-12-13 04:54:37'),
(102, 'Taipei', 'Taiwan', 'TPE', 2, '2024-12-13 04:54:37'),
(103, 'Tel Aviv', 'Israel', 'TLV', 2, '2024-12-13 04:54:37'),
(104, 'Tokyo', 'Japan', 'NRT', 2, '2024-12-13 04:54:37'),
(105, 'Toronto', 'Canada', 'YYZ', 2, '2024-12-13 04:54:37'),
(106, 'Vancouver', 'Canada', 'YVR', 2, '2024-12-13 04:54:37'),
(107, 'Wellington', 'New Zealand', 'WLG', 2, '2024-12-13 04:54:37');

--
-- Triggers `airport`
--
DELIMITER $$
CREATE TRIGGER `after_airport_delete` AFTER DELETE ON `airport` FOR EACH ROW BEGIN
    INSERT INTO audit_airport (action_type, airport_id, airport_data) 
    VALUES ('DELETE', OLD.airport_id, JSON_OBJECT('airport_name', OLD.airport_name, 'country', OLD.country, 'airport_code', OLD.airport_code, 'flight_type_id', OLD.flight_type_id, 'timestamp', OLD.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_airport_insert` AFTER INSERT ON `airport` FOR EACH ROW BEGIN
    INSERT INTO audit_airport (action_type, airport_id, airport_data) 
    VALUES ('INSERT', NEW.airport_id, JSON_OBJECT('airport_name', NEW.airport_name, 'country', NEW.country, 'airport_code', NEW.airport_code, 'flight_type_id', NEW.flight_type_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_airport_update` AFTER UPDATE ON `airport` FOR EACH ROW BEGIN
    INSERT INTO audit_airport (action_type, airport_id, airport_data) 
    VALUES ('UPDATE', NEW.airport_id, JSON_OBJECT('airport_name', NEW.airport_name, 'country', NEW.country, 'airport_code', NEW.airport_code, 'flight_type_id', NEW.flight_type_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `audit_aircraft`
--

CREATE TABLE `audit_aircraft` (
  `audit_id` int(11) NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `action_timestamp` datetime DEFAULT current_timestamp(),
  `aircraft_id` int(11) DEFAULT NULL,
  `aircraft_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_aircraft`
--

INSERT INTO `audit_aircraft` (`audit_id`, `action_type`, `action_timestamp`, `aircraft_id`, `aircraft_data`) VALUES
(1, 'DELETE', '2024-12-14 13:57:25', 50, '{\"aircraft_number\": \"B767-300F\", \"aircraft_model\": \"Boeing 767-300F\", \"timestamp\": \"2024-12-13 12:54:58\"}'),
(2, 'INSERT', '2024-12-14 14:38:57', 51, '{\"aircraft_number\": \"B767-300F\", \"aircraft_model\": \"Boeing 767-300F\", \"timestamp\": \"2024-12-13 12:54:58\"}'),
(3, 'DELETE', '2024-12-14 14:51:07', 51, '{\"aircraft_number\": \"B767-300F\", \"aircraft_model\": \"Boeing 767-300F\", \"timestamp\": \"2024-12-13 12:54:58\"}'),
(4, 'INSERT', '2024-12-14 14:52:08', 52, '{\"aircraft_number\": \"B767-300F\", \"aircraft_model\": \"Boeing 767-300F\", \"timestamp\": \"2024-12-13 12:54:58\"}'),
(5, 'DELETE', '2024-12-14 14:57:28', 52, '{\"aircraft_number\": \"B767-300F\", \"aircraft_model\": \"Boeing 767-300F\", \"timestamp\": \"2024-12-13 12:54:58\"}'),
(6, 'INSERT', '2024-12-14 15:01:48', 53, '{\"aircraft_number\": \"B767-300F\", \"aircraft_model\": \"Boeing 767-300F\", \"timestamp\": \"2024-12-13 12:54:58\"}'),
(7, 'UPDATE', '2024-12-14 15:02:09', 53, '{\"aircraft_number\": \"B767-350F\", \"aircraft_model\": \"Boeing 767-300F\", \"timestamp\": \"2024-12-14 15:02:09\"}'),
(8, 'UPDATE', '2024-12-14 23:13:01', 28, '{\"aircraft_number\": \"Cessna Citation X\", \"aircraft_model\": \"Cessna Citation CC-112\", \"timestamp\": \"2024-12-14 23:13:01\"}'),
(9, 'UPDATE', '2024-12-16 04:54:46', 4, '{\"aircraft_number\": \"A350-1010\", \"aircraft_model\": \"Airbus A350\", \"timestamp\": \"2024-12-16 04:54:46\"}'),
(10, 'DELETE', '2024-12-16 08:23:48', 53, '{\"aircraft_number\": \"B767-350F\", \"aircraft_model\": \"Boeing 767-300F\", \"timestamp\": \"2024-12-14 15:02:09\"}'),
(11, 'INSERT', '2024-12-16 08:24:28', 54, '{\"aircraft_number\": \"B767-350F\", \"aircraft_model\": \"Boeing 767-300F\", \"timestamp\": \"2024-12-14 15:02:09\"}');

-- --------------------------------------------------------

--
-- Table structure for table `audit_airport`
--

CREATE TABLE `audit_airport` (
  `audit_id` int(11) NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `action_timestamp` datetime DEFAULT current_timestamp(),
  `airport_id` int(11) DEFAULT NULL,
  `airport_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`airport_data`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_airport`
--

INSERT INTO `audit_airport` (`audit_id`, `action_type`, `action_timestamp`, `airport_id`, `airport_data`) VALUES
(1, 'UPDATE', '2024-12-14 19:11:53', 1, '{\"airport_name\": \"Manila\", \"country\": \"Philippines\", \"airport_code\": \"MNL\", \"flight_type_id\": 1, \"timestamp\": \"2024-12-14 19:11:53\"}');

-- --------------------------------------------------------

--
-- Table structure for table `audit_booking`
--

CREATE TABLE `audit_booking` (
  `audit_id` int(11) NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `action_timestamp` datetime DEFAULT current_timestamp(),
  `booking_id` int(11) DEFAULT NULL,
  `booking_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`booking_data`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_booking`
--

INSERT INTO `audit_booking` (`audit_id`, `action_type`, `action_timestamp`, `booking_id`, `booking_data`) VALUES
(1, 'INSERT', '2024-12-23 21:22:09', 1, '{\"passenger_id\": 1, \"flight_id\": 1, \"timestamp\": \"2024-12-23 21:22:09\"}');

-- --------------------------------------------------------

--
-- Table structure for table `audit_flights`
--

CREATE TABLE `audit_flights` (
  `audit_id` int(11) NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `action_timestamp` datetime DEFAULT current_timestamp(),
  `flight_id` int(11) DEFAULT NULL,
  `flight_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`flight_data`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_flights`
--

INSERT INTO `audit_flights` (`audit_id`, `action_type`, `action_timestamp`, `flight_id`, `flight_data`) VALUES
(1, 'INSERT', '2024-12-16 04:21:58', 1, '{\"flight_number\": \"SB9001\", \"gate_number\": \"23\", \"flight_date\": \"2024-12-17\", \"reference_number\": \"23231197382\", \"origin_airport_id\": 1, \"destination_airport_id\": 31, \"departure_time\": \"04:00:00\", \"arrival_time\": \"13:55:00\", \"layover_id\": 101, \"class_id\": 1, \"price\": 59735.75, \"aircraft_id\": 45, \"type_id\": 2, \"timestamp\": \"2024-12-16 04:21:58\"}'),
(2, 'UPDATE', '2024-12-23 21:34:41', 1, '{\"flight_number\": \"SB9001\", \"gate_number\": \"23\", \"flight_date\": \"2024-12-17\", \"reference_number\": \"23231197382\", \"origin_airport_id\": 1, \"destination_airport_id\": 31, \"departure_time\": \"04:00:00\", \"arrival_time\": \"13:55:00\", \"layover_id\": 101, \"class_id\": 1, \"price\": 59735.75, \"aircraft_id\": 45, \"type_id\": 2, \"timestamp\": \"2024-12-23 21:34:41\"}');

-- --------------------------------------------------------

--
-- Table structure for table `audit_flight_duration`
--

CREATE TABLE `audit_flight_duration` (
  `audit_id` int(11) NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `action_timestamp` datetime DEFAULT current_timestamp(),
  `duration_id` int(11) DEFAULT NULL,
  `duration_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`duration_data`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_flight_duration`
--

INSERT INTO `audit_flight_duration` (`audit_id`, `action_type`, `action_timestamp`, `duration_id`, `duration_data`) VALUES
(1, 'UPDATE', '2024-12-14 17:06:04', 1, '{\"origin_airport_id\": 1, \"destination_airport_id\": 31, \"base_duration\": \"09:55:00\", \"miles\": 4979, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(2, 'UPDATE', '2024-12-14 17:06:04', 2, '{\"origin_airport_id\": 1, \"destination_airport_id\": 29, \"base_duration\": \"10:33:00\", \"miles\": 5313, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(3, 'UPDATE', '2024-12-14 17:06:04', 3, '{\"origin_airport_id\": 1, \"destination_airport_id\": 27, \"base_duration\": \"03:21:00\", \"miles\": 1514, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(4, 'UPDATE', '2024-12-14 17:06:04', 4, '{\"origin_airport_id\": 1, \"destination_airport_id\": 28, \"base_duration\": \"02:35:00\", \"miles\": 1108, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(5, 'UPDATE', '2024-12-14 17:06:04', 5, '{\"origin_airport_id\": 1, \"destination_airport_id\": 30, \"base_duration\": \"17:00:00\", \"miles\": 8722, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(6, 'UPDATE', '2024-12-14 17:06:04', 6, '{\"origin_airport_id\": 1, \"destination_airport_id\": 32, \"base_duration\": \"16:27:00\", \"miles\": 8427, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(7, 'UPDATE', '2024-12-14 17:06:04', 7, '{\"origin_airport_id\": 1, \"destination_airport_id\": 26, \"base_duration\": \"04:26:00\", \"miles\": 2085, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(8, 'UPDATE', '2024-12-14 17:06:04', 8, '{\"origin_airport_id\": 1, \"destination_airport_id\": 33, \"base_duration\": \"09:10:00\", \"miles\": 4586, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(9, 'UPDATE', '2024-12-14 17:06:04', 9, '{\"origin_airport_id\": 1, \"destination_airport_id\": 9, \"base_duration\": \"01:02:00\", \"miles\": 290, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(10, 'UPDATE', '2024-12-14 17:06:04', 10, '{\"origin_airport_id\": 1, \"destination_airport_id\": 35, \"base_duration\": \"03:03:00\", \"miles\": 1361, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(11, 'UPDATE', '2024-12-14 17:06:04', 11, '{\"origin_airport_id\": 1, \"destination_airport_id\": 37, \"base_duration\": \"13:00:00\", \"miles\": 6606, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(12, 'UPDATE', '2024-12-14 17:06:04', 12, '{\"origin_airport_id\": 1, \"destination_airport_id\": 41, \"base_duration\": \"07:18:00\", \"miles\": 3596, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(13, 'UPDATE', '2024-12-14 17:06:04', 13, '{\"origin_airport_id\": 1, \"destination_airport_id\": 39, \"base_duration\": \"13:51:00\", \"miles\": 7053, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(14, 'UPDATE', '2024-12-14 17:06:04', 14, '{\"origin_airport_id\": 1, \"destination_airport_id\": 40, \"base_duration\": \"16:29:00\", \"miles\": 8444, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(15, 'UPDATE', '2024-12-14 17:06:04', 15, '{\"origin_airport_id\": 1, \"destination_airport_id\": 24, \"base_duration\": \"01:16:00\", \"miles\": 414, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(16, 'UPDATE', '2024-12-14 17:06:04', 16, '{\"origin_airport_id\": 1, \"destination_airport_id\": 38, \"base_duration\": \"02:18:00\", \"miles\": 954, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(17, 'UPDATE', '2024-12-14 17:06:04', 17, '{\"origin_airport_id\": 1, \"destination_airport_id\": 12, \"base_duration\": \"01:25:00\", \"miles\": 487, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(18, 'UPDATE', '2024-12-14 17:06:04', 18, '{\"origin_airport_id\": 1, \"destination_airport_id\": 66, \"base_duration\": \"02:00:00\", \"miles\": 792, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(19, 'UPDATE', '2024-12-14 17:06:04', 19, '{\"origin_airport_id\": 1, \"destination_airport_id\": 19, \"base_duration\": \"01:32:00\", \"miles\": 549, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(20, 'UPDATE', '2024-12-14 17:06:04', 20, '{\"origin_airport_id\": 1, \"destination_airport_id\": 91, \"base_duration\": \"13:08:00\", \"miles\": 6678, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(21, 'UPDATE', '2024-12-14 17:06:04', 21, '{\"origin_airport_id\": 1, \"destination_airport_id\": 2, \"base_duration\": \"01:10:00\", \"miles\": 521, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(22, 'UPDATE', '2024-12-14 17:06:04', 22, '{\"origin_airport_id\": 1, \"destination_airport_id\": 74, \"base_duration\": \"03:46:00\", \"miles\": 1727, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(23, 'UPDATE', '2024-12-14 17:06:04', 23, '{\"origin_airport_id\": 1, \"destination_airport_id\": 8, \"base_duration\": \"01:23:00\", \"miles\": 467, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(24, 'UPDATE', '2024-12-14 17:06:04', 24, '{\"origin_airport_id\": 1, \"destination_airport_id\": 48, \"base_duration\": \"01:16:00\", \"miles\": 414, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(25, 'UPDATE', '2024-12-14 17:06:04', 25, '{\"origin_airport_id\": 1, \"destination_airport_id\": 50, \"base_duration\": \"01:44:00\", \"miles\": 656, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(26, 'UPDATE', '2024-12-14 17:06:04', 26, '{\"origin_airport_id\": 1, \"destination_airport_id\": 51, \"base_duration\": \"16:21:00\", \"miles\": 8379, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(27, 'UPDATE', '2024-12-14 17:06:04', 27, '{\"origin_airport_id\": 1, \"destination_airport_id\": 46, \"base_duration\": \"03:21:00\", \"miles\": 1514, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(28, 'UPDATE', '2024-12-14 17:06:04', 28, '{\"origin_airport_id\": 1, \"destination_airport_id\": 4, \"base_duration\": \"00:36:00\", \"miles\": 56, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(29, 'UPDATE', '2024-12-14 17:06:04', 29, '{\"origin_airport_id\": 1, \"destination_airport_id\": 52, \"base_duration\": \"16:41:00\", \"miles\": 8551, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(30, 'UPDATE', '2024-12-14 17:06:04', 30, '{\"origin_airport_id\": 1, \"destination_airport_id\": 45, \"base_duration\": \"03:26:00\", \"miles\": 1549, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(31, 'UPDATE', '2024-12-14 17:06:04', 31, '{\"origin_airport_id\": 1, \"destination_airport_id\": 49, \"base_duration\": \"16:23:00\", \"miles\": 8392, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(32, 'UPDATE', '2024-12-14 17:06:04', 32, '{\"origin_airport_id\": 1, \"destination_airport_id\": 21, \"base_duration\": \"00:49:00\", \"miles\": 173, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(33, 'UPDATE', '2024-12-14 17:06:04', 33, '{\"origin_airport_id\": 1, \"destination_airport_id\": 56, \"base_duration\": \"15:02:00\", \"miles\": 7680, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(34, 'UPDATE', '2024-12-14 17:06:04', 34, '{\"origin_airport_id\": 1, \"destination_airport_id\": 53, \"base_duration\": \"16:15:00\", \"miles\": 8320, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(35, 'UPDATE', '2024-12-14 17:06:04', 35, '{\"origin_airport_id\": 1, \"destination_airport_id\": 13, \"base_duration\": \"01:14:00\", \"miles\": 388, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(36, 'UPDATE', '2024-12-14 17:06:04', 36, '{\"origin_airport_id\": 1, \"destination_airport_id\": 54, \"base_duration\": \"09:16:00\", \"miles\": 4636, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(37, 'UPDATE', '2024-12-14 17:06:04', 37, '{\"origin_airport_id\": 1, \"destination_airport_id\": 58, \"base_duration\": \"09:04:00\", \"miles\": 4531, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(38, 'UPDATE', '2024-12-14 17:06:04', 38, '{\"origin_airport_id\": 1, \"destination_airport_id\": 20, \"base_duration\": \"01:19:00\", \"miles\": 435, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(39, 'UPDATE', '2024-12-14 17:06:04', 39, '{\"origin_airport_id\": 1, \"destination_airport_id\": 34, \"base_duration\": \"03:37:00\", \"miles\": 1648, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(40, 'UPDATE', '2024-12-14 17:06:04', 40, '{\"origin_airport_id\": 1, \"destination_airport_id\": 57, \"base_duration\": \"16:05:00\", \"miles\": 8232, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(41, 'UPDATE', '2024-12-14 17:06:04', 41, '{\"origin_airport_id\": 1, \"destination_airport_id\": 3, \"base_duration\": \"01:37:00\", \"miles\": 597, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(42, 'UPDATE', '2024-12-14 17:06:04', 42, '{\"origin_airport_id\": 1, \"destination_airport_id\": 59, \"base_duration\": \"08:38:00\", \"miles\": 4297, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(43, 'UPDATE', '2024-12-14 17:06:04', 43, '{\"origin_airport_id\": 1, \"destination_airport_id\": 61, \"base_duration\": \"13:15:00\", \"miles\": 6734, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(44, 'UPDATE', '2024-12-14 17:06:04', 44, '{\"origin_airport_id\": 1, \"destination_airport_id\": 62, \"base_duration\": \"10:37:00\", \"miles\": 5350, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(45, 'UPDATE', '2024-12-14 17:06:04', 45, '{\"origin_airport_id\": 1, \"destination_airport_id\": 63, \"base_duration\": \"18:06:00\", \"miles\": 9301, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(46, 'UPDATE', '2024-12-14 17:06:04', 46, '{\"origin_airport_id\": 1, \"destination_airport_id\": 64, \"base_duration\": \"03:02:00\", \"miles\": 1343, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(47, 'UPDATE', '2024-12-14 17:06:04', 47, '{\"origin_airport_id\": 1, \"destination_airport_id\": 65, \"base_duration\": \"03:31:00\", \"miles\": 1597, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(48, 'UPDATE', '2024-12-14 17:06:04', 48, '{\"origin_airport_id\": 1, \"destination_airport_id\": 68, \"base_duration\": \"03:30:00\", \"miles\": 1102, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(49, 'UPDATE', '2024-12-14 17:06:04', 49, '{\"origin_airport_id\": 1, \"destination_airport_id\": 70, \"base_duration\": \"01:50:00\", \"miles\": 711, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(50, 'UPDATE', '2024-12-14 17:06:04', 50, '{\"origin_airport_id\": 1, \"destination_airport_id\": 94, \"base_duration\": \"03:31:00\", \"miles\": 1600, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(51, 'UPDATE', '2024-12-14 17:06:04', 51, '{\"origin_airport_id\": 1, \"destination_airport_id\": 71, \"base_duration\": \"10:32:00\", \"miles\": 5302, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(52, 'UPDATE', '2024-12-14 17:06:04', 52, '{\"origin_airport_id\": 1, \"destination_airport_id\": 72, \"base_duration\": \"16:39:00\", \"miles\": 8535, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(53, 'UPDATE', '2024-12-14 17:06:04', 53, '{\"origin_airport_id\": 1, \"destination_airport_id\": 17, \"base_duration\": \"01:22:00\", \"miles\": 465, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(54, 'UPDATE', '2024-12-14 17:06:04', 54, '{\"origin_airport_id\": 1, \"destination_airport_id\": 98, \"base_duration\": \"03:33:00\", \"miles\": 1615, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(55, 'UPDATE', '2024-12-14 17:06:04', 55, '{\"origin_airport_id\": 1, \"destination_airport_id\": 5, \"base_duration\": \"01:01:00\", \"miles\": 280, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(56, 'UPDATE', '2024-12-14 17:06:04', 56, '{\"origin_airport_id\": 1, \"destination_airport_id\": 73, \"base_duration\": \"11:15:00\", \"miles\": 5684, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(57, 'UPDATE', '2024-12-14 17:06:04', 57, '{\"origin_airport_id\": 1, \"destination_airport_id\": 75, \"base_duration\": \"10:37:00\", \"miles\": 5348, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(58, 'UPDATE', '2024-12-14 17:06:04', 58, '{\"origin_airport_id\": 1, \"destination_airport_id\": 89, \"base_duration\": \"16:37:00\", \"miles\": 8520, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(59, 'UPDATE', '2024-12-14 17:06:04', 59, '{\"origin_airport_id\": 1, \"destination_airport_id\": 76, \"base_duration\": \"03:18:00\", \"miles\": 1479, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(60, 'UPDATE', '2024-12-14 17:06:04', 60, '{\"origin_airport_id\": 1, \"destination_airport_id\": 90, \"base_duration\": \"03:35:00\", \"miles\": 1634, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(61, 'UPDATE', '2024-12-14 17:06:04', 61, '{\"origin_airport_id\": 1, \"destination_airport_id\": 6, \"base_duration\": \"00:54:00\", \"miles\": 215, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(62, 'UPDATE', '2024-12-14 17:06:04', 62, '{\"origin_airport_id\": 1, \"destination_airport_id\": 77, \"base_duration\": \"03:02:00\", \"miles\": 1339, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(63, 'UPDATE', '2024-12-14 17:06:04', 63, '{\"origin_airport_id\": 1, \"destination_airport_id\": 79, \"base_duration\": \"03:25:00\", \"miles\": 1546, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(64, 'UPDATE', '2024-12-14 17:06:04', 64, '{\"origin_airport_id\": 1, \"destination_airport_id\": 80, \"base_duration\": \"09:27:00\", \"miles\": 4730, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(65, 'UPDATE', '2024-12-14 17:06:04', 65, '{\"origin_airport_id\": 1, \"destination_airport_id\": 23, \"base_duration\": \"00:58:00\", \"miles\": 254, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(66, 'UPDATE', '2024-12-14 17:06:04', 66, '{\"origin_airport_id\": 1, \"destination_airport_id\": 81, \"base_duration\": \"14:28:00\", \"miles\": 7385, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(67, 'UPDATE', '2024-12-14 17:06:04', 67, '{\"origin_airport_id\": 1, \"destination_airport_id\": 83, \"base_duration\": \"14:19:00\", \"miles\": 7305, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(68, 'UPDATE', '2024-12-14 17:06:04', 68, '{\"origin_airport_id\": 1, \"destination_airport_id\": 14, \"base_duration\": \"00:53:00\", \"miles\": 205, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(69, 'UPDATE', '2024-12-14 17:06:04', 69, '{\"origin_airport_id\": 1, \"destination_airport_id\": 82, \"base_duration\": \"13:11:00\", \"miles\": 6699, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(70, 'UPDATE', '2024-12-14 17:06:04', 70, '{\"origin_airport_id\": 1, \"destination_airport_id\": 85, \"base_duration\": \"07:54:00\", \"miles\": 3909, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(71, 'UPDATE', '2024-12-14 17:06:04', 71, '{\"origin_airport_id\": 1, \"destination_airport_id\": 84, \"base_duration\": \"01:51:00\", \"miles\": 717, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(72, 'UPDATE', '2024-12-14 17:06:04', 72, '{\"origin_airport_id\": 1, \"destination_airport_id\": 86, \"base_duration\": \"18:08:00\", \"miles\": 9314, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(73, 'UPDATE', '2024-12-14 17:06:04', 73, '{\"origin_airport_id\": 31, \"destination_airport_id\": 1, \"base_duration\": \"09:55:00\", \"miles\": 4979, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(74, 'UPDATE', '2024-12-14 17:06:04', 74, '{\"origin_airport_id\": 29, \"destination_airport_id\": 1, \"base_duration\": \"10:33:00\", \"miles\": 5313, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(75, 'UPDATE', '2024-12-14 17:06:04', 75, '{\"origin_airport_id\": 27, \"destination_airport_id\": 1, \"base_duration\": \"03:21:00\", \"miles\": 1514, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(76, 'UPDATE', '2024-12-14 17:06:04', 76, '{\"origin_airport_id\": 28, \"destination_airport_id\": 1, \"base_duration\": \"02:35:00\", \"miles\": 1108, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(77, 'UPDATE', '2024-12-14 17:06:04', 77, '{\"origin_airport_id\": 30, \"destination_airport_id\": 1, \"base_duration\": \"17:00:00\", \"miles\": 8722, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(78, 'UPDATE', '2024-12-14 17:06:04', 78, '{\"origin_airport_id\": 32, \"destination_airport_id\": 1, \"base_duration\": \"16:27:00\", \"miles\": 8427, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(79, 'UPDATE', '2024-12-14 17:06:04', 79, '{\"origin_airport_id\": 26, \"destination_airport_id\": 1, \"base_duration\": \"04:26:00\", \"miles\": 2085, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(80, 'UPDATE', '2024-12-14 17:06:04', 80, '{\"origin_airport_id\": 33, \"destination_airport_id\": 1, \"base_duration\": \"09:10:00\", \"miles\": 4586, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(81, 'UPDATE', '2024-12-14 17:06:04', 81, '{\"origin_airport_id\": 9, \"destination_airport_id\": 1, \"base_duration\": \"01:02:00\", \"miles\": 290, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(82, 'UPDATE', '2024-12-14 17:06:04', 82, '{\"origin_airport_id\": 35, \"destination_airport_id\": 1, \"base_duration\": \"03:03:00\", \"miles\": 1361, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(83, 'UPDATE', '2024-12-14 17:06:04', 83, '{\"origin_airport_id\": 37, \"destination_airport_id\": 1, \"base_duration\": \"13:00:00\", \"miles\": 6606, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(84, 'UPDATE', '2024-12-14 17:06:04', 84, '{\"origin_airport_id\": 41, \"destination_airport_id\": 1, \"base_duration\": \"07:18:00\", \"miles\": 3596, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(85, 'UPDATE', '2024-12-14 17:06:04', 85, '{\"origin_airport_id\": 39, \"destination_airport_id\": 1, \"base_duration\": \"13:51:00\", \"miles\": 7053, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(86, 'UPDATE', '2024-12-14 17:06:04', 86, '{\"origin_airport_id\": 40, \"destination_airport_id\": 1, \"base_duration\": \"16:29:00\", \"miles\": 8444, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(87, 'UPDATE', '2024-12-14 17:06:04', 87, '{\"origin_airport_id\": 24, \"destination_airport_id\": 1, \"base_duration\": \"01:16:00\", \"miles\": 414, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(88, 'UPDATE', '2024-12-14 17:06:04', 88, '{\"origin_airport_id\": 38, \"destination_airport_id\": 1, \"base_duration\": \"02:18:00\", \"miles\": 954, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(89, 'UPDATE', '2024-12-14 17:06:04', 89, '{\"origin_airport_id\": 12, \"destination_airport_id\": 1, \"base_duration\": \"01:25:00\", \"miles\": 487, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(90, 'UPDATE', '2024-12-14 17:06:04', 90, '{\"origin_airport_id\": 66, \"destination_airport_id\": 1, \"base_duration\": \"02:00:00\", \"miles\": 792, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(91, 'UPDATE', '2024-12-14 17:06:04', 91, '{\"origin_airport_id\": 19, \"destination_airport_id\": 1, \"base_duration\": \"01:32:00\", \"miles\": 549, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(92, 'UPDATE', '2024-12-14 17:06:04', 92, '{\"origin_airport_id\": 91, \"destination_airport_id\": 1, \"base_duration\": \"13:08:00\", \"miles\": 6678, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(93, 'UPDATE', '2024-12-14 17:06:04', 93, '{\"origin_airport_id\": 2, \"destination_airport_id\": 1, \"base_duration\": \"01:10:00\", \"miles\": 521, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(94, 'UPDATE', '2024-12-14 17:06:04', 94, '{\"origin_airport_id\": 74, \"destination_airport_id\": 1, \"base_duration\": \"03:46:00\", \"miles\": 1727, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(95, 'UPDATE', '2024-12-14 17:06:04', 95, '{\"origin_airport_id\": 8, \"destination_airport_id\": 1, \"base_duration\": \"01:23:00\", \"miles\": 467, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(96, 'UPDATE', '2024-12-14 17:06:04', 96, '{\"origin_airport_id\": 48, \"destination_airport_id\": 1, \"base_duration\": \"10:14:00\", \"miles\": 5148, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(97, 'UPDATE', '2024-12-14 17:06:04', 97, '{\"origin_airport_id\": 50, \"destination_airport_id\": 1, \"base_duration\": \"16:14:00\", \"miles\": 8316, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(98, 'UPDATE', '2024-12-14 17:06:04', 98, '{\"origin_airport_id\": 51, \"destination_airport_id\": 1, \"base_duration\": \"16:21:00\", \"miles\": 8379, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(99, 'UPDATE', '2024-12-14 17:06:04', 99, '{\"origin_airport_id\": 46, \"destination_airport_id\": 1, \"base_duration\": \"03:19:00\", \"miles\": 1490, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(100, 'UPDATE', '2024-12-14 17:06:04', 100, '{\"origin_airport_id\": 4, \"destination_airport_id\": 1, \"base_duration\": \"00:36:00\", \"miles\": 56, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(101, 'UPDATE', '2024-12-14 17:06:04', 101, '{\"origin_airport_id\": 52, \"destination_airport_id\": 1, \"base_duration\": \"16:41:00\", \"miles\": 8551, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(102, 'UPDATE', '2024-12-14 17:06:04', 102, '{\"origin_airport_id\": 45, \"destination_airport_id\": 1, \"base_duration\": \"03:26:00\", \"miles\": 1549, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(103, 'UPDATE', '2024-12-14 17:06:04', 103, '{\"origin_airport_id\": 49, \"destination_airport_id\": 1, \"base_duration\": \"16:23:00\", \"miles\": 8392, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(104, 'UPDATE', '2024-12-14 17:06:04', 104, '{\"origin_airport_id\": 21, \"destination_airport_id\": 1, \"base_duration\": \"00:49:00\", \"miles\": 173, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(105, 'UPDATE', '2024-12-14 17:06:04', 105, '{\"origin_airport_id\": 56, \"destination_airport_id\": 1, \"base_duration\": \"15:02:00\", \"miles\": 7680, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(106, 'UPDATE', '2024-12-14 17:06:04', 106, '{\"origin_airport_id\": 53, \"destination_airport_id\": 1, \"base_duration\": \"16:15:00\", \"miles\": 8320, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(107, 'UPDATE', '2024-12-14 17:06:04', 107, '{\"origin_airport_id\": 13, \"destination_airport_id\": 1, \"base_duration\": \"01:14:00\", \"miles\": 388, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(108, 'UPDATE', '2024-12-14 17:06:04', 108, '{\"origin_airport_id\": 54, \"destination_airport_id\": 1, \"base_duration\": \"09:16:00\", \"miles\": 4636, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(109, 'UPDATE', '2024-12-14 17:06:04', 109, '{\"origin_airport_id\": 58, \"destination_airport_id\": 1, \"base_duration\": \"09:04:00\", \"miles\": 4531, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(110, 'UPDATE', '2024-12-14 17:06:04', 110, '{\"origin_airport_id\": 20, \"destination_airport_id\": 1, \"base_duration\": \"01:19:00\", \"miles\": 435, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(111, 'UPDATE', '2024-12-14 17:06:04', 111, '{\"origin_airport_id\": 34, \"destination_airport_id\": 1, \"base_duration\": \"03:37:00\", \"miles\": 1648, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(112, 'UPDATE', '2024-12-14 17:06:04', 112, '{\"origin_airport_id\": 57, \"destination_airport_id\": 1, \"base_duration\": \"16:05:00\", \"miles\": 8232, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(113, 'UPDATE', '2024-12-14 17:06:04', 113, '{\"origin_airport_id\": 3, \"destination_airport_id\": 1, \"base_duration\": \"01:37:00\", \"miles\": 597, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(114, 'UPDATE', '2024-12-14 17:06:04', 114, '{\"origin_airport_id\": 59, \"destination_airport_id\": 1, \"base_duration\": \"08:38:00\", \"miles\": 4297, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(115, 'UPDATE', '2024-12-14 17:06:04', 115, '{\"origin_airport_id\": 61, \"destination_airport_id\": 1, \"base_duration\": \"13:15:00\", \"miles\": 6734, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(116, 'UPDATE', '2024-12-14 17:06:04', 116, '{\"origin_airport_id\": 62, \"destination_airport_id\": 1, \"base_duration\": \"10:37:00\", \"miles\": 5350, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(117, 'UPDATE', '2024-12-14 17:06:04', 117, '{\"origin_airport_id\": 63, \"destination_airport_id\": 1, \"base_duration\": \"18:06:00\", \"miles\": 9301, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(118, 'UPDATE', '2024-12-14 17:06:04', 118, '{\"origin_airport_id\": 64, \"destination_airport_id\": 1, \"base_duration\": \"03:02:00\", \"miles\": 1343, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(119, 'UPDATE', '2024-12-14 17:06:04', 119, '{\"origin_airport_id\": 65, \"destination_airport_id\": 1, \"base_duration\": \"03:31:00\", \"miles\": 1597, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(120, 'UPDATE', '2024-12-14 17:06:04', 120, '{\"origin_airport_id\": 68, \"destination_airport_id\": 1, \"base_duration\": \"03:30:00\", \"miles\": 1102, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(121, 'UPDATE', '2024-12-14 17:06:04', 121, '{\"origin_airport_id\": 70, \"destination_airport_id\": 1, \"base_duration\": \"01:50:00\", \"miles\": 711, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(122, 'UPDATE', '2024-12-14 17:06:04', 122, '{\"origin_airport_id\": 94, \"destination_airport_id\": 1, \"base_duration\": \"03:31:00\", \"miles\": 1600, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(123, 'UPDATE', '2024-12-14 17:06:04', 123, '{\"origin_airport_id\": 71, \"destination_airport_id\": 1, \"base_duration\": \"10:32:00\", \"miles\": 5302, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(124, 'UPDATE', '2024-12-14 17:06:04', 124, '{\"origin_airport_id\": 72, \"destination_airport_id\": 1, \"base_duration\": \"16:39:00\", \"miles\": 8535, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(125, 'UPDATE', '2024-12-14 17:06:04', 125, '{\"origin_airport_id\": 17, \"destination_airport_id\": 1, \"base_duration\": \"01:22:00\", \"miles\": 465, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(126, 'UPDATE', '2024-12-14 17:06:04', 126, '{\"origin_airport_id\": 98, \"destination_airport_id\": 1, \"base_duration\": \"03:33:00\", \"miles\": 1615, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(127, 'UPDATE', '2024-12-14 17:06:04', 127, '{\"origin_airport_id\": 5, \"destination_airport_id\": 1, \"base_duration\": \"01:01:00\", \"miles\": 280, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(128, 'UPDATE', '2024-12-14 17:06:04', 128, '{\"origin_airport_id\": 73, \"destination_airport_id\": 1, \"base_duration\": \"11:15:00\", \"miles\": 5684, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(129, 'UPDATE', '2024-12-14 17:06:04', 129, '{\"origin_airport_id\": 75, \"destination_airport_id\": 1, \"base_duration\": \"10:37:00\", \"miles\": 5348, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(130, 'UPDATE', '2024-12-14 17:06:04', 130, '{\"origin_airport_id\": 89, \"destination_airport_id\": 1, \"base_duration\": \"16:37:00\", \"miles\": 8520, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(131, 'UPDATE', '2024-12-14 17:06:04', 131, '{\"origin_airport_id\": 76, \"destination_airport_id\": 1, \"base_duration\": \"03:18:00\", \"miles\": 1479, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(132, 'UPDATE', '2024-12-14 17:06:04', 132, '{\"origin_airport_id\": 90, \"destination_airport_id\": 1, \"base_duration\": \"03:35:00\", \"miles\": 1634, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(133, 'UPDATE', '2024-12-14 17:06:04', 133, '{\"origin_airport_id\": 6, \"destination_airport_id\": 1, \"base_duration\": \"00:54:00\", \"miles\": 215, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(134, 'UPDATE', '2024-12-14 17:06:04', 134, '{\"origin_airport_id\": 77, \"destination_airport_id\": 1, \"base_duration\": \"03:02:00\", \"miles\": 1339, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(135, 'UPDATE', '2024-12-14 17:06:04', 135, '{\"origin_airport_id\": 79, \"destination_airport_id\": 1, \"base_duration\": \"03:25:00\", \"miles\": 1546, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(136, 'UPDATE', '2024-12-14 17:06:04', 136, '{\"origin_airport_id\": 80, \"destination_airport_id\": 1, \"base_duration\": \"09:27:00\", \"miles\": 4730, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(137, 'UPDATE', '2024-12-14 17:06:04', 137, '{\"origin_airport_id\": 23, \"destination_airport_id\": 1, \"base_duration\": \"00:58:00\", \"miles\": 254, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(138, 'UPDATE', '2024-12-14 17:06:04', 138, '{\"origin_airport_id\": 81, \"destination_airport_id\": 1, \"base_duration\": \"14:28:00\", \"miles\": 7385, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(139, 'UPDATE', '2024-12-14 17:06:04', 139, '{\"origin_airport_id\": 83, \"destination_airport_id\": 1, \"base_duration\": \"14:19:00\", \"miles\": 7305, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(140, 'UPDATE', '2024-12-14 17:06:04', 140, '{\"origin_airport_id\": 14, \"destination_airport_id\": 1, \"base_duration\": \"00:53:00\", \"miles\": 205, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(141, 'UPDATE', '2024-12-14 17:06:04', 141, '{\"origin_airport_id\": 82, \"destination_airport_id\": 1, \"base_duration\": \"13:11:00\", \"miles\": 6699, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(142, 'UPDATE', '2024-12-14 17:06:04', 142, '{\"origin_airport_id\": 85, \"destination_airport_id\": 1, \"base_duration\": \"07:54:00\", \"miles\": 3909, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(143, 'UPDATE', '2024-12-14 17:06:04', 143, '{\"origin_airport_id\": 84, \"destination_airport_id\": 1, \"base_duration\": \"01:51:00\", \"miles\": 717, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(144, 'UPDATE', '2024-12-14 17:06:04', 144, '{\"origin_airport_id\": 86, \"destination_airport_id\": 1, \"base_duration\": \"18:08:00\", \"miles\": 9314, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(145, 'UPDATE', '2024-12-14 17:06:04', 145, '{\"origin_airport_id\": 88, \"destination_airport_id\": 1, \"base_duration\": \"03:44:00\", \"miles\": 1712, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(146, 'UPDATE', '2024-12-14 17:06:04', 146, '{\"origin_airport_id\": 104, \"destination_airport_id\": 1, \"base_duration\": \"04:05:00\", \"miles\": 1893, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(147, 'UPDATE', '2024-12-14 17:06:04', 147, '{\"origin_airport_id\": 47, \"destination_airport_id\": 1, \"base_duration\": \"15:53:00\", \"miles\": 8132, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(148, 'UPDATE', '2024-12-14 17:06:04', 148, '{\"origin_airport_id\": 16, \"destination_airport_id\": 1, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(149, 'UPDATE', '2024-12-14 17:06:04', 149, '{\"origin_airport_id\": 22, \"destination_airport_id\": 1, \"base_duration\": \"01:25:00\", \"miles\": 488, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(150, 'UPDATE', '2024-12-14 17:06:04', 150, '{\"origin_airport_id\": 95, \"destination_airport_id\": 1, \"base_duration\": \"13:12:00\", \"miles\": 6712, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(151, 'UPDATE', '2024-12-14 17:06:04', 151, '{\"origin_airport_id\": 36, \"destination_airport_id\": 1, \"base_duration\": \"03:52:00\", \"miles\": 1781, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(152, 'UPDATE', '2024-12-14 17:06:04', 152, '{\"origin_airport_id\": 92, \"destination_airport_id\": 1, \"base_duration\": \"06:34:00\", \"miles\": 3211, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(153, 'UPDATE', '2024-12-14 17:06:04', 153, '{\"origin_airport_id\": 93, \"destination_airport_id\": 1, \"base_duration\": \"02:35:00\", \"miles\": 1109, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(154, 'UPDATE', '2024-12-14 17:06:04', 154, '{\"origin_airport_id\": 7, \"destination_airport_id\": 1, \"base_duration\": \"01:11:00\", \"miles\": 362, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(155, 'UPDATE', '2024-12-14 17:06:04', 155, '{\"origin_airport_id\": 42, \"destination_airport_id\": 1, \"base_duration\": \"03:21:00\", \"miles\": 1506, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(156, 'UPDATE', '2024-12-14 17:06:04', 156, '{\"origin_airport_id\": 99, \"destination_airport_id\": 1, \"base_duration\": \"02:40:00\", \"miles\": 1146, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(157, 'UPDATE', '2024-12-14 17:06:04', 157, '{\"origin_airport_id\": 96, \"destination_airport_id\": 1, \"base_duration\": \"09:39:00\", \"miles\": 4839, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(158, 'UPDATE', '2024-12-14 17:06:04', 158, '{\"origin_airport_id\": 18, \"destination_airport_id\": 1, \"base_duration\": \"00:56:00\", \"miles\": 232, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(159, 'UPDATE', '2024-12-14 17:06:04', 159, '{\"origin_airport_id\": 97, \"destination_airport_id\": 1, \"base_duration\": \"13:43:00\", \"miles\": 6987, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(160, 'UPDATE', '2024-12-14 17:06:04', 160, '{\"origin_airport_id\": 69, \"destination_airport_id\": 1, \"base_duration\": \"02:23:00\", \"miles\": 1002, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(161, 'UPDATE', '2024-12-14 17:06:04', 161, '{\"origin_airport_id\": 100, \"destination_airport_id\": 1, \"base_duration\": \"03:17:00\", \"miles\": 1474, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(162, 'UPDATE', '2024-12-14 17:06:04', 162, '{\"origin_airport_id\": 101, \"destination_airport_id\": 1, \"base_duration\": \"07:50:00\", \"miles\": 3879, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(163, 'UPDATE', '2024-12-14 17:06:04', 163, '{\"origin_airport_id\": 10, \"destination_airport_id\": 1, \"base_duration\": \"01:09:00\", \"miles\": 352, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(164, 'UPDATE', '2024-12-14 17:06:04', 164, '{\"origin_airport_id\": 103, \"destination_airport_id\": 1, \"base_duration\": \"10:52:00\", \"miles\": 5476, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(165, 'UPDATE', '2024-12-14 17:06:04', 165, '{\"origin_airport_id\": 102, \"destination_airport_id\": 1, \"base_duration\": \"01:52:00\", \"miles\": 727, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(166, 'UPDATE', '2024-12-14 17:06:04', 166, '{\"origin_airport_id\": 15, \"destination_airport_id\": 1, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(167, 'UPDATE', '2024-12-14 17:06:04', 167, '{\"origin_airport_id\": 25, \"destination_airport_id\": 1, \"base_duration\": \"01:44:00\", \"miles\": 656, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(168, 'UPDATE', '2024-12-14 17:06:04', 168, '{\"origin_airport_id\": 107, \"destination_airport_id\": 1, \"base_duration\": \"10:15:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(169, 'UPDATE', '2024-12-14 17:06:04', 169, '{\"origin_airport_id\": 55, \"destination_airport_id\": 1, \"base_duration\": \"15:43:00\", \"miles\": 8043, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(170, 'UPDATE', '2024-12-14 17:06:04', 170, '{\"origin_airport_id\": 60, \"destination_airport_id\": 1, \"base_duration\": \"13:17:00\", \"miles\": 6760, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(171, 'UPDATE', '2024-12-14 17:06:04', 171, '{\"origin_airport_id\": 67, \"destination_airport_id\": 1, \"base_duration\": \"16:16:00\", \"miles\": 8334, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(172, 'UPDATE', '2024-12-14 17:06:04', 172, '{\"origin_airport_id\": 78, \"destination_airport_id\": 1, \"base_duration\": \"13:02:00\", \"miles\": 6620, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(173, 'UPDATE', '2024-12-14 17:06:04', 173, '{\"origin_airport_id\": 87, \"destination_airport_id\": 1, \"base_duration\": \"16:01:00\", \"miles\": 8201, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(174, 'UPDATE', '2024-12-14 17:06:04', 174, '{\"origin_airport_id\": 106, \"destination_airport_id\": 1, \"base_duration\": \"12:55:00\", \"miles\": 6567, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(175, 'UPDATE', '2024-12-14 17:06:04', 175, '{\"origin_airport_id\": 43, \"destination_airport_id\": 1, \"base_duration\": \"13:26:00\", \"miles\": 6836, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(176, 'UPDATE', '2024-12-14 17:06:04', 176, '{\"origin_airport_id\": 44, \"destination_airport_id\": 1, \"base_duration\": \"16:05:00\", \"miles\": 8238, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(177, 'UPDATE', '2024-12-14 17:06:04', 177, '{\"origin_airport_id\": 105, \"destination_airport_id\": 1, \"base_duration\": \"16:03:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(178, 'UPDATE', '2024-12-14 17:06:04', 178, '{\"origin_airport_id\": 11, \"destination_airport_id\": 1, \"base_duration\": \"01:29:00\", \"miles\": 526, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(179, 'UPDATE', '2024-12-14 17:06:04', 179, '{\"origin_airport_id\": 1, \"destination_airport_id\": 88, \"base_duration\": \"03:44:00\", \"miles\": 1712, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(180, 'UPDATE', '2024-12-14 17:06:04', 180, '{\"origin_airport_id\": 1, \"destination_airport_id\": 104, \"base_duration\": \"04:05:00\", \"miles\": 1893, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(181, 'UPDATE', '2024-12-14 17:06:04', 181, '{\"origin_airport_id\": 1, \"destination_airport_id\": 47, \"base_duration\": \"15:54:00\", \"miles\": 8132, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(182, 'UPDATE', '2024-12-14 17:06:04', 182, '{\"origin_airport_id\": 1, \"destination_airport_id\": 16, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(183, 'UPDATE', '2024-12-14 17:06:04', 183, '{\"origin_airport_id\": 1, \"destination_airport_id\": 22, \"base_duration\": \"01:25:00\", \"miles\": 488, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(184, 'UPDATE', '2024-12-14 17:06:04', 184, '{\"origin_airport_id\": 1, \"destination_airport_id\": 95, \"base_duration\": \"13:12:00\", \"miles\": 6712, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(185, 'UPDATE', '2024-12-14 17:06:04', 185, '{\"origin_airport_id\": 1, \"destination_airport_id\": 36, \"base_duration\": \"03:52:00\", \"miles\": 1781, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(186, 'UPDATE', '2024-12-14 17:06:04', 186, '{\"origin_airport_id\": 1, \"destination_airport_id\": 92, \"base_duration\": \"06:34:00\", \"miles\": 3211, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(187, 'UPDATE', '2024-12-14 17:06:04', 187, '{\"origin_airport_id\": 1, \"destination_airport_id\": 93, \"base_duration\": \"02:35:00\", \"miles\": 1109, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(188, 'UPDATE', '2024-12-14 17:06:04', 188, '{\"origin_airport_id\": 1, \"destination_airport_id\": 7, \"base_duration\": \"01:11:00\", \"miles\": 362, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(189, 'UPDATE', '2024-12-14 17:06:04', 189, '{\"origin_airport_id\": 1, \"destination_airport_id\": 42, \"base_duration\": \"03:21:00\", \"miles\": 1506, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(190, 'UPDATE', '2024-12-14 17:06:04', 190, '{\"origin_airport_id\": 1, \"destination_airport_id\": 99, \"base_duration\": \"02:40:00\", \"miles\": 1146, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(191, 'UPDATE', '2024-12-14 17:06:04', 191, '{\"origin_airport_id\": 1, \"destination_airport_id\": 96, \"base_duration\": \"09:39:00\", \"miles\": 4839, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(192, 'UPDATE', '2024-12-14 17:06:04', 192, '{\"origin_airport_id\": 1, \"destination_airport_id\": 18, \"base_duration\": \"00:56:00\", \"miles\": 232, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(193, 'UPDATE', '2024-12-14 17:06:04', 193, '{\"origin_airport_id\": 1, \"destination_airport_id\": 97, \"base_duration\": \"13:43:00\", \"miles\": 6987, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(194, 'UPDATE', '2024-12-14 17:06:04', 194, '{\"origin_airport_id\": 1, \"destination_airport_id\": 69, \"base_duration\": \"02:23:00\", \"miles\": 1002, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(195, 'UPDATE', '2024-12-14 17:06:04', 195, '{\"origin_airport_id\": 1, \"destination_airport_id\": 100, \"base_duration\": \"03:17:00\", \"miles\": 1474, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(196, 'UPDATE', '2024-12-14 17:06:04', 196, '{\"origin_airport_id\": 1, \"destination_airport_id\": 101, \"base_duration\": \"07:50:00\", \"miles\": 3879, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(197, 'UPDATE', '2024-12-14 17:06:04', 197, '{\"origin_airport_id\": 1, \"destination_airport_id\": 10, \"base_duration\": \"01:09:00\", \"miles\": 352, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(198, 'UPDATE', '2024-12-14 17:06:04', 198, '{\"origin_airport_id\": 1, \"destination_airport_id\": 103, \"base_duration\": \"10:52:00\", \"miles\": 5476, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(199, 'UPDATE', '2024-12-14 17:06:04', 199, '{\"origin_airport_id\": 1, \"destination_airport_id\": 102, \"base_duration\": \"01:52:00\", \"miles\": 727, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(200, 'UPDATE', '2024-12-14 17:06:04', 200, '{\"origin_airport_id\": 1, \"destination_airport_id\": 15, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(201, 'UPDATE', '2024-12-14 17:06:04', 201, '{\"origin_airport_id\": 1, \"destination_airport_id\": 25, \"base_duration\": \"01:44:00\", \"miles\": 656, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(202, 'UPDATE', '2024-12-14 17:06:04', 202, '{\"origin_airport_id\": 1, \"destination_airport_id\": 107, \"base_duration\": \"10:15:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(203, 'UPDATE', '2024-12-14 17:06:04', 203, '{\"origin_airport_id\": 1, \"destination_airport_id\": 55, \"base_duration\": \"15:43:00\", \"miles\": 8043, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(204, 'UPDATE', '2024-12-14 17:06:04', 204, '{\"origin_airport_id\": 1, \"destination_airport_id\": 60, \"base_duration\": \"13:17:00\", \"miles\": 6760, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(205, 'UPDATE', '2024-12-14 17:06:04', 205, '{\"origin_airport_id\": 1, \"destination_airport_id\": 67, \"base_duration\": \"16:16:00\", \"miles\": 8334, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(206, 'UPDATE', '2024-12-14 17:06:04', 206, '{\"origin_airport_id\": 1, \"destination_airport_id\": 78, \"base_duration\": \"13:02:00\", \"miles\": 6620, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(207, 'UPDATE', '2024-12-14 17:06:04', 207, '{\"origin_airport_id\": 1, \"destination_airport_id\": 87, \"base_duration\": \"16:01:00\", \"miles\": 8201, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(208, 'UPDATE', '2024-12-14 17:06:04', 208, '{\"origin_airport_id\": 1, \"destination_airport_id\": 106, \"base_duration\": \"12:55:00\", \"miles\": 6567, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(209, 'UPDATE', '2024-12-14 17:06:04', 209, '{\"origin_airport_id\": 1, \"destination_airport_id\": 43, \"base_duration\": \"13:26:00\", \"miles\": 8238, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(210, 'UPDATE', '2024-12-14 17:06:04', 210, '{\"origin_airport_id\": 1, \"destination_airport_id\": 44, \"base_duration\": \"16:05:00\", \"miles\": 8238, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(211, 'UPDATE', '2024-12-14 17:06:04', 211, '{\"origin_airport_id\": 1, \"destination_airport_id\": 105, \"base_duration\": \"16:03:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(212, 'UPDATE', '2024-12-14 17:06:04', 212, '{\"origin_airport_id\": 1, \"destination_airport_id\": 11, \"base_duration\": \"01:29:00\", \"miles\": 526, \"timestamp\": \"2024-12-14 17:06:04\"}'),
(213, 'UPDATE', '2024-12-14 17:08:51', 1, '{\"origin_airport_id\": 1, \"destination_airport_id\": 31, \"base_duration\": \"09:55:00\", \"miles\": 4979, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(214, 'UPDATE', '2024-12-14 17:08:51', 2, '{\"origin_airport_id\": 1, \"destination_airport_id\": 29, \"base_duration\": \"10:33:00\", \"miles\": 5313, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(215, 'UPDATE', '2024-12-14 17:08:51', 3, '{\"origin_airport_id\": 1, \"destination_airport_id\": 27, \"base_duration\": \"03:21:00\", \"miles\": 1514, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(216, 'UPDATE', '2024-12-14 17:08:51', 4, '{\"origin_airport_id\": 1, \"destination_airport_id\": 28, \"base_duration\": \"02:35:00\", \"miles\": 1108, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(217, 'UPDATE', '2024-12-14 17:08:51', 5, '{\"origin_airport_id\": 1, \"destination_airport_id\": 30, \"base_duration\": \"17:00:00\", \"miles\": 8722, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(218, 'UPDATE', '2024-12-14 17:08:51', 6, '{\"origin_airport_id\": 1, \"destination_airport_id\": 32, \"base_duration\": \"16:27:00\", \"miles\": 8427, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(219, 'UPDATE', '2024-12-14 17:08:51', 7, '{\"origin_airport_id\": 1, \"destination_airport_id\": 26, \"base_duration\": \"04:26:00\", \"miles\": 2085, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(220, 'UPDATE', '2024-12-14 17:08:51', 8, '{\"origin_airport_id\": 1, \"destination_airport_id\": 33, \"base_duration\": \"09:10:00\", \"miles\": 4586, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(221, 'UPDATE', '2024-12-14 17:08:51', 9, '{\"origin_airport_id\": 1, \"destination_airport_id\": 9, \"base_duration\": \"01:02:00\", \"miles\": 290, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(222, 'UPDATE', '2024-12-14 17:08:51', 10, '{\"origin_airport_id\": 1, \"destination_airport_id\": 35, \"base_duration\": \"03:03:00\", \"miles\": 1361, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(223, 'UPDATE', '2024-12-14 17:08:51', 11, '{\"origin_airport_id\": 1, \"destination_airport_id\": 37, \"base_duration\": \"13:00:00\", \"miles\": 6606, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(224, 'UPDATE', '2024-12-14 17:08:51', 12, '{\"origin_airport_id\": 1, \"destination_airport_id\": 41, \"base_duration\": \"07:18:00\", \"miles\": 3596, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(225, 'UPDATE', '2024-12-14 17:08:51', 13, '{\"origin_airport_id\": 1, \"destination_airport_id\": 39, \"base_duration\": \"13:51:00\", \"miles\": 7053, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(226, 'UPDATE', '2024-12-14 17:08:51', 14, '{\"origin_airport_id\": 1, \"destination_airport_id\": 40, \"base_duration\": \"16:29:00\", \"miles\": 8444, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(227, 'UPDATE', '2024-12-14 17:08:51', 15, '{\"origin_airport_id\": 1, \"destination_airport_id\": 24, \"base_duration\": \"01:16:00\", \"miles\": 414, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(228, 'UPDATE', '2024-12-14 17:08:51', 16, '{\"origin_airport_id\": 1, \"destination_airport_id\": 38, \"base_duration\": \"02:18:00\", \"miles\": 954, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(229, 'UPDATE', '2024-12-14 17:08:51', 17, '{\"origin_airport_id\": 1, \"destination_airport_id\": 12, \"base_duration\": \"01:25:00\", \"miles\": 487, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(230, 'UPDATE', '2024-12-14 17:08:51', 18, '{\"origin_airport_id\": 1, \"destination_airport_id\": 66, \"base_duration\": \"02:00:00\", \"miles\": 792, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(231, 'UPDATE', '2024-12-14 17:08:51', 19, '{\"origin_airport_id\": 1, \"destination_airport_id\": 19, \"base_duration\": \"01:32:00\", \"miles\": 549, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(232, 'UPDATE', '2024-12-14 17:08:51', 20, '{\"origin_airport_id\": 1, \"destination_airport_id\": 91, \"base_duration\": \"13:08:00\", \"miles\": 6678, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(233, 'UPDATE', '2024-12-14 17:08:51', 21, '{\"origin_airport_id\": 1, \"destination_airport_id\": 2, \"base_duration\": \"01:10:00\", \"miles\": 521, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(234, 'UPDATE', '2024-12-14 17:08:51', 22, '{\"origin_airport_id\": 1, \"destination_airport_id\": 74, \"base_duration\": \"03:46:00\", \"miles\": 1727, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(235, 'UPDATE', '2024-12-14 17:08:51', 23, '{\"origin_airport_id\": 1, \"destination_airport_id\": 8, \"base_duration\": \"01:23:00\", \"miles\": 467, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(236, 'UPDATE', '2024-12-14 17:08:51', 24, '{\"origin_airport_id\": 1, \"destination_airport_id\": 48, \"base_duration\": \"01:16:00\", \"miles\": 414, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(237, 'UPDATE', '2024-12-14 17:08:51', 25, '{\"origin_airport_id\": 1, \"destination_airport_id\": 50, \"base_duration\": \"01:44:00\", \"miles\": 656, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(238, 'UPDATE', '2024-12-14 17:08:51', 26, '{\"origin_airport_id\": 1, \"destination_airport_id\": 51, \"base_duration\": \"16:21:00\", \"miles\": 8379, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(239, 'UPDATE', '2024-12-14 17:08:51', 27, '{\"origin_airport_id\": 1, \"destination_airport_id\": 46, \"base_duration\": \"03:21:00\", \"miles\": 1514, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(240, 'UPDATE', '2024-12-14 17:08:51', 28, '{\"origin_airport_id\": 1, \"destination_airport_id\": 4, \"base_duration\": \"00:36:00\", \"miles\": 56, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(241, 'UPDATE', '2024-12-14 17:08:51', 29, '{\"origin_airport_id\": 1, \"destination_airport_id\": 52, \"base_duration\": \"16:41:00\", \"miles\": 8551, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(242, 'UPDATE', '2024-12-14 17:08:51', 30, '{\"origin_airport_id\": 1, \"destination_airport_id\": 45, \"base_duration\": \"03:26:00\", \"miles\": 1549, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(243, 'UPDATE', '2024-12-14 17:08:51', 31, '{\"origin_airport_id\": 1, \"destination_airport_id\": 49, \"base_duration\": \"16:23:00\", \"miles\": 8392, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(244, 'UPDATE', '2024-12-14 17:08:51', 32, '{\"origin_airport_id\": 1, \"destination_airport_id\": 21, \"base_duration\": \"00:49:00\", \"miles\": 173, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(245, 'UPDATE', '2024-12-14 17:08:51', 33, '{\"origin_airport_id\": 1, \"destination_airport_id\": 56, \"base_duration\": \"15:02:00\", \"miles\": 7680, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(246, 'UPDATE', '2024-12-14 17:08:51', 34, '{\"origin_airport_id\": 1, \"destination_airport_id\": 53, \"base_duration\": \"16:15:00\", \"miles\": 8320, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(247, 'UPDATE', '2024-12-14 17:08:51', 35, '{\"origin_airport_id\": 1, \"destination_airport_id\": 13, \"base_duration\": \"01:14:00\", \"miles\": 388, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(248, 'UPDATE', '2024-12-14 17:08:51', 36, '{\"origin_airport_id\": 1, \"destination_airport_id\": 54, \"base_duration\": \"09:16:00\", \"miles\": 4636, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(249, 'UPDATE', '2024-12-14 17:08:51', 37, '{\"origin_airport_id\": 1, \"destination_airport_id\": 58, \"base_duration\": \"09:04:00\", \"miles\": 4531, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(250, 'UPDATE', '2024-12-14 17:08:51', 38, '{\"origin_airport_id\": 1, \"destination_airport_id\": 20, \"base_duration\": \"01:19:00\", \"miles\": 435, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(251, 'UPDATE', '2024-12-14 17:08:51', 39, '{\"origin_airport_id\": 1, \"destination_airport_id\": 34, \"base_duration\": \"03:37:00\", \"miles\": 1648, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(252, 'UPDATE', '2024-12-14 17:08:51', 40, '{\"origin_airport_id\": 1, \"destination_airport_id\": 57, \"base_duration\": \"16:05:00\", \"miles\": 8232, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(253, 'UPDATE', '2024-12-14 17:08:51', 41, '{\"origin_airport_id\": 1, \"destination_airport_id\": 3, \"base_duration\": \"01:37:00\", \"miles\": 597, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(254, 'UPDATE', '2024-12-14 17:08:51', 42, '{\"origin_airport_id\": 1, \"destination_airport_id\": 59, \"base_duration\": \"08:38:00\", \"miles\": 4297, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(255, 'UPDATE', '2024-12-14 17:08:51', 43, '{\"origin_airport_id\": 1, \"destination_airport_id\": 61, \"base_duration\": \"13:15:00\", \"miles\": 6734, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(256, 'UPDATE', '2024-12-14 17:08:51', 44, '{\"origin_airport_id\": 1, \"destination_airport_id\": 62, \"base_duration\": \"10:37:00\", \"miles\": 5350, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(257, 'UPDATE', '2024-12-14 17:08:51', 45, '{\"origin_airport_id\": 1, \"destination_airport_id\": 63, \"base_duration\": \"18:06:00\", \"miles\": 9301, \"timestamp\": \"2024-12-14 17:08:51\"}');
INSERT INTO `audit_flight_duration` (`audit_id`, `action_type`, `action_timestamp`, `duration_id`, `duration_data`) VALUES
(258, 'UPDATE', '2024-12-14 17:08:51', 46, '{\"origin_airport_id\": 1, \"destination_airport_id\": 64, \"base_duration\": \"03:02:00\", \"miles\": 1343, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(259, 'UPDATE', '2024-12-14 17:08:51', 47, '{\"origin_airport_id\": 1, \"destination_airport_id\": 65, \"base_duration\": \"03:31:00\", \"miles\": 1597, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(260, 'UPDATE', '2024-12-14 17:08:51', 48, '{\"origin_airport_id\": 1, \"destination_airport_id\": 68, \"base_duration\": \"03:30:00\", \"miles\": 1102, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(261, 'UPDATE', '2024-12-14 17:08:51', 49, '{\"origin_airport_id\": 1, \"destination_airport_id\": 70, \"base_duration\": \"01:50:00\", \"miles\": 711, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(262, 'UPDATE', '2024-12-14 17:08:51', 50, '{\"origin_airport_id\": 1, \"destination_airport_id\": 94, \"base_duration\": \"03:31:00\", \"miles\": 1600, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(263, 'UPDATE', '2024-12-14 17:08:51', 51, '{\"origin_airport_id\": 1, \"destination_airport_id\": 71, \"base_duration\": \"10:32:00\", \"miles\": 5302, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(264, 'UPDATE', '2024-12-14 17:08:51', 52, '{\"origin_airport_id\": 1, \"destination_airport_id\": 72, \"base_duration\": \"16:39:00\", \"miles\": 8535, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(265, 'UPDATE', '2024-12-14 17:08:51', 53, '{\"origin_airport_id\": 1, \"destination_airport_id\": 17, \"base_duration\": \"01:22:00\", \"miles\": 465, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(266, 'UPDATE', '2024-12-14 17:08:51', 54, '{\"origin_airport_id\": 1, \"destination_airport_id\": 98, \"base_duration\": \"03:33:00\", \"miles\": 1615, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(267, 'UPDATE', '2024-12-14 17:08:51', 55, '{\"origin_airport_id\": 1, \"destination_airport_id\": 5, \"base_duration\": \"01:01:00\", \"miles\": 280, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(268, 'UPDATE', '2024-12-14 17:08:51', 56, '{\"origin_airport_id\": 1, \"destination_airport_id\": 73, \"base_duration\": \"11:15:00\", \"miles\": 5684, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(269, 'UPDATE', '2024-12-14 17:08:51', 57, '{\"origin_airport_id\": 1, \"destination_airport_id\": 75, \"base_duration\": \"10:37:00\", \"miles\": 5348, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(270, 'UPDATE', '2024-12-14 17:08:51', 58, '{\"origin_airport_id\": 1, \"destination_airport_id\": 89, \"base_duration\": \"16:37:00\", \"miles\": 8520, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(271, 'UPDATE', '2024-12-14 17:08:51', 59, '{\"origin_airport_id\": 1, \"destination_airport_id\": 76, \"base_duration\": \"03:18:00\", \"miles\": 1479, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(272, 'UPDATE', '2024-12-14 17:08:51', 60, '{\"origin_airport_id\": 1, \"destination_airport_id\": 90, \"base_duration\": \"03:35:00\", \"miles\": 1634, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(273, 'UPDATE', '2024-12-14 17:08:51', 61, '{\"origin_airport_id\": 1, \"destination_airport_id\": 6, \"base_duration\": \"00:54:00\", \"miles\": 215, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(274, 'UPDATE', '2024-12-14 17:08:51', 62, '{\"origin_airport_id\": 1, \"destination_airport_id\": 77, \"base_duration\": \"03:02:00\", \"miles\": 1339, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(275, 'UPDATE', '2024-12-14 17:08:51', 63, '{\"origin_airport_id\": 1, \"destination_airport_id\": 79, \"base_duration\": \"03:25:00\", \"miles\": 1546, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(276, 'UPDATE', '2024-12-14 17:08:51', 64, '{\"origin_airport_id\": 1, \"destination_airport_id\": 80, \"base_duration\": \"09:27:00\", \"miles\": 4730, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(277, 'UPDATE', '2024-12-14 17:08:51', 65, '{\"origin_airport_id\": 1, \"destination_airport_id\": 23, \"base_duration\": \"00:58:00\", \"miles\": 254, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(278, 'UPDATE', '2024-12-14 17:08:51', 66, '{\"origin_airport_id\": 1, \"destination_airport_id\": 81, \"base_duration\": \"14:28:00\", \"miles\": 7385, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(279, 'UPDATE', '2024-12-14 17:08:51', 67, '{\"origin_airport_id\": 1, \"destination_airport_id\": 83, \"base_duration\": \"14:19:00\", \"miles\": 7305, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(280, 'UPDATE', '2024-12-14 17:08:51', 68, '{\"origin_airport_id\": 1, \"destination_airport_id\": 14, \"base_duration\": \"00:53:00\", \"miles\": 205, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(281, 'UPDATE', '2024-12-14 17:08:51', 69, '{\"origin_airport_id\": 1, \"destination_airport_id\": 82, \"base_duration\": \"13:11:00\", \"miles\": 6699, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(282, 'UPDATE', '2024-12-14 17:08:51', 70, '{\"origin_airport_id\": 1, \"destination_airport_id\": 85, \"base_duration\": \"07:54:00\", \"miles\": 3909, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(283, 'UPDATE', '2024-12-14 17:08:51', 71, '{\"origin_airport_id\": 1, \"destination_airport_id\": 84, \"base_duration\": \"01:51:00\", \"miles\": 717, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(284, 'UPDATE', '2024-12-14 17:08:51', 72, '{\"origin_airport_id\": 1, \"destination_airport_id\": 86, \"base_duration\": \"18:08:00\", \"miles\": 9314, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(285, 'UPDATE', '2024-12-14 17:08:51', 73, '{\"origin_airport_id\": 31, \"destination_airport_id\": 1, \"base_duration\": \"09:55:00\", \"miles\": 4979, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(286, 'UPDATE', '2024-12-14 17:08:51', 74, '{\"origin_airport_id\": 29, \"destination_airport_id\": 1, \"base_duration\": \"10:33:00\", \"miles\": 5313, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(287, 'UPDATE', '2024-12-14 17:08:51', 75, '{\"origin_airport_id\": 27, \"destination_airport_id\": 1, \"base_duration\": \"03:21:00\", \"miles\": 1514, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(288, 'UPDATE', '2024-12-14 17:08:51', 76, '{\"origin_airport_id\": 28, \"destination_airport_id\": 1, \"base_duration\": \"02:35:00\", \"miles\": 1108, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(289, 'UPDATE', '2024-12-14 17:08:51', 77, '{\"origin_airport_id\": 30, \"destination_airport_id\": 1, \"base_duration\": \"17:00:00\", \"miles\": 8722, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(290, 'UPDATE', '2024-12-14 17:08:51', 78, '{\"origin_airport_id\": 32, \"destination_airport_id\": 1, \"base_duration\": \"16:27:00\", \"miles\": 8427, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(291, 'UPDATE', '2024-12-14 17:08:51', 79, '{\"origin_airport_id\": 26, \"destination_airport_id\": 1, \"base_duration\": \"04:26:00\", \"miles\": 2085, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(292, 'UPDATE', '2024-12-14 17:08:51', 80, '{\"origin_airport_id\": 33, \"destination_airport_id\": 1, \"base_duration\": \"09:10:00\", \"miles\": 4586, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(293, 'UPDATE', '2024-12-14 17:08:51', 81, '{\"origin_airport_id\": 9, \"destination_airport_id\": 1, \"base_duration\": \"01:02:00\", \"miles\": 290, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(294, 'UPDATE', '2024-12-14 17:08:51', 82, '{\"origin_airport_id\": 35, \"destination_airport_id\": 1, \"base_duration\": \"03:03:00\", \"miles\": 1361, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(295, 'UPDATE', '2024-12-14 17:08:51', 83, '{\"origin_airport_id\": 37, \"destination_airport_id\": 1, \"base_duration\": \"13:00:00\", \"miles\": 6606, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(296, 'UPDATE', '2024-12-14 17:08:51', 84, '{\"origin_airport_id\": 41, \"destination_airport_id\": 1, \"base_duration\": \"07:18:00\", \"miles\": 3596, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(297, 'UPDATE', '2024-12-14 17:08:51', 85, '{\"origin_airport_id\": 39, \"destination_airport_id\": 1, \"base_duration\": \"13:51:00\", \"miles\": 7053, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(298, 'UPDATE', '2024-12-14 17:08:51', 86, '{\"origin_airport_id\": 40, \"destination_airport_id\": 1, \"base_duration\": \"16:29:00\", \"miles\": 8444, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(299, 'UPDATE', '2024-12-14 17:08:51', 87, '{\"origin_airport_id\": 24, \"destination_airport_id\": 1, \"base_duration\": \"01:16:00\", \"miles\": 414, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(300, 'UPDATE', '2024-12-14 17:08:51', 88, '{\"origin_airport_id\": 38, \"destination_airport_id\": 1, \"base_duration\": \"02:18:00\", \"miles\": 954, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(301, 'UPDATE', '2024-12-14 17:08:51', 89, '{\"origin_airport_id\": 12, \"destination_airport_id\": 1, \"base_duration\": \"01:25:00\", \"miles\": 487, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(302, 'UPDATE', '2024-12-14 17:08:51', 90, '{\"origin_airport_id\": 66, \"destination_airport_id\": 1, \"base_duration\": \"02:00:00\", \"miles\": 792, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(303, 'UPDATE', '2024-12-14 17:08:51', 91, '{\"origin_airport_id\": 19, \"destination_airport_id\": 1, \"base_duration\": \"01:32:00\", \"miles\": 549, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(304, 'UPDATE', '2024-12-14 17:08:51', 92, '{\"origin_airport_id\": 91, \"destination_airport_id\": 1, \"base_duration\": \"13:08:00\", \"miles\": 6678, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(305, 'UPDATE', '2024-12-14 17:08:51', 93, '{\"origin_airport_id\": 2, \"destination_airport_id\": 1, \"base_duration\": \"01:10:00\", \"miles\": 521, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(306, 'UPDATE', '2024-12-14 17:08:51', 94, '{\"origin_airport_id\": 74, \"destination_airport_id\": 1, \"base_duration\": \"03:46:00\", \"miles\": 1727, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(307, 'UPDATE', '2024-12-14 17:08:51', 95, '{\"origin_airport_id\": 8, \"destination_airport_id\": 1, \"base_duration\": \"01:23:00\", \"miles\": 467, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(308, 'UPDATE', '2024-12-14 17:08:51', 96, '{\"origin_airport_id\": 48, \"destination_airport_id\": 1, \"base_duration\": \"10:14:00\", \"miles\": 5148, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(309, 'UPDATE', '2024-12-14 17:08:51', 97, '{\"origin_airport_id\": 50, \"destination_airport_id\": 1, \"base_duration\": \"16:14:00\", \"miles\": 8316, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(310, 'UPDATE', '2024-12-14 17:08:51', 98, '{\"origin_airport_id\": 51, \"destination_airport_id\": 1, \"base_duration\": \"16:21:00\", \"miles\": 8379, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(311, 'UPDATE', '2024-12-14 17:08:51', 99, '{\"origin_airport_id\": 46, \"destination_airport_id\": 1, \"base_duration\": \"03:19:00\", \"miles\": 1490, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(312, 'UPDATE', '2024-12-14 17:08:51', 100, '{\"origin_airport_id\": 4, \"destination_airport_id\": 1, \"base_duration\": \"00:36:00\", \"miles\": 56, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(313, 'UPDATE', '2024-12-14 17:08:51', 101, '{\"origin_airport_id\": 52, \"destination_airport_id\": 1, \"base_duration\": \"16:41:00\", \"miles\": 8551, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(314, 'UPDATE', '2024-12-14 17:08:51', 102, '{\"origin_airport_id\": 45, \"destination_airport_id\": 1, \"base_duration\": \"03:26:00\", \"miles\": 1549, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(315, 'UPDATE', '2024-12-14 17:08:51', 103, '{\"origin_airport_id\": 49, \"destination_airport_id\": 1, \"base_duration\": \"16:23:00\", \"miles\": 8392, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(316, 'UPDATE', '2024-12-14 17:08:51', 104, '{\"origin_airport_id\": 21, \"destination_airport_id\": 1, \"base_duration\": \"00:49:00\", \"miles\": 173, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(317, 'UPDATE', '2024-12-14 17:08:51', 105, '{\"origin_airport_id\": 56, \"destination_airport_id\": 1, \"base_duration\": \"15:02:00\", \"miles\": 7680, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(318, 'UPDATE', '2024-12-14 17:08:51', 106, '{\"origin_airport_id\": 53, \"destination_airport_id\": 1, \"base_duration\": \"16:15:00\", \"miles\": 8320, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(319, 'UPDATE', '2024-12-14 17:08:51', 107, '{\"origin_airport_id\": 13, \"destination_airport_id\": 1, \"base_duration\": \"01:14:00\", \"miles\": 388, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(320, 'UPDATE', '2024-12-14 17:08:51', 108, '{\"origin_airport_id\": 54, \"destination_airport_id\": 1, \"base_duration\": \"09:16:00\", \"miles\": 4636, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(321, 'UPDATE', '2024-12-14 17:08:51', 109, '{\"origin_airport_id\": 58, \"destination_airport_id\": 1, \"base_duration\": \"09:04:00\", \"miles\": 4531, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(322, 'UPDATE', '2024-12-14 17:08:51', 110, '{\"origin_airport_id\": 20, \"destination_airport_id\": 1, \"base_duration\": \"01:19:00\", \"miles\": 435, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(323, 'UPDATE', '2024-12-14 17:08:51', 111, '{\"origin_airport_id\": 34, \"destination_airport_id\": 1, \"base_duration\": \"03:37:00\", \"miles\": 1648, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(324, 'UPDATE', '2024-12-14 17:08:51', 112, '{\"origin_airport_id\": 57, \"destination_airport_id\": 1, \"base_duration\": \"16:05:00\", \"miles\": 8232, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(325, 'UPDATE', '2024-12-14 17:08:51', 113, '{\"origin_airport_id\": 3, \"destination_airport_id\": 1, \"base_duration\": \"01:37:00\", \"miles\": 597, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(326, 'UPDATE', '2024-12-14 17:08:51', 114, '{\"origin_airport_id\": 59, \"destination_airport_id\": 1, \"base_duration\": \"08:38:00\", \"miles\": 4297, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(327, 'UPDATE', '2024-12-14 17:08:51', 115, '{\"origin_airport_id\": 61, \"destination_airport_id\": 1, \"base_duration\": \"13:15:00\", \"miles\": 6734, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(328, 'UPDATE', '2024-12-14 17:08:51', 116, '{\"origin_airport_id\": 62, \"destination_airport_id\": 1, \"base_duration\": \"10:37:00\", \"miles\": 5350, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(329, 'UPDATE', '2024-12-14 17:08:51', 117, '{\"origin_airport_id\": 63, \"destination_airport_id\": 1, \"base_duration\": \"18:06:00\", \"miles\": 9301, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(330, 'UPDATE', '2024-12-14 17:08:51', 118, '{\"origin_airport_id\": 64, \"destination_airport_id\": 1, \"base_duration\": \"03:02:00\", \"miles\": 1343, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(331, 'UPDATE', '2024-12-14 17:08:51', 119, '{\"origin_airport_id\": 65, \"destination_airport_id\": 1, \"base_duration\": \"03:31:00\", \"miles\": 1597, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(332, 'UPDATE', '2024-12-14 17:08:51', 120, '{\"origin_airport_id\": 68, \"destination_airport_id\": 1, \"base_duration\": \"03:30:00\", \"miles\": 1102, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(333, 'UPDATE', '2024-12-14 17:08:51', 121, '{\"origin_airport_id\": 70, \"destination_airport_id\": 1, \"base_duration\": \"01:50:00\", \"miles\": 711, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(334, 'UPDATE', '2024-12-14 17:08:51', 122, '{\"origin_airport_id\": 94, \"destination_airport_id\": 1, \"base_duration\": \"03:31:00\", \"miles\": 1600, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(335, 'UPDATE', '2024-12-14 17:08:51', 123, '{\"origin_airport_id\": 71, \"destination_airport_id\": 1, \"base_duration\": \"10:32:00\", \"miles\": 5302, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(336, 'UPDATE', '2024-12-14 17:08:51', 124, '{\"origin_airport_id\": 72, \"destination_airport_id\": 1, \"base_duration\": \"16:39:00\", \"miles\": 8535, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(337, 'UPDATE', '2024-12-14 17:08:51', 125, '{\"origin_airport_id\": 17, \"destination_airport_id\": 1, \"base_duration\": \"01:22:00\", \"miles\": 465, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(338, 'UPDATE', '2024-12-14 17:08:51', 126, '{\"origin_airport_id\": 98, \"destination_airport_id\": 1, \"base_duration\": \"03:33:00\", \"miles\": 1615, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(339, 'UPDATE', '2024-12-14 17:08:51', 127, '{\"origin_airport_id\": 5, \"destination_airport_id\": 1, \"base_duration\": \"01:01:00\", \"miles\": 280, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(340, 'UPDATE', '2024-12-14 17:08:51', 128, '{\"origin_airport_id\": 73, \"destination_airport_id\": 1, \"base_duration\": \"11:15:00\", \"miles\": 5684, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(341, 'UPDATE', '2024-12-14 17:08:51', 129, '{\"origin_airport_id\": 75, \"destination_airport_id\": 1, \"base_duration\": \"10:37:00\", \"miles\": 5348, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(342, 'UPDATE', '2024-12-14 17:08:51', 130, '{\"origin_airport_id\": 89, \"destination_airport_id\": 1, \"base_duration\": \"16:37:00\", \"miles\": 8520, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(343, 'UPDATE', '2024-12-14 17:08:51', 131, '{\"origin_airport_id\": 76, \"destination_airport_id\": 1, \"base_duration\": \"03:18:00\", \"miles\": 1479, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(344, 'UPDATE', '2024-12-14 17:08:51', 132, '{\"origin_airport_id\": 90, \"destination_airport_id\": 1, \"base_duration\": \"03:35:00\", \"miles\": 1634, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(345, 'UPDATE', '2024-12-14 17:08:51', 133, '{\"origin_airport_id\": 6, \"destination_airport_id\": 1, \"base_duration\": \"00:54:00\", \"miles\": 215, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(346, 'UPDATE', '2024-12-14 17:08:51', 134, '{\"origin_airport_id\": 77, \"destination_airport_id\": 1, \"base_duration\": \"03:02:00\", \"miles\": 1339, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(347, 'UPDATE', '2024-12-14 17:08:51', 135, '{\"origin_airport_id\": 79, \"destination_airport_id\": 1, \"base_duration\": \"03:25:00\", \"miles\": 1546, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(348, 'UPDATE', '2024-12-14 17:08:51', 136, '{\"origin_airport_id\": 80, \"destination_airport_id\": 1, \"base_duration\": \"09:27:00\", \"miles\": 4730, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(349, 'UPDATE', '2024-12-14 17:08:51', 137, '{\"origin_airport_id\": 23, \"destination_airport_id\": 1, \"base_duration\": \"00:58:00\", \"miles\": 254, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(350, 'UPDATE', '2024-12-14 17:08:51', 138, '{\"origin_airport_id\": 81, \"destination_airport_id\": 1, \"base_duration\": \"14:28:00\", \"miles\": 7385, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(351, 'UPDATE', '2024-12-14 17:08:51', 139, '{\"origin_airport_id\": 83, \"destination_airport_id\": 1, \"base_duration\": \"14:19:00\", \"miles\": 7305, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(352, 'UPDATE', '2024-12-14 17:08:51', 140, '{\"origin_airport_id\": 14, \"destination_airport_id\": 1, \"base_duration\": \"00:53:00\", \"miles\": 205, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(353, 'UPDATE', '2024-12-14 17:08:51', 141, '{\"origin_airport_id\": 82, \"destination_airport_id\": 1, \"base_duration\": \"13:11:00\", \"miles\": 6699, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(354, 'UPDATE', '2024-12-14 17:08:51', 142, '{\"origin_airport_id\": 85, \"destination_airport_id\": 1, \"base_duration\": \"07:54:00\", \"miles\": 3909, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(355, 'UPDATE', '2024-12-14 17:08:51', 143, '{\"origin_airport_id\": 84, \"destination_airport_id\": 1, \"base_duration\": \"01:51:00\", \"miles\": 717, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(356, 'UPDATE', '2024-12-14 17:08:51', 144, '{\"origin_airport_id\": 86, \"destination_airport_id\": 1, \"base_duration\": \"18:08:00\", \"miles\": 9314, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(357, 'UPDATE', '2024-12-14 17:08:51', 145, '{\"origin_airport_id\": 88, \"destination_airport_id\": 1, \"base_duration\": \"03:44:00\", \"miles\": 1712, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(358, 'UPDATE', '2024-12-14 17:08:51', 146, '{\"origin_airport_id\": 104, \"destination_airport_id\": 1, \"base_duration\": \"04:05:00\", \"miles\": 1893, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(359, 'UPDATE', '2024-12-14 17:08:51', 147, '{\"origin_airport_id\": 47, \"destination_airport_id\": 1, \"base_duration\": \"15:53:00\", \"miles\": 8132, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(360, 'UPDATE', '2024-12-14 17:08:51', 148, '{\"origin_airport_id\": 16, \"destination_airport_id\": 1, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(361, 'UPDATE', '2024-12-14 17:08:51', 149, '{\"origin_airport_id\": 22, \"destination_airport_id\": 1, \"base_duration\": \"01:25:00\", \"miles\": 488, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(362, 'UPDATE', '2024-12-14 17:08:51', 150, '{\"origin_airport_id\": 95, \"destination_airport_id\": 1, \"base_duration\": \"13:12:00\", \"miles\": 6712, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(363, 'UPDATE', '2024-12-14 17:08:51', 151, '{\"origin_airport_id\": 36, \"destination_airport_id\": 1, \"base_duration\": \"03:52:00\", \"miles\": 1781, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(364, 'UPDATE', '2024-12-14 17:08:51', 152, '{\"origin_airport_id\": 92, \"destination_airport_id\": 1, \"base_duration\": \"06:34:00\", \"miles\": 3211, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(365, 'UPDATE', '2024-12-14 17:08:51', 153, '{\"origin_airport_id\": 93, \"destination_airport_id\": 1, \"base_duration\": \"02:35:00\", \"miles\": 1109, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(366, 'UPDATE', '2024-12-14 17:08:51', 154, '{\"origin_airport_id\": 7, \"destination_airport_id\": 1, \"base_duration\": \"01:11:00\", \"miles\": 362, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(367, 'UPDATE', '2024-12-14 17:08:51', 155, '{\"origin_airport_id\": 42, \"destination_airport_id\": 1, \"base_duration\": \"03:21:00\", \"miles\": 1506, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(368, 'UPDATE', '2024-12-14 17:08:51', 156, '{\"origin_airport_id\": 99, \"destination_airport_id\": 1, \"base_duration\": \"02:40:00\", \"miles\": 1146, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(369, 'UPDATE', '2024-12-14 17:08:51', 157, '{\"origin_airport_id\": 96, \"destination_airport_id\": 1, \"base_duration\": \"09:39:00\", \"miles\": 4839, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(370, 'UPDATE', '2024-12-14 17:08:51', 158, '{\"origin_airport_id\": 18, \"destination_airport_id\": 1, \"base_duration\": \"00:56:00\", \"miles\": 232, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(371, 'UPDATE', '2024-12-14 17:08:51', 159, '{\"origin_airport_id\": 97, \"destination_airport_id\": 1, \"base_duration\": \"13:43:00\", \"miles\": 6987, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(372, 'UPDATE', '2024-12-14 17:08:51', 160, '{\"origin_airport_id\": 69, \"destination_airport_id\": 1, \"base_duration\": \"02:23:00\", \"miles\": 1002, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(373, 'UPDATE', '2024-12-14 17:08:51', 161, '{\"origin_airport_id\": 100, \"destination_airport_id\": 1, \"base_duration\": \"03:17:00\", \"miles\": 1474, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(374, 'UPDATE', '2024-12-14 17:08:51', 162, '{\"origin_airport_id\": 101, \"destination_airport_id\": 1, \"base_duration\": \"07:50:00\", \"miles\": 3879, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(375, 'UPDATE', '2024-12-14 17:08:51', 163, '{\"origin_airport_id\": 10, \"destination_airport_id\": 1, \"base_duration\": \"01:09:00\", \"miles\": 352, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(376, 'UPDATE', '2024-12-14 17:08:51', 164, '{\"origin_airport_id\": 103, \"destination_airport_id\": 1, \"base_duration\": \"10:52:00\", \"miles\": 5476, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(377, 'UPDATE', '2024-12-14 17:08:51', 165, '{\"origin_airport_id\": 102, \"destination_airport_id\": 1, \"base_duration\": \"01:52:00\", \"miles\": 727, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(378, 'UPDATE', '2024-12-14 17:08:51', 166, '{\"origin_airport_id\": 15, \"destination_airport_id\": 1, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(379, 'UPDATE', '2024-12-14 17:08:51', 167, '{\"origin_airport_id\": 25, \"destination_airport_id\": 1, \"base_duration\": \"01:44:00\", \"miles\": 656, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(380, 'UPDATE', '2024-12-14 17:08:51', 168, '{\"origin_airport_id\": 107, \"destination_airport_id\": 1, \"base_duration\": \"10:15:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(381, 'UPDATE', '2024-12-14 17:08:51', 169, '{\"origin_airport_id\": 55, \"destination_airport_id\": 1, \"base_duration\": \"15:43:00\", \"miles\": 8043, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(382, 'UPDATE', '2024-12-14 17:08:51', 170, '{\"origin_airport_id\": 60, \"destination_airport_id\": 1, \"base_duration\": \"13:17:00\", \"miles\": 6760, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(383, 'UPDATE', '2024-12-14 17:08:51', 171, '{\"origin_airport_id\": 67, \"destination_airport_id\": 1, \"base_duration\": \"16:16:00\", \"miles\": 8334, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(384, 'UPDATE', '2024-12-14 17:08:51', 172, '{\"origin_airport_id\": 78, \"destination_airport_id\": 1, \"base_duration\": \"13:02:00\", \"miles\": 6620, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(385, 'UPDATE', '2024-12-14 17:08:51', 173, '{\"origin_airport_id\": 87, \"destination_airport_id\": 1, \"base_duration\": \"16:01:00\", \"miles\": 8201, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(386, 'UPDATE', '2024-12-14 17:08:51', 174, '{\"origin_airport_id\": 106, \"destination_airport_id\": 1, \"base_duration\": \"12:55:00\", \"miles\": 6567, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(387, 'UPDATE', '2024-12-14 17:08:51', 175, '{\"origin_airport_id\": 43, \"destination_airport_id\": 1, \"base_duration\": \"13:26:00\", \"miles\": 6836, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(388, 'UPDATE', '2024-12-14 17:08:51', 176, '{\"origin_airport_id\": 44, \"destination_airport_id\": 1, \"base_duration\": \"16:05:00\", \"miles\": 8238, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(389, 'UPDATE', '2024-12-14 17:08:51', 177, '{\"origin_airport_id\": 105, \"destination_airport_id\": 1, \"base_duration\": \"16:03:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(390, 'UPDATE', '2024-12-14 17:08:51', 178, '{\"origin_airport_id\": 11, \"destination_airport_id\": 1, \"base_duration\": \"01:29:00\", \"miles\": 526, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(391, 'UPDATE', '2024-12-14 17:08:51', 179, '{\"origin_airport_id\": 1, \"destination_airport_id\": 88, \"base_duration\": \"03:44:00\", \"miles\": 1712, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(392, 'UPDATE', '2024-12-14 17:08:51', 180, '{\"origin_airport_id\": 1, \"destination_airport_id\": 104, \"base_duration\": \"04:05:00\", \"miles\": 1893, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(393, 'UPDATE', '2024-12-14 17:08:51', 181, '{\"origin_airport_id\": 1, \"destination_airport_id\": 47, \"base_duration\": \"15:54:00\", \"miles\": 8132, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(394, 'UPDATE', '2024-12-14 17:08:51', 182, '{\"origin_airport_id\": 1, \"destination_airport_id\": 16, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(395, 'UPDATE', '2024-12-14 17:08:51', 183, '{\"origin_airport_id\": 1, \"destination_airport_id\": 22, \"base_duration\": \"01:25:00\", \"miles\": 488, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(396, 'UPDATE', '2024-12-14 17:08:51', 184, '{\"origin_airport_id\": 1, \"destination_airport_id\": 95, \"base_duration\": \"13:12:00\", \"miles\": 6712, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(397, 'UPDATE', '2024-12-14 17:08:51', 185, '{\"origin_airport_id\": 1, \"destination_airport_id\": 36, \"base_duration\": \"03:52:00\", \"miles\": 1781, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(398, 'UPDATE', '2024-12-14 17:08:51', 186, '{\"origin_airport_id\": 1, \"destination_airport_id\": 92, \"base_duration\": \"06:34:00\", \"miles\": 3211, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(399, 'UPDATE', '2024-12-14 17:08:51', 187, '{\"origin_airport_id\": 1, \"destination_airport_id\": 93, \"base_duration\": \"02:35:00\", \"miles\": 1109, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(400, 'UPDATE', '2024-12-14 17:08:51', 188, '{\"origin_airport_id\": 1, \"destination_airport_id\": 7, \"base_duration\": \"01:11:00\", \"miles\": 362, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(401, 'UPDATE', '2024-12-14 17:08:51', 189, '{\"origin_airport_id\": 1, \"destination_airport_id\": 42, \"base_duration\": \"03:21:00\", \"miles\": 1506, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(402, 'UPDATE', '2024-12-14 17:08:51', 190, '{\"origin_airport_id\": 1, \"destination_airport_id\": 99, \"base_duration\": \"02:40:00\", \"miles\": 1146, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(403, 'UPDATE', '2024-12-14 17:08:51', 191, '{\"origin_airport_id\": 1, \"destination_airport_id\": 96, \"base_duration\": \"09:39:00\", \"miles\": 4839, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(404, 'UPDATE', '2024-12-14 17:08:51', 192, '{\"origin_airport_id\": 1, \"destination_airport_id\": 18, \"base_duration\": \"00:56:00\", \"miles\": 232, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(405, 'UPDATE', '2024-12-14 17:08:51', 193, '{\"origin_airport_id\": 1, \"destination_airport_id\": 97, \"base_duration\": \"13:43:00\", \"miles\": 6987, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(406, 'UPDATE', '2024-12-14 17:08:51', 194, '{\"origin_airport_id\": 1, \"destination_airport_id\": 69, \"base_duration\": \"02:23:00\", \"miles\": 1002, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(407, 'UPDATE', '2024-12-14 17:08:51', 195, '{\"origin_airport_id\": 1, \"destination_airport_id\": 100, \"base_duration\": \"03:17:00\", \"miles\": 1474, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(408, 'UPDATE', '2024-12-14 17:08:51', 196, '{\"origin_airport_id\": 1, \"destination_airport_id\": 101, \"base_duration\": \"07:50:00\", \"miles\": 3879, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(409, 'UPDATE', '2024-12-14 17:08:51', 197, '{\"origin_airport_id\": 1, \"destination_airport_id\": 10, \"base_duration\": \"01:09:00\", \"miles\": 352, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(410, 'UPDATE', '2024-12-14 17:08:51', 198, '{\"origin_airport_id\": 1, \"destination_airport_id\": 103, \"base_duration\": \"10:52:00\", \"miles\": 5476, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(411, 'UPDATE', '2024-12-14 17:08:51', 199, '{\"origin_airport_id\": 1, \"destination_airport_id\": 102, \"base_duration\": \"01:52:00\", \"miles\": 727, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(412, 'UPDATE', '2024-12-14 17:08:51', 200, '{\"origin_airport_id\": 1, \"destination_airport_id\": 15, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(413, 'UPDATE', '2024-12-14 17:08:51', 201, '{\"origin_airport_id\": 1, \"destination_airport_id\": 25, \"base_duration\": \"01:44:00\", \"miles\": 656, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(414, 'UPDATE', '2024-12-14 17:08:51', 202, '{\"origin_airport_id\": 1, \"destination_airport_id\": 107, \"base_duration\": \"10:15:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(415, 'UPDATE', '2024-12-14 17:08:51', 203, '{\"origin_airport_id\": 1, \"destination_airport_id\": 55, \"base_duration\": \"15:43:00\", \"miles\": 8043, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(416, 'UPDATE', '2024-12-14 17:08:51', 204, '{\"origin_airport_id\": 1, \"destination_airport_id\": 60, \"base_duration\": \"13:17:00\", \"miles\": 6760, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(417, 'UPDATE', '2024-12-14 17:08:51', 205, '{\"origin_airport_id\": 1, \"destination_airport_id\": 67, \"base_duration\": \"16:16:00\", \"miles\": 8334, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(418, 'UPDATE', '2024-12-14 17:08:51', 206, '{\"origin_airport_id\": 1, \"destination_airport_id\": 78, \"base_duration\": \"13:02:00\", \"miles\": 6620, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(419, 'UPDATE', '2024-12-14 17:08:51', 207, '{\"origin_airport_id\": 1, \"destination_airport_id\": 87, \"base_duration\": \"16:01:00\", \"miles\": 8201, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(420, 'UPDATE', '2024-12-14 17:08:51', 208, '{\"origin_airport_id\": 1, \"destination_airport_id\": 106, \"base_duration\": \"12:55:00\", \"miles\": 6567, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(421, 'UPDATE', '2024-12-14 17:08:51', 209, '{\"origin_airport_id\": 1, \"destination_airport_id\": 43, \"base_duration\": \"13:26:00\", \"miles\": 8238, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(422, 'UPDATE', '2024-12-14 17:08:51', 210, '{\"origin_airport_id\": 1, \"destination_airport_id\": 44, \"base_duration\": \"16:05:00\", \"miles\": 8238, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(423, 'UPDATE', '2024-12-14 17:08:51', 211, '{\"origin_airport_id\": 1, \"destination_airport_id\": 105, \"base_duration\": \"16:03:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(424, 'UPDATE', '2024-12-14 17:08:51', 212, '{\"origin_airport_id\": 1, \"destination_airport_id\": 11, \"base_duration\": \"01:29:00\", \"miles\": 526, \"timestamp\": \"2024-12-14 17:08:51\"}'),
(425, 'UPDATE', '2024-12-14 17:10:14', 1, '{\"origin_airport_id\": 1, \"destination_airport_id\": 31, \"base_duration\": \"09:55:00\", \"miles\": 4979, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(426, 'UPDATE', '2024-12-14 17:10:14', 2, '{\"origin_airport_id\": 1, \"destination_airport_id\": 29, \"base_duration\": \"10:33:00\", \"miles\": 5313, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(427, 'UPDATE', '2024-12-14 17:10:14', 3, '{\"origin_airport_id\": 1, \"destination_airport_id\": 27, \"base_duration\": \"03:21:00\", \"miles\": 1514, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(428, 'UPDATE', '2024-12-14 17:10:14', 4, '{\"origin_airport_id\": 1, \"destination_airport_id\": 28, \"base_duration\": \"02:35:00\", \"miles\": 1108, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(429, 'UPDATE', '2024-12-14 17:10:14', 5, '{\"origin_airport_id\": 1, \"destination_airport_id\": 30, \"base_duration\": \"17:00:00\", \"miles\": 8722, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(430, 'UPDATE', '2024-12-14 17:10:14', 6, '{\"origin_airport_id\": 1, \"destination_airport_id\": 32, \"base_duration\": \"16:27:00\", \"miles\": 8427, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(431, 'UPDATE', '2024-12-14 17:10:14', 7, '{\"origin_airport_id\": 1, \"destination_airport_id\": 26, \"base_duration\": \"04:26:00\", \"miles\": 2085, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(432, 'UPDATE', '2024-12-14 17:10:14', 8, '{\"origin_airport_id\": 1, \"destination_airport_id\": 33, \"base_duration\": \"09:10:00\", \"miles\": 4586, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(433, 'UPDATE', '2024-12-14 17:10:14', 9, '{\"origin_airport_id\": 1, \"destination_airport_id\": 9, \"base_duration\": \"01:02:00\", \"miles\": 290, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(434, 'UPDATE', '2024-12-14 17:10:14', 10, '{\"origin_airport_id\": 1, \"destination_airport_id\": 35, \"base_duration\": \"03:03:00\", \"miles\": 1361, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(435, 'UPDATE', '2024-12-14 17:10:14', 11, '{\"origin_airport_id\": 1, \"destination_airport_id\": 37, \"base_duration\": \"13:00:00\", \"miles\": 6606, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(436, 'UPDATE', '2024-12-14 17:10:14', 12, '{\"origin_airport_id\": 1, \"destination_airport_id\": 41, \"base_duration\": \"07:18:00\", \"miles\": 3596, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(437, 'UPDATE', '2024-12-14 17:10:14', 13, '{\"origin_airport_id\": 1, \"destination_airport_id\": 39, \"base_duration\": \"13:51:00\", \"miles\": 7053, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(438, 'UPDATE', '2024-12-14 17:10:14', 14, '{\"origin_airport_id\": 1, \"destination_airport_id\": 40, \"base_duration\": \"16:29:00\", \"miles\": 8444, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(439, 'UPDATE', '2024-12-14 17:10:14', 15, '{\"origin_airport_id\": 1, \"destination_airport_id\": 24, \"base_duration\": \"01:16:00\", \"miles\": 414, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(440, 'UPDATE', '2024-12-14 17:10:14', 16, '{\"origin_airport_id\": 1, \"destination_airport_id\": 38, \"base_duration\": \"02:18:00\", \"miles\": 954, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(441, 'UPDATE', '2024-12-14 17:10:14', 17, '{\"origin_airport_id\": 1, \"destination_airport_id\": 12, \"base_duration\": \"01:25:00\", \"miles\": 487, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(442, 'UPDATE', '2024-12-14 17:10:14', 18, '{\"origin_airport_id\": 1, \"destination_airport_id\": 66, \"base_duration\": \"02:00:00\", \"miles\": 792, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(443, 'UPDATE', '2024-12-14 17:10:14', 19, '{\"origin_airport_id\": 1, \"destination_airport_id\": 19, \"base_duration\": \"01:32:00\", \"miles\": 549, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(444, 'UPDATE', '2024-12-14 17:10:14', 20, '{\"origin_airport_id\": 1, \"destination_airport_id\": 91, \"base_duration\": \"13:08:00\", \"miles\": 6678, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(445, 'UPDATE', '2024-12-14 17:10:14', 21, '{\"origin_airport_id\": 1, \"destination_airport_id\": 2, \"base_duration\": \"01:10:00\", \"miles\": 521, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(446, 'UPDATE', '2024-12-14 17:10:14', 22, '{\"origin_airport_id\": 1, \"destination_airport_id\": 74, \"base_duration\": \"03:46:00\", \"miles\": 1727, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(447, 'UPDATE', '2024-12-14 17:10:14', 23, '{\"origin_airport_id\": 1, \"destination_airport_id\": 8, \"base_duration\": \"01:23:00\", \"miles\": 467, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(448, 'UPDATE', '2024-12-14 17:10:14', 24, '{\"origin_airport_id\": 1, \"destination_airport_id\": 48, \"base_duration\": \"01:16:00\", \"miles\": 414, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(449, 'UPDATE', '2024-12-14 17:10:14', 25, '{\"origin_airport_id\": 1, \"destination_airport_id\": 50, \"base_duration\": \"01:44:00\", \"miles\": 656, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(450, 'UPDATE', '2024-12-14 17:10:14', 26, '{\"origin_airport_id\": 1, \"destination_airport_id\": 51, \"base_duration\": \"16:21:00\", \"miles\": 8379, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(451, 'UPDATE', '2024-12-14 17:10:14', 27, '{\"origin_airport_id\": 1, \"destination_airport_id\": 46, \"base_duration\": \"03:21:00\", \"miles\": 1514, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(452, 'UPDATE', '2024-12-14 17:10:14', 28, '{\"origin_airport_id\": 1, \"destination_airport_id\": 4, \"base_duration\": \"00:36:00\", \"miles\": 56, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(453, 'UPDATE', '2024-12-14 17:10:14', 29, '{\"origin_airport_id\": 1, \"destination_airport_id\": 52, \"base_duration\": \"16:41:00\", \"miles\": 8551, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(454, 'UPDATE', '2024-12-14 17:10:14', 30, '{\"origin_airport_id\": 1, \"destination_airport_id\": 45, \"base_duration\": \"03:26:00\", \"miles\": 1549, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(455, 'UPDATE', '2024-12-14 17:10:14', 31, '{\"origin_airport_id\": 1, \"destination_airport_id\": 49, \"base_duration\": \"16:23:00\", \"miles\": 8392, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(456, 'UPDATE', '2024-12-14 17:10:14', 32, '{\"origin_airport_id\": 1, \"destination_airport_id\": 21, \"base_duration\": \"00:49:00\", \"miles\": 173, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(457, 'UPDATE', '2024-12-14 17:10:14', 33, '{\"origin_airport_id\": 1, \"destination_airport_id\": 56, \"base_duration\": \"15:02:00\", \"miles\": 7680, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(458, 'UPDATE', '2024-12-14 17:10:14', 34, '{\"origin_airport_id\": 1, \"destination_airport_id\": 53, \"base_duration\": \"16:15:00\", \"miles\": 8320, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(459, 'UPDATE', '2024-12-14 17:10:14', 35, '{\"origin_airport_id\": 1, \"destination_airport_id\": 13, \"base_duration\": \"01:14:00\", \"miles\": 388, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(460, 'UPDATE', '2024-12-14 17:10:14', 36, '{\"origin_airport_id\": 1, \"destination_airport_id\": 54, \"base_duration\": \"09:16:00\", \"miles\": 4636, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(461, 'UPDATE', '2024-12-14 17:10:14', 37, '{\"origin_airport_id\": 1, \"destination_airport_id\": 58, \"base_duration\": \"09:04:00\", \"miles\": 4531, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(462, 'UPDATE', '2024-12-14 17:10:14', 38, '{\"origin_airport_id\": 1, \"destination_airport_id\": 20, \"base_duration\": \"01:19:00\", \"miles\": 435, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(463, 'UPDATE', '2024-12-14 17:10:14', 39, '{\"origin_airport_id\": 1, \"destination_airport_id\": 34, \"base_duration\": \"03:37:00\", \"miles\": 1648, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(464, 'UPDATE', '2024-12-14 17:10:14', 40, '{\"origin_airport_id\": 1, \"destination_airport_id\": 57, \"base_duration\": \"16:05:00\", \"miles\": 8232, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(465, 'UPDATE', '2024-12-14 17:10:14', 41, '{\"origin_airport_id\": 1, \"destination_airport_id\": 3, \"base_duration\": \"01:37:00\", \"miles\": 597, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(466, 'UPDATE', '2024-12-14 17:10:14', 42, '{\"origin_airport_id\": 1, \"destination_airport_id\": 59, \"base_duration\": \"08:38:00\", \"miles\": 4297, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(467, 'UPDATE', '2024-12-14 17:10:14', 43, '{\"origin_airport_id\": 1, \"destination_airport_id\": 61, \"base_duration\": \"13:15:00\", \"miles\": 6734, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(468, 'UPDATE', '2024-12-14 17:10:14', 44, '{\"origin_airport_id\": 1, \"destination_airport_id\": 62, \"base_duration\": \"10:37:00\", \"miles\": 5350, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(469, 'UPDATE', '2024-12-14 17:10:14', 45, '{\"origin_airport_id\": 1, \"destination_airport_id\": 63, \"base_duration\": \"18:06:00\", \"miles\": 9301, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(470, 'UPDATE', '2024-12-14 17:10:14', 46, '{\"origin_airport_id\": 1, \"destination_airport_id\": 64, \"base_duration\": \"03:02:00\", \"miles\": 1343, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(471, 'UPDATE', '2024-12-14 17:10:14', 47, '{\"origin_airport_id\": 1, \"destination_airport_id\": 65, \"base_duration\": \"03:31:00\", \"miles\": 1597, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(472, 'UPDATE', '2024-12-14 17:10:14', 48, '{\"origin_airport_id\": 1, \"destination_airport_id\": 68, \"base_duration\": \"03:30:00\", \"miles\": 1102, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(473, 'UPDATE', '2024-12-14 17:10:14', 49, '{\"origin_airport_id\": 1, \"destination_airport_id\": 70, \"base_duration\": \"01:50:00\", \"miles\": 711, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(474, 'UPDATE', '2024-12-14 17:10:14', 50, '{\"origin_airport_id\": 1, \"destination_airport_id\": 94, \"base_duration\": \"03:31:00\", \"miles\": 1600, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(475, 'UPDATE', '2024-12-14 17:10:14', 51, '{\"origin_airport_id\": 1, \"destination_airport_id\": 71, \"base_duration\": \"10:32:00\", \"miles\": 5302, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(476, 'UPDATE', '2024-12-14 17:10:14', 52, '{\"origin_airport_id\": 1, \"destination_airport_id\": 72, \"base_duration\": \"16:39:00\", \"miles\": 8535, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(477, 'UPDATE', '2024-12-14 17:10:14', 53, '{\"origin_airport_id\": 1, \"destination_airport_id\": 17, \"base_duration\": \"01:22:00\", \"miles\": 465, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(478, 'UPDATE', '2024-12-14 17:10:14', 54, '{\"origin_airport_id\": 1, \"destination_airport_id\": 98, \"base_duration\": \"03:33:00\", \"miles\": 1615, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(479, 'UPDATE', '2024-12-14 17:10:14', 55, '{\"origin_airport_id\": 1, \"destination_airport_id\": 5, \"base_duration\": \"01:01:00\", \"miles\": 280, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(480, 'UPDATE', '2024-12-14 17:10:14', 56, '{\"origin_airport_id\": 1, \"destination_airport_id\": 73, \"base_duration\": \"11:15:00\", \"miles\": 5684, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(481, 'UPDATE', '2024-12-14 17:10:14', 57, '{\"origin_airport_id\": 1, \"destination_airport_id\": 75, \"base_duration\": \"10:37:00\", \"miles\": 5348, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(482, 'UPDATE', '2024-12-14 17:10:14', 58, '{\"origin_airport_id\": 1, \"destination_airport_id\": 89, \"base_duration\": \"16:37:00\", \"miles\": 8520, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(483, 'UPDATE', '2024-12-14 17:10:14', 59, '{\"origin_airport_id\": 1, \"destination_airport_id\": 76, \"base_duration\": \"03:18:00\", \"miles\": 1479, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(484, 'UPDATE', '2024-12-14 17:10:14', 60, '{\"origin_airport_id\": 1, \"destination_airport_id\": 90, \"base_duration\": \"03:35:00\", \"miles\": 1634, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(485, 'UPDATE', '2024-12-14 17:10:14', 61, '{\"origin_airport_id\": 1, \"destination_airport_id\": 6, \"base_duration\": \"00:54:00\", \"miles\": 215, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(486, 'UPDATE', '2024-12-14 17:10:14', 62, '{\"origin_airport_id\": 1, \"destination_airport_id\": 77, \"base_duration\": \"03:02:00\", \"miles\": 1339, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(487, 'UPDATE', '2024-12-14 17:10:14', 63, '{\"origin_airport_id\": 1, \"destination_airport_id\": 79, \"base_duration\": \"03:25:00\", \"miles\": 1546, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(488, 'UPDATE', '2024-12-14 17:10:14', 64, '{\"origin_airport_id\": 1, \"destination_airport_id\": 80, \"base_duration\": \"09:27:00\", \"miles\": 4730, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(489, 'UPDATE', '2024-12-14 17:10:14', 65, '{\"origin_airport_id\": 1, \"destination_airport_id\": 23, \"base_duration\": \"00:58:00\", \"miles\": 254, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(490, 'UPDATE', '2024-12-14 17:10:14', 66, '{\"origin_airport_id\": 1, \"destination_airport_id\": 81, \"base_duration\": \"14:28:00\", \"miles\": 7385, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(491, 'UPDATE', '2024-12-14 17:10:14', 67, '{\"origin_airport_id\": 1, \"destination_airport_id\": 83, \"base_duration\": \"14:19:00\", \"miles\": 7305, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(492, 'UPDATE', '2024-12-14 17:10:14', 68, '{\"origin_airport_id\": 1, \"destination_airport_id\": 14, \"base_duration\": \"00:53:00\", \"miles\": 205, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(493, 'UPDATE', '2024-12-14 17:10:14', 69, '{\"origin_airport_id\": 1, \"destination_airport_id\": 82, \"base_duration\": \"13:11:00\", \"miles\": 6699, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(494, 'UPDATE', '2024-12-14 17:10:14', 70, '{\"origin_airport_id\": 1, \"destination_airport_id\": 85, \"base_duration\": \"07:54:00\", \"miles\": 3909, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(495, 'UPDATE', '2024-12-14 17:10:14', 71, '{\"origin_airport_id\": 1, \"destination_airport_id\": 84, \"base_duration\": \"01:51:00\", \"miles\": 717, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(496, 'UPDATE', '2024-12-14 17:10:14', 72, '{\"origin_airport_id\": 1, \"destination_airport_id\": 86, \"base_duration\": \"18:08:00\", \"miles\": 9314, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(497, 'UPDATE', '2024-12-14 17:10:14', 73, '{\"origin_airport_id\": 31, \"destination_airport_id\": 1, \"base_duration\": \"09:55:00\", \"miles\": 4979, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(498, 'UPDATE', '2024-12-14 17:10:14', 74, '{\"origin_airport_id\": 29, \"destination_airport_id\": 1, \"base_duration\": \"10:33:00\", \"miles\": 5313, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(499, 'UPDATE', '2024-12-14 17:10:14', 75, '{\"origin_airport_id\": 27, \"destination_airport_id\": 1, \"base_duration\": \"03:21:00\", \"miles\": 1514, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(500, 'UPDATE', '2024-12-14 17:10:14', 76, '{\"origin_airport_id\": 28, \"destination_airport_id\": 1, \"base_duration\": \"02:35:00\", \"miles\": 1108, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(501, 'UPDATE', '2024-12-14 17:10:14', 77, '{\"origin_airport_id\": 30, \"destination_airport_id\": 1, \"base_duration\": \"17:00:00\", \"miles\": 8722, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(502, 'UPDATE', '2024-12-14 17:10:14', 78, '{\"origin_airport_id\": 32, \"destination_airport_id\": 1, \"base_duration\": \"16:27:00\", \"miles\": 8427, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(503, 'UPDATE', '2024-12-14 17:10:14', 79, '{\"origin_airport_id\": 26, \"destination_airport_id\": 1, \"base_duration\": \"04:26:00\", \"miles\": 2085, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(504, 'UPDATE', '2024-12-14 17:10:14', 80, '{\"origin_airport_id\": 33, \"destination_airport_id\": 1, \"base_duration\": \"09:10:00\", \"miles\": 4586, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(505, 'UPDATE', '2024-12-14 17:10:14', 81, '{\"origin_airport_id\": 9, \"destination_airport_id\": 1, \"base_duration\": \"01:02:00\", \"miles\": 290, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(506, 'UPDATE', '2024-12-14 17:10:14', 82, '{\"origin_airport_id\": 35, \"destination_airport_id\": 1, \"base_duration\": \"03:03:00\", \"miles\": 1361, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(507, 'UPDATE', '2024-12-14 17:10:14', 83, '{\"origin_airport_id\": 37, \"destination_airport_id\": 1, \"base_duration\": \"13:00:00\", \"miles\": 6606, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(508, 'UPDATE', '2024-12-14 17:10:14', 84, '{\"origin_airport_id\": 41, \"destination_airport_id\": 1, \"base_duration\": \"07:18:00\", \"miles\": 3596, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(509, 'UPDATE', '2024-12-14 17:10:14', 85, '{\"origin_airport_id\": 39, \"destination_airport_id\": 1, \"base_duration\": \"13:51:00\", \"miles\": 7053, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(510, 'UPDATE', '2024-12-14 17:10:14', 86, '{\"origin_airport_id\": 40, \"destination_airport_id\": 1, \"base_duration\": \"16:29:00\", \"miles\": 8444, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(511, 'UPDATE', '2024-12-14 17:10:14', 87, '{\"origin_airport_id\": 24, \"destination_airport_id\": 1, \"base_duration\": \"01:16:00\", \"miles\": 414, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(512, 'UPDATE', '2024-12-14 17:10:14', 88, '{\"origin_airport_id\": 38, \"destination_airport_id\": 1, \"base_duration\": \"02:18:00\", \"miles\": 954, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(513, 'UPDATE', '2024-12-14 17:10:14', 89, '{\"origin_airport_id\": 12, \"destination_airport_id\": 1, \"base_duration\": \"01:25:00\", \"miles\": 487, \"timestamp\": \"2024-12-14 17:10:14\"}');
INSERT INTO `audit_flight_duration` (`audit_id`, `action_type`, `action_timestamp`, `duration_id`, `duration_data`) VALUES
(514, 'UPDATE', '2024-12-14 17:10:14', 90, '{\"origin_airport_id\": 66, \"destination_airport_id\": 1, \"base_duration\": \"02:00:00\", \"miles\": 792, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(515, 'UPDATE', '2024-12-14 17:10:14', 91, '{\"origin_airport_id\": 19, \"destination_airport_id\": 1, \"base_duration\": \"01:32:00\", \"miles\": 549, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(516, 'UPDATE', '2024-12-14 17:10:14', 92, '{\"origin_airport_id\": 91, \"destination_airport_id\": 1, \"base_duration\": \"13:08:00\", \"miles\": 6678, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(517, 'UPDATE', '2024-12-14 17:10:14', 93, '{\"origin_airport_id\": 2, \"destination_airport_id\": 1, \"base_duration\": \"01:10:00\", \"miles\": 521, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(518, 'UPDATE', '2024-12-14 17:10:14', 94, '{\"origin_airport_id\": 74, \"destination_airport_id\": 1, \"base_duration\": \"03:46:00\", \"miles\": 1727, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(519, 'UPDATE', '2024-12-14 17:10:14', 95, '{\"origin_airport_id\": 8, \"destination_airport_id\": 1, \"base_duration\": \"01:23:00\", \"miles\": 467, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(520, 'UPDATE', '2024-12-14 17:10:14', 96, '{\"origin_airport_id\": 48, \"destination_airport_id\": 1, \"base_duration\": \"10:14:00\", \"miles\": 5148, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(521, 'UPDATE', '2024-12-14 17:10:14', 97, '{\"origin_airport_id\": 50, \"destination_airport_id\": 1, \"base_duration\": \"16:14:00\", \"miles\": 8316, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(522, 'UPDATE', '2024-12-14 17:10:14', 98, '{\"origin_airport_id\": 51, \"destination_airport_id\": 1, \"base_duration\": \"16:21:00\", \"miles\": 8379, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(523, 'UPDATE', '2024-12-14 17:10:14', 99, '{\"origin_airport_id\": 46, \"destination_airport_id\": 1, \"base_duration\": \"03:19:00\", \"miles\": 1490, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(524, 'UPDATE', '2024-12-14 17:10:14', 100, '{\"origin_airport_id\": 4, \"destination_airport_id\": 1, \"base_duration\": \"00:36:00\", \"miles\": 56, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(525, 'UPDATE', '2024-12-14 17:10:14', 101, '{\"origin_airport_id\": 52, \"destination_airport_id\": 1, \"base_duration\": \"16:41:00\", \"miles\": 8551, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(526, 'UPDATE', '2024-12-14 17:10:14', 102, '{\"origin_airport_id\": 45, \"destination_airport_id\": 1, \"base_duration\": \"03:26:00\", \"miles\": 1549, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(527, 'UPDATE', '2024-12-14 17:10:14', 103, '{\"origin_airport_id\": 49, \"destination_airport_id\": 1, \"base_duration\": \"16:23:00\", \"miles\": 8392, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(528, 'UPDATE', '2024-12-14 17:10:14', 104, '{\"origin_airport_id\": 21, \"destination_airport_id\": 1, \"base_duration\": \"00:49:00\", \"miles\": 173, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(529, 'UPDATE', '2024-12-14 17:10:14', 105, '{\"origin_airport_id\": 56, \"destination_airport_id\": 1, \"base_duration\": \"15:02:00\", \"miles\": 7680, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(530, 'UPDATE', '2024-12-14 17:10:14', 106, '{\"origin_airport_id\": 53, \"destination_airport_id\": 1, \"base_duration\": \"16:15:00\", \"miles\": 8320, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(531, 'UPDATE', '2024-12-14 17:10:14', 107, '{\"origin_airport_id\": 13, \"destination_airport_id\": 1, \"base_duration\": \"01:14:00\", \"miles\": 388, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(532, 'UPDATE', '2024-12-14 17:10:14', 108, '{\"origin_airport_id\": 54, \"destination_airport_id\": 1, \"base_duration\": \"09:16:00\", \"miles\": 4636, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(533, 'UPDATE', '2024-12-14 17:10:14', 109, '{\"origin_airport_id\": 58, \"destination_airport_id\": 1, \"base_duration\": \"09:04:00\", \"miles\": 4531, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(534, 'UPDATE', '2024-12-14 17:10:14', 110, '{\"origin_airport_id\": 20, \"destination_airport_id\": 1, \"base_duration\": \"01:19:00\", \"miles\": 435, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(535, 'UPDATE', '2024-12-14 17:10:14', 111, '{\"origin_airport_id\": 34, \"destination_airport_id\": 1, \"base_duration\": \"03:37:00\", \"miles\": 1648, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(536, 'UPDATE', '2024-12-14 17:10:14', 112, '{\"origin_airport_id\": 57, \"destination_airport_id\": 1, \"base_duration\": \"16:05:00\", \"miles\": 8232, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(537, 'UPDATE', '2024-12-14 17:10:14', 113, '{\"origin_airport_id\": 3, \"destination_airport_id\": 1, \"base_duration\": \"01:37:00\", \"miles\": 597, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(538, 'UPDATE', '2024-12-14 17:10:14', 114, '{\"origin_airport_id\": 59, \"destination_airport_id\": 1, \"base_duration\": \"08:38:00\", \"miles\": 4297, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(539, 'UPDATE', '2024-12-14 17:10:14', 115, '{\"origin_airport_id\": 61, \"destination_airport_id\": 1, \"base_duration\": \"13:15:00\", \"miles\": 6734, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(540, 'UPDATE', '2024-12-14 17:10:14', 116, '{\"origin_airport_id\": 62, \"destination_airport_id\": 1, \"base_duration\": \"10:37:00\", \"miles\": 5350, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(541, 'UPDATE', '2024-12-14 17:10:14', 117, '{\"origin_airport_id\": 63, \"destination_airport_id\": 1, \"base_duration\": \"18:06:00\", \"miles\": 9301, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(542, 'UPDATE', '2024-12-14 17:10:14', 118, '{\"origin_airport_id\": 64, \"destination_airport_id\": 1, \"base_duration\": \"03:02:00\", \"miles\": 1343, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(543, 'UPDATE', '2024-12-14 17:10:14', 119, '{\"origin_airport_id\": 65, \"destination_airport_id\": 1, \"base_duration\": \"03:31:00\", \"miles\": 1597, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(544, 'UPDATE', '2024-12-14 17:10:14', 120, '{\"origin_airport_id\": 68, \"destination_airport_id\": 1, \"base_duration\": \"03:30:00\", \"miles\": 1102, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(545, 'UPDATE', '2024-12-14 17:10:14', 121, '{\"origin_airport_id\": 70, \"destination_airport_id\": 1, \"base_duration\": \"01:50:00\", \"miles\": 711, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(546, 'UPDATE', '2024-12-14 17:10:14', 122, '{\"origin_airport_id\": 94, \"destination_airport_id\": 1, \"base_duration\": \"03:31:00\", \"miles\": 1600, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(547, 'UPDATE', '2024-12-14 17:10:14', 123, '{\"origin_airport_id\": 71, \"destination_airport_id\": 1, \"base_duration\": \"10:32:00\", \"miles\": 5302, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(548, 'UPDATE', '2024-12-14 17:10:14', 124, '{\"origin_airport_id\": 72, \"destination_airport_id\": 1, \"base_duration\": \"16:39:00\", \"miles\": 8535, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(549, 'UPDATE', '2024-12-14 17:10:14', 125, '{\"origin_airport_id\": 17, \"destination_airport_id\": 1, \"base_duration\": \"01:22:00\", \"miles\": 465, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(550, 'UPDATE', '2024-12-14 17:10:14', 126, '{\"origin_airport_id\": 98, \"destination_airport_id\": 1, \"base_duration\": \"03:33:00\", \"miles\": 1615, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(551, 'UPDATE', '2024-12-14 17:10:14', 127, '{\"origin_airport_id\": 5, \"destination_airport_id\": 1, \"base_duration\": \"01:01:00\", \"miles\": 280, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(552, 'UPDATE', '2024-12-14 17:10:14', 128, '{\"origin_airport_id\": 73, \"destination_airport_id\": 1, \"base_duration\": \"11:15:00\", \"miles\": 5684, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(553, 'UPDATE', '2024-12-14 17:10:14', 129, '{\"origin_airport_id\": 75, \"destination_airport_id\": 1, \"base_duration\": \"10:37:00\", \"miles\": 5348, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(554, 'UPDATE', '2024-12-14 17:10:14', 130, '{\"origin_airport_id\": 89, \"destination_airport_id\": 1, \"base_duration\": \"16:37:00\", \"miles\": 8520, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(555, 'UPDATE', '2024-12-14 17:10:14', 131, '{\"origin_airport_id\": 76, \"destination_airport_id\": 1, \"base_duration\": \"03:18:00\", \"miles\": 1479, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(556, 'UPDATE', '2024-12-14 17:10:14', 132, '{\"origin_airport_id\": 90, \"destination_airport_id\": 1, \"base_duration\": \"03:35:00\", \"miles\": 1634, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(557, 'UPDATE', '2024-12-14 17:10:14', 133, '{\"origin_airport_id\": 6, \"destination_airport_id\": 1, \"base_duration\": \"00:54:00\", \"miles\": 215, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(558, 'UPDATE', '2024-12-14 17:10:14', 134, '{\"origin_airport_id\": 77, \"destination_airport_id\": 1, \"base_duration\": \"03:02:00\", \"miles\": 1339, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(559, 'UPDATE', '2024-12-14 17:10:14', 135, '{\"origin_airport_id\": 79, \"destination_airport_id\": 1, \"base_duration\": \"03:25:00\", \"miles\": 1546, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(560, 'UPDATE', '2024-12-14 17:10:14', 136, '{\"origin_airport_id\": 80, \"destination_airport_id\": 1, \"base_duration\": \"09:27:00\", \"miles\": 4730, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(561, 'UPDATE', '2024-12-14 17:10:14', 137, '{\"origin_airport_id\": 23, \"destination_airport_id\": 1, \"base_duration\": \"00:58:00\", \"miles\": 254, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(562, 'UPDATE', '2024-12-14 17:10:14', 138, '{\"origin_airport_id\": 81, \"destination_airport_id\": 1, \"base_duration\": \"14:28:00\", \"miles\": 7385, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(563, 'UPDATE', '2024-12-14 17:10:14', 139, '{\"origin_airport_id\": 83, \"destination_airport_id\": 1, \"base_duration\": \"14:19:00\", \"miles\": 7305, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(564, 'UPDATE', '2024-12-14 17:10:14', 140, '{\"origin_airport_id\": 14, \"destination_airport_id\": 1, \"base_duration\": \"00:53:00\", \"miles\": 205, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(565, 'UPDATE', '2024-12-14 17:10:14', 141, '{\"origin_airport_id\": 82, \"destination_airport_id\": 1, \"base_duration\": \"13:11:00\", \"miles\": 6699, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(566, 'UPDATE', '2024-12-14 17:10:14', 142, '{\"origin_airport_id\": 85, \"destination_airport_id\": 1, \"base_duration\": \"07:54:00\", \"miles\": 3909, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(567, 'UPDATE', '2024-12-14 17:10:14', 143, '{\"origin_airport_id\": 84, \"destination_airport_id\": 1, \"base_duration\": \"01:51:00\", \"miles\": 717, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(568, 'UPDATE', '2024-12-14 17:10:14', 144, '{\"origin_airport_id\": 86, \"destination_airport_id\": 1, \"base_duration\": \"18:08:00\", \"miles\": 9314, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(569, 'UPDATE', '2024-12-14 17:10:14', 145, '{\"origin_airport_id\": 88, \"destination_airport_id\": 1, \"base_duration\": \"03:44:00\", \"miles\": 1712, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(570, 'UPDATE', '2024-12-14 17:10:14', 146, '{\"origin_airport_id\": 104, \"destination_airport_id\": 1, \"base_duration\": \"04:05:00\", \"miles\": 1893, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(571, 'UPDATE', '2024-12-14 17:10:14', 147, '{\"origin_airport_id\": 47, \"destination_airport_id\": 1, \"base_duration\": \"15:53:00\", \"miles\": 8132, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(572, 'UPDATE', '2024-12-14 17:10:14', 148, '{\"origin_airport_id\": 16, \"destination_airport_id\": 1, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(573, 'UPDATE', '2024-12-14 17:10:14', 149, '{\"origin_airport_id\": 22, \"destination_airport_id\": 1, \"base_duration\": \"01:25:00\", \"miles\": 488, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(574, 'UPDATE', '2024-12-14 17:10:14', 150, '{\"origin_airport_id\": 95, \"destination_airport_id\": 1, \"base_duration\": \"13:12:00\", \"miles\": 6712, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(575, 'UPDATE', '2024-12-14 17:10:14', 151, '{\"origin_airport_id\": 36, \"destination_airport_id\": 1, \"base_duration\": \"03:52:00\", \"miles\": 1781, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(576, 'UPDATE', '2024-12-14 17:10:14', 152, '{\"origin_airport_id\": 92, \"destination_airport_id\": 1, \"base_duration\": \"06:34:00\", \"miles\": 3211, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(577, 'UPDATE', '2024-12-14 17:10:14', 153, '{\"origin_airport_id\": 93, \"destination_airport_id\": 1, \"base_duration\": \"02:35:00\", \"miles\": 1109, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(578, 'UPDATE', '2024-12-14 17:10:14', 154, '{\"origin_airport_id\": 7, \"destination_airport_id\": 1, \"base_duration\": \"01:11:00\", \"miles\": 362, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(579, 'UPDATE', '2024-12-14 17:10:14', 155, '{\"origin_airport_id\": 42, \"destination_airport_id\": 1, \"base_duration\": \"03:21:00\", \"miles\": 1506, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(580, 'UPDATE', '2024-12-14 17:10:14', 156, '{\"origin_airport_id\": 99, \"destination_airport_id\": 1, \"base_duration\": \"02:40:00\", \"miles\": 1146, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(581, 'UPDATE', '2024-12-14 17:10:14', 157, '{\"origin_airport_id\": 96, \"destination_airport_id\": 1, \"base_duration\": \"09:39:00\", \"miles\": 4839, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(582, 'UPDATE', '2024-12-14 17:10:14', 158, '{\"origin_airport_id\": 18, \"destination_airport_id\": 1, \"base_duration\": \"00:56:00\", \"miles\": 232, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(583, 'UPDATE', '2024-12-14 17:10:14', 159, '{\"origin_airport_id\": 97, \"destination_airport_id\": 1, \"base_duration\": \"13:43:00\", \"miles\": 6987, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(584, 'UPDATE', '2024-12-14 17:10:14', 160, '{\"origin_airport_id\": 69, \"destination_airport_id\": 1, \"base_duration\": \"02:23:00\", \"miles\": 1002, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(585, 'UPDATE', '2024-12-14 17:10:14', 161, '{\"origin_airport_id\": 100, \"destination_airport_id\": 1, \"base_duration\": \"03:17:00\", \"miles\": 1474, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(586, 'UPDATE', '2024-12-14 17:10:14', 162, '{\"origin_airport_id\": 101, \"destination_airport_id\": 1, \"base_duration\": \"07:50:00\", \"miles\": 3879, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(587, 'UPDATE', '2024-12-14 17:10:14', 163, '{\"origin_airport_id\": 10, \"destination_airport_id\": 1, \"base_duration\": \"01:09:00\", \"miles\": 352, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(588, 'UPDATE', '2024-12-14 17:10:14', 164, '{\"origin_airport_id\": 103, \"destination_airport_id\": 1, \"base_duration\": \"10:52:00\", \"miles\": 5476, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(589, 'UPDATE', '2024-12-14 17:10:14', 165, '{\"origin_airport_id\": 102, \"destination_airport_id\": 1, \"base_duration\": \"01:52:00\", \"miles\": 727, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(590, 'UPDATE', '2024-12-14 17:10:14', 166, '{\"origin_airport_id\": 15, \"destination_airport_id\": 1, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(591, 'UPDATE', '2024-12-14 17:10:14', 167, '{\"origin_airport_id\": 25, \"destination_airport_id\": 1, \"base_duration\": \"01:44:00\", \"miles\": 656, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(592, 'UPDATE', '2024-12-14 17:10:14', 168, '{\"origin_airport_id\": 107, \"destination_airport_id\": 1, \"base_duration\": \"10:15:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(593, 'UPDATE', '2024-12-14 17:10:14', 169, '{\"origin_airport_id\": 55, \"destination_airport_id\": 1, \"base_duration\": \"15:43:00\", \"miles\": 8043, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(594, 'UPDATE', '2024-12-14 17:10:14', 170, '{\"origin_airport_id\": 60, \"destination_airport_id\": 1, \"base_duration\": \"13:17:00\", \"miles\": 6760, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(595, 'UPDATE', '2024-12-14 17:10:14', 171, '{\"origin_airport_id\": 67, \"destination_airport_id\": 1, \"base_duration\": \"16:16:00\", \"miles\": 8334, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(596, 'UPDATE', '2024-12-14 17:10:14', 172, '{\"origin_airport_id\": 78, \"destination_airport_id\": 1, \"base_duration\": \"13:02:00\", \"miles\": 6620, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(597, 'UPDATE', '2024-12-14 17:10:14', 173, '{\"origin_airport_id\": 87, \"destination_airport_id\": 1, \"base_duration\": \"16:01:00\", \"miles\": 8201, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(598, 'UPDATE', '2024-12-14 17:10:14', 174, '{\"origin_airport_id\": 106, \"destination_airport_id\": 1, \"base_duration\": \"12:55:00\", \"miles\": 6567, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(599, 'UPDATE', '2024-12-14 17:10:14', 175, '{\"origin_airport_id\": 43, \"destination_airport_id\": 1, \"base_duration\": \"13:26:00\", \"miles\": 6836, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(600, 'UPDATE', '2024-12-14 17:10:14', 176, '{\"origin_airport_id\": 44, \"destination_airport_id\": 1, \"base_duration\": \"16:05:00\", \"miles\": 8238, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(601, 'UPDATE', '2024-12-14 17:10:14', 177, '{\"origin_airport_id\": 105, \"destination_airport_id\": 1, \"base_duration\": \"16:03:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(602, 'UPDATE', '2024-12-14 17:10:14', 178, '{\"origin_airport_id\": 11, \"destination_airport_id\": 1, \"base_duration\": \"01:29:00\", \"miles\": 526, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(603, 'UPDATE', '2024-12-14 17:10:14', 179, '{\"origin_airport_id\": 1, \"destination_airport_id\": 88, \"base_duration\": \"03:44:00\", \"miles\": 1712, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(604, 'UPDATE', '2024-12-14 17:10:14', 180, '{\"origin_airport_id\": 1, \"destination_airport_id\": 104, \"base_duration\": \"04:05:00\", \"miles\": 1893, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(605, 'UPDATE', '2024-12-14 17:10:14', 181, '{\"origin_airport_id\": 1, \"destination_airport_id\": 47, \"base_duration\": \"15:54:00\", \"miles\": 8132, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(606, 'UPDATE', '2024-12-14 17:10:14', 182, '{\"origin_airport_id\": 1, \"destination_airport_id\": 16, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(607, 'UPDATE', '2024-12-14 17:10:14', 183, '{\"origin_airport_id\": 1, \"destination_airport_id\": 22, \"base_duration\": \"01:25:00\", \"miles\": 488, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(608, 'UPDATE', '2024-12-14 17:10:14', 184, '{\"origin_airport_id\": 1, \"destination_airport_id\": 95, \"base_duration\": \"13:12:00\", \"miles\": 6712, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(609, 'UPDATE', '2024-12-14 17:10:14', 185, '{\"origin_airport_id\": 1, \"destination_airport_id\": 36, \"base_duration\": \"03:52:00\", \"miles\": 1781, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(610, 'UPDATE', '2024-12-14 17:10:14', 186, '{\"origin_airport_id\": 1, \"destination_airport_id\": 92, \"base_duration\": \"06:34:00\", \"miles\": 3211, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(611, 'UPDATE', '2024-12-14 17:10:14', 187, '{\"origin_airport_id\": 1, \"destination_airport_id\": 93, \"base_duration\": \"02:35:00\", \"miles\": 1109, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(612, 'UPDATE', '2024-12-14 17:10:14', 188, '{\"origin_airport_id\": 1, \"destination_airport_id\": 7, \"base_duration\": \"01:11:00\", \"miles\": 362, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(613, 'UPDATE', '2024-12-14 17:10:14', 189, '{\"origin_airport_id\": 1, \"destination_airport_id\": 42, \"base_duration\": \"03:21:00\", \"miles\": 1506, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(614, 'UPDATE', '2024-12-14 17:10:14', 190, '{\"origin_airport_id\": 1, \"destination_airport_id\": 99, \"base_duration\": \"02:40:00\", \"miles\": 1146, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(615, 'UPDATE', '2024-12-14 17:10:14', 191, '{\"origin_airport_id\": 1, \"destination_airport_id\": 96, \"base_duration\": \"09:39:00\", \"miles\": 4839, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(616, 'UPDATE', '2024-12-14 17:10:14', 192, '{\"origin_airport_id\": 1, \"destination_airport_id\": 18, \"base_duration\": \"00:56:00\", \"miles\": 232, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(617, 'UPDATE', '2024-12-14 17:10:14', 193, '{\"origin_airport_id\": 1, \"destination_airport_id\": 97, \"base_duration\": \"13:43:00\", \"miles\": 6987, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(618, 'UPDATE', '2024-12-14 17:10:14', 194, '{\"origin_airport_id\": 1, \"destination_airport_id\": 69, \"base_duration\": \"02:23:00\", \"miles\": 1002, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(619, 'UPDATE', '2024-12-14 17:10:14', 195, '{\"origin_airport_id\": 1, \"destination_airport_id\": 100, \"base_duration\": \"03:17:00\", \"miles\": 1474, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(620, 'UPDATE', '2024-12-14 17:10:14', 196, '{\"origin_airport_id\": 1, \"destination_airport_id\": 101, \"base_duration\": \"07:50:00\", \"miles\": 3879, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(621, 'UPDATE', '2024-12-14 17:10:14', 197, '{\"origin_airport_id\": 1, \"destination_airport_id\": 10, \"base_duration\": \"01:09:00\", \"miles\": 352, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(622, 'UPDATE', '2024-12-14 17:10:14', 198, '{\"origin_airport_id\": 1, \"destination_airport_id\": 103, \"base_duration\": \"10:52:00\", \"miles\": 5476, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(623, 'UPDATE', '2024-12-14 17:10:14', 199, '{\"origin_airport_id\": 1, \"destination_airport_id\": 102, \"base_duration\": \"01:52:00\", \"miles\": 727, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(624, 'UPDATE', '2024-12-14 17:10:14', 200, '{\"origin_airport_id\": 1, \"destination_airport_id\": 15, \"base_duration\": \"00:55:00\", \"miles\": 221, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(625, 'UPDATE', '2024-12-14 17:10:14', 201, '{\"origin_airport_id\": 1, \"destination_airport_id\": 25, \"base_duration\": \"01:44:00\", \"miles\": 656, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(626, 'UPDATE', '2024-12-14 17:10:14', 202, '{\"origin_airport_id\": 1, \"destination_airport_id\": 107, \"base_duration\": \"10:15:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(627, 'UPDATE', '2024-12-14 17:10:14', 203, '{\"origin_airport_id\": 1, \"destination_airport_id\": 55, \"base_duration\": \"15:43:00\", \"miles\": 8043, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(628, 'UPDATE', '2024-12-14 17:10:14', 204, '{\"origin_airport_id\": 1, \"destination_airport_id\": 60, \"base_duration\": \"13:17:00\", \"miles\": 6760, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(629, 'UPDATE', '2024-12-14 17:10:14', 205, '{\"origin_airport_id\": 1, \"destination_airport_id\": 67, \"base_duration\": \"16:16:00\", \"miles\": 8334, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(630, 'UPDATE', '2024-12-14 17:10:14', 206, '{\"origin_airport_id\": 1, \"destination_airport_id\": 78, \"base_duration\": \"13:02:00\", \"miles\": 6620, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(631, 'UPDATE', '2024-12-14 17:10:14', 207, '{\"origin_airport_id\": 1, \"destination_airport_id\": 87, \"base_duration\": \"16:01:00\", \"miles\": 8201, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(632, 'UPDATE', '2024-12-14 17:10:14', 208, '{\"origin_airport_id\": 1, \"destination_airport_id\": 106, \"base_duration\": \"12:55:00\", \"miles\": 6567, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(633, 'UPDATE', '2024-12-14 17:10:14', 209, '{\"origin_airport_id\": 1, \"destination_airport_id\": 43, \"base_duration\": \"13:26:00\", \"miles\": 8238, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(634, 'UPDATE', '2024-12-14 17:10:14', 210, '{\"origin_airport_id\": 1, \"destination_airport_id\": 44, \"base_duration\": \"16:05:00\", \"miles\": 8238, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(635, 'UPDATE', '2024-12-14 17:10:14', 211, '{\"origin_airport_id\": 1, \"destination_airport_id\": 105, \"base_duration\": \"16:03:00\", \"miles\": 8221, \"timestamp\": \"2024-12-14 17:10:14\"}'),
(636, 'UPDATE', '2024-12-14 17:10:14', 212, '{\"origin_airport_id\": 1, \"destination_airport_id\": 11, \"base_duration\": \"01:29:00\", \"miles\": 526, \"timestamp\": \"2024-12-14 17:10:14\"}');

-- --------------------------------------------------------

--
-- Table structure for table `audit_flight_pricing`
--

CREATE TABLE `audit_flight_pricing` (
  `audit_id` int(11) NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `action_timestamp` datetime DEFAULT current_timestamp(),
  `pricing_id` int(11) DEFAULT NULL,
  `pricing_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`pricing_data`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_layover`
--

CREATE TABLE `audit_layover` (
  `audit_id` int(11) NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `action_timestamp` datetime DEFAULT current_timestamp(),
  `layover_id` int(11) DEFAULT NULL,
  `layover_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`layover_data`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_layover`
--

INSERT INTO `audit_layover` (`audit_id`, `action_type`, `action_timestamp`, `layover_id`, `layover_data`) VALUES
(1, 'UPDATE', '2024-12-13 14:37:29', 45, '{\"origin_airport_id\": 1, \"destination_airport_id\": 63, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 14:37:29\"}'),
(2, 'UPDATE', '2024-12-13 14:37:35', 117, '{\"origin_airport_id\": 63, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 14:37:35\"}'),
(3, 'UPDATE', '2024-12-13 14:38:18', 45, '{\"origin_airport_id\": 1, \"destination_airport_id\": 63, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 14:38:18\"}'),
(4, 'UPDATE', '2024-12-13 14:38:29', 117, '{\"origin_airport_id\": 63, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 14:38:29\"}'),
(5, 'UPDATE', '2024-12-13 15:34:07', 77, '{\"origin_airport_id\": 30, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:34:07\"}'),
(6, 'UPDATE', '2024-12-13 15:34:14', 5, '{\"origin_airport_id\": 1, \"destination_airport_id\": 30, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:34:14\"}'),
(7, 'UPDATE', '2024-12-13 15:35:08', 5, '{\"origin_airport_id\": 1, \"destination_airport_id\": 30, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 15:35:08\"}'),
(8, 'UPDATE', '2024-12-13 15:35:13', 77, '{\"origin_airport_id\": 30, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 15:35:13\"}'),
(9, 'UPDATE', '2024-12-13 15:42:58', 29, '{\"origin_airport_id\": 1, \"destination_airport_id\": 52, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:42:58\"}'),
(10, 'UPDATE', '2024-12-13 15:43:02', 101, '{\"origin_airport_id\": 52, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:43:02\"}'),
(11, 'UPDATE', '2024-12-13 15:43:06', 101, '{\"origin_airport_id\": 52, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:43:06\"}'),
(12, 'UPDATE', '2024-12-13 15:43:14', 29, '{\"origin_airport_id\": 1, \"destination_airport_id\": 52, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:43:14\"}'),
(13, 'UPDATE', '2024-12-13 15:44:22', 124, '{\"origin_airport_id\": 72, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:44:22\"}'),
(14, 'UPDATE', '2024-12-13 15:44:29', 124, '{\"origin_airport_id\": 72, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:44:29\"}'),
(15, 'UPDATE', '2024-12-13 15:44:56', 52, '{\"origin_airport_id\": 1, \"destination_airport_id\": 72, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:44:56\"}'),
(16, 'UPDATE', '2024-12-13 15:45:15', 52, '{\"origin_airport_id\": 1, \"destination_airport_id\": 72, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:45:15\"}'),
(17, 'UPDATE', '2024-12-13 15:46:36', 58, '{\"origin_airport_id\": 1, \"destination_airport_id\": 89, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:46:36\"}'),
(18, 'UPDATE', '2024-12-13 15:46:38', 130, '{\"origin_airport_id\": 89, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:46:38\"}'),
(19, 'UPDATE', '2024-12-13 15:46:43', 58, '{\"origin_airport_id\": 1, \"destination_airport_id\": 89, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:46:43\"}'),
(20, 'UPDATE', '2024-12-13 15:46:49', 130, '{\"origin_airport_id\": 89, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:46:49\"}'),
(21, 'UPDATE', '2024-12-13 15:47:40', 14, '{\"origin_airport_id\": 1, \"destination_airport_id\": 40, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:47:40\"}'),
(22, 'UPDATE', '2024-12-13 15:47:44', 86, '{\"origin_airport_id\": 40, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:47:44\"}'),
(23, 'UPDATE', '2024-12-13 15:47:50', 14, '{\"origin_airport_id\": 1, \"destination_airport_id\": 40, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:47:50\"}'),
(24, 'UPDATE', '2024-12-13 15:47:57', 86, '{\"origin_airport_id\": 40, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:47:57\"}'),
(25, 'UPDATE', '2024-12-13 15:49:51', 78, '{\"origin_airport_id\": 32, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:49:51\"}'),
(26, 'UPDATE', '2024-12-13 15:49:54', 32, '{\"origin_airport_id\": 1, \"destination_airport_id\": 21, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:49:54\"}'),
(27, 'UPDATE', '2024-12-13 15:49:59', 32, '{\"origin_airport_id\": 1, \"destination_airport_id\": 21, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:49:59\"}'),
(28, 'UPDATE', '2024-12-13 15:50:07', 78, '{\"origin_airport_id\": 32, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 15:50:07\"}'),
(29, 'UPDATE', '2024-12-13 15:50:54', 49, '{\"origin_airport_id\": 1, \"destination_airport_id\": 70, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:50:54\"}'),
(30, 'UPDATE', '2024-12-13 15:50:58', 31, '{\"origin_airport_id\": 1, \"destination_airport_id\": 49, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:50:58\"}'),
(31, 'UPDATE', '2024-12-13 15:51:53', 31, '{\"origin_airport_id\": 1, \"destination_airport_id\": 49, \"layover_status\": 1, \"layover_airport_id\": 89, \"timestamp\": \"2024-12-13 15:51:53\"}'),
(32, 'UPDATE', '2024-12-13 15:52:02', 103, '{\"origin_airport_id\": 49, \"destination_airport_id\": 1, \"layover_status\": 0, \"layover_airport_id\": 89, \"timestamp\": \"2024-12-13 15:52:02\"}'),
(33, 'UPDATE', '2024-12-13 15:52:44', 26, '{\"origin_airport_id\": 1, \"destination_airport_id\": 51, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:52:44\"}'),
(34, 'UPDATE', '2024-12-13 15:53:23', 26, '{\"origin_airport_id\": 1, \"destination_airport_id\": 51, \"layover_status\": 1, \"layover_airport_id\": 89, \"timestamp\": \"2024-12-13 15:53:23\"}'),
(35, 'UPDATE', '2024-12-13 15:53:37', 98, '{\"origin_airport_id\": 51, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 15:53:37\"}'),
(36, 'UPDATE', '2024-12-13 15:53:41', 98, '{\"origin_airport_id\": 51, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 89, \"timestamp\": \"2024-12-13 15:53:41\"}'),
(37, 'UPDATE', '2024-12-13 16:09:47', 171, '{\"origin_airport_id\": 67, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:09:47\"}'),
(38, 'UPDATE', '2024-12-13 16:09:51', 205, '{\"origin_airport_id\": 1, \"destination_airport_id\": 67, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:09:51\"}'),
(39, 'UPDATE', '2024-12-13 16:11:48', 171, '{\"origin_airport_id\": 67, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 105, \"timestamp\": \"2024-12-13 16:11:48\"}'),
(40, 'UPDATE', '2024-12-13 16:11:52', 205, '{\"origin_airport_id\": 1, \"destination_airport_id\": 67, \"layover_status\": 1, \"layover_airport_id\": 105, \"timestamp\": \"2024-12-13 16:11:52\"}'),
(41, 'UPDATE', '2024-12-13 16:12:07', 34, '{\"origin_airport_id\": 1, \"destination_airport_id\": 53, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:12:07\"}'),
(42, 'UPDATE', '2024-12-13 16:12:10', 106, '{\"origin_airport_id\": 53, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:12:10\"}'),
(43, 'UPDATE', '2024-12-13 16:15:08', 34, '{\"origin_airport_id\": 1, \"destination_airport_id\": 53, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:15:08\"}'),
(44, 'UPDATE', '2024-12-13 16:15:14', 106, '{\"origin_airport_id\": 53, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:15:14\"}'),
(45, 'UPDATE', '2024-12-13 16:16:09', 40, '{\"origin_airport_id\": 1, \"destination_airport_id\": 57, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:16:09\"}'),
(46, 'UPDATE', '2024-12-13 16:16:16', 40, '{\"origin_airport_id\": 1, \"destination_airport_id\": 57, \"layover_status\": 1, \"layover_airport_id\": 97, \"timestamp\": \"2024-12-13 16:16:16\"}'),
(47, 'UPDATE', '2024-12-13 16:16:36', 112, '{\"origin_airport_id\": 57, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:16:36\"}'),
(48, 'UPDATE', '2024-12-13 16:16:44', 112, '{\"origin_airport_id\": 57, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 97, \"timestamp\": \"2024-12-13 16:16:44\"}'),
(49, 'UPDATE', '2024-12-13 16:17:05', 44, '{\"origin_airport_id\": 1, \"destination_airport_id\": 62, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:17:05\"}'),
(50, 'UPDATE', '2024-12-13 16:17:08', 176, '{\"origin_airport_id\": 44, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:17:08\"}'),
(51, 'UPDATE', '2024-12-13 16:17:20', 44, '{\"origin_airport_id\": 1, \"destination_airport_id\": 62, \"layover_status\": 0, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:17:20\"}'),
(52, 'UPDATE', '2024-12-13 16:17:25', 210, '{\"origin_airport_id\": 1, \"destination_airport_id\": 44, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:17:25\"}'),
(53, 'UPDATE', '2024-12-13 16:19:25', 176, '{\"origin_airport_id\": 44, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 105, \"timestamp\": \"2024-12-13 16:19:25\"}'),
(54, 'UPDATE', '2024-12-13 16:19:28', 210, '{\"origin_airport_id\": 1, \"destination_airport_id\": 44, \"layover_status\": 1, \"layover_airport_id\": 105, \"timestamp\": \"2024-12-13 16:19:28\"}'),
(55, 'UPDATE', '2024-12-13 16:20:04', 211, '{\"origin_airport_id\": 1, \"destination_airport_id\": 105, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:20:04\"}'),
(56, 'UPDATE', '2024-12-13 16:20:09', 177, '{\"origin_airport_id\": 105, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:20:09\"}'),
(57, 'UPDATE', '2024-12-13 16:20:12', 177, '{\"origin_airport_id\": 105, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 16:20:12\"}'),
(58, 'UPDATE', '2024-12-13 16:20:16', 211, '{\"origin_airport_id\": 1, \"destination_airport_id\": 105, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 16:20:16\"}'),
(59, 'UPDATE', '2024-12-13 16:20:33', 173, '{\"origin_airport_id\": 87, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:20:33\"}'),
(60, 'UPDATE', '2024-12-13 16:20:36', 207, '{\"origin_airport_id\": 1, \"destination_airport_id\": 87, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:20:36\"}'),
(61, 'UPDATE', '2024-12-13 16:22:06', 173, '{\"origin_airport_id\": 87, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 16:22:06\"}'),
(62, 'UPDATE', '2024-12-13 16:22:09', 207, '{\"origin_airport_id\": 1, \"destination_airport_id\": 87, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 16:22:09\"}'),
(63, 'UPDATE', '2024-12-13 16:22:55', 181, '{\"origin_airport_id\": 1, \"destination_airport_id\": 47, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:22:55\"}'),
(64, 'UPDATE', '2024-12-13 16:22:57', 147, '{\"origin_airport_id\": 47, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:22:57\"}'),
(65, 'UPDATE', '2024-12-13 16:23:01', 147, '{\"origin_airport_id\": 47, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:23:01\"}'),
(66, 'UPDATE', '2024-12-13 16:23:06', 181, '{\"origin_airport_id\": 1, \"destination_airport_id\": 47, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:23:06\"}'),
(67, 'UPDATE', '2024-12-13 16:23:19', 203, '{\"origin_airport_id\": 1, \"destination_airport_id\": 55, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:23:19\"}'),
(68, 'UPDATE', '2024-12-13 16:23:21', 169, '{\"origin_airport_id\": 55, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:23:21\"}'),
(69, 'UPDATE', '2024-12-13 16:24:08', 169, '{\"origin_airport_id\": 55, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 105, \"timestamp\": \"2024-12-13 16:24:08\"}'),
(70, 'UPDATE', '2024-12-13 16:24:11', 203, '{\"origin_airport_id\": 1, \"destination_airport_id\": 55, \"layover_status\": 1, \"layover_airport_id\": 105, \"timestamp\": \"2024-12-13 16:24:11\"}'),
(71, 'UPDATE', '2024-12-13 16:24:27', 33, '{\"origin_airport_id\": 1, \"destination_airport_id\": 56, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:24:27\"}'),
(72, 'UPDATE', '2024-12-13 16:24:30', 105, '{\"origin_airport_id\": 56, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:24:30\"}'),
(73, 'UPDATE', '2024-12-13 16:25:11', 33, '{\"origin_airport_id\": 1, \"destination_airport_id\": 56, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:25:11\"}'),
(74, 'UPDATE', '2024-12-13 16:25:19', 105, '{\"origin_airport_id\": 56, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:25:19\"}'),
(75, 'UPDATE', '2024-12-13 16:25:55', 66, '{\"origin_airport_id\": 1, \"destination_airport_id\": 81, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:25:55\"}'),
(76, 'UPDATE', '2024-12-13 16:25:59', 66, '{\"origin_airport_id\": 1, \"destination_airport_id\": 81, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:25:59\"}'),
(77, 'UPDATE', '2024-12-13 16:26:08', 138, '{\"origin_airport_id\": 81, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:26:08\"}'),
(78, 'UPDATE', '2024-12-13 16:26:11', 138, '{\"origin_airport_id\": 81, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:26:11\"}'),
(79, 'UPDATE', '2024-12-13 16:26:39', 67, '{\"origin_airport_id\": 1, \"destination_airport_id\": 83, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:26:39\"}'),
(80, 'UPDATE', '2024-12-13 16:27:22', 67, '{\"origin_airport_id\": 1, \"destination_airport_id\": 83, \"layover_status\": 0, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:27:22\"}'),
(81, 'UPDATE', '2024-12-13 16:27:42', 13, '{\"origin_airport_id\": 1, \"destination_airport_id\": 39, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:27:42\"}'),
(82, 'UPDATE', '2024-12-13 16:27:44', 85, '{\"origin_airport_id\": 39, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:27:44\"}'),
(83, 'UPDATE', '2024-12-13 16:28:20', 85, '{\"origin_airport_id\": 39, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:28:20\"}'),
(84, 'UPDATE', '2024-12-13 16:28:23', 13, '{\"origin_airport_id\": 1, \"destination_airport_id\": 39, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:28:23\"}'),
(85, 'UPDATE', '2024-12-13 16:30:13', 209, '{\"origin_airport_id\": 1, \"destination_airport_id\": 43, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:30:13\"}'),
(86, 'UPDATE', '2024-12-13 16:30:16', 175, '{\"origin_airport_id\": 43, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:30:16\"}'),
(87, 'UPDATE', '2024-12-13 16:30:22', 175, '{\"origin_airport_id\": 43, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 16:30:22\"}'),
(88, 'UPDATE', '2024-12-13 16:30:26', 209, '{\"origin_airport_id\": 1, \"destination_airport_id\": 43, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 16:30:26\"}'),
(89, 'UPDATE', '2024-12-13 16:31:08', 204, '{\"origin_airport_id\": 1, \"destination_airport_id\": 60, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:31:08\"}'),
(90, 'UPDATE', '2024-12-13 16:31:11', 170, '{\"origin_airport_id\": 60, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:31:11\"}'),
(91, 'UPDATE', '2024-12-13 16:31:15', 170, '{\"origin_airport_id\": 60, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 16:31:15\"}'),
(92, 'UPDATE', '2024-12-13 16:31:22', 204, '{\"origin_airport_id\": 1, \"destination_airport_id\": 60, \"layover_status\": 1, \"layover_airport_id\": 106, \"timestamp\": \"2024-12-13 16:31:22\"}'),
(93, 'UPDATE', '2024-12-13 16:33:40', 150, '{\"origin_airport_id\": 95, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:33:40\"}'),
(94, 'UPDATE', '2024-12-13 16:33:43', 184, '{\"origin_airport_id\": 1, \"destination_airport_id\": 95, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:33:43\"}'),
(95, 'UPDATE', '2024-12-13 16:33:47', 150, '{\"origin_airport_id\": 95, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:33:47\"}'),
(96, 'UPDATE', '2024-12-13 16:33:50', 184, '{\"origin_airport_id\": 1, \"destination_airport_id\": 95, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 16:33:50\"}'),
(97, 'UPDATE', '2024-12-13 16:37:12', 141, '{\"origin_airport_id\": 82, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:37:12\"}'),
(98, 'UPDATE', '2024-12-13 16:38:02', 69, '{\"origin_airport_id\": 1, \"destination_airport_id\": 82, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:38:02\"}'),
(99, 'UPDATE', '2024-12-13 16:38:06', 69, '{\"origin_airport_id\": 1, \"destination_airport_id\": 82, \"layover_status\": 1, \"layover_airport_id\": 100, \"timestamp\": \"2024-12-13 16:38:06\"}'),
(100, 'UPDATE', '2024-12-13 16:38:14', 141, '{\"origin_airport_id\": 82, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 100, \"timestamp\": \"2024-12-13 16:38:14\"}'),
(101, 'UPDATE', '2024-12-13 16:38:22', 20, '{\"origin_airport_id\": 1, \"destination_airport_id\": 91, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:38:22\"}'),
(102, 'UPDATE', '2024-12-13 16:38:25', 20, '{\"origin_airport_id\": 1, \"destination_airport_id\": 91, \"layover_status\": 1, \"layover_airport_id\": 100, \"timestamp\": \"2024-12-13 16:38:25\"}'),
(103, 'UPDATE', '2024-12-13 16:38:29', 92, '{\"origin_airport_id\": 91, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:38:29\"}'),
(104, 'UPDATE', '2024-12-13 16:38:32', 92, '{\"origin_airport_id\": 91, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 100, \"timestamp\": \"2024-12-13 16:38:32\"}'),
(105, 'UPDATE', '2024-12-13 16:39:55', 172, '{\"origin_airport_id\": 78, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:39:55\"}'),
(106, 'UPDATE', '2024-12-13 16:39:58', 206, '{\"origin_airport_id\": 1, \"destination_airport_id\": 78, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:39:58\"}'),
(107, 'UPDATE', '2024-12-13 16:40:03', 172, '{\"origin_airport_id\": 78, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 43, \"timestamp\": \"2024-12-13 16:40:03\"}'),
(108, 'UPDATE', '2024-12-13 16:40:06', 206, '{\"origin_airport_id\": 1, \"destination_airport_id\": 78, \"layover_status\": 1, \"layover_airport_id\": 43, \"timestamp\": \"2024-12-13 16:40:06\"}'),
(109, 'UPDATE', '2024-12-13 16:43:24', 56, '{\"origin_airport_id\": 1, \"destination_airport_id\": 73, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:43:24\"}'),
(110, 'UPDATE', '2024-12-13 16:43:30', 128, '{\"origin_airport_id\": 73, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:43:30\"}'),
(111, 'UPDATE', '2024-12-13 16:43:49', 56, '{\"origin_airport_id\": 1, \"destination_airport_id\": 73, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 16:43:49\"}'),
(112, 'UPDATE', '2024-12-13 16:44:11', 128, '{\"origin_airport_id\": 73, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 16:44:11\"}'),
(113, 'UPDATE', '2024-12-13 16:45:38', 164, '{\"origin_airport_id\": 103, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:45:38\"}'),
(114, 'UPDATE', '2024-12-13 16:45:44', 198, '{\"origin_airport_id\": 1, \"destination_airport_id\": 103, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 16:45:44\"}'),
(115, 'UPDATE', '2024-12-13 16:45:56', 103, '{\"origin_airport_id\": 49, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 89, \"timestamp\": \"2024-12-13 16:45:56\"}'),
(116, 'UPDATE', '2024-12-13 16:46:19', 164, '{\"origin_airport_id\": 103, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 16:46:19\"}'),
(117, 'UPDATE', '2024-12-13 16:46:23', 198, '{\"origin_airport_id\": 1, \"destination_airport_id\": 103, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 16:46:23\"}'),
(118, 'UPDATE', '2024-12-13 17:37:36', 57, '{\"origin_airport_id\": 1, \"destination_airport_id\": 75, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:37:36\"}'),
(119, 'UPDATE', '2024-12-13 17:37:40', 129, '{\"origin_airport_id\": 75, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:37:40\"}'),
(120, 'UPDATE', '2024-12-13 17:37:47', 129, '{\"origin_airport_id\": 75, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:37:47\"}'),
(121, 'UPDATE', '2024-12-13 17:37:52', 57, '{\"origin_airport_id\": 1, \"destination_airport_id\": 75, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:37:52\"}'),
(122, 'UPDATE', '2024-12-13 17:38:37', 2, '{\"origin_airport_id\": 1, \"destination_airport_id\": 29, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:38:37\"}'),
(123, 'UPDATE', '2024-12-13 17:38:40', 74, '{\"origin_airport_id\": 29, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:38:40\"}'),
(124, 'UPDATE', '2024-12-13 17:38:43', 2, '{\"origin_airport_id\": 1, \"destination_airport_id\": 29, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 17:38:43\"}'),
(125, 'UPDATE', '2024-12-13 17:38:47', 74, '{\"origin_airport_id\": 29, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 17:38:47\"}'),
(126, 'UPDATE', '2024-12-13 17:39:37', 51, '{\"origin_airport_id\": 1, \"destination_airport_id\": 71, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:39:37\"}'),
(127, 'UPDATE', '2024-12-13 17:39:41', 51, '{\"origin_airport_id\": 1, \"destination_airport_id\": 71, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 17:39:41\"}'),
(128, 'UPDATE', '2024-12-13 17:39:52', 123, '{\"origin_airport_id\": 71, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:39:52\"}'),
(129, 'UPDATE', '2024-12-13 17:39:58', 123, '{\"origin_airport_id\": 71, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 83, \"timestamp\": \"2024-12-13 17:39:58\"}'),
(130, 'UPDATE', '2024-12-13 17:40:46', 168, '{\"origin_airport_id\": 107, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:40:46\"}'),
(131, 'UPDATE', '2024-12-13 17:40:50', 202, '{\"origin_airport_id\": 1, \"destination_airport_id\": 107, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:40:50\"}'),
(132, 'UPDATE', '2024-12-13 17:40:57', 168, '{\"origin_airport_id\": 107, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 41, \"timestamp\": \"2024-12-13 17:40:57\"}'),
(133, 'UPDATE', '2024-12-13 17:41:01', 202, '{\"origin_airport_id\": 1, \"destination_airport_id\": 107, \"layover_status\": 1, \"layover_airport_id\": 41, \"timestamp\": \"2024-12-13 17:41:01\"}'),
(134, 'UPDATE', '2024-12-13 17:41:59', 1, '{\"origin_airport_id\": 1, \"destination_airport_id\": 31, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:41:59\"}'),
(135, 'UPDATE', '2024-12-13 17:42:02', 1, '{\"origin_airport_id\": 1, \"destination_airport_id\": 31, \"layover_status\": 1, \"layover_airport_id\": 101, \"timestamp\": \"2024-12-13 17:42:02\"}'),
(136, 'UPDATE', '2024-12-13 17:42:06', 73, '{\"origin_airport_id\": 31, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:42:06\"}'),
(137, 'UPDATE', '2024-12-13 17:42:11', 73, '{\"origin_airport_id\": 31, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 101, \"timestamp\": \"2024-12-13 17:42:11\"}'),
(138, 'UPDATE', '2024-12-13 17:43:40', 64, '{\"origin_airport_id\": 1, \"destination_airport_id\": 80, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:43:40\"}'),
(139, 'UPDATE', '2024-12-13 17:43:44', 136, '{\"origin_airport_id\": 80, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:43:44\"}'),
(140, 'UPDATE', '2024-12-13 17:43:48', 64, '{\"origin_airport_id\": 1, \"destination_airport_id\": 80, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:43:48\"}'),
(141, 'UPDATE', '2024-12-13 17:43:52', 136, '{\"origin_airport_id\": 80, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:43:52\"}'),
(142, 'UPDATE', '2024-12-13 17:44:39', 36, '{\"origin_airport_id\": 1, \"destination_airport_id\": 54, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:44:39\"}'),
(143, 'UPDATE', '2024-12-13 17:44:41', 108, '{\"origin_airport_id\": 54, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:44:41\"}'),
(144, 'UPDATE', '2024-12-13 17:44:46', 36, '{\"origin_airport_id\": 1, \"destination_airport_id\": 54, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:44:46\"}'),
(145, 'UPDATE', '2024-12-13 17:44:50', 108, '{\"origin_airport_id\": 54, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:44:50\"}'),
(146, 'UPDATE', '2024-12-13 17:45:38', 8, '{\"origin_airport_id\": 1, \"destination_airport_id\": 33, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:45:38\"}'),
(147, 'UPDATE', '2024-12-13 17:45:42', 80, '{\"origin_airport_id\": 33, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:45:42\"}'),
(148, 'UPDATE', '2024-12-13 17:45:49', 8, '{\"origin_airport_id\": 1, \"destination_airport_id\": 33, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:45:49\"}'),
(149, 'UPDATE', '2024-12-13 17:45:54', 80, '{\"origin_airport_id\": 33, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:45:54\"}'),
(150, 'UPDATE', '2024-12-13 17:46:38', 37, '{\"origin_airport_id\": 1, \"destination_airport_id\": 58, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:46:38\"}'),
(151, 'UPDATE', '2024-12-13 17:46:41', 109, '{\"origin_airport_id\": 58, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:46:41\"}'),
(152, 'UPDATE', '2024-12-13 17:46:47', 37, '{\"origin_airport_id\": 1, \"destination_airport_id\": 58, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:46:47\"}'),
(153, 'UPDATE', '2024-12-13 17:46:55', 109, '{\"origin_airport_id\": 58, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 59, \"timestamp\": \"2024-12-13 17:46:55\"}'),
(154, 'UPDATE', '2024-12-13 17:47:34', 70, '{\"origin_airport_id\": 1, \"destination_airport_id\": 85, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:47:34\"}'),
(155, 'UPDATE', '2024-12-13 17:47:36', 142, '{\"origin_airport_id\": 85, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:47:36\"}'),
(156, 'UPDATE', '2024-12-13 17:47:44', 70, '{\"origin_airport_id\": 1, \"destination_airport_id\": 85, \"layover_status\": 1, \"layover_airport_id\": 101, \"timestamp\": \"2024-12-13 17:47:44\"}'),
(157, 'UPDATE', '2024-12-13 17:47:48', 142, '{\"origin_airport_id\": 85, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 101, \"timestamp\": \"2024-12-13 17:47:48\"}'),
(158, 'UPDATE', '2024-12-13 17:48:40', 12, '{\"origin_airport_id\": 1, \"destination_airport_id\": 41, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:48:40\"}'),
(159, 'UPDATE', '2024-12-13 17:48:44', 12, '{\"origin_airport_id\": 1, \"destination_airport_id\": 41, \"layover_status\": 1, \"layover_airport_id\": 101, \"timestamp\": \"2024-12-13 17:48:44\"}'),
(160, 'UPDATE', '2024-12-13 17:48:48', 84, '{\"origin_airport_id\": 41, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:48:48\"}'),
(161, 'UPDATE', '2024-12-13 17:48:53', 84, '{\"origin_airport_id\": 41, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 101, \"timestamp\": \"2024-12-13 17:48:53\"}'),
(162, 'UPDATE', '2024-12-13 17:49:43', 152, '{\"origin_airport_id\": 92, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:49:43\"}'),
(163, 'UPDATE', '2024-12-13 17:49:45', 186, '{\"origin_airport_id\": 1, \"destination_airport_id\": 92, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:49:45\"}'),
(164, 'UPDATE', '2024-12-13 17:49:48', 152, '{\"origin_airport_id\": 92, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 101, \"timestamp\": \"2024-12-13 17:49:48\"}'),
(165, 'UPDATE', '2024-12-13 17:49:55', 186, '{\"origin_airport_id\": 1, \"destination_airport_id\": 92, \"layover_status\": 1, \"layover_airport_id\": 101, \"timestamp\": \"2024-12-13 17:49:55\"}'),
(166, 'UPDATE', '2024-12-13 17:50:48', 7, '{\"origin_airport_id\": 1, \"destination_airport_id\": 26, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:50:48\"}'),
(167, 'UPDATE', '2024-12-13 17:50:54', 79, '{\"origin_airport_id\": 26, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:50:54\"}'),
(168, 'UPDATE', '2024-12-13 17:50:59', 7, '{\"origin_airport_id\": 1, \"destination_airport_id\": 26, \"layover_status\": 1, \"layover_airport_id\": 104, \"timestamp\": \"2024-12-13 17:50:59\"}'),
(169, 'UPDATE', '2024-12-13 17:51:02', 79, '{\"origin_airport_id\": 26, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 104, \"timestamp\": \"2024-12-13 17:51:02\"}'),
(170, 'UPDATE', '2024-12-13 17:52:49', 151, '{\"origin_airport_id\": 36, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:52:49\"}'),
(171, 'UPDATE', '2024-12-13 17:52:52', 185, '{\"origin_airport_id\": 1, \"destination_airport_id\": 36, \"layover_status\": 1, \"layover_airport_id\": 1, \"timestamp\": \"2024-12-13 17:52:52\"}'),
(172, 'UPDATE', '2024-12-13 17:52:56', 151, '{\"origin_airport_id\": 36, \"destination_airport_id\": 1, \"layover_status\": 1, \"layover_airport_id\": 70, \"timestamp\": \"2024-12-13 17:52:56\"}'),
(173, 'UPDATE', '2024-12-13 17:53:00', 185, '{\"origin_airport_id\": 1, \"destination_airport_id\": 36, \"layover_status\": 1, \"layover_airport_id\": 70, \"timestamp\": \"2024-12-13 17:53:00\"}');

-- --------------------------------------------------------

--
-- Table structure for table `audit_passenger_info`
--

CREATE TABLE `audit_passenger_info` (
  `audit_id` int(11) NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `action_timestamp` datetime DEFAULT current_timestamp(),
  `passenger_id` int(11) DEFAULT NULL,
  `passenger_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`passenger_data`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_passenger_info`
--

INSERT INTO `audit_passenger_info` (`audit_id`, `action_type`, `action_timestamp`, `passenger_id`, `passenger_data`) VALUES
(1, 'INSERT', '2024-12-16 09:32:28', 1, '{\"first_name\": \"\", \"last_name\": \"\", \"email\": \"\", \"phone_number\": null, \"passport_number\": \"\", \"nationality\": \"\", \"passport_expiry_date\": \"0000-00-00\", \"timestamp\": \"0000-00-00 00:00:00\"}'),
(2, 'DELETE', '2024-12-16 09:34:03', 1, '{\"first_name\": \"\", \"last_name\": \"\", \"email\": \"\", \"phone_number\": null, \"passport_number\": \"\", \"nationality\": \"\", \"passport_expiry_date\": \"0000-00-00\", \"timestamp\": \"0000-00-00 00:00:00\"}'),
(3, 'INSERT', '2024-12-16 09:36:59', 4, '{\"first_name\": \"\", \"last_name\": \"\", \"email\": \"\", \"phone_number\": null, \"passport_number\": \"\", \"nationality\": \"\", \"passport_expiry_date\": \"0000-00-00\", \"timestamp\": \"0000-00-00 00:00:00\"}'),
(4, 'DELETE', '2024-12-16 10:08:56', 4, '{\"first_name\": \"\", \"last_name\": \"\", \"email\": \"\", \"phone_number\": null, \"passport_number\": \"\", \"nationality\": \"\", \"passport_expiry_date\": \"0000-00-00\", \"timestamp\": \"0000-00-00 00:00:00\"}'),
(5, 'INSERT', '2024-12-16 10:09:19', 17, '{\"first_name\": \"\", \"last_name\": \"\", \"email\": \"\", \"phone_number\": null, \"passport_number\": \"\", \"nationality\": \"\", \"passport_expiry_date\": \"0000-00-00\", \"timestamp\": \"0000-00-00 00:00:00\"}'),
(6, 'DELETE', '2024-12-16 10:09:51', 17, '{\"first_name\": \"\", \"last_name\": \"\", \"email\": \"\", \"phone_number\": null, \"passport_number\": \"\", \"nationality\": \"\", \"passport_expiry_date\": \"0000-00-00\", \"timestamp\": \"0000-00-00 00:00:00\"}'),
(7, 'INSERT', '2024-12-16 10:13:12', 19, '{\"first_name\": \"juju\", \"last_name\": \"nunu\", \"email\": \"aaaa@gmail.com\", \"phone_number\": \"909090909\", \"passport_number\": \"2312sdsad\", \"nationality\": \"Filipino\", \"passport_expiry_date\": \"2024-12-12\", \"timestamp\": \"2024-12-16 10:13:12\"}'),
(8, 'INSERT', '2024-12-16 10:19:07', 22, '{\"first_name\": \"as\", \"last_name\": \"asd\", \"email\": \"aaaa@gmail.com\", \"phone_number\": \"909090909\", \"passport_number\": \"asdasdsdad\", \"nationality\": \"Filipino\", \"passport_expiry_date\": \"2024-12-11\", \"timestamp\": \"2024-12-16 10:19:07\"}'),
(9, 'DELETE', '2024-12-23 21:20:11', 19, '{\"first_name\": \"juju\", \"last_name\": \"nunu\", \"email\": \"aaaa@gmail.com\", \"phone_number\": \"909090909\", \"passport_number\": \"2312sdsad\", \"nationality\": \"Filipino\", \"passport_expiry_date\": \"2024-12-12\", \"timestamp\": \"2024-12-16 10:13:12\"}'),
(10, 'DELETE', '2024-12-23 21:20:11', 22, '{\"first_name\": \"as\", \"last_name\": \"asd\", \"email\": \"aaaa@gmail.com\", \"phone_number\": \"909090909\", \"passport_number\": \"asdasdsdad\", \"nationality\": \"Filipino\", \"passport_expiry_date\": \"2024-12-11\", \"timestamp\": \"2024-12-16 10:19:07\"}'),
(11, 'INSERT', '2024-12-23 21:21:41', 1, '{\"first_name\": \"julian\", \"last_name\": \"naceda\", \"email\": \"juliannaceda@gmail.com\", \"phone_number\": \"09723123732\", \"passport_number\": \"R221G2\", \"nationality\": \"Filipno\", \"passport_expiry_date\": \"2029-04-18\", \"timestamp\": \"2024-12-23 21:21:41\"}');

-- --------------------------------------------------------

--
-- Table structure for table `backup_log`
--

CREATE TABLE `backup_log` (
  `backup_id` int(11) NOT NULL,
  `table_name` varchar(255) DEFAULT NULL,
  `last_backup_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `booking`
--

CREATE TABLE `booking` (
  `booking_id` int(11) NOT NULL,
  `passenger_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `booking`
--

INSERT INTO `booking` (`booking_id`, `passenger_id`, `flight_id`, `timestamp`) VALUES
(1, 1, 1, '2024-12-23 13:22:09');

--
-- Triggers `booking`
--
DELIMITER $$
CREATE TRIGGER `after_booking_delete` AFTER DELETE ON `booking` FOR EACH ROW BEGIN
    INSERT INTO audit_booking (action_type, booking_id, booking_data) 
    VALUES ('DELETE', OLD.booking_id, JSON_OBJECT('passenger_id', OLD.passenger_id, 'flight_id', OLD.flight_id, 'timestamp', OLD.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_booking_insert` AFTER INSERT ON `booking` FOR EACH ROW BEGIN
    INSERT INTO audit_booking (action_type, booking_id, booking_data) 
    VALUES ('INSERT', NEW.booking_id, JSON_OBJECT('passenger_id', NEW.passenger_id, 'flight_id', NEW.flight_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_booking_update` AFTER UPDATE ON `booking` FOR EACH ROW BEGIN
    INSERT INTO audit_booking (action_type, booking_id, booking_data) 
    VALUES ('UPDATE', NEW.booking_id, JSON_OBJECT('passenger_id', NEW.passenger_id, 'flight_id', NEW.flight_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `class`
--

CREATE TABLE `class` (
  `class_id` int(11) NOT NULL,
  `class_name` enum('Economy','Business') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `class`
--

INSERT INTO `class` (`class_id`, `class_name`) VALUES
(1, 'Economy'),
(2, 'Business');

-- --------------------------------------------------------

--
-- Stand-in structure for view `domestic_airports_view`
-- (See below for the actual view)
--
CREATE TABLE `domestic_airports_view` (
`airport_id` int(11)
,`airport_name` varchar(255)
,`airport_code` varchar(10)
);

-- --------------------------------------------------------

--
-- Table structure for table `flights`
--

CREATE TABLE `flights` (
  `flight_id` int(11) NOT NULL,
  `flight_number` varchar(50) NOT NULL,
  `gate_number` varchar(10) DEFAULT NULL,
  `flight_date` date NOT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `origin_airport_id` int(11) NOT NULL,
  `destination_airport_id` int(11) NOT NULL,
  `departure_time` time NOT NULL,
  `arrival_time` time NOT NULL,
  `layover_id` int(11) DEFAULT NULL,
  `class_id` int(11) NOT NULL,
  `seat_id` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flights`
--

INSERT INTO `flights` (`flight_id`, `flight_number`, `gate_number`, `flight_date`, `reference_number`, `origin_airport_id`, `destination_airport_id`, `departure_time`, `arrival_time`, `layover_id`, `class_id`, `seat_id`, `price`, `aircraft_id`, `type_id`, `timestamp`) VALUES
(1, 'SB9001', '23', '2024-12-17', '23231197382', 1, 31, '04:00:00', '13:55:00', 101, 1, 5, 59735.75, 45, 2, '2024-12-23 13:34:41');

--
-- Triggers `flights`
--
DELIMITER $$
CREATE TRIGGER `after_flights_delete` AFTER DELETE ON `flights` FOR EACH ROW BEGIN
    INSERT INTO audit_flights (action_type, flight_id, flight_data) 
    VALUES ('DELETE', OLD.flight_id, JSON_OBJECT('flight_number', OLD.flight_number, 'gate_number', OLD.gate_number, 'flight_date', OLD.flight_date, 'reference_number', OLD.reference_number, 'origin_airport_id', OLD.origin_airport_id, 'destination_airport_id', OLD.destination_airport_id, 'departure_time', OLD.departure_time, 'arrival_time', OLD.arrival_time, 'layover_id', OLD.layover_id, 'class_id', OLD.class_id, 'price', OLD.price, 'aircraft_id', OLD.aircraft_id, 'type_id', OLD.type_id, 'timestamp', OLD.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_flights_insert` AFTER INSERT ON `flights` FOR EACH ROW BEGIN
    INSERT INTO audit_flights (action_type, flight_id, flight_data) 
    VALUES ('INSERT', NEW.flight_id, JSON_OBJECT('flight_number', NEW.flight_number, 'gate_number', NEW.gate_number, 'flight_date', NEW.flight_date, 'reference_number', NEW.reference_number, 'origin_airport_id', NEW.origin_airport_id, 'destination_airport_id', NEW.destination_airport_id, 'departure_time', NEW.departure_time, 'arrival_time', NEW.arrival_time, 'layover_id', NEW.layover_id, 'class_id', NEW.class_id, 'price', NEW.price, 'aircraft_id', NEW.aircraft_id, 'type_id', NEW.type_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_flights_update` AFTER UPDATE ON `flights` FOR EACH ROW BEGIN
    INSERT INTO audit_flights (action_type, flight_id, flight_data) 
    VALUES ('UPDATE', NEW.flight_id, JSON_OBJECT('flight_number', NEW.flight_number, 'gate_number', NEW.gate_number, 'flight_date', NEW.flight_date, 'reference_number', NEW.reference_number, 'origin_airport_id', NEW.origin_airport_id, 'destination_airport_id', NEW.destination_airport_id, 'departure_time', NEW.departure_time, 'arrival_time', NEW.arrival_time, 'layover_id', NEW.layover_id, 'class_id', NEW.class_id, 'price', NEW.price, 'aircraft_id', NEW.aircraft_id, 'type_id', NEW.type_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `flight_details_view`
-- (See below for the actual view)
--
CREATE TABLE `flight_details_view` (
`origin_airport_id` int(11)
,`origin_airport_code` varchar(10)
,`origin_airport_name` varchar(255)
,`origin_country` varchar(100)
,`destination_airport_id` int(11)
,`destination_airport_code` varchar(10)
,`destination_airport_name` varchar(255)
,`destination_country` varchar(100)
,`duration` varchar(5)
,`miles` int(11)
,`base_price` decimal(10,2)
,`haul_id` int(11)
,`layover_status` tinyint(1)
,`layover_airport_id` int(11)
,`layover_airport_code` varchar(10)
,`layover_airport_name` varchar(255)
,`layover_country` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `flight_duration`
--

CREATE TABLE `flight_duration` (
  `duration_id` int(11) NOT NULL,
  `origin_airport_id` int(11) DEFAULT NULL,
  `destination_airport_id` int(11) DEFAULT NULL,
  `base_duration` varchar(5) DEFAULT NULL,
  `miles` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flight_duration`
--

INSERT INTO `flight_duration` (`duration_id`, `origin_airport_id`, `destination_airport_id`, `base_duration`, `miles`, `timestamp`) VALUES
(1, 1, 31, '09:55', 4979, '2024-12-13 04:53:20'),
(2, 1, 29, '10:33', 5313, '2024-12-13 04:53:20'),
(3, 1, 27, '03:21', 1514, '2024-12-13 04:53:20'),
(4, 1, 28, '02:35', 1108, '2024-12-13 04:53:20'),
(5, 1, 30, '17:00', 8722, '2024-12-13 04:53:20'),
(6, 1, 32, '16:27', 8427, '2024-12-13 04:53:20'),
(7, 1, 26, '04:26', 2085, '2024-12-13 04:53:20'),
(8, 1, 33, '09:10', 4586, '2024-12-14 09:06:04'),
(9, 1, 9, '01:02', 290, '2024-12-13 04:53:20'),
(10, 1, 35, '03:03', 1361, '2024-12-13 04:53:20'),
(11, 1, 37, '13:00', 6606, '2024-12-13 04:53:20'),
(12, 1, 41, '07:18', 3596, '2024-12-13 04:53:20'),
(13, 1, 39, '13:51', 7053, '2024-12-13 04:53:20'),
(14, 1, 40, '16:29', 8444, '2024-12-13 04:53:20'),
(15, 1, 24, '01:16', 414, '2024-12-13 04:53:20'),
(16, 1, 38, '02:18', 954, '2024-12-13 04:53:20'),
(17, 1, 12, '01:25', 487, '2024-12-13 04:53:20'),
(18, 1, 66, '02:00', 792, '2024-12-13 04:53:20'),
(19, 1, 19, '01:32', 549, '2024-12-13 04:53:20'),
(20, 1, 91, '13:08', 6678, '2024-12-13 04:53:20'),
(21, 1, 2, '01:10', 521, '2024-12-13 04:53:20'),
(22, 1, 74, '03:46', 1727, '2024-12-13 04:53:20'),
(23, 1, 8, '01:23', 467, '2024-12-13 04:53:20'),
(24, 1, 48, '01:16', 414, '2024-12-13 04:53:20'),
(25, 1, 50, '01:44', 656, '2024-12-13 04:53:20'),
(26, 1, 51, '16:21', 8379, '2024-12-13 04:53:20'),
(27, 1, 46, '03:21', 1514, '2024-12-13 04:53:20'),
(28, 1, 4, '00:36', 56, '2024-12-13 04:53:20'),
(29, 1, 52, '16:41', 8551, '2024-12-13 04:53:20'),
(30, 1, 45, '03:26', 1549, '2024-12-13 04:53:20'),
(31, 1, 49, '16:23', 8392, '2024-12-13 04:53:20'),
(32, 1, 21, '00:49', 173, '2024-12-13 04:53:20'),
(33, 1, 56, '15:02', 7680, '2024-12-13 04:53:20'),
(34, 1, 53, '16:15', 8320, '2024-12-13 04:53:20'),
(35, 1, 13, '01:14', 388, '2024-12-13 04:53:20'),
(36, 1, 54, '09:16', 4636, '2024-12-13 04:53:20'),
(37, 1, 58, '09:04', 4531, '2024-12-13 04:53:20'),
(38, 1, 20, '01:19', 435, '2024-12-13 04:53:20'),
(39, 1, 34, '03:37', 1648, '2024-12-13 04:53:20'),
(40, 1, 57, '16:05', 8232, '2024-12-13 04:53:20'),
(41, 1, 3, '01:37', 597, '2024-12-13 04:53:20'),
(42, 1, 59, '08:38', 4297, '2024-12-13 04:53:20'),
(43, 1, 61, '13:15', 6734, '2024-12-13 04:53:20'),
(44, 1, 62, '10:37', 5350, '2024-12-13 04:53:20'),
(45, 1, 63, '18:06', 9301, '2024-12-13 04:53:20'),
(46, 1, 64, '03:02', 1343, '2024-12-13 04:53:20'),
(47, 1, 65, '03:31', 1597, '2024-12-13 04:53:20'),
(48, 1, 68, '03:30', 1102, '2024-12-13 04:53:20'),
(49, 1, 70, '01:50', 711, '2024-12-13 04:53:20'),
(50, 1, 94, '03:31', 1600, '2024-12-13 04:53:20'),
(51, 1, 71, '10:32', 5302, '2024-12-13 04:53:20'),
(52, 1, 72, '16:39', 8535, '2024-12-13 04:53:20'),
(53, 1, 17, '01:22', 465, '2024-12-13 04:53:20'),
(54, 1, 98, '03:33', 1615, '2024-12-13 04:53:20'),
(55, 1, 5, '01:01', 280, '2024-12-13 04:53:20'),
(56, 1, 73, '11:15', 5684, '2024-12-13 04:53:20'),
(57, 1, 75, '10:37', 5348, '2024-12-13 04:53:20'),
(58, 1, 89, '16:37', 8520, '2024-12-13 04:53:20'),
(59, 1, 76, '03:18', 1479, '2024-12-13 04:53:20'),
(60, 1, 90, '03:35', 1634, '2024-12-13 04:53:20'),
(61, 1, 6, '00:54', 215, '2024-12-13 04:53:20'),
(62, 1, 77, '03:02', 1339, '2024-12-13 04:53:20'),
(63, 1, 79, '03:25', 1546, '2024-12-13 04:53:20'),
(64, 1, 80, '09:27', 4730, '2024-12-13 04:53:20'),
(65, 1, 23, '00:58', 254, '2024-12-13 04:53:20'),
(66, 1, 81, '14:28', 7385, '2024-12-13 04:53:20'),
(67, 1, 83, '14:19', 7305, '2024-12-13 04:53:20'),
(68, 1, 14, '00:53', 205, '2024-12-13 04:53:20'),
(69, 1, 82, '13:11', 6699, '2024-12-13 04:53:20'),
(70, 1, 85, '07:54', 3909, '2024-12-13 04:53:20'),
(71, 1, 84, '01:51', 717, '2024-12-13 04:53:20'),
(72, 1, 86, '18:08', 9314, '2024-12-13 04:53:20'),
(73, 31, 1, '09:55', 4979, '2024-12-13 04:53:20'),
(74, 29, 1, '10:33', 5313, '2024-12-13 04:53:20'),
(75, 27, 1, '03:21', 1514, '2024-12-13 04:53:20'),
(76, 28, 1, '02:35', 1108, '2024-12-13 04:53:20'),
(77, 30, 1, '17:00', 8722, '2024-12-13 04:53:20'),
(78, 32, 1, '16:27', 8427, '2024-12-13 04:53:20'),
(79, 26, 1, '04:26', 2085, '2024-12-13 04:53:20'),
(80, 33, 1, '09:10', 4586, '2024-12-14 09:06:04'),
(81, 9, 1, '01:02', 290, '2024-12-13 04:53:20'),
(82, 35, 1, '03:03', 1361, '2024-12-13 04:53:20'),
(83, 37, 1, '13:00', 6606, '2024-12-13 04:53:20'),
(84, 41, 1, '07:18', 3596, '2024-12-13 04:53:20'),
(85, 39, 1, '13:51', 7053, '2024-12-13 04:53:20'),
(86, 40, 1, '16:29', 8444, '2024-12-13 04:53:20'),
(87, 24, 1, '01:16', 414, '2024-12-13 04:53:20'),
(88, 38, 1, '02:18', 954, '2024-12-13 04:53:20'),
(89, 12, 1, '01:25', 487, '2024-12-13 04:53:20'),
(90, 66, 1, '02:00', 792, '2024-12-13 04:53:20'),
(91, 19, 1, '01:32', 549, '2024-12-13 04:53:20'),
(92, 91, 1, '13:08', 6678, '2024-12-13 04:53:20'),
(93, 2, 1, '01:10', 521, '2024-12-13 04:53:20'),
(94, 74, 1, '03:46', 1727, '2024-12-13 04:53:20'),
(95, 8, 1, '01:23', 467, '2024-12-13 04:53:20'),
(96, 48, 1, '10:14', 5148, '2024-12-13 04:53:20'),
(97, 50, 1, '16:14', 8316, '2024-12-13 04:53:20'),
(98, 51, 1, '16:21', 8379, '2024-12-13 04:53:20'),
(99, 46, 1, '03:19', 1490, '2024-12-13 04:53:20'),
(100, 4, 1, '00:36', 56, '2024-12-13 04:53:20'),
(101, 52, 1, '16:41', 8551, '2024-12-13 04:53:20'),
(102, 45, 1, '03:26', 1549, '2024-12-13 04:53:20'),
(103, 49, 1, '16:23', 8392, '2024-12-13 04:53:20'),
(104, 21, 1, '00:49', 173, '2024-12-13 04:53:20'),
(105, 56, 1, '15:02', 7680, '2024-12-13 04:53:20'),
(106, 53, 1, '16:15', 8320, '2024-12-13 04:53:20'),
(107, 13, 1, '01:14', 388, '2024-12-13 04:53:20'),
(108, 54, 1, '09:16', 4636, '2024-12-13 04:53:20'),
(109, 58, 1, '09:04', 4531, '2024-12-13 04:53:20'),
(110, 20, 1, '01:19', 435, '2024-12-13 04:53:20'),
(111, 34, 1, '03:37', 1648, '2024-12-13 04:53:20'),
(112, 57, 1, '16:05', 8232, '2024-12-13 04:53:20'),
(113, 3, 1, '01:37', 597, '2024-12-13 04:53:20'),
(114, 59, 1, '08:38', 4297, '2024-12-13 04:53:20'),
(115, 61, 1, '13:15', 6734, '2024-12-13 04:53:20'),
(116, 62, 1, '10:37', 5350, '2024-12-13 04:53:20'),
(117, 63, 1, '18:06', 9301, '2024-12-13 04:53:20'),
(118, 64, 1, '03:02', 1343, '2024-12-13 04:53:20'),
(119, 65, 1, '03:31', 1597, '2024-12-13 04:53:20'),
(120, 68, 1, '03:30', 1102, '2024-12-13 04:53:20'),
(121, 70, 1, '01:50', 711, '2024-12-13 04:53:20'),
(122, 94, 1, '03:31', 1600, '2024-12-13 04:53:20'),
(123, 71, 1, '10:32', 5302, '2024-12-13 04:53:20'),
(124, 72, 1, '16:39', 8535, '2024-12-13 04:53:20'),
(125, 17, 1, '01:22', 465, '2024-12-13 04:53:20'),
(126, 98, 1, '03:33', 1615, '2024-12-13 04:53:20'),
(127, 5, 1, '01:01', 280, '2024-12-13 04:53:20'),
(128, 73, 1, '11:15', 5684, '2024-12-13 04:53:20'),
(129, 75, 1, '10:37', 5348, '2024-12-13 04:53:20'),
(130, 89, 1, '16:37', 8520, '2024-12-13 04:53:20'),
(131, 76, 1, '03:18', 1479, '2024-12-13 04:53:20'),
(132, 90, 1, '03:35', 1634, '2024-12-13 04:53:20'),
(133, 6, 1, '00:54', 215, '2024-12-13 04:53:20'),
(134, 77, 1, '03:02', 1339, '2024-12-13 04:53:20'),
(135, 79, 1, '03:25', 1546, '2024-12-13 04:53:20'),
(136, 80, 1, '09:27', 4730, '2024-12-13 04:53:20'),
(137, 23, 1, '00:58', 254, '2024-12-13 04:53:20'),
(138, 81, 1, '14:28', 7385, '2024-12-13 04:53:20'),
(139, 83, 1, '14:19', 7305, '2024-12-13 04:53:20'),
(140, 14, 1, '00:53', 205, '2024-12-13 04:53:20'),
(141, 82, 1, '13:11', 6699, '2024-12-13 04:53:20'),
(142, 85, 1, '07:54', 3909, '2024-12-13 04:53:20'),
(143, 84, 1, '01:51', 717, '2024-12-13 04:53:20'),
(144, 86, 1, '18:08', 9314, '2024-12-13 04:53:20'),
(145, 88, 1, '03:44', 1712, '2024-12-13 04:53:20'),
(146, 104, 1, '04:05', 1893, '2024-12-13 04:53:20'),
(147, 47, 1, '15:53', 8132, '2024-12-13 04:53:20'),
(148, 16, 1, '00:55', 221, '2024-12-13 04:53:20'),
(149, 22, 1, '01:25', 488, '2024-12-13 04:53:20'),
(150, 95, 1, '13:12', 6712, '2024-12-13 04:53:20'),
(151, 36, 1, '03:52', 1781, '2024-12-13 04:53:20'),
(152, 92, 1, '06:34', 3211, '2024-12-13 04:53:20'),
(153, 93, 1, '02:35', 1109, '2024-12-13 04:53:20'),
(154, 7, 1, '01:11', 362, '2024-12-13 04:53:20'),
(155, 42, 1, '03:21', 1506, '2024-12-13 04:53:20'),
(156, 99, 1, '02:40', 1146, '2024-12-13 04:53:20'),
(157, 96, 1, '09:39', 4839, '2024-12-13 04:53:20'),
(158, 18, 1, '00:56', 232, '2024-12-13 04:53:20'),
(159, 97, 1, '13:43', 6987, '2024-12-13 04:53:20'),
(160, 69, 1, '02:23', 1002, '2024-12-13 04:53:20'),
(161, 100, 1, '03:17', 1474, '2024-12-13 04:53:20'),
(162, 101, 1, '07:50', 3879, '2024-12-13 04:53:20'),
(163, 10, 1, '01:09', 352, '2024-12-13 04:53:20'),
(164, 103, 1, '10:52', 5476, '2024-12-13 04:53:20'),
(165, 102, 1, '01:52', 727, '2024-12-13 04:53:20'),
(166, 15, 1, '00:55', 221, '2024-12-13 04:53:20'),
(167, 25, 1, '01:44', 656, '2024-12-13 04:53:20'),
(168, 107, 1, '10:15', 8221, '2024-12-13 04:53:20'),
(169, 55, 1, '15:43', 8043, '2024-12-13 04:53:20'),
(170, 60, 1, '13:17', 6760, '2024-12-13 04:53:20'),
(171, 67, 1, '16:16', 8334, '2024-12-13 04:53:20'),
(172, 78, 1, '13:02', 6620, '2024-12-13 04:53:20'),
(173, 87, 1, '16:01', 8201, '2024-12-13 04:53:20'),
(174, 106, 1, '12:55', 6567, '2024-12-13 04:53:20'),
(175, 43, 1, '13:26', 6836, '2024-12-13 04:53:20'),
(176, 44, 1, '16:05', 8238, '2024-12-13 04:53:20'),
(177, 105, 1, '16:03', 8221, '2024-12-13 04:53:20'),
(178, 11, 1, '01:29', 526, '2024-12-13 04:53:20'),
(179, 1, 88, '03:44', 1712, '2024-12-13 04:53:20'),
(180, 1, 104, '04:05', 1893, '2024-12-13 04:53:20'),
(181, 1, 47, '15:54', 8132, '2024-12-13 04:53:20'),
(182, 1, 16, '00:55', 221, '2024-12-13 04:53:20'),
(183, 1, 22, '01:25', 488, '2024-12-13 04:53:20'),
(184, 1, 95, '13:12', 6712, '2024-12-13 04:53:20'),
(185, 1, 36, '03:52', 1781, '2024-12-13 04:53:20'),
(186, 1, 92, '06:34', 3211, '2024-12-13 04:53:20'),
(187, 1, 93, '02:35', 1109, '2024-12-13 04:53:20'),
(188, 1, 7, '01:11', 362, '2024-12-13 04:53:20'),
(189, 1, 42, '03:21', 1506, '2024-12-13 04:53:20'),
(190, 1, 99, '02:40', 1146, '2024-12-13 04:53:20'),
(191, 1, 96, '09:39', 4839, '2024-12-13 04:53:20'),
(192, 1, 18, '00:56', 232, '2024-12-13 04:53:20'),
(193, 1, 97, '13:43', 6987, '2024-12-13 04:53:20'),
(194, 1, 69, '02:23', 1002, '2024-12-13 04:53:20'),
(195, 1, 100, '03:17', 1474, '2024-12-13 04:53:20'),
(196, 1, 101, '07:50', 3879, '2024-12-13 04:53:20'),
(197, 1, 10, '01:09', 352, '2024-12-13 04:53:20'),
(198, 1, 103, '10:52', 5476, '2024-12-13 04:53:20'),
(199, 1, 102, '01:52', 727, '2024-12-13 04:53:20'),
(200, 1, 15, '00:55', 221, '2024-12-13 04:53:20'),
(201, 1, 25, '01:44', 656, '2024-12-13 04:53:20'),
(202, 1, 107, '10:15', 8221, '2024-12-13 04:53:20'),
(203, 1, 55, '15:43', 8043, '2024-12-13 04:53:20'),
(204, 1, 60, '13:17', 6760, '2024-12-13 04:53:20'),
(205, 1, 67, '16:16', 8334, '2024-12-13 04:53:20'),
(206, 1, 78, '13:02', 6620, '2024-12-13 04:53:20'),
(207, 1, 87, '16:01', 8201, '2024-12-13 04:53:20'),
(208, 1, 106, '12:55', 6567, '2024-12-13 04:53:20'),
(209, 1, 43, '13:26', 8238, '2024-12-13 04:53:20'),
(210, 1, 44, '16:05', 8238, '2024-12-13 04:53:20'),
(211, 1, 105, '16:03', 8221, '2024-12-13 04:53:20'),
(212, 1, 11, '01:29', 526, '2024-12-13 04:53:20');

--
-- Triggers `flight_duration`
--
DELIMITER $$
CREATE TRIGGER `after_flight_duration_delete` AFTER DELETE ON `flight_duration` FOR EACH ROW BEGIN
    INSERT INTO audit_flight_duration (action_type, duration_id, duration_data) 
    VALUES ('DELETE', OLD.duration_id, JSON_OBJECT('origin_airport_id', OLD.origin_airport_id, 'destination_airport_id', OLD.destination_airport_id, 'base_duration', OLD.base_duration, 'miles', OLD.miles, 'timestamp', OLD.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_flight_duration_insert` AFTER INSERT ON `flight_duration` FOR EACH ROW BEGIN
    INSERT INTO audit_flight_duration (action_type, duration_id, duration_data) 
    VALUES ('INSERT', NEW.duration_id, JSON_OBJECT('origin_airport_id', NEW.origin_airport_id, 'destination_airport_id', NEW.destination_airport_id, 'base_duration', NEW.base_duration, 'miles', NEW.miles, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_flight_duration_update` AFTER UPDATE ON `flight_duration` FOR EACH ROW BEGIN
    INSERT INTO audit_flight_duration (action_type, duration_id, duration_data) 
    VALUES ('UPDATE', NEW.duration_id, JSON_OBJECT('origin_airport_id', NEW.origin_airport_id, 'destination_airport_id', NEW.destination_airport_id, 'base_duration', NEW.base_duration, 'miles', NEW.miles, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `flight_number`
--

CREATE TABLE `flight_number` (
  `flight_number_id` int(11) NOT NULL,
  `flight_number` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flight_number`
--

INSERT INTO `flight_number` (`flight_number_id`, `flight_number`) VALUES
(1, 'SB9001'),
(2, 'SB9345'),
(3, 'SB9921'),
(4, 'SB9571'),
(5, 'SB9092'),
(6, 'SB9746'),
(7, 'SB9457'),
(8, 'SB9045'),
(9, 'SB9855'),
(10, 'SB9142'),
(11, 'SB9145'),
(12, 'SB9298'),
(13, 'SB9055'),
(14, 'SB9382'),
(15, 'SB9746'),
(16, 'SB9584'),
(17, 'SB9682'),
(18, 'SB9658'),
(19, 'SB9244'),
(20, 'SB9245'),
(21, 'SB9496'),
(22, 'SB9746'),
(23, 'SB9243'),
(24, 'SB9975'),
(25, 'SB9146'),
(26, 'SB9808'),
(27, 'SB9601'),
(28, 'SB9583'),
(29, 'SB9112'),
(30, 'SB9813'),
(31, 'SB9727'),
(32, 'SB9198'),
(33, 'SB9810'),
(34, 'SB9457'),
(35, 'SB9854'),
(36, 'SB9901'),
(37, 'SB9945'),
(38, 'SB9020'),
(39, 'SB9267'),
(40, 'SB9275'),
(41, 'SB9574'),
(42, 'SB9046'),
(43, 'SB9508'),
(44, 'SB9401'),
(45, 'SB9484'),
(46, 'SB9215'),
(47, 'SB9626'),
(48, 'SB9482'),
(49, 'SB9536'),
(50, 'SB9233'),
(51, 'SB9559'),
(52, 'SB9097'),
(53, 'SB9808'),
(54, 'SB9749'),
(55, 'SB9321'),
(56, 'SB9360'),
(57, 'SB9839'),
(58, 'SB9112'),
(59, 'SB9047'),
(60, 'SB9897'),
(61, 'SB9345'),
(62, 'SB9033'),
(63, 'SB9132'),
(64, 'SB9559'),
(65, 'SB9403'),
(66, 'SB9337'),
(67, 'SB9475'),
(68, 'SB9366'),
(69, 'SB9406'),
(70, 'SB9931'),
(71, 'SB9437'),
(72, 'SB9391'),
(73, 'SB9647'),
(74, 'SB9062'),
(75, 'SB9371'),
(76, 'SB9669'),
(77, 'SB9233'),
(78, 'SB9156'),
(79, 'SB9082'),
(80, 'SB9941'),
(81, 'SB9463'),
(82, 'SB9489'),
(83, 'SB9058'),
(84, 'SB9824'),
(85, 'SB9948'),
(86, 'SB9266'),
(87, 'SB9486'),
(88, 'SB9632'),
(89, 'SB9703'),
(90, 'SB9620'),
(91, 'SB9993'),
(92, 'SB9103'),
(93, 'SB9539'),
(94, 'SB9387'),
(95, 'SB9317'),
(96, 'SB9423'),
(97, 'SB9165'),
(98, 'SB9558'),
(99, 'SB9295'),
(100, 'SB9800'),
(101, 'SB9118'),
(102, 'SB9187'),
(103, 'SB9585'),
(104, 'SB9364'),
(105, 'SB9065'),
(106, 'SB9232'),
(107, 'SB9966'),
(108, 'SB9134'),
(109, 'SB9773'),
(110, 'SB9463'),
(111, 'SB9998'),
(112, 'SB9601'),
(113, 'SB9013'),
(114, 'SB9260'),
(115, 'SB9263'),
(116, 'SB9535'),
(117, 'SB9888'),
(118, 'SB9835'),
(119, 'SB9510'),
(120, 'SB9046'),
(121, 'SB9702'),
(122, 'SB9372'),
(123, 'SB9756'),
(124, 'SB9662'),
(125, 'SB9044'),
(126, 'SB9233'),
(127, 'SB9036'),
(128, 'SB9481'),
(129, 'SB9296'),
(130, 'SB9037'),
(131, 'SB9300'),
(132, 'SB9390'),
(133, 'SB9050'),
(134, 'SB9079'),
(135, 'SB9248'),
(136, 'SB9002'),
(137, 'SB9265'),
(138, 'SB9323'),
(139, 'SB9818'),
(140, 'SB9120'),
(141, 'SB9149'),
(142, 'SB9385'),
(143, 'SB9477'),
(144, 'SB9230'),
(145, 'SB9720'),
(146, 'SB9911'),
(147, 'SB9394'),
(148, 'SB9238'),
(149, 'SB9007');

-- --------------------------------------------------------

--
-- Table structure for table `flight_pricing`
--

CREATE TABLE `flight_pricing` (
  `pricing_id` int(11) NOT NULL,
  `origin_airport_id` int(11) DEFAULT NULL,
  `destination_airport_id` int(11) DEFAULT NULL,
  `base_price` decimal(10,2) DEFAULT NULL,
  `haul_id` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flight_pricing`
--

INSERT INTO `flight_pricing` (`pricing_id`, `origin_airport_id`, `destination_airport_id`, `base_price`, `haul_id`, `timestamp`) VALUES
(2, 1, 31, 4481.10, 3, '2024-12-13 04:53:02'),
(3, 1, 29, 4781.70, 3, '2024-12-13 04:53:02'),
(4, 1, 27, 1362.60, 2, '2024-12-13 04:53:02'),
(5, 1, 28, 997.20, 1, '2024-12-13 04:53:02'),
(6, 1, 30, 7849.80, 4, '2024-12-13 04:53:02'),
(7, 1, 32, 7584.30, 4, '2024-12-13 04:53:02'),
(8, 1, 26, 1876.50, 2, '2024-12-13 04:53:02'),
(9, 1, 33, 4127.40, 3, '2024-12-13 04:53:02'),
(10, 1, 9, 261.00, 1, '2024-12-13 04:53:02'),
(11, 1, 35, 1224.90, 2, '2024-12-13 04:53:02'),
(12, 1, 37, 5945.40, 4, '2024-12-13 04:53:02'),
(13, 1, 41, 3236.40, 3, '2024-12-13 04:53:02'),
(14, 1, 39, 6347.70, 4, '2024-12-13 04:53:02'),
(15, 1, 40, 7599.60, 4, '2024-12-13 04:53:02'),
(16, 1, 24, 372.60, 1, '2024-12-13 04:53:02'),
(17, 1, 38, 858.60, 1, '2024-12-13 04:53:02'),
(18, 1, 12, 438.30, 1, '2024-12-13 04:53:02'),
(19, 1, 66, 712.80, 1, '2024-12-13 04:53:02'),
(20, 1, 19, 494.10, 1, '2024-12-13 04:53:02'),
(21, 1, 91, 6010.20, 4, '2024-12-13 04:53:02'),
(22, 1, 2, 468.90, 1, '2024-12-13 04:53:02'),
(23, 1, 74, 1554.30, 2, '2024-12-13 04:53:02'),
(24, 1, 8, 420.30, 1, '2024-12-13 04:53:02'),
(25, 1, 48, 372.60, 1, '2024-12-13 04:53:02'),
(26, 1, 50, 590.40, 1, '2024-12-13 04:53:02'),
(27, 1, 51, 7541.10, 4, '2024-12-13 04:53:02'),
(28, 1, 46, 1362.60, 2, '2024-12-13 04:53:02'),
(29, 1, 4, 50.40, 1, '2024-12-13 04:53:02'),
(30, 1, 52, 7695.90, 4, '2024-12-13 04:53:02'),
(31, 1, 45, 1394.10, 2, '2024-12-13 04:53:02'),
(32, 1, 49, 7552.80, 4, '2024-12-13 04:53:02'),
(33, 1, 21, 155.70, 1, '2024-12-13 04:53:02'),
(34, 1, 56, 6912.00, 4, '2024-12-13 04:53:02'),
(35, 1, 53, 7488.00, 4, '2024-12-13 04:53:02'),
(36, 1, 13, 349.20, 1, '2024-12-13 04:53:02'),
(37, 1, 54, 4172.40, 3, '2024-12-13 04:53:02'),
(38, 1, 58, 4077.90, 3, '2024-12-13 04:53:02'),
(39, 1, 20, 391.50, 1, '2024-12-13 04:53:02'),
(40, 1, 34, 1483.20, 2, '2024-12-13 04:53:02'),
(41, 1, 57, 7408.80, 4, '2024-12-13 04:53:02'),
(42, 1, 3, 537.30, 1, '2024-12-13 04:53:02'),
(43, 1, 59, 3867.30, 3, '2024-12-13 04:53:02'),
(44, 1, 61, 6060.60, 4, '2024-12-13 04:53:02'),
(45, 1, 62, 4815.00, 3, '2024-12-13 04:53:02'),
(46, 1, 63, 8370.90, 4, '2024-12-13 04:53:02'),
(47, 1, 64, 1208.70, 2, '2024-12-13 04:53:02'),
(48, 1, 65, 1437.30, 2, '2024-12-13 04:53:02'),
(49, 1, 68, 991.80, 2, '2024-12-13 04:53:02'),
(50, 1, 70, 639.90, 1, '2024-12-13 04:53:02'),
(51, 1, 94, 1440.00, 2, '2024-12-13 04:53:02'),
(52, 1, 71, 4771.80, 3, '2024-12-13 04:53:02'),
(53, 1, 72, 7681.50, 4, '2024-12-13 04:53:02'),
(54, 1, 17, 418.50, 1, '2024-12-13 04:53:02'),
(55, 1, 98, 1453.50, 2, '2024-12-13 04:53:02'),
(56, 1, 5, 252.00, 1, '2024-12-13 04:53:02'),
(57, 1, 73, 5115.60, 3, '2024-12-13 04:53:02'),
(58, 1, 75, 4813.20, 3, '2024-12-13 04:53:02'),
(59, 1, 89, 7668.00, 4, '2024-12-13 04:53:02'),
(60, 1, 76, 1331.10, 2, '2024-12-13 04:53:02'),
(61, 1, 90, 1470.60, 2, '2024-12-13 04:53:02'),
(62, 1, 6, 193.50, 1, '2024-12-13 04:53:02'),
(63, 1, 77, 1205.10, 2, '2024-12-13 04:53:02'),
(64, 1, 79, 1391.40, 2, '2024-12-13 04:53:02'),
(65, 1, 80, 4257.00, 3, '2024-12-13 04:53:02'),
(66, 1, 23, 228.60, 1, '2024-12-13 04:53:02'),
(67, 1, 81, 6646.50, 4, '2024-12-13 04:53:02'),
(68, 1, 83, 6574.50, 4, '2024-12-13 04:53:02'),
(69, 1, 14, 184.50, 1, '2024-12-13 04:53:02'),
(70, 1, 82, 6029.10, 4, '2024-12-13 04:53:02'),
(71, 1, 85, 3518.10, 3, '2024-12-13 04:53:02'),
(72, 1, 84, 645.30, 1, '2024-12-13 04:53:02'),
(73, 1, 86, 8382.60, 4, '2024-12-13 04:53:02'),
(74, 31, 1, 4481.10, 3, '2024-12-13 04:53:02'),
(75, 29, 1, 4781.70, 3, '2024-12-13 04:53:02'),
(76, 27, 1, 1362.60, 2, '2024-12-13 04:53:02'),
(77, 28, 1, 997.20, 1, '2024-12-13 04:53:02'),
(78, 30, 1, 7849.80, 4, '2024-12-13 04:53:02'),
(79, 32, 1, 7584.30, 4, '2024-12-13 04:53:02'),
(80, 26, 1, 1876.50, 2, '2024-12-13 04:53:02'),
(81, 33, 1, 4127.40, 3, '2024-12-13 04:53:02'),
(82, 9, 1, 261.00, 1, '2024-12-13 04:53:02'),
(83, 35, 1, 1224.90, 2, '2024-12-13 04:53:02'),
(84, 37, 1, 5945.40, 4, '2024-12-13 04:53:02'),
(85, 41, 1, 3236.40, 3, '2024-12-13 04:53:02'),
(86, 39, 1, 6347.70, 4, '2024-12-13 04:53:02'),
(87, 40, 1, 7599.60, 4, '2024-12-13 04:53:02'),
(88, 24, 1, 372.60, 1, '2024-12-13 04:53:02'),
(89, 38, 1, 858.60, 1, '2024-12-13 04:53:02'),
(90, 12, 1, 438.30, 1, '2024-12-13 04:53:02'),
(91, 66, 1, 712.80, 1, '2024-12-13 04:53:02'),
(92, 19, 1, 494.10, 1, '2024-12-13 04:53:02'),
(93, 91, 1, 6010.20, 4, '2024-12-13 04:53:02'),
(94, 2, 1, 468.90, 1, '2024-12-13 04:53:02'),
(95, 74, 1, 1554.30, 2, '2024-12-13 04:53:02'),
(96, 8, 1, 420.30, 1, '2024-12-13 04:53:02'),
(97, 48, 1, 4633.20, 3, '2024-12-13 04:53:02'),
(98, 50, 1, 7484.40, 4, '2024-12-13 04:53:02'),
(99, 51, 1, 7541.10, 4, '2024-12-13 04:53:02'),
(100, 46, 1, 1341.00, 2, '2024-12-13 04:53:02'),
(101, 4, 1, 50.40, 1, '2024-12-13 04:53:02'),
(102, 52, 1, 7695.90, 4, '2024-12-13 04:53:02'),
(103, 45, 1, 1394.10, 2, '2024-12-13 04:53:02'),
(104, 49, 1, 7552.80, 4, '2024-12-13 04:53:02'),
(105, 21, 1, 155.70, 1, '2024-12-13 04:53:02'),
(106, 56, 1, 6912.00, 4, '2024-12-13 04:53:02'),
(107, 53, 1, 7488.00, 4, '2024-12-13 04:53:02'),
(108, 13, 1, 349.20, 1, '2024-12-13 04:53:02'),
(109, 54, 1, 4172.40, 3, '2024-12-13 04:53:02'),
(110, 58, 1, 4077.90, 3, '2024-12-13 04:53:02'),
(111, 20, 1, 391.50, 1, '2024-12-13 04:53:02'),
(112, 34, 1, 1483.20, 2, '2024-12-13 04:53:02'),
(113, 57, 1, 7408.80, 4, '2024-12-13 04:53:02'),
(114, 3, 1, 537.30, 1, '2024-12-13 04:53:02'),
(115, 59, 1, 3867.30, 3, '2024-12-13 04:53:02'),
(116, 61, 1, 6060.60, 4, '2024-12-13 04:53:02'),
(117, 62, 1, 4815.00, 3, '2024-12-13 04:53:02'),
(118, 63, 1, 8370.90, 4, '2024-12-13 04:53:02'),
(119, 64, 1, 1208.70, 2, '2024-12-13 04:53:02'),
(120, 65, 1, 1437.30, 2, '2024-12-13 04:53:02'),
(121, 68, 1, 991.80, 2, '2024-12-13 04:53:02'),
(122, 70, 1, 639.90, 1, '2024-12-13 04:53:02'),
(123, 94, 1, 1440.00, 2, '2024-12-13 04:53:02'),
(124, 71, 1, 4771.80, 3, '2024-12-13 04:53:02'),
(125, 72, 1, 7681.50, 4, '2024-12-13 04:53:02'),
(126, 17, 1, 418.50, 1, '2024-12-13 04:53:02'),
(127, 98, 1, 1453.50, 2, '2024-12-13 04:53:02'),
(128, 5, 1, 252.00, 1, '2024-12-13 04:53:02'),
(129, 73, 1, 5115.60, 3, '2024-12-13 04:53:02'),
(130, 75, 1, 4813.20, 3, '2024-12-13 04:53:02'),
(131, 89, 1, 7668.00, 4, '2024-12-13 04:53:02'),
(132, 76, 1, 1331.10, 2, '2024-12-13 04:53:02'),
(133, 90, 1, 1470.60, 2, '2024-12-13 04:53:02'),
(134, 6, 1, 193.50, 1, '2024-12-13 04:53:02'),
(135, 77, 1, 1205.10, 2, '2024-12-13 04:53:02'),
(136, 79, 1, 1391.40, 2, '2024-12-13 04:53:02'),
(137, 80, 1, 4257.00, 3, '2024-12-13 04:53:02'),
(138, 23, 1, 228.60, 1, '2024-12-13 04:53:02'),
(139, 81, 1, 6646.50, 4, '2024-12-13 04:53:02'),
(140, 83, 1, 6574.50, 4, '2024-12-13 04:53:02'),
(141, 14, 1, 184.50, 1, '2024-12-13 04:53:02'),
(142, 82, 1, 6029.10, 4, '2024-12-13 04:53:02'),
(143, 85, 1, 3518.10, 3, '2024-12-13 04:53:02'),
(144, 84, 1, 645.30, 1, '2024-12-13 04:53:02'),
(145, 86, 1, 8382.60, 4, '2024-12-13 04:53:02'),
(146, 88, 1, 1540.80, 2, '2024-12-13 04:53:02'),
(147, 104, 1, 1703.70, 2, '2024-12-13 04:53:02'),
(148, 47, 1, 7318.80, 4, '2024-12-13 04:53:02'),
(149, 16, 1, 198.90, 1, '2024-12-13 04:53:02'),
(150, 22, 1, 439.20, 1, '2024-12-13 04:53:02'),
(151, 95, 1, 6040.80, 4, '2024-12-13 04:53:02'),
(152, 36, 1, 1602.90, 2, '2024-12-13 04:53:02'),
(153, 92, 1, 2889.90, 2, '2024-12-13 04:53:02'),
(154, 93, 1, 998.10, 1, '2024-12-13 04:53:02'),
(155, 7, 1, 325.80, 1, '2024-12-13 04:53:02'),
(156, 42, 1, 1355.40, 2, '2024-12-13 04:53:02'),
(157, 99, 1, 1031.40, 1, '2024-12-13 04:53:02'),
(158, 96, 1, 4355.10, 3, '2024-12-13 04:53:02'),
(159, 18, 1, 208.80, 1, '2024-12-13 04:53:02'),
(160, 97, 1, 6288.30, 4, '2024-12-13 04:53:02'),
(161, 69, 1, 901.80, 1, '2024-12-13 04:53:02'),
(162, 100, 1, 1326.60, 2, '2024-12-13 04:53:02'),
(163, 101, 1, 3491.10, 3, '2024-12-13 04:53:02'),
(164, 10, 1, 316.80, 1, '2024-12-13 04:53:02'),
(165, 103, 1, 4928.40, 3, '2024-12-13 04:53:02'),
(166, 102, 1, 654.30, 1, '2024-12-13 04:53:02'),
(167, 15, 1, 198.90, 1, '2024-12-13 04:53:02'),
(168, 25, 1, 590.40, 1, '2024-12-13 04:53:02'),
(169, 107, 1, 7398.90, 3, '2024-12-13 04:53:02'),
(170, 55, 1, 7238.70, 4, '2024-12-13 04:53:02'),
(171, 60, 1, 6084.00, 4, '2024-12-13 04:53:02'),
(172, 67, 1, 7500.60, 4, '2024-12-13 04:53:02'),
(173, 78, 1, 5958.00, 4, '2024-12-13 04:53:02'),
(174, 87, 1, 7380.90, 4, '2024-12-13 04:53:02'),
(175, 106, 1, 5910.30, 4, '2024-12-13 04:53:02'),
(176, 43, 1, 6152.40, 4, '2024-12-13 04:53:02'),
(177, 44, 1, 7414.20, 4, '2024-12-13 04:53:02'),
(178, 105, 1, 7398.90, 4, '2024-12-13 04:53:02'),
(179, 11, 1, 473.40, 1, '2024-12-13 04:53:02'),
(180, 1, 88, 1540.80, 2, '2024-12-13 04:53:02'),
(181, 1, 104, 1703.70, 2, '2024-12-13 04:53:02'),
(182, 1, 47, 7318.80, 4, '2024-12-13 04:53:02'),
(183, 1, 16, 198.90, 1, '2024-12-13 04:53:02'),
(184, 1, 22, 439.20, 1, '2024-12-13 04:53:02'),
(185, 1, 95, 6040.80, 4, '2024-12-13 04:53:02'),
(186, 1, 36, 1602.90, 2, '2024-12-13 04:53:02'),
(187, 1, 92, 2889.90, 2, '2024-12-13 04:53:02'),
(188, 1, 93, 998.10, 1, '2024-12-13 04:53:02'),
(189, 1, 7, 325.80, 1, '2024-12-13 04:53:02'),
(190, 1, 42, 1355.40, 2, '2024-12-13 04:53:02'),
(191, 1, 99, 1031.40, 1, '2024-12-13 04:53:02'),
(192, 1, 96, 4355.10, 3, '2024-12-13 04:53:02'),
(193, 1, 18, 208.80, 1, '2024-12-13 04:53:02'),
(194, 1, 97, 6288.30, 4, '2024-12-13 04:53:02'),
(195, 1, 69, 901.80, 1, '2024-12-13 04:53:02'),
(196, 1, 100, 1326.60, 2, '2024-12-13 04:53:02'),
(197, 1, 101, 3491.10, 3, '2024-12-13 04:53:02'),
(198, 1, 10, 316.80, 1, '2024-12-13 04:53:02'),
(199, 1, 103, 4928.40, 3, '2024-12-13 04:53:02'),
(200, 1, 102, 654.30, 1, '2024-12-13 04:53:02'),
(201, 1, 15, 198.90, 1, '2024-12-13 04:53:02'),
(202, 1, 25, 590.40, 1, '2024-12-13 04:53:02'),
(203, 1, 107, 7398.90, 3, '2024-12-13 04:53:02'),
(204, 1, 55, 7238.70, 4, '2024-12-13 04:53:02'),
(205, 1, 60, 6084.00, 4, '2024-12-13 04:53:02'),
(206, 1, 67, 7500.60, 4, '2024-12-13 04:53:02'),
(207, 1, 78, 5958.00, 4, '2024-12-13 04:53:02'),
(208, 1, 87, 7380.90, 4, '2024-12-13 04:53:02'),
(209, 1, 106, 5910.30, 4, '2024-12-13 04:53:02'),
(210, 1, 43, 7414.20, 4, '2024-12-13 04:53:02'),
(211, 1, 44, 7414.20, 4, '2024-12-13 04:53:02'),
(212, 1, 105, 7398.90, 4, '2024-12-13 04:53:02'),
(213, 1, 11, 473.40, 1, '2024-12-13 04:53:02');

--
-- Triggers `flight_pricing`
--
DELIMITER $$
CREATE TRIGGER `after_flight_pricing_delete` AFTER DELETE ON `flight_pricing` FOR EACH ROW BEGIN
    INSERT INTO audit_flight_pricing (action_type, pricing_id, pricing_data) 
    VALUES ('DELETE', OLD.pricing_id, JSON_OBJECT('origin_airport_id', OLD.origin_airport_id, 'destination_airport_id', OLD.destination_airport_id, 'base_price', OLD.base_price, 'haul_id', OLD.haul_id, 'timestamp', OLD.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_flight_pricing_insert` AFTER INSERT ON `flight_pricing` FOR EACH ROW BEGIN
    INSERT INTO audit_flight_pricing (action_type, pricing_id, pricing_data) 
    VALUES ('INSERT', NEW.pricing_id, JSON_OBJECT('origin_airport_id', NEW.origin_airport_id, 'destination_airport_id', NEW.destination_airport_id, 'base_price', NEW.base_price, 'haul_id', NEW.haul_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_flight_pricing_update` AFTER UPDATE ON `flight_pricing` FOR EACH ROW BEGIN
    INSERT INTO audit_flight_pricing (action_type, pricing_id, pricing_data) 
    VALUES ('UPDATE', NEW.pricing_id, JSON_OBJECT('origin_airport_id', NEW.origin_airport_id, 'destination_airport_id', NEW.destination_airport_id, 'base_price', NEW.base_price, 'haul_id', NEW.haul_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `flight_schedule`
--

CREATE TABLE `flight_schedule` (
  `schedule_id` int(11) NOT NULL,
  `day_of_week` varchar(10) DEFAULT NULL,
  `departure_time` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flight_schedule`
--

INSERT INTO `flight_schedule` (`schedule_id`, `day_of_week`, `departure_time`) VALUES
(1, 'Monday', '02:56:38'),
(2, 'Monday', '07:09:15'),
(3, 'Monday', '04:56:22'),
(4, 'Monday', '07:11:45'),
(5, 'Monday', '09:07:52'),
(6, 'Monday', '09:04:05'),
(7, 'Monday', '15:20:10'),
(8, 'Monday', '19:26:07'),
(9, 'Monday', '17:10:05'),
(10, 'Monday', '19:26:45'),
(11, 'Monday', '21:48:34'),
(12, 'Monday', '23:42:37'),
(13, 'Tuesday', '04:44:49'),
(14, 'Tuesday', '04:58:39'),
(15, 'Tuesday', '06:38:50'),
(16, 'Tuesday', '09:45:12'),
(17, 'Tuesday', '12:38:53'),
(18, 'Tuesday', '13:58:53'),
(19, 'Tuesday', '14:09:16'),
(20, 'Tuesday', '19:50:24'),
(21, 'Tuesday', '16:44:12'),
(22, 'Tuesday', '21:38:11'),
(23, 'Tuesday', '23:50:25'),
(24, 'Tuesday', '22:17:31'),
(25, 'Wednesday', '06:55:37'),
(26, 'Wednesday', '02:59:01'),
(27, 'Wednesday', '08:08:14'),
(28, 'Wednesday', '10:56:47'),
(29, 'Wednesday', '09:53:21'),
(30, 'Wednesday', '11:36:24'),
(31, 'Wednesday', '15:50:21'),
(32, 'Wednesday', '18:48:43'),
(33, 'Wednesday', '18:32:32'),
(34, 'Wednesday', '21:43:45'),
(35, 'Wednesday', '24:47:28'),
(36, 'Wednesday', '21:46:05'),
(37, 'Thursday', '06:21:39'),
(38, 'Thursday', '02:02:22'),
(39, 'Thursday', '05:06:52'),
(40, 'Thursday', '10:42:41'),
(41, 'Thursday', '11:16:17'),
(42, 'Thursday', '09:13:21'),
(43, 'Thursday', '14:33:29'),
(44, 'Thursday', '14:59:21'),
(45, 'Thursday', '15:16:18'),
(46, 'Thursday', '22:39:34'),
(47, 'Thursday', '22:37:04'),
(48, 'Thursday', '23:06:39'),
(49, 'Friday', '04:14:30'),
(50, 'Friday', '04:36:31'),
(51, 'Friday', '06:19:09'),
(52, 'Friday', '09:18:28'),
(53, 'Friday', '11:14:27'),
(54, 'Friday', '13:16:53'),
(55, 'Friday', '15:01:17'),
(56, 'Friday', '14:41:37'),
(57, 'Friday', '18:24:15'),
(58, 'Friday', '21:27:01'),
(59, 'Friday', '23:44:28'),
(60, 'Friday', '22:21:16'),
(61, 'Saturday', '01:39:32'),
(62, 'Saturday', '06:25:09'),
(63, 'Saturday', '05:07:08'),
(64, 'Saturday', '09:46:52'),
(65, 'Saturday', '11:36:30'),
(66, 'Saturday', '13:41:55'),
(67, 'Saturday', '16:12:07'),
(68, 'Saturday', '19:05:40'),
(69, 'Saturday', '18:52:01'),
(70, 'Saturday', '22:22:33'),
(71, 'Saturday', '22:12:43'),
(72, 'Saturday', '21:55:58'),
(73, 'Sunday', '04:38:03'),
(74, 'Sunday', '04:48:43'),
(75, 'Sunday', '06:09:29'),
(76, 'Sunday', '08:07:42'),
(77, 'Sunday', '10:44:51'),
(78, 'Sunday', '09:21:06'),
(79, 'Sunday', '17:13:12'),
(80, 'Sunday', '15:50:00'),
(81, 'Sunday', '17:30:25'),
(82, 'Sunday', '19:51:45'),
(83, 'Sunday', '23:02:44'),
(84, 'Sunday', '23:38:23');

-- --------------------------------------------------------

--
-- Stand-in structure for view `flight_status_view`
-- (See below for the actual view)
--
CREATE TABLE `flight_status_view` (
`flight_id` int(11)
,`flight_number` varchar(50)
,`origin_airport_id` int(11)
,`destination_airport_id` int(11)
,`departure_time` time
,`arrival_time` time
,`flight_date` date
,`status` varchar(9)
);

-- --------------------------------------------------------

--
-- Table structure for table `flight_type`
--

CREATE TABLE `flight_type` (
  `type_id` int(11) NOT NULL,
  `type_name` enum('Domestic','International') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flight_type`
--

INSERT INTO `flight_type` (`type_id`, `type_name`) VALUES
(1, 'Domestic'),
(2, 'International');

-- --------------------------------------------------------

--
-- Table structure for table `haul`
--

CREATE TABLE `haul` (
  `haul_id` int(11) NOT NULL,
  `haul_type` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `haul`
--

INSERT INTO `haul` (`haul_id`, `haul_type`) VALUES
(1, 'Short Haul Flight'),
(2, 'Medium Haul Flight'),
(3, 'Long Haul Flight'),
(4, 'Ultra Long Haul Flight');

-- --------------------------------------------------------

--
-- Stand-in structure for view `international_airports_view`
-- (See below for the actual view)
--
CREATE TABLE `international_airports_view` (
`airport_id` int(11)
,`airport_name` varchar(255)
,`airport_code` varchar(10)
);

-- --------------------------------------------------------

--
-- Table structure for table `layover`
--

CREATE TABLE `layover` (
  `layover_id` int(11) NOT NULL,
  `origin_airport_id` int(11) NOT NULL,
  `destination_airport_id` int(11) NOT NULL,
  `layover_status` tinyint(1) NOT NULL,
  `layover_airport_id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `layover`
--

INSERT INTO `layover` (`layover_id`, `origin_airport_id`, `destination_airport_id`, `layover_status`, `layover_airport_id`, `timestamp`) VALUES
(1, 1, 31, 1, 101, '2024-12-13 09:42:02'),
(2, 1, 29, 1, 83, '2024-12-13 09:38:43'),
(3, 1, 27, 0, 1, '2024-12-13 04:51:57'),
(4, 1, 28, 0, 1, '2024-12-13 04:51:57'),
(5, 1, 30, 1, 106, '2024-12-13 07:35:08'),
(6, 1, 32, 0, 1, '2024-12-13 04:51:57'),
(7, 1, 26, 1, 104, '2024-12-13 09:50:59'),
(8, 1, 33, 1, 59, '2024-12-13 09:45:49'),
(9, 1, 9, 0, 1, '2024-12-13 04:51:57'),
(10, 1, 35, 0, 1, '2024-12-13 04:51:57'),
(11, 1, 37, 0, 1, '2024-12-13 04:51:57'),
(12, 1, 41, 1, 101, '2024-12-13 09:48:44'),
(13, 1, 39, 1, 83, '2024-12-13 08:28:23'),
(14, 1, 40, 1, 83, '2024-12-13 07:47:50'),
(15, 1, 24, 0, 1, '2024-12-13 04:51:57'),
(16, 1, 38, 0, 1, '2024-12-13 04:51:57'),
(17, 1, 12, 0, 1, '2024-12-13 04:51:57'),
(18, 1, 66, 0, 1, '2024-12-13 04:51:57'),
(19, 1, 19, 0, 1, '2024-12-13 04:51:57'),
(20, 1, 91, 1, 100, '2024-12-13 08:38:25'),
(21, 1, 2, 0, 1, '2024-12-13 04:51:57'),
(22, 1, 74, 0, 1, '2024-12-13 04:51:57'),
(23, 1, 8, 0, 1, '2024-12-13 04:51:57'),
(24, 1, 48, 0, 1, '2024-12-13 04:51:57'),
(25, 1, 50, 0, 1, '2024-12-13 04:51:57'),
(26, 1, 51, 1, 89, '2024-12-13 07:53:23'),
(27, 1, 46, 0, 1, '2024-12-13 04:51:57'),
(28, 1, 4, 0, 1, '2024-12-13 04:51:57'),
(29, 1, 52, 1, 83, '2024-12-13 07:43:14'),
(30, 1, 45, 0, 1, '2024-12-13 04:51:57'),
(31, 1, 49, 1, 89, '2024-12-13 07:51:53'),
(32, 1, 21, 1, 83, '2024-12-13 07:49:59'),
(33, 1, 56, 1, 83, '2024-12-13 08:25:11'),
(34, 1, 53, 1, 83, '2024-12-13 08:15:08'),
(35, 1, 13, 0, 1, '2024-12-13 04:51:57'),
(36, 1, 54, 1, 59, '2024-12-13 09:44:46'),
(37, 1, 58, 1, 59, '2024-12-13 09:46:47'),
(38, 1, 20, 0, 1, '2024-12-13 04:51:57'),
(39, 1, 34, 0, 1, '2024-12-13 04:51:57'),
(40, 1, 57, 1, 97, '2024-12-13 08:16:16'),
(41, 1, 3, 0, 1, '2024-12-13 04:51:57'),
(42, 1, 59, 0, 1, '2024-12-13 04:51:57'),
(43, 1, 61, 0, 1, '2024-12-13 04:51:57'),
(44, 1, 62, 0, 1, '2024-12-13 08:17:20'),
(45, 1, 63, 1, 83, '2024-12-13 06:38:18'),
(46, 1, 64, 0, 1, '2024-12-13 04:51:57'),
(47, 1, 65, 0, 1, '2024-12-13 04:51:57'),
(48, 1, 68, 0, 1, '2024-12-13 04:51:57'),
(49, 1, 70, 1, 1, '2024-12-13 07:50:54'),
(50, 1, 94, 0, 1, '2024-12-13 04:51:57'),
(51, 1, 71, 1, 83, '2024-12-13 09:39:41'),
(52, 1, 72, 1, 83, '2024-12-13 07:45:15'),
(53, 1, 17, 0, 1, '2024-12-13 04:51:57'),
(54, 1, 98, 0, 1, '2024-12-13 04:51:57'),
(55, 1, 5, 0, 1, '2024-12-13 04:51:57'),
(56, 1, 73, 1, 59, '2024-12-13 08:43:49'),
(57, 1, 75, 1, 59, '2024-12-13 09:37:52'),
(58, 1, 89, 1, 83, '2024-12-13 07:46:43'),
(59, 1, 76, 0, 1, '2024-12-13 04:51:57'),
(60, 1, 90, 0, 1, '2024-12-13 04:51:57'),
(61, 1, 6, 0, 1, '2024-12-13 04:51:57'),
(62, 1, 77, 0, 1, '2024-12-13 04:51:57'),
(63, 1, 79, 0, 1, '2024-12-13 04:51:57'),
(64, 1, 80, 1, 59, '2024-12-13 09:43:48'),
(65, 1, 23, 0, 1, '2024-12-13 04:51:57'),
(66, 1, 81, 1, 83, '2024-12-13 08:25:59'),
(67, 1, 83, 0, 1, '2024-12-13 08:27:22'),
(68, 1, 14, 0, 1, '2024-12-13 04:51:57'),
(69, 1, 82, 1, 100, '2024-12-13 08:38:06'),
(70, 1, 85, 1, 101, '2024-12-13 09:47:44'),
(71, 1, 84, 0, 1, '2024-12-13 04:51:57'),
(72, 1, 86, 1, 83, '2024-12-13 04:51:57'),
(73, 31, 1, 1, 101, '2024-12-13 09:42:11'),
(74, 29, 1, 1, 83, '2024-12-13 09:38:47'),
(75, 27, 1, 0, 1, '2024-12-13 04:51:57'),
(76, 28, 1, 0, 1, '2024-12-13 04:51:57'),
(77, 30, 1, 1, 106, '2024-12-13 07:35:13'),
(78, 32, 1, 1, 83, '2024-12-13 07:50:07'),
(79, 26, 1, 1, 104, '2024-12-13 09:51:02'),
(80, 33, 1, 1, 59, '2024-12-13 09:45:54'),
(81, 9, 1, 0, 1, '2024-12-13 04:51:57'),
(82, 35, 1, 0, 1, '2024-12-13 04:51:57'),
(83, 37, 1, 0, 1, '2024-12-13 04:51:57'),
(84, 41, 1, 1, 101, '2024-12-13 09:48:53'),
(85, 39, 1, 1, 83, '2024-12-13 08:28:20'),
(86, 40, 1, 1, 83, '2024-12-13 07:47:57'),
(87, 24, 1, 0, 1, '2024-12-13 04:51:57'),
(88, 38, 1, 0, 1, '2024-12-13 04:51:57'),
(89, 12, 1, 0, 1, '2024-12-13 04:51:57'),
(90, 66, 1, 0, 1, '2024-12-13 04:51:57'),
(91, 19, 1, 0, 1, '2024-12-13 04:51:57'),
(92, 91, 1, 1, 100, '2024-12-13 08:38:32'),
(93, 2, 1, 0, 1, '2024-12-13 04:51:57'),
(94, 74, 1, 0, 1, '2024-12-13 04:51:57'),
(95, 8, 1, 0, 1, '2024-12-13 04:51:57'),
(96, 48, 1, 0, 1, '2024-12-13 04:51:57'),
(97, 50, 1, 0, 1, '2024-12-13 04:51:57'),
(98, 51, 1, 1, 89, '2024-12-13 07:53:41'),
(99, 46, 1, 0, 1, '2024-12-13 04:51:57'),
(100, 4, 1, 0, 1, '2024-12-13 04:51:57'),
(101, 52, 1, 1, 83, '2024-12-13 07:43:06'),
(102, 45, 1, 0, 1, '2024-12-13 04:51:57'),
(103, 49, 1, 1, 89, '2024-12-13 08:45:56'),
(104, 21, 1, 0, 1, '2024-12-13 04:51:57'),
(105, 56, 1, 1, 83, '2024-12-13 08:25:19'),
(106, 53, 1, 1, 83, '2024-12-13 08:15:14'),
(107, 13, 1, 0, 1, '2024-12-13 04:51:57'),
(108, 54, 1, 1, 59, '2024-12-13 09:44:50'),
(109, 58, 1, 1, 59, '2024-12-13 09:46:55'),
(110, 20, 1, 0, 1, '2024-12-13 04:51:57'),
(111, 34, 1, 0, 1, '2024-12-13 04:51:57'),
(112, 57, 1, 1, 97, '2024-12-13 08:16:44'),
(113, 3, 1, 0, 1, '2024-12-13 04:51:57'),
(114, 59, 1, 0, 1, '2024-12-13 04:51:57'),
(115, 61, 1, 0, 1, '2024-12-13 04:51:57'),
(116, 62, 1, 0, 1, '2024-12-13 04:51:57'),
(117, 63, 1, 1, 83, '2024-12-13 06:38:29'),
(118, 64, 1, 0, 1, '2024-12-13 04:51:57'),
(119, 65, 1, 0, 1, '2024-12-13 04:51:57'),
(120, 68, 1, 0, 1, '2024-12-13 04:51:57'),
(121, 70, 1, 0, 1, '2024-12-13 04:51:57'),
(122, 94, 1, 0, 1, '2024-12-13 04:51:57'),
(123, 71, 1, 1, 83, '2024-12-13 09:39:58'),
(124, 72, 1, 1, 83, '2024-12-13 07:44:29'),
(125, 17, 1, 0, 1, '2024-12-13 04:51:57'),
(126, 98, 1, 0, 1, '2024-12-13 04:51:57'),
(127, 5, 1, 0, 1, '2024-12-13 04:51:57'),
(128, 73, 1, 1, 59, '2024-12-13 08:44:11'),
(129, 75, 1, 1, 59, '2024-12-13 09:37:47'),
(130, 89, 1, 1, 83, '2024-12-13 07:46:49'),
(131, 76, 1, 0, 1, '2024-12-13 04:51:57'),
(132, 90, 1, 0, 1, '2024-12-13 04:51:57'),
(133, 6, 1, 0, 1, '2024-12-13 04:51:57'),
(134, 77, 1, 0, 1, '2024-12-13 04:51:57'),
(135, 79, 1, 0, 1, '2024-12-13 04:51:57'),
(136, 80, 1, 1, 59, '2024-12-13 09:43:52'),
(137, 23, 1, 0, 1, '2024-12-13 04:51:57'),
(138, 81, 1, 1, 83, '2024-12-13 08:26:11'),
(139, 83, 1, 0, 1, '2024-12-13 04:51:57'),
(140, 14, 1, 0, 1, '2024-12-13 04:51:57'),
(141, 82, 1, 1, 100, '2024-12-13 08:38:14'),
(142, 85, 1, 1, 101, '2024-12-13 09:47:48'),
(143, 84, 1, 0, 1, '2024-12-13 04:51:57'),
(144, 86, 1, 1, 83, '2024-12-13 04:51:57'),
(145, 88, 1, 0, 1, '2024-12-13 04:51:57'),
(146, 104, 1, 0, 1, '2024-12-13 04:51:57'),
(147, 47, 1, 1, 83, '2024-12-13 08:23:01'),
(148, 16, 1, 0, 1, '2024-12-13 04:51:57'),
(149, 22, 1, 0, 1, '2024-12-13 04:51:57'),
(150, 95, 1, 1, 83, '2024-12-13 08:33:47'),
(151, 36, 1, 1, 70, '2024-12-13 09:52:56'),
(152, 92, 1, 1, 101, '2024-12-13 09:49:48'),
(153, 93, 1, 0, 1, '2024-12-13 04:51:57'),
(154, 7, 1, 0, 1, '2024-12-13 04:51:57'),
(155, 42, 1, 0, 1, '2024-12-13 04:51:57'),
(156, 99, 1, 0, 1, '2024-12-13 04:51:57'),
(157, 96, 1, 0, 1, '2024-12-13 04:51:57'),
(158, 18, 1, 0, 1, '2024-12-13 04:51:57'),
(159, 97, 1, 0, 1, '2024-12-13 04:51:57'),
(160, 69, 1, 0, 1, '2024-12-13 04:51:57'),
(161, 100, 1, 0, 1, '2024-12-13 04:51:57'),
(162, 101, 1, 0, 1, '2024-12-13 04:51:57'),
(163, 10, 1, 0, 1, '2024-12-13 04:51:57'),
(164, 103, 1, 1, 59, '2024-12-13 08:46:19'),
(165, 102, 1, 0, 1, '2024-12-13 04:51:57'),
(166, 15, 1, 0, 1, '2024-12-13 04:51:57'),
(167, 25, 1, 0, 1, '2024-12-13 04:51:57'),
(168, 107, 1, 1, 41, '2024-12-13 09:40:57'),
(169, 55, 1, 1, 105, '2024-12-13 08:24:08'),
(170, 60, 1, 1, 106, '2024-12-13 08:31:15'),
(171, 67, 1, 1, 105, '2024-12-13 08:11:48'),
(172, 78, 1, 1, 43, '2024-12-13 08:40:03'),
(173, 87, 1, 1, 106, '2024-12-13 08:22:06'),
(174, 106, 1, 0, 1, '2024-12-13 04:51:57'),
(175, 43, 1, 1, 106, '2024-12-13 08:30:22'),
(176, 44, 1, 1, 105, '2024-12-13 08:19:25'),
(177, 105, 1, 1, 106, '2024-12-13 08:20:12'),
(178, 11, 1, 0, 1, '2024-12-13 04:51:57'),
(179, 1, 88, 0, 1, '2024-12-13 04:51:57'),
(180, 1, 104, 0, 1, '2024-12-13 04:51:57'),
(181, 1, 47, 1, 83, '2024-12-13 08:23:06'),
(182, 1, 16, 0, 1, '2024-12-13 04:51:57'),
(183, 1, 22, 0, 1, '2024-12-13 04:51:57'),
(184, 1, 95, 1, 83, '2024-12-13 08:33:50'),
(185, 1, 36, 1, 70, '2024-12-13 09:53:00'),
(186, 1, 92, 1, 101, '2024-12-13 09:49:55'),
(187, 1, 93, 0, 1, '2024-12-13 04:51:57'),
(188, 1, 7, 0, 1, '2024-12-13 04:51:57'),
(189, 1, 42, 0, 1, '2024-12-13 04:51:57'),
(190, 1, 99, 0, 1, '2024-12-13 04:51:57'),
(191, 1, 96, 0, 1, '2024-12-13 04:51:57'),
(192, 1, 18, 0, 1, '2024-12-13 04:51:57'),
(193, 1, 97, 0, 1, '2024-12-13 04:51:57'),
(194, 1, 69, 0, 1, '2024-12-13 04:51:57'),
(195, 1, 100, 0, 1, '2024-12-13 04:51:57'),
(196, 1, 101, 0, 1, '2024-12-13 04:51:57'),
(197, 1, 10, 0, 1, '2024-12-13 04:51:57'),
(198, 1, 103, 1, 59, '2024-12-13 08:46:23'),
(199, 1, 102, 0, 1, '2024-12-13 04:51:57'),
(200, 1, 15, 0, 1, '2024-12-13 04:51:57'),
(201, 1, 25, 0, 1, '2024-12-13 04:51:57'),
(202, 1, 107, 1, 41, '2024-12-13 09:41:01'),
(203, 1, 55, 1, 105, '2024-12-13 08:24:11'),
(204, 1, 60, 1, 106, '2024-12-13 08:31:22'),
(205, 1, 67, 1, 105, '2024-12-13 08:11:52'),
(206, 1, 78, 1, 43, '2024-12-13 08:40:06'),
(207, 1, 87, 1, 106, '2024-12-13 08:22:09'),
(208, 1, 106, 0, 1, '2024-12-13 04:51:57'),
(209, 1, 43, 1, 106, '2024-12-13 08:30:26'),
(210, 1, 44, 1, 105, '2024-12-13 08:19:28'),
(211, 1, 105, 1, 106, '2024-12-13 08:20:16'),
(212, 1, 11, 0, 1, '2024-12-13 04:51:57');

--
-- Triggers `layover`
--
DELIMITER $$
CREATE TRIGGER `after_layover_delete` AFTER DELETE ON `layover` FOR EACH ROW BEGIN
    INSERT INTO audit_layover (action_type, layover_id, layover_data) 
    VALUES ('DELETE', OLD.layover_id, JSON_OBJECT('origin_airport_id', OLD.origin_airport_id, 'destination_airport_id', OLD.destination_airport_id, 'layover_status', OLD.layover_status, 'layover_airport_id', OLD.layover_airport_id, 'timestamp', OLD.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_layover_insert` AFTER INSERT ON `layover` FOR EACH ROW BEGIN
    INSERT INTO audit_layover (action_type, layover_id, layover_data) 
    VALUES ('INSERT', NEW.layover_id, JSON_OBJECT('origin_airport_id', NEW.origin_airport_id, 'destination_airport_id', NEW.destination_airport_id, 'layover_status', NEW.layover_status, 'layover_airport_id', NEW.layover_airport_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_layover_update` AFTER UPDATE ON `layover` FOR EACH ROW BEGIN
    INSERT INTO audit_layover (action_type, layover_id, layover_data) 
    VALUES ('UPDATE', NEW.layover_id, JSON_OBJECT('origin_airport_id', NEW.origin_airport_id, 'destination_airport_id', NEW.destination_airport_id, 'layover_status', NEW.layover_status, 'layover_airport_id', NEW.layover_airport_id, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `manage_booking_view`
-- (See below for the actual view)
--
CREATE TABLE `manage_booking_view` (
`booking_id` int(11)
,`passenger_id` int(11)
,`flight_number` varchar(50)
,`reference_number` varchar(100)
,`booking_status` varchar(6)
);

-- --------------------------------------------------------

--
-- Table structure for table `passenger_info`
--

CREATE TABLE `passenger_info` (
  `passenger_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `passport_number` varchar(50) NOT NULL,
  `nationality` varchar(50) NOT NULL,
  `passport_expiry_date` date NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `passenger_info`
--

INSERT INTO `passenger_info` (`passenger_id`, `first_name`, `last_name`, `email`, `phone_number`, `passport_number`, `nationality`, `passport_expiry_date`, `timestamp`) VALUES
(1, 'julian', 'naceda', 'juliannaceda@gmail.com', '09723123732', 'R221G2', 'Filipno', '2029-04-18', '2024-12-23 13:21:41');

--
-- Triggers `passenger_info`
--
DELIMITER $$
CREATE TRIGGER `after_passenger_info_delete` AFTER DELETE ON `passenger_info` FOR EACH ROW BEGIN
    INSERT INTO audit_passenger_info (action_type, passenger_id, passenger_data) 
    VALUES ('DELETE', OLD.passenger_id, JSON_OBJECT('first_name', OLD.first_name, 'last_name', OLD.last_name, 'email', OLD.email, 'phone_number', OLD.phone_number, 'passport_number', OLD.passport_number, 'nationality', OLD.nationality, 'passport_expiry_date', OLD.passport_expiry_date, 'timestamp', OLD.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_passenger_info_insert` AFTER INSERT ON `passenger_info` FOR EACH ROW BEGIN
    INSERT INTO audit_passenger_info (action_type, passenger_id, passenger_data) 
    VALUES ('INSERT', NEW.passenger_id, JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name, 'email', NEW.email, 'phone_number', NEW.phone_number, 'passport_number', NEW.passport_number, 'nationality', NEW.nationality, 'passport_expiry_date', NEW.passport_expiry_date, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_passenger_info_update` AFTER UPDATE ON `passenger_info` FOR EACH ROW BEGIN
    INSERT INTO audit_passenger_info (action_type, passenger_id, passenger_data) 
    VALUES ('UPDATE', NEW.passenger_id, JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name, 'email', NEW.email, 'phone_number', NEW.phone_number, 'passport_number', NEW.passport_number, 'nationality', NEW.nationality, 'passport_expiry_date', NEW.passport_expiry_date, 'timestamp', NEW.timestamp));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `seat_number`
--

CREATE TABLE `seat_number` (
  `seat_id` int(11) NOT NULL,
  `seat_number` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `seat_number`
--

INSERT INTO `seat_number` (`seat_id`, `seat_number`) VALUES
(1, 'A01'),
(2, 'A02'),
(3, 'A03'),
(4, 'B01'),
(5, 'B02'),
(6, 'B03'),
(7, 'C01'),
(8, 'C02'),
(9, 'C03'),
(10, 'E01'),
(11, 'E02'),
(12, 'E03'),
(13, 'F01'),
(14, 'F02'),
(15, 'F03'),
(16, 'A07'),
(17, 'A08'),
(18, 'A09'),
(19, 'A10'),
(20, 'A11'),
(21, 'A12'),
(22, 'A13'),
(23, 'A14'),
(24, 'A15'),
(25, 'A16'),
(26, 'A17'),
(27, 'A18'),
(28, 'A19'),
(29, 'A20'),
(30, 'A21'),
(31, 'A22'),
(32, 'A23'),
(33, 'A24'),
(34, 'A25'),
(35, 'A26'),
(36, 'A27'),
(37, 'A28'),
(38, 'A29'),
(39, 'A30'),
(40, 'A31'),
(41, 'A32'),
(42, 'A33'),
(43, 'A34'),
(44, 'A35'),
(45, 'A36'),
(46, 'A37'),
(47, 'A38');

-- --------------------------------------------------------

--
-- Structure for view `aircraft_view`
--
DROP TABLE IF EXISTS `aircraft_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `aircraft_view`  AS SELECT `aircraft`.`aircraft_number` AS `aircraft_number` FROM `aircraft` ;

-- --------------------------------------------------------

--
-- Structure for view `domestic_airports_view`
--
DROP TABLE IF EXISTS `domestic_airports_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `domestic_airports_view`  AS SELECT `airport`.`airport_id` AS `airport_id`, `airport`.`airport_name` AS `airport_name`, `airport`.`airport_code` AS `airport_code` FROM `airport` WHERE `airport`.`flight_type_id` = 1 ;

-- --------------------------------------------------------

--
-- Structure for view `flight_details_view`
--
DROP TABLE IF EXISTS `flight_details_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `flight_details_view`  AS SELECT `o`.`airport_id` AS `origin_airport_id`, `o`.`airport_code` AS `origin_airport_code`, `o`.`airport_name` AS `origin_airport_name`, `o`.`country` AS `origin_country`, `d`.`airport_id` AS `destination_airport_id`, `d`.`airport_code` AS `destination_airport_code`, `d`.`airport_name` AS `destination_airport_name`, `d`.`country` AS `destination_country`, `fd`.`base_duration` AS `duration`, `fd`.`miles` AS `miles`, `fp`.`base_price` AS `base_price`, `h`.`haul_id` AS `haul_id`, `l`.`layover_status` AS `layover_status`, `l`.`layover_airport_id` AS `layover_airport_id`, `la`.`airport_code` AS `layover_airport_code`, `la`.`airport_name` AS `layover_airport_name`, `la`.`country` AS `layover_country` FROM ((((((`flight_duration` `fd` join `airport` `o` on(`fd`.`origin_airport_id` = `o`.`airport_id`)) join `airport` `d` on(`fd`.`destination_airport_id` = `d`.`airport_id`)) join `flight_pricing` `fp` on(`fd`.`origin_airport_id` = `fp`.`origin_airport_id` and `fd`.`destination_airport_id` = `fp`.`destination_airport_id`)) left join `layover` `l` on(`fd`.`origin_airport_id` = `l`.`origin_airport_id` and `fd`.`destination_airport_id` = `l`.`destination_airport_id`)) left join `airport` `la` on(`l`.`layover_airport_id` = `la`.`airport_id`)) left join `haul` `h` on(`fp`.`haul_id` = `h`.`haul_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `flight_status_view`
--
DROP TABLE IF EXISTS `flight_status_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `flight_status_view`  AS SELECT `flights`.`flight_id` AS `flight_id`, `flights`.`flight_number` AS `flight_number`, `flights`.`origin_airport_id` AS `origin_airport_id`, `flights`.`destination_airport_id` AS `destination_airport_id`, `flights`.`departure_time` AS `departure_time`, `flights`.`arrival_time` AS `arrival_time`, cast(`flights`.`departure_time` as date) AS `flight_date`, CASE WHEN current_timestamp() < `flights`.`departure_time` THEN 'Scheduled' WHEN current_timestamp() between `flights`.`departure_time` and `flights`.`departure_time` + interval 15 minute THEN 'Boarding' WHEN current_timestamp() between `flights`.`departure_time` + interval 15 minute and `flights`.`arrival_time` THEN 'In Route' WHEN current_timestamp() > `flights`.`arrival_time` THEN 'Arrived' ELSE 'Unknown' END AS `status` FROM `flights` ;

-- --------------------------------------------------------

--
-- Structure for view `international_airports_view`
--
DROP TABLE IF EXISTS `international_airports_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `international_airports_view`  AS SELECT `airport`.`airport_id` AS `airport_id`, `airport`.`airport_name` AS `airport_name`, `airport`.`airport_code` AS `airport_code` FROM `airport` WHERE `airport`.`flight_type_id` = 2 ;

-- --------------------------------------------------------

--
-- Structure for view `manage_booking_view`
--
DROP TABLE IF EXISTS `manage_booking_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `manage_booking_view`  AS SELECT `b`.`booking_id` AS `booking_id`, `b`.`passenger_id` AS `passenger_id`, `f`.`flight_number` AS `flight_number`, `f`.`reference_number` AS `reference_number`, 'Active' AS `booking_status` FROM ((`booking` `b` join `flights` `f` on(`b`.`flight_id` = `f`.`flight_id`)) join `passenger_info` `p` on(`b`.`passenger_id` = `p`.`passenger_id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `aircraft`
--
ALTER TABLE `aircraft`
  ADD PRIMARY KEY (`aircraft_id`),
  ADD UNIQUE KEY `aircraft_number` (`aircraft_number`);

--
-- Indexes for table `airport`
--
ALTER TABLE `airport`
  ADD PRIMARY KEY (`airport_id`),
  ADD UNIQUE KEY `airport_code` (`airport_code`),
  ADD KEY `flight_type_id` (`flight_type_id`);

--
-- Indexes for table `audit_aircraft`
--
ALTER TABLE `audit_aircraft`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `audit_airport`
--
ALTER TABLE `audit_airport`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `audit_booking`
--
ALTER TABLE `audit_booking`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `audit_flights`
--
ALTER TABLE `audit_flights`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `audit_flight_duration`
--
ALTER TABLE `audit_flight_duration`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `audit_flight_pricing`
--
ALTER TABLE `audit_flight_pricing`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `audit_layover`
--
ALTER TABLE `audit_layover`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `audit_passenger_info`
--
ALTER TABLE `audit_passenger_info`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `backup_log`
--
ALTER TABLE `backup_log`
  ADD PRIMARY KEY (`backup_id`);

--
-- Indexes for table `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `passenger_id` (`passenger_id`),
  ADD KEY `flight_id` (`flight_id`);

--
-- Indexes for table `class`
--
ALTER TABLE `class`
  ADD PRIMARY KEY (`class_id`);

--
-- Indexes for table `flights`
--
ALTER TABLE `flights`
  ADD PRIMARY KEY (`flight_id`),
  ADD UNIQUE KEY `seat_id` (`seat_id`),
  ADD UNIQUE KEY `reference_number` (`reference_number`),
  ADD KEY `origin_airport_id` (`origin_airport_id`),
  ADD KEY `destination_airport_id` (`destination_airport_id`),
  ADD KEY `class_id` (`class_id`),
  ADD KEY `aircraft_id` (`aircraft_id`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `flights_ibfk_3` (`layover_id`);

--
-- Indexes for table `flight_duration`
--
ALTER TABLE `flight_duration`
  ADD PRIMARY KEY (`duration_id`),
  ADD KEY `origin_airport_id` (`origin_airport_id`),
  ADD KEY `destination_airport_id` (`destination_airport_id`);

--
-- Indexes for table `flight_number`
--
ALTER TABLE `flight_number`
  ADD PRIMARY KEY (`flight_number_id`);

--
-- Indexes for table `flight_pricing`
--
ALTER TABLE `flight_pricing`
  ADD PRIMARY KEY (`pricing_id`),
  ADD KEY `origin_airport_id` (`origin_airport_id`),
  ADD KEY `destination_airport_id` (`destination_airport_id`),
  ADD KEY `fk_haul` (`haul_id`);

--
-- Indexes for table `flight_schedule`
--
ALTER TABLE `flight_schedule`
  ADD PRIMARY KEY (`schedule_id`);

--
-- Indexes for table `flight_type`
--
ALTER TABLE `flight_type`
  ADD PRIMARY KEY (`type_id`);

--
-- Indexes for table `haul`
--
ALTER TABLE `haul`
  ADD PRIMARY KEY (`haul_id`);

--
-- Indexes for table `layover`
--
ALTER TABLE `layover`
  ADD PRIMARY KEY (`layover_id`),
  ADD UNIQUE KEY `origin_airport_id` (`origin_airport_id`,`destination_airport_id`,`layover_airport_id`),
  ADD KEY `destination_airport_id` (`destination_airport_id`),
  ADD KEY `layover_airport_id` (`layover_airport_id`);

--
-- Indexes for table `passenger_info`
--
ALTER TABLE `passenger_info`
  ADD PRIMARY KEY (`passenger_id`),
  ADD UNIQUE KEY `passport_number` (`passport_number`);

--
-- Indexes for table `seat_number`
--
ALTER TABLE `seat_number`
  ADD PRIMARY KEY (`seat_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `aircraft`
--
ALTER TABLE `aircraft`
  MODIFY `aircraft_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `airport`
--
ALTER TABLE `airport`
  MODIFY `airport_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=108;

--
-- AUTO_INCREMENT for table `audit_aircraft`
--
ALTER TABLE `audit_aircraft`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `audit_airport`
--
ALTER TABLE `audit_airport`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `audit_booking`
--
ALTER TABLE `audit_booking`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `audit_flights`
--
ALTER TABLE `audit_flights`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `audit_flight_duration`
--
ALTER TABLE `audit_flight_duration`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=637;

--
-- AUTO_INCREMENT for table `audit_flight_pricing`
--
ALTER TABLE `audit_flight_pricing`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_layover`
--
ALTER TABLE `audit_layover`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=174;

--
-- AUTO_INCREMENT for table `audit_passenger_info`
--
ALTER TABLE `audit_passenger_info`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `backup_log`
--
ALTER TABLE `backup_log`
  MODIFY `backup_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `booking`
--
ALTER TABLE `booking`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `class`
--
ALTER TABLE `class`
  MODIFY `class_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `flights`
--
ALTER TABLE `flights`
  MODIFY `flight_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `flight_duration`
--
ALTER TABLE `flight_duration`
  MODIFY `duration_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=213;

--
-- AUTO_INCREMENT for table `flight_number`
--
ALTER TABLE `flight_number`
  MODIFY `flight_number_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=150;

--
-- AUTO_INCREMENT for table `flight_pricing`
--
ALTER TABLE `flight_pricing`
  MODIFY `pricing_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=214;

--
-- AUTO_INCREMENT for table `flight_schedule`
--
ALTER TABLE `flight_schedule`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT for table `flight_type`
--
ALTER TABLE `flight_type`
  MODIFY `type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `haul`
--
ALTER TABLE `haul`
  MODIFY `haul_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `layover`
--
ALTER TABLE `layover`
  MODIFY `layover_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=214;

--
-- AUTO_INCREMENT for table `passenger_info`
--
ALTER TABLE `passenger_info`
  MODIFY `passenger_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `seat_number`
--
ALTER TABLE `seat_number`
  MODIFY `seat_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `airport`
--
ALTER TABLE `airport`
  ADD CONSTRAINT `airport_ibfk_1` FOREIGN KEY (`flight_type_id`) REFERENCES `flight_type` (`type_id`);

--
-- Constraints for table `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`passenger_id`) REFERENCES `passenger_info` (`passenger_id`),
  ADD CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`flight_id`) REFERENCES `flights` (`flight_id`);

--
-- Constraints for table `flights`
--
ALTER TABLE `flights`
  ADD CONSTRAINT `flights_ibfk_1` FOREIGN KEY (`origin_airport_id`) REFERENCES `airport` (`airport_id`),
  ADD CONSTRAINT `flights_ibfk_2` FOREIGN KEY (`destination_airport_id`) REFERENCES `airport` (`airport_id`),
  ADD CONSTRAINT `flights_ibfk_3` FOREIGN KEY (`layover_id`) REFERENCES `layover` (`layover_id`),
  ADD CONSTRAINT `flights_ibfk_4` FOREIGN KEY (`class_id`) REFERENCES `class` (`class_id`),
  ADD CONSTRAINT `flights_ibfk_5` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`aircraft_id`),
  ADD CONSTRAINT `flights_ibfk_6` FOREIGN KEY (`type_id`) REFERENCES `flight_type` (`type_id`),
  ADD CONSTRAINT `flights_ibfk_7` FOREIGN KEY (`seat_id`) REFERENCES `seat_number` (`seat_id`);

--
-- Constraints for table `flight_duration`
--
ALTER TABLE `flight_duration`
  ADD CONSTRAINT `flight_duration_ibfk_1` FOREIGN KEY (`origin_airport_id`) REFERENCES `airport` (`airport_id`),
  ADD CONSTRAINT `flight_duration_ibfk_2` FOREIGN KEY (`destination_airport_id`) REFERENCES `airport` (`airport_id`);

--
-- Constraints for table `flight_pricing`
--
ALTER TABLE `flight_pricing`
  ADD CONSTRAINT `fk_haul` FOREIGN KEY (`haul_id`) REFERENCES `haul` (`haul_id`),
  ADD CONSTRAINT `flight_pricing_ibfk_1` FOREIGN KEY (`origin_airport_id`) REFERENCES `airport` (`airport_id`),
  ADD CONSTRAINT `flight_pricing_ibfk_2` FOREIGN KEY (`destination_airport_id`) REFERENCES `airport` (`airport_id`);

--
-- Constraints for table `layover`
--
ALTER TABLE `layover`
  ADD CONSTRAINT `layover_ibfk_2` FOREIGN KEY (`origin_airport_id`) REFERENCES `airport` (`airport_id`),
  ADD CONSTRAINT `layover_ibfk_3` FOREIGN KEY (`destination_airport_id`) REFERENCES `airport` (`airport_id`),
  ADD CONSTRAINT `layover_ibfk_4` FOREIGN KEY (`layover_airport_id`) REFERENCES `airport` (`airport_id`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `update_flight_status_event` ON SCHEDULE EVERY 1 MINUTE STARTS '2024-12-16 08:31:55' ON COMPLETION NOT PRESERVE ENABLE DO CALL update_flight_status()$$

CREATE DEFINER=`root`@`localhost` EVENT `ClearAuditTablesEvent` ON SCHEDULE EVERY 1 DAY STARTS '2024-12-16 10:00:29' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    CALL ClearOldAuditRows('audit_aircraft');
    CALL ClearOldAuditRows('audit_airport');
    CALL ClearOldAuditRows('audit_booking');
    CALL ClearOldAuditRows('audit_flights');
    CALL ClearOldAuditRows('audit_flight_duration');
    CALL ClearOldAuditRows('audit_flight_pricing');
    CALL ClearOldAuditRows('audit_layover');
    CALL ClearOldAuditRows('audit_passenger_info');
END$$

CREATE DEFINER=`root`@`localhost` EVENT `incremental_backup_event` ON SCHEDULE EVERY 1 DAY STARTS '2024-12-23 22:59:19' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    -- Current backup timestamp
    SET @current_time = NOW();
    
    -- Backup new rows from the booking table
    SET @last_booking_backup = (SELECT MAX(last_backup_time) FROM backup_log WHERE table_name = 'booking');
    IF @last_booking_backup IS NULL THEN SET @last_booking_backup = '1970-01-01 00:00:00'; END IF;
    SET @backup_booking = CONCAT(
        'CREATE TABLE booking_backup_', 
        DATE_FORMAT(@current_time, '%Y%m%d%H%i%s'), 
        ' AS SELECT * FROM booking WHERE timestamp > ''', @last_booking_backup, ''';'
    );
    PREPARE stmt1 FROM @backup_booking;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;
    INSERT INTO backup_log (table_name, last_backup_time) VALUES ('booking', @current_time)
    ON DUPLICATE KEY UPDATE last_backup_time = @current_time;

    -- Repeat for flights table
    SET @last_flights_backup = (SELECT MAX(last_backup_time) FROM backup_log WHERE table_name = 'flights');
    IF @last_flights_backup IS NULL THEN SET @last_flights_backup = '1970-01-01 00:00:00'; END IF;
    SET @backup_flights = CONCAT(
        'CREATE TABLE flights_backup_', 
        DATE_FORMAT(@current_time, '%Y%m%d%H%i%s'), 
        ' AS SELECT * FROM flights WHERE timestamp > ''', @last_flights_backup, ''';'
    );
    PREPARE stmt2 FROM @backup_flights;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
    INSERT INTO backup_log (table_name, last_backup_time) VALUES ('flights', @current_time)
    ON DUPLICATE KEY UPDATE last_backup_time = @current_time;

    -- Repeat for passenger_info table
    SET @last_passenger_info_backup = (SELECT MAX(last_backup_time) FROM backup_log WHERE table_name = 'passenger_info');
    IF @last_passenger_info_backup IS NULL THEN SET @last_passenger_info_backup = '1970-01-01 00:00:00'; END IF;
    SET @backup_passenger_info = CONCAT(
        'CREATE TABLE passenger_info_backup_', 
        DATE_FORMAT(@current_time, '%Y%m%d%H%i%s'), 
        ' AS SELECT * FROM passenger_info WHERE timestamp > ''', @last_passenger_info_backup, ''';'
    );
    PREPARE stmt3 FROM @backup_passenger_info;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;
    INSERT INTO backup_log (table_name, last_backup_time) VALUES ('passenger_info', @current_time)
    ON DUPLICATE KEY UPDATE last_backup_time = @current_time;
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
