-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3307
-- Tiempo de generación: 06-06-2024 a las 04:09:56
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `libreria_comercial`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualiza_credito` ()   BEGIN
    -- Actualizar el estado de pago a 'VENCIDA' para facturas que estén pendientes y con más de 30 días de antigüedad
    UPDATE cartera
    SET estado_pago = 'VENCIDA'
    WHERE fecha_venta < CURDATE() - INTERVAL 30 DAY
      AND estado_pago = 'PENDIENTE';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualiza_estado` ()   BEGIN
    UPDATE cartera
    SET estado_pago = 'S'
    WHERE saldo <= 0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualiza_netocartera` ()   BEGIN
    UPDATE cartera t1
    JOIN ventas t2 ON t1.cod_ventas = t2.cod_ventas
    SET t1.neto = t2.valor_venta - t2.valor_compra
    WHERE t2.estado_pago = 'pendiente';  -- Asume que 'pendiente' es un estado válido
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_salario_mayor` ()   BEGIN
    DECLARE var_codemp INT;
    DECLARE var_nombre VARCHAR(25);
    DECLARE var_apellido VARCHAR(25);
    DECLARE var_netop DECIMAL(10,0);
    DECLARE mayor DECIMAL(10,0);
    DECLARE total INT;
    DECLARE i INT;
    DECLARE resultado VARCHAR(100);

    -- Sección de creación de cursor para consulta Select INNER JOIN
    DECLARE c1 CURSOR FOR 
        SELECT t1.vendedor_cod, t2.nombre1, t2.apellido1, t1.neto_pagar
        FROM nomina_vendedores t1 
        INNER JOIN vendedor t2 ON t1.vendedor_cod = t2.cod_vendedor;

    SET mayor = 0;
    SET i = 1;
    SET total = 0;

    -- Conteo de registros en tabla nomina
    SELECT COUNT(*) INTO total FROM nomina_vendedores;

    -- Apertura cursor
    OPEN c1;

    WHILE i <= total DO   -- Ciclo para realizar recorrido de toda la consulta
        -- Variables deben estar en mismo orden de la consulta select en Declare cursor
        FETCH c1 INTO var_codemp, var_nombre, var_apellido, var_netop;
        
        IF var_netop > mayor THEN
            SET resultado = CONCAT(var_codemp, ' ', var_nombre, ' ', var_apellido, ' ', var_netop);
            SET mayor = var_netop; -- Asignar nuevo salario mayor encontrado
        END IF;
        
        SET i = i + 1; -- Contador
    END WHILE;

    CLOSE c1;

    SELECT resultado AS empleado_con_salario_mayor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CalcularTotalLibrosPorCliente` ()   BEGIN
    SELECT 
        t1.nombre1,
        COUNT(t3.libro_cod) AS total_libros_comprados
    FROM 
        cliente t1
    LEFT JOIN 
        ventas t2 ON t1.cod_cliente = t2.cliente_cod
    LEFT JOIN 
        detalle_ventas t3 ON t2.cod_ventas = t3.ventas_cod
    GROUP BY 
        t1.nombre1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consulta_ciudad` (IN `ciudad` VARCHAR(50))   BEGIN
    SELECT * FROM vendedor
    WHERE ciudad = ciudad;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consulta_editorial_por_tipo_documento` (IN `tipo_documento` VARCHAR(50))   BEGIN
    SELECT * FROM editorial WHERE tipo_documento = tipo_documento;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consulta_ventaciudad` (IN `dato` VARCHAR(50))   BEGIN
    SELECT * FROM cliente
    WHERE ciudad = dato; -- Corregido el nombre del parámetro y la comparación
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `editoriales_rut` (IN `rut` VARCHAR(50))   BEGIN
    IF rut IS NULL THEN
        SELECT * FROM editorial;
    ELSE
        SELECT * FROM editorial WHERE rut = rut;
    END IF;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `promedad` () RETURNS INT(11)  BEGIN
DECLARE suma int;
DECLARE total int;
DECLARE edadp int;
DECLARE i int;
-- seccion de claracion de nombre de cursor
DECLARE c1 CURSOR FOR SELECT edad FROM cliente;
-- seccion de asignacion de valores a variables
SET suma=0;  -- acumulador de edades
SET i=1; -- contador ciclo while
SET total=0; -- contador de cantidad de clientes en tabla
SELECT COUNT(*) INTO total FROM cliente; -- cantidad de clientes que tiene la tabla
-- apertura del cursor
OPEN c1;
-- seccion de ciclo while
WHILE i<= total DO
 FETCH c1 INTO edadp; -- revisa cada fila de la consulta  de conteo de registro
  SET suma= suma+edadp; -- totalizador de edad
  SET i=i+1; -- contador de edades
  END WHILE;
  -- cierre de cursor
CLOSE c1;
RETURN suma/total; -- para generar promedio de edad
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cartera`
--

CREATE TABLE `cartera` (
  `id` int(11) NOT NULL,
  `cliente_cod` int(11) DEFAULT NULL,
  `codigo_factura` varchar(255) DEFAULT NULL,
  `cod_ventas` int(11) DEFAULT NULL,
  `estado_pago` enum('pendiente','pagado') DEFAULT NULL,
  `fecha_venta` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cartera`
--

INSERT INTO `cartera` (`id`, `cliente_cod`, `codigo_factura`, `cod_ventas`, `estado_pago`, `fecha_venta`) VALUES
(1, 3, 'FAC003', 3, '', '2024-04-03'),
(2, 4, 'FAC004', 4, '', '2024-04-04'),
(3, 6, 'FAC006', 6, '', '2024-04-06'),
(4, 8, 'FAC008', 8, '', '2024-04-08'),
(5, 9, 'FAC009', 9, '', '2024-04-09'),
(6, 11, 'FAC011', 11, '', '2024-04-11'),
(7, 14, 'FAC014', 14, '', '2024-04-14'),
(8, 16, 'FAC016', 16, '', '2024-04-16'),
(9, 18, 'FAC018', 18, '', '2024-04-18'),
(10, 21, 'FAC021', 21, '', '2024-04-21'),
(11, 23, 'FAC023', 23, '', '2024-04-23'),
(12, 26, 'FAC026', 26, '', '2024-04-26'),
(13, 27, 'FAC027', 27, '', '2024-04-27'),
(14, 29, 'FAC029', 29, '', '2024-04-29'),
(16, 1, 'FACT-001', 123, 'pendiente', '2024-05-10');

--
-- Disparadores `cartera`
--
DELIMITER $$
CREATE TRIGGER `validar_estado_pago` BEFORE INSERT ON `cartera` FOR EACH ROW BEGIN
    IF NEW.estado_pago NOT IN ('PAGADA', 'PENDIENTE') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El estado de pago debe ser PAGADA o PENDIENTE';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `cod_cliente` int(11) NOT NULL,
  `nombre1` varchar(25) NOT NULL,
  `nombre2` varchar(25) NOT NULL,
  `apellido1` varchar(25) NOT NULL,
  `apellido2` varchar(25) NOT NULL,
  `tipo_documento` enum('cc','ce','nit','rut','ppt') DEFAULT NULL,
  `sexo` enum('femenino','masculino') DEFAULT NULL,
  `direccion` varchar(50) NOT NULL,
  `ciudad` varchar(20) NOT NULL,
  `edad` int(11) NOT NULL CHECK (`edad` >= 18),
  `telefono` varchar(25) NOT NULL,
  `no_documento` varchar(25) NOT NULL,
  `vendedor_cod` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`cod_cliente`, `nombre1`, `nombre2`, `apellido1`, `apellido2`, `tipo_documento`, `sexo`, `direccion`, `ciudad`, `edad`, `telefono`, `no_documento`, `vendedor_cod`) VALUES
(1, 'Juan', 'Pablo', 'González', 'López', 'cc', 'masculino', 'Cra 24 # 15-30', 'Bogotá', 25, '1234567890', '123456789', 1),
(2, 'María', 'Alejandra', 'Martínez', 'Hernández', 'ce', 'femenino', 'Av 24 # 15-30', 'Medellín', 30, '0987654321', '987654321', 2),
(3, 'Carlos', 'Andrés', 'Londoño', 'Pérez', 'nit', 'masculino', 'Diago 24 # 15-30', 'Cali', 40, '5678901234', '567890123', 3),
(4, 'Laura', 'Fernanda', 'Rodríguez', 'García', 'cc', 'femenino', 'Cra 24 # 15-30', 'Barranquilla', 22, '3456789012', '345678901', 4),
(5, 'Javier', 'Santiago', 'Gómez', 'Ramírez', 'ce', 'masculino', 'Av 24 # 15-30', 'Cartagena', 35, '2345678901', '234567890', 5),
(6, 'Ana', 'María', 'Sánchez', 'López', 'nit', 'femenino', 'Diago 24 # 15-30', 'Bogotá', 28, '6789012345', '678901234', 6),
(7, 'Pedro', 'José', 'Hernández', 'González', 'cc', 'masculino', 'Cra 24 # 15-30', 'Medellín', 33, '4567890123', '456789012', 7),
(8, 'Sofía', 'Isabel', 'López', 'Martínez', 'ce', 'femenino', 'Av 24 # 15-30', 'Cali', 45, '7890123456', '789012345', 8),
(9, 'David', 'Felipe', 'Pérez', 'Sánchez', 'nit', 'masculino', 'Diago 24 # 15-30', 'Barranquilla', 20, '5678901234', '567890123', 9),
(10, 'Camila', 'Juliana', 'Ramírez', 'Gómez', 'cc', 'femenino', 'Cra 24 # 15-30', 'Cartagena', 27, '3456789012', '345678901', 10),
(11, 'Luis', 'Fernando', 'García', 'Hernández', 'ce', 'masculino', 'Av 24 # 15-30', 'Bogotá', 38, '2345678901', '234567890', 11),
(12, 'Andrea', 'Valentina', 'Martínez', 'Sánchez', 'nit', 'femenino', 'Diago 24 # 15-30', 'Medellín', 24, '6789012345', '678901234', 12),
(13, 'José', 'Daniel', 'López', 'Hernández', 'cc', 'masculino', 'Cra 24 # 15-30', 'Cali', 29, '4567890123', '456789012', 13),
(14, 'Marcela', 'Victoria', 'Gómez', 'Pérez', 'ce', 'femenino', 'Av 24 # 15-30', 'Barranquilla', 32, '7890123456', '789012345', 14),
(15, 'Gabriel', 'Andrés', 'Ramírez', 'Martínez', 'nit', 'masculino', 'Diago 24 # 15-30', 'Cartagena', 26, '5678901234', '567890123', 15),
(16, 'Valeria', 'Isabella', 'Sánchez', 'Gómez', 'cc', 'femenino', 'Cra 24 # 15-30', 'Bogotá', 31, '3456789012', '345678901', 16),
(17, 'Daniel', 'Alejandro', 'Hernández', 'López', 'ce', 'masculino', 'Av 24 # 15-30', 'Medellín', 34, '2345678901', '234567890', 17),
(18, 'Paula', 'Andrea', 'Martínez', 'Ramírez', 'nit', 'femenino', 'Diago 24 # 15-30', 'Cali', 23, '6789012345', '678901234', 18),
(19, 'Mario', 'Javier', 'López', 'Sánchez', 'cc', 'masculino', 'Cra 24 # 15-30', 'Barranquilla', 36, '4567890123', '456789012', 19),
(20, 'Carolina', 'María', 'Gómez', 'Martínez', 'ce', 'femenino', 'Av 24 # 15-30', 'Cartagena', 21, '7890123456', '789012345', 20),
(21, 'Andrés', 'Felipe', 'Ramírez', 'Gómez', 'nit', 'masculino', 'Diago 24 # 15-30', 'Bogotá', 37, '5678901234', '567890123', 21),
(22, 'Diana', 'Marcela', 'Sánchez', 'Hernández', 'cc', 'femenino', 'Cra 24 # 15-30', 'Medellín', 29, '3456789012', '345678901', 22),
(23, 'Fernando', 'José', 'Martínez', 'Ramírez', 'ce', 'masculino', 'Av 24 # 15-30', 'Cali', 40, '2345678901', '234567890', 23),
(24, 'Camilo', 'Andrés', 'López', 'Sánchez', 'nit', 'masculino', 'Diago 24 # 15-30', 'Barranquilla', 27, '6789012345', '678901234', 24),
(25, 'Natalia', 'Isabel', 'Gómez', 'Martínez', 'cc', 'femenino', 'Cra 24 # 15-30', 'Cartagena', 31, '4567890123', '456789012', 5),
(26, 'Santiago', 'Alejandro', 'Ramírez', 'Gómez', 'ce', 'masculino', 'Av 24 # 15-30', 'Bogotá', 35, '7890123456', '789012345', 6),
(27, 'Valentina', 'María', 'Sánchez', 'Martínez', 'nit', 'femenino', 'Diago 24 # 15-30', 'Medellín', 28, '5678901234', '567890123', 7),
(28, 'Mateo', 'Andrés', 'Martínez', 'Gómez', 'cc', 'masculino', 'Cra 24 # 15-30', 'Cali', 33, '3456789012', '345678901', 8),
(29, 'Laura', 'Fernanda', 'Hernández', 'García', 'ce', 'femenino', 'Av 24 # 15-30', 'Barranquilla', 26, '2345678901', '234567890', 2),
(30, 'Carlos', 'Andrés', 'Ramírez', 'Pérez', 'nit', 'masculino', 'Diago 24 # 15-30', 'Cartagena', 30, '6789012345', '678901234', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_ventas`
--

CREATE TABLE `detalle_ventas` (
  `cod_detallev` int(11) NOT NULL,
  `libro_cod` int(11) NOT NULL,
  `ventas_cod` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `valor_venta` decimal(10,0) NOT NULL DEFAULT 0,
  `subtotal` decimal(10,0) GENERATED ALWAYS AS (`valor_venta` * `cantidad`) VIRTUAL,
  `descuento` decimal(10,2) NOT NULL DEFAULT 0.00,
  `neto` decimal(10,0) GENERATED ALWAYS AS (`subtotal` * (1 - `descuento`)) VIRTUAL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalle_ventas`
--

INSERT INTO `detalle_ventas` (`cod_detallev`, `libro_cod`, `ventas_cod`, `cantidad`, `valor_venta`, `descuento`) VALUES
(31, 41, 1, 2, 20000, 4000.00),
(32, 42, 1, 1, 25000, 2500.00),
(33, 43, 2, 3, 18000, 5400.00),
(34, 44, 2, 1, 26000, 2600.00),
(35, 45, 3, 2, 15000, 0.10),
(36, 46, 3, 1, 22000, 0.05),
(37, 47, 4, 1, 16000, 0.20),
(38, 48, 4, 3, 24000, 0.10),
(39, 49, 5, 2, 19000, 3800.00),
(40, 50, 5, 1, 27000, 2700.00),
(41, 51, 6, 2, 17000, 0.10),
(42, 52, 6, 3, 25000, 0.05),
(43, 53, 7, 1, 20000, 2000.00),
(44, 54, 7, 2, 28000, 5600.00),
(45, 55, 8, 1, 21000, 0.10),
(46, 56, 8, 3, 29000, 0.15),
(47, 57, 9, 2, 22000, 0.20),
(48, 58, 9, 1, 30000, 0.10),
(49, 59, 10, 3, 23000, 6900.00),
(50, 60, 10, 2, 31000, 6200.00),
(51, 61, 11, 1, 24000, 0.15),
(52, 62, 11, 3, 32000, 0.20),
(53, 63, 12, 2, 25000, 5000.00),
(54, 64, 12, 1, 33000, 3300.00),
(55, 65, 13, 3, 26000, 7800.00),
(56, 66, 13, 2, 34000, 6800.00),
(57, 60, 14, 1, 27000, 0.20),
(58, 43, 14, 3, 35000, 0.10),
(59, 42, 15, 2, 28000, 5600.00),
(60, 41, 15, 1, 36000, 3600.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `editorial`
--

CREATE TABLE `editorial` (
  `cod_editoral` int(11) NOT NULL,
  `nombre_editorial` varchar(50) NOT NULL,
  `tipo_documento` enum('NIT','RUT') DEFAULT NULL,
  `direcccion` varchar(50) NOT NULL,
  `cuidad` varchar(25) NOT NULL,
  `telefono` varchar(25) NOT NULL,
  `pagina_web` varchar(255) DEFAULT NULL,
  `pais` varchar(50) NOT NULL,
  `e_mail` varchar(50) NOT NULL,
  `asesor_comercial` varchar(50) NOT NULL,
  `telefono_asesor` varchar(25) NOT NULL,
  `e_mail_asesor` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `editorial`
--

INSERT INTO `editorial` (`cod_editoral`, `nombre_editorial`, `tipo_documento`, `direcccion`, `cuidad`, `telefono`, `pagina_web`, `pais`, `e_mail`, `asesor_comercial`, `telefono_asesor`, `e_mail_asesor`) VALUES
(1, 'Editorial Uno', 'NIT', 'Calle Principal 123', 'Ciudad de México', '123456789', 'www.editorialuno.com', 'México', 'info@editorialuno.com', 'Juan Pérez', '987654321', 'juanperez@editorialuno.com'),
(2, 'Editorial Dos', 'RUT', 'Avenida Principal 456', 'Nueva York', '987654321', 'www.editorialdos.com', 'Estados Unidos', 'info@editorialdos.com', 'María Gómez', '123456789', 'mariagomez@editorialdos.com'),
(3, 'Editorial Tres', 'NIT', 'Carrera Principal 789', 'Londres', '456789123', 'www.editorialtres.com', 'Reino Unido', 'info@editorialtres.com', 'Carlos López', '789123456', 'carloslopez@editorialtres.com'),
(4, 'Editorial Cuatro', 'NIT', 'Calle Secundaria 123', 'Tokio', '789123456', 'www.editorialcuatro.com', 'Japón', 'info@editorialcuatro.com', 'Laura Martínez', '456789123', 'lauramartinez@editorialcuatro.com'),
(5, 'Editorial Cinco', 'RUT', 'Avenida Secundaria 456', 'París', '654321987', 'www.editorialcinco.com', 'Francia', 'info@editorialcinco.com', 'Pedro Ramírez', '321987654', 'pedroramirez@editorialcinco.com'),
(6, 'Editorial Seis', 'NIT', 'Carrera Secundaria 789', 'Los Ángeles', '321987654', 'www.editorialseis.com', 'Estados Unidos', 'info@editorialseis.com', 'Ana Silva', '654321987', 'anasilva@editorialseis.com'),
(7, 'Editorial Siete', 'RUT', 'Calle Terciaria 123', 'Madrid', '159357852', 'www.editorialsiete.com', 'España', 'info@editorialsiete.com', 'David González', '852963741', 'davidgonzalez@editorialsiete.com'),
(8, 'Editorial Ocho', 'NIT', 'Avenida Terciaria 456', 'Buenos Aires', '357951456', 'www.editorialocho.com', 'Argentina', 'info@editorialocho.com', 'Sofía Torres', '369852147', 'sofiatorres@editorialocho.com'),
(9, 'Editorial Nueve', 'RUT', 'Carrera Terciaria 789', 'Río de Janeiro', '753951486', 'www.editorialnueve.com', 'Brasil', 'info@editorialnueve.com', 'Laura Martínez', '951753852', 'lauramartinez@editorialnueve.com'),
(10, 'Editorial Diez', 'NIT', 'Calle Cuarta 123', 'Roma', '123654987', 'www.editorialdiez.com', 'Italia', 'info@editorialdiez.com', 'José López', '369852147', 'joselopez@editorialdiez.com'),
(11, 'Editorial Once', 'RUT', 'Avenida Quinta 456', 'Toronto', '987654123', 'www.editorialonce.com', 'Canadá', 'info@editorialonce.com', 'María García', '852963741', 'mariagarcia@editorialonce.com'),
(12, 'Editorial Doce', 'NIT', 'Carrera Sexta 789', 'Sídney', '654321789', 'www.editorialdoce.com', 'Australia', 'info@editorialdoce.com', 'David Martínez', '123654789', 'davidmartinez@editorialdoce.com'),
(13, 'Editorial Trece', 'RUT', 'Calle Séptima 123', 'Berlín', '147258369', 'www.editorialtrece.com', 'Alemania', 'info@editorialtrece.com', 'Sofía García', '789456123', 'sofiagarcia@editorialtrece.com'),
(14, 'Editorial Catorce', 'NIT', 'Avenida Octava 456', 'Pekín', '258369147', 'www.editorialcatorce.com', 'China', 'info@editorialcatorce.com', 'Andrés López', '987321654', 'andreslopez@editorialcatorce.com'),
(15, 'Editorial Quince', 'RUT', 'Carrera Novena 789', 'Moscú', '369852147', 'www.editorialquince.com', 'Rusia', 'info@editorialquince.com', 'María García', '654789321', 'mariagarcia@editorialquince.com'),
(16, 'Editorial Dieciséis', 'NIT', 'Calle Décima 123', 'Estambul', '741852963', 'www.editorialdieciseis.com', 'Turquía', 'info@editorialdieciseis.com', 'David Martínez', '963852741', 'davidmartinez@editorialdieciseis.com'),
(17, 'Editorial Diecisiete', 'RUT', 'Avenida Once 456', 'Bangkok', '852963741', 'www.editorialdiecisiete.com', 'Tailandia', 'info@editorialdiecisiete.com', 'Sofía García', '369852147', 'sofiagarcia@editorialdiecisiete.com'),
(18, 'Editorial Dieciocho', 'NIT', 'Carrera Doce 789', 'El Cairo', '963741852', 'www.editorialdieciocho.com', 'Egipto', 'info@editorialdieciocho.com', 'David Martínez', '852963741', 'davidmartinez@editorialdieciocho.com'),
(19, 'Editorial Diecinueve', 'RUT', 'Calle Trece 123', 'Ciudad del Cabo', '741963852', 'www.editorialdiecinueve.com', 'Sudáfrica', 'info@editorialdiecinueve.com', 'Sofía García', '369852147', 'sofiagarcia@editorialdiecinueve.com'),
(20, 'Editorial Veinte', 'NIT', 'Avenida Catorce 456', 'Dubái', '852741963', 'www.editorialveinte.com', 'Emiratos Árabes Unidos', 'info@editorialveinte.com', 'David Martínez', '963852741', 'davidmartinez@editorial.com'),
(21, 'Editorial Veintiuno', 'RUT', 'Calle Quince 123', 'Mumbai', '369741852', 'www.editorialveintiuno.com', 'India', 'info@editorialveintiuno.com', 'Sofía García', '852963741', 'sofiagarcia@editorialveintiuno.com'),
(22, 'Editorial Veintidós', 'NIT', 'Avenida Dieciséis 456', 'Seúl', '741852963', 'www.editorialveintidos.com', 'Corea del Sur', 'info@editorialveintidos.com', 'David Martínez', '963741852', 'davidmartinez@editorialveintidos.com'),
(23, 'Editorial Veintitrés', 'RUT', 'Carrera Diecisiete 789', 'Ciudad de Singapur', '852963741', 'www.editorialveintitres.com', 'Singapur', 'info@editorialveintitres.com', 'María García', '369741852', 'mariagarcia@editorialveintitres.com'),
(24, 'Editorial Veinticuatro', 'NIT', 'Calle Dieciocho 123', 'Ámsterdam', '963741852', 'www.editorialveinticuatro.com', 'Países Bajos', 'info@editorialveinticuatro.com', 'David Martínez', '852963741', 'davidmartinez@editorialveinticuatro.com'),
(25, 'Editorial Veinticinco', 'RUT', 'Avenida Diecinueve 456', 'Buenos Aires', '852963741', 'www.editorialveinticinco.com', 'Argentina', 'info@editorialveinticinco.com', 'Sofía García', '369741852', 'sofiagarcia@editorialveinticinco.com'),
(26, 'Editorial Veintiséis', 'NIT', 'Carrera Veinte 789', 'Lima', '963741852', 'www.editorialveintiseis.com', 'Perú', 'info@editorialveintiseis.com', 'David Martínez', '852963741', 'davidmartinez@editorialveintiseis.com'),
(27, 'Editorial Veintisiete', 'RUT', 'Calle Veintiuno 123', 'Oslo', '741852963', 'www.editorialveintisiete.com', 'Noruega', 'info@editorialveintisiete.com', 'María García', '369741852', 'mariagarcia@editorialveintisiete.com'),
(28, 'Editorial Veintiocho', 'NIT', 'Avenida Veintidós 456', 'Helsinki', '852963741', 'www.editorialveintiocho.com', 'Finlandia', 'info@editorialveintiocho.com', 'David Martínez', '963741852', 'davidmartinez@editorialveintiocho.com'),
(29, 'Editorial Veintinueve', 'RUT', 'Carrera Veintitrés 789', 'Estocolmo', '741852963', 'www.editorialveintinueve.com', 'Suecia', 'info@editorialveintinueve.com', 'Sofía García', '369741852', 'sofiagarcia@editorialveintinueve.com'),
(30, 'Editorial Treinta', 'NIT', 'Calle Veinticuatro 123', 'Varsovia', '963741852', 'www.editorialtreinta.com', 'Polonia', 'info@editorialtreinta.com', 'David Martínez', '852963741', 'davidmartinez@editorialtreinta.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entrada_cabeza`
--

CREATE TABLE `entrada_cabeza` (
  `cod_entrada` int(11) NOT NULL,
  `fecha_entrada` date NOT NULL,
  `editorial_cod` int(11) NOT NULL,
  `vendedor_cod` int(11) NOT NULL,
  `forma_pago` enum('efectivo','nequi','credito') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `entrada_cabeza`
--

INSERT INTO `entrada_cabeza` (`cod_entrada`, `fecha_entrada`, `editorial_cod`, `vendedor_cod`, `forma_pago`) VALUES
(1, '2024-04-01', 1, 1, 'efectivo'),
(2, '2024-04-02', 2, 2, 'nequi'),
(3, '2024-04-03', 3, 3, 'credito'),
(4, '2024-04-04', 4, 4, 'efectivo'),
(5, '2024-04-05', 5, 5, 'nequi'),
(6, '2024-04-06', 6, 6, 'credito'),
(7, '2024-04-07', 7, 7, 'efectivo'),
(8, '2024-04-08', 8, 8, 'nequi'),
(9, '2024-04-09', 9, 9, 'credito'),
(10, '2024-04-10', 10, 10, 'efectivo'),
(11, '2024-04-11', 11, 11, 'nequi'),
(12, '2024-04-12', 12, 12, 'credito'),
(13, '2024-04-13', 13, 13, 'efectivo'),
(14, '2024-04-14', 14, 14, 'nequi'),
(15, '2024-04-15', 15, 15, 'credito'),
(16, '2024-04-16', 16, 16, 'efectivo'),
(17, '2024-04-17', 17, 17, 'nequi'),
(18, '2024-04-18', 18, 18, 'credito'),
(19, '2024-04-19', 19, 19, 'efectivo'),
(20, '2024-04-20', 20, 20, 'nequi'),
(21, '2024-04-21', 21, 21, 'credito'),
(22, '2024-04-22', 22, 22, 'efectivo'),
(23, '2024-04-23', 23, 23, 'nequi'),
(24, '2024-04-24', 24, 24, 'credito'),
(25, '2024-04-25', 23, 19, 'efectivo'),
(26, '2024-04-26', 26, 26, 'nequi'),
(27, '2024-04-27', 2, 15, 'credito'),
(28, '2024-04-28', 11, 8, 'efectivo'),
(29, '2024-04-29', 19, 9, 'nequi'),
(30, '2024-04-30', 20, 20, 'credito'),
(31, '2023-08-12', 2, 1, 'efectivo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entrada_detalle`
--

CREATE TABLE `entrada_detalle` (
  `cod_edetalle` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `entrada_cod` int(11) NOT NULL,
  `libro_cod` int(11) NOT NULL,
  `valor_compra` decimal(10,0) NOT NULL DEFAULT 0,
  `subtotal` decimal(10,0) GENERATED ALWAYS AS (`valor_compra` * `cantidad`) VIRTUAL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `entrada_detalle`
--

INSERT INTO `entrada_detalle` (`cod_edetalle`, `cantidad`, `entrada_cod`, `libro_cod`, `valor_compra`) VALUES
(61, 1, 1, 61, 20000),
(62, 2, 1, 62, 25000),
(63, 3, 2, 63, 18000),
(64, 1, 2, 64, 26000),
(65, 2, 3, 65, 15000),
(66, 1, 3, 66, 22000),
(67, 1, 4, 67, 16000),
(68, 3, 4, 58, 24000),
(69, 2, 5, 59, 19000),
(70, 1, 5, 50, 27000),
(71, 2, 6, 41, 17000),
(72, 3, 6, 52, 25000),
(73, 1, 7, 43, 20000),
(74, 2, 7, 64, 28000),
(75, 1, 8, 55, 21000),
(76, 3, 8, 46, 29000),
(77, 2, 9, 57, 22000),
(78, 1, 9, 58, 30000),
(79, 3, 10, 59, 23000),
(80, 2, 10, 50, 31000),
(81, 1, 11, 51, 24000),
(82, 3, 11, 52, 32000),
(83, 2, 12, 41, 25000),
(84, 1, 12, 44, 33000),
(85, 3, 13, 45, 26000),
(86, 2, 13, 46, 34000),
(87, 1, 14, 47, 27000),
(88, 3, 14, 48, 35000),
(89, 2, 15, 42, 28000),
(90, 1, 15, 41, 36000);

--
-- Disparadores `entrada_detalle`
--
DELIMITER $$
CREATE TRIGGER `entrada_inventario` AFTER INSERT ON `entrada_detalle` FOR EACH ROW BEGIN
UPDATE libros SET existencia=libros.existencia+NEW.cantidad
WHERE libros.cod_libro=NEW.libro_cod;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libros`
--

CREATE TABLE `libros` (
  `cod_libro` int(11) NOT NULL,
  `titulo_libro` varchar(25) NOT NULL,
  `autor` varchar(25) NOT NULL,
  `valor_compra` decimal(10,0) NOT NULL DEFAULT 0,
  `valor_venta` decimal(10,0) NOT NULL DEFAULT 0,
  `existencia` bigint(20) NOT NULL CHECK (`existencia` >= 0),
  `fecha_publicacion` date NOT NULL,
  `temas_cod` int(11) NOT NULL,
  `editorial_cod` int(11) NOT NULL,
  `idioma` varchar(25) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `libros`
--

INSERT INTO `libros` (`cod_libro`, `titulo_libro`, `autor`, `valor_compra`, `valor_venta`, `existencia`, `fecha_publicacion`, `temas_cod`, `editorial_cod`, `idioma`) VALUES
(41, 'El alquimista', 'Paulo Coelho', 16500, 25000, 100, '0000-00-00', 1, 1, NULL),
(42, 'Harry Potter y la piedra ', 'J.K. Rowling', 18000, 28000, 120, '1997-06-26', 11, 2, NULL),
(43, 'El principito', 'Antoine de Saint-Exupéry', 12000, 22000, 80, '1943-04-06', 11, 3, NULL),
(44, 'El código Da Vinci', 'Dan Brown', 16000, 26000, 90, '2003-03-18', 11, 4, NULL),
(45, 'Don Quijote de la Mancha', 'Miguel de Cervantes', 14000, 24000, 110, '1605-01-16', 11, 5, NULL),
(46, 'Orgullo y prejuicio', 'Jane Austen', 13000, 23000, 70, '1813-01-28', 20, 6, NULL),
(47, 'La Odisea', 'Homero', 11000, 21000, 85, '0000-00-00', 11, 7, NULL),
(48, 'Rayuela', 'Julio Cortázar', 13750, 22500, 105, '1963-06-28', 1, 10, NULL),
(49, 'English Grammar in Use', 'Raymond Murphy', 15500, 25500, 115, '0000-00-00', 18, 11, NULL),
(50, 'Oxford English Dictionary', 'James Murray', 13500, 23500, 65, '0000-00-00', 18, 12, NULL),
(51, 'El señor de los anillos', 'J.R.R. Tolkien', 19000, 29000, 125, '1954-07-29', 20, 13, NULL),
(52, 'Essential English Idioms', 'Robert J. Dixson', 15000, 25000, 95, '0000-00-00', 18, 14, NULL),
(53, 'The Elements of Style', 'William Strunk Jr. y E.B.', 17000, 27000, 80, '0000-00-00', 18, 15, NULL),
(54, 'Cambridge English: Advanc', 'Cambridge University Pres', 15500, 25500, 100, '0000-00-00', 9, 16, NULL),
(55, 'Cien años de soledad', 'Gabriel García Márquez', 15000, 25000, 90, '1967-05-30', 20, 1, NULL),
(56, 'Mastering the Art of Fren', 'Julia Child', 12000, 22000, 95, '0000-00-00', 9, 3, NULL),
(57, 'The Joy of Cooking', 'Irma S. Rombauer', 16000, 26000, 85, '0000-00-00', 9, 4, NULL),
(58, 'Salt, Fat, Acid, Heat: Ma', 'Salt, Fat, Acid, Heat: Ma', 14000, 24000, 105, '0000-00-00', 9, 5, NULL),
(59, 'How to Cook Everything', 'Mark Bittman', 13000, 23000, 75, '0000-00-00', 9, 6, NULL),
(60, 'Essentials of Classic Ita', 'Marcella Hazan', 11000, 21000, 90, '0000-00-00', 9, 7, NULL),
(61, 'El médico', 'Noah Gordon', 17000, 27000, 100, '0000-00-00', 20, 8, NULL),
(62, 'Rebelión en la granja', 'George Orwell', 14500, 24500, 70, '0000-00-00', 12, 9, NULL),
(63, 'Mujercitas', 'Louisa May Alcott', 12500, 22500, 110, '0000-00-00', 6, 10, NULL),
(64, 'La naranja mecánica', 'Anthony Burgesse', 15500, 25500, 120, '0000-00-00', 6, 11, NULL),
(65, 'El hombre invisible', 'H.G. Wells', 19000, 29000, 130, '0000-00-00', 11, 13, NULL),
(66, 'Crónica de una muerte anu', 'Gabriel García Márquez', 15000, 25000, 20, '0000-00-00', 8, 14, NULL),
(67, 'La insoportable levedad d', 'Milan Kundera', 17000, 27000, 80, '0000-00-00', 8, 15, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `nomina_vendedores`
--

CREATE TABLE `nomina_vendedores` (
  `cod_nomina` int(11) NOT NULL,
  `fecha_nomina` date NOT NULL,
  `vendedor_cod` int(11) NOT NULL,
  `salario` decimal(10,0) NOT NULL,
  `auxilio_transporte` decimal(10,0) NOT NULL DEFAULT 0,
  `nro_recargo` int(11) DEFAULT 0,
  `recargo_noche` decimal(10,0) NOT NULL,
  `total_devengado` decimal(10,0) NOT NULL,
  `salud` decimal(10,0) NOT NULL,
  `pension` decimal(10,0) DEFAULT NULL,
  `total_deducido` decimal(10,0) NOT NULL,
  `neto_pagar` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `nomina_vendedores`
--

INSERT INTO `nomina_vendedores` (`cod_nomina`, `fecha_nomina`, `vendedor_cod`, `salario`, `auxilio_transporte`, `nro_recargo`, `recargo_noche`, `total_devengado`, `salud`, `pension`, `total_deducido`, `neto_pagar`) VALUES
(1, '2024-04-01', 1, 1100000, 106454, 2, 50000, 111454, 15000, 9000, 24000, 87454),
(2, '2024-04-02', 2, 1100000, 106454, 1, 50000, 115454, 16000, 9500, 25500, 89954),
(3, '2024-04-03', 3, 1200000, 106454, 0, 50000, 120454, 17000, 10000, 27000, 93454),
(4, '2024-04-04', 4, 1430000, 106454, 2, 50000, 125454, 18000, 10500, 28500, 96954),
(5, '2024-04-05', 5, 1400000, 106454, 1, 50000, 130454, 19000, 11000, 30000, 100454),
(6, '2024-04-06', 6, 1500000, 106454, 0, 50000, 135454, 20000, 11500, 31500, 103954),
(7, '2024-04-07', 7, 1600000, 106454, 2, 50000, 140454, 21000, 12000, 33000, 107454),
(8, '2024-04-08', 8, 1700000, 106454, 1, 50000, 145454, 22000, 12500, 34500, 110954),
(9, '2024-04-09', 9, 1800000, 106454, 0, 50000, 150454, 23000, 13000, 36000, 114454),
(10, '2024-04-10', 10, 1900000, 106454, 2, 50000, 155454, 24000, 13500, 37500, 117954),
(11, '2024-04-11', 11, 2200000, 106454, 1, 50000, 160454, 25000, 14000, 39000, 121454),
(12, '2024-04-12', 12, 2100000, 106454, 0, 50000, 165454, 26000, 14500, 40500, 124954),
(13, '2024-04-13', 13, 2200000, 106454, 2, 50000, 170454, 27000, 15000, 42000, 128454),
(14, '2024-04-14', 14, 2300000, 106454, 1, 50000, 175454, 28000, 15500, 43500, 131954),
(15, '2024-04-15', 15, 2400000, 106454, 0, 50000, 180454, 29000, 16000, 45000, 135454),
(16, '2024-04-16', 16, 2750000, 106454, 2, 50000, 185454, 30000, 16500, 46500, 138954),
(17, '2024-04-17', 17, 2600000, 106454, 1, 50000, 190454, 31000, 17000, 48000, 142454),
(18, '2024-04-18', 18, 2700000, 106454, 0, 50000, 195454, 32000, 17500, 49500, 145954),
(19, '2024-04-19', 19, 3080000, 106454, 2, 50000, 200454, 33000, 18000, 51000, 149454),
(20, '2024-04-20', 20, 2900000, 106454, 1, 50000, 205454, 34000, 18500, 52500, 152954),
(21, '2024-04-21', 21, 3000000, 106454, 0, 50000, 210454, 35000, 19000, 54000, 156454),
(22, '2024-04-22', 22, 3100000, 106454, 2, 50000, 215454, 36000, 19500, 55500, 159954),
(23, '2024-04-23', 23, 3200000, 106454, 1, 50000, 220454, 37000, 20000, 57000, 163454),
(24, '2024-04-24', 24, 3300000, 106454, 0, 50000, 225454, 38000, 20500, 58500, 166954),
(25, '2024-04-25', 25, 3740000, 106454, 2, 50000, 230454, 39000, 21000, 60000, 170454),
(26, '2024-04-26', 26, 3500000, 106454, 1, 50000, 235454, 40000, 21500, 61500, 173954),
(27, '2024-04-27', 27, 3600000, 106454, 0, 50000, 240454, 41000, 22000, 63000, 177454),
(28, '2024-04-28', 28, 3700000, 106454, 2, 50000, 245454, 42000, 22500, 64500, 180954);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `temas`
--

CREATE TABLE `temas` (
  `cod_temas` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `genero` enum('novela','filosofia','sicologia','gastronomia','fantasia','ciencias','idioma','otros') DEFAULT 'otros'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `temas`
--

INSERT INTO `temas` (`cod_temas`, `nombre`, `genero`) VALUES
(1, 'Autoayuda', 'otros'),
(2, 'Arte', 'otros'),
(3, 'cocina', 'otros'),
(4, 'Deportes', ''),
(5, 'Viajes', ''),
(6, 'El primer plato', 'novela'),
(7, 'recetario', 'gastronomia'),
(8, 'El Humor', 'filosofia'),
(9, 'gastronomia', 'gastronomia'),
(10, 'Medicina', 'ciencias'),
(11, 'Principito', 'fantasia'),
(12, 'Psicología', 'sicologia'),
(13, 'Negocios', 'otros'),
(14, 'Derecho', 'otros'),
(15, 'Postres', 'gastronomia'),
(16, 'Astronomía', ''),
(17, 'spañol', 'idioma'),
(18, 'Ingles', 'idioma'),
(19, 'Tecnología', 'ciencias'),
(20, 'El leon y el niño', 'novela');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vendedor`
--

CREATE TABLE `vendedor` (
  `cod_vendedor` int(11) NOT NULL,
  `nombre1` varchar(25) NOT NULL,
  `nombre2` varchar(25) NOT NULL,
  `apellido1` varchar(25) NOT NULL,
  `apellido2` varchar(25) NOT NULL,
  `tipo_documento` enum('cc','ce','nit','rut','ppt') DEFAULT NULL,
  `sexo` enum('femenino','masculino') DEFAULT NULL,
  `direccion` varchar(50) NOT NULL,
  `ciudad` varchar(20) NOT NULL,
  `edad` int(11) NOT NULL CHECK (`edad` >= 18),
  `telefono` varchar(25) NOT NULL,
  `nivel_estudios` enum('primaria','bachillerato','tecnico','tecnologo','profecional','otro') DEFAULT NULL,
  `eps` enum('sanitas','sura','capital salud','nueva eps','compensar','famisanar','aliansalud') DEFAULT NULL,
  `no_documento` varchar(25) NOT NULL,
  `pensiones` enum('colfondos','proteccion','provenir','skandia') DEFAULT NULL,
  `cesantia` enum('fna','colfondos','proteccion') DEFAULT NULL,
  `banco` enum('BBVA','DAVIPLATA','BANCOLOMBIA','CAJA SOCIAL','POPULAR') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `vendedor`
--

INSERT INTO `vendedor` (`cod_vendedor`, `nombre1`, `nombre2`, `apellido1`, `apellido2`, `tipo_documento`, `sexo`, `direccion`, `ciudad`, `edad`, `telefono`, `nivel_estudios`, `eps`, `no_documento`, `pensiones`, `cesantia`, `banco`) VALUES
(1, 'Camilo', 'Andrés', 'Gómez', 'Martínez', 'cc', 'masculino', 'Cra 24 # 15-30', 'Pereira', 28, '3167890123', 'tecnico', 'compensar', '1234567890', 'colfondos', 'fna', 'BANCOLOMBIA'),
(2, 'Valentina', 'María', 'Rodríguez', 'González', 'cc', 'femenino', 'Calle 58 # 12-45', 'Medellín', 29, '3004567890', 'bachillerato', 'sura', '9876543210', 'proteccion', '', 'BANCOLOMBIA'),
(3, 'Juan', 'Pablo', 'López', 'Sánchez', 'cc', 'masculino', 'Cra 18 # 30-25', 'Bogotá', 31, '3111234567', '', 'nueva eps', '8529637410', 'skandia', 'colfondos', 'CAJA SOCIAL'),
(4, 'María', 'José', 'Martínez', 'Díaz', 'cc', 'femenino', 'Calle 36 # 40-15', 'Cali', 27, '3172345678', 'tecnico', 'famisanar', '3698521470', 'provenir', 'fna', 'POPULAR'),
(5, 'Andrea', 'Fernanda', 'Gómez', 'Hernández', 'ce', 'femenino', 'Cra 10 # 22-18', 'Barranquilla', 30, '3135678901', '', 'capital salud', '7418529630', 'colfondos', 'proteccion', 'DAVIPLATA'),
(6, 'Pedro', 'José', 'Díaz', 'Sánchez', 'cc', 'masculino', 'Cra 5 # 15-10', 'Santa Marta', 29, '3106789012', 'bachillerato', 'sanitas', '9638527410', 'colfondos', 'fna', 'BANCOLOMBIA'),
(7, 'Sara', 'Isabel', 'González', 'Pérez', 'cc', 'femenino', 'Cra 8 # 18-20', 'Bucaramanga', 26, '3147890123', 'tecnologo', 'sura', '2583691470', 'provenir', 'proteccion', 'POPULAR'),
(8, 'David', 'Felipe', 'Hernández', 'Martínez', 'ce', 'masculino', 'Cra 12 # 24-30', 'Cúcuta', 32, '3188901234', '', 'compensar', '1237894560', 'skandia', 'colfondos', 'BANCOLOMBIA'),
(9, 'Daniela', 'Marcela', 'Pérez', 'López', 'cc', 'femenino', 'Calle 30 # 10-15', 'Ibagué', 28, '3152345678', 'bachillerato', 'famisanar', '9876543210', '', 'fna', 'DAVIPLATA'),
(10, 'Javier', 'Andrés', 'Gómez', 'Díaz', 'cc', 'masculino', 'Cra 15 # 20-25', 'Neiva', 29, '3138901234', '', 'nueva eps', '8529637410', 'colfondos', 'colfondos', 'BANCOLOMBIA'),
(11, 'María', 'José', 'Martínez', 'González', 'cc', 'femenino', 'Cra 35 # 40-15', 'Pereira', 27, '3115678901', 'tecnico', 'sanitas', '3691472580', 'provenir', 'fna', 'POPULAR'),
(12, 'Andrés', 'Felipe', 'Díaz', 'Sánchez', 'cc', 'masculino', 'Calle 45 # 15-20', 'Medellín', 30, '3176789012', 'bachillerato', 'sura', '2583691470', 'colfondos', 'proteccion', 'BANCOLOMBIA'),
(13, 'Laura', 'Isabel', 'Gómez', 'Martínez', 'cc', 'femenino', 'Cra 12 # 25-30', 'Bogotá', 29, '3128901234', '', 'famisanar', '1234567890', '', 'colfondos', 'DAVIPLATA'),
(14, 'Juan', 'Pablo', 'Hernández', 'López', 'cc', 'masculino', 'Cra 8 # 10-15', 'Cali', 28, '3102345678', 'tecnologo', 'compensar', '9876543210', 'provenir', 'proteccion', 'POPULAR'),
(15, 'Camila', 'Fernanda', 'Pérez', 'Gómez', 'ce', 'femenino', 'Cra 10 # 15-20', 'Barranquilla', 31, '3145678901', 'bachillerato', 'capital salud', '7418529630', 'colfondos', 'fna', 'BANCOLOMBIA'),
(16, 'Daniel', 'Felipe', 'González', 'Martínez', 'cc', 'masculino', 'Calle 20 # 24-30', 'Santa Marta', 27, '3137890123', 'tecnico', 'sanitas', '9638527410', 'provenir', 'fna', 'DAVIPLATA'),
(17, 'Sofía', 'Isabel', 'López', 'Pérez', 'cc', 'femenino', 'Cra 22 # 18-15', 'Bucaramanga', 30, '3178901234', '', 'nueva eps', '2583691470', 'colfondos', 'proteccion', 'POPULAR'),
(18, 'María', 'Fernanda', 'Rodríguez', 'Gómez', 'cc', 'femenino', 'Cra 15 # 80-52', 'Bogotá', 27, '3101234567', '', 'sanitas', '123456789', 'colfondos', 'fna', 'BANCOLOMBIA'),
(19, 'Luis', 'Alberto', 'Martínez', 'Pérez', 'cc', 'masculino', 'Calle 70 # 20-30', 'Medellín', 30, '3129876543', 'tecnico', 'sura', '987654321', 'proteccion', '', 'BANCOLOMBIA'),
(20, 'Ana', 'Isabel', 'González', 'Hernández', 'ce', 'femenino', 'Cra 8 # 56-18', 'Barranquilla', 32, '3157418529', '', 'capital salud', '1234567890', 'proteccion', 'proteccion', 'DAVIPLATA'),
(21, 'Pedro', 'José', 'Díaz', 'Sánchez', 'cc', 'masculino', 'Calle 23 # 17-45', 'Cali', 28, '3003698521', 'tecnologo', 'nueva eps', '9876543210', 'colfondos', 'colfondos', 'POPULAR'),
(22, 'Laura', 'Marcela', 'Ramírez', 'Castro', 'nit', 'femenino', 'Cra 5 # 10-30', 'Pereira', 29, '3202583691', 'bachillerato', 'famisanar', '2583691470', 'provenir', 'fna', 'DAVIPLATA'),
(23, 'Andrés', 'Felipe', 'López', 'González', 'cc', 'masculino', 'Calle 80 # 45-23', 'Santa Marta', 25, '3181472583', '', 'sanitas', '1472583690', 'colfondos', 'fna', 'BBVA'),
(24, 'Sofía', 'Alejandra', 'Gómez', 'Rodríguez', 'cc', 'femenino', 'Cra 13 # 24-56', 'Villavicencio', 31, '3229637418', 'bachillerato', 'sura', '3691472580', 'provenir', 'proteccion', 'CAJA SOCIAL'),
(25, 'Carlos', 'Andrés', 'Hernández', 'Gómez', 'ce', 'masculino', 'Cra 21 # 33-17', 'Cúcuta', 29, '3147894562', 'tecnico', 'compensar', '1237894560', 'skandia', 'colfondos', 'BANCOLOMBIA'),
(26, 'Daniela', 'Fernanda', 'Pérez', 'Díaz', 'cc', 'femenino', 'Calle 10 # 12-40', 'Ibagué', 27, '3019876543', 'bachillerato', 'nueva eps', '9876543210', '', 'fna', 'BANCOLOMBIA'),
(27, 'Jorge', 'Luis', 'González', 'Martínez', 'cc', 'masculino', 'Cra 7 # 34-23', 'Bucaramanga', 32, '3173691472', '', 'famisanar', '3691472580', 'provenir', 'proteccion', 'DAVIPLATA'),
(28, 'Fernanda', 'Isabel', 'Sánchez', 'López', 'nit', 'femenino', 'Calle 45 # 34-10', 'Neiva', 30, '3108529637', 'tecnologo', 'sanitas', '8529637410', 'colfondos', 'colfondos', 'POPULAR'),
(29, 'Juan', 'Carlos', 'Perez', 'Gomez', 'cc', 'masculino', 'Calle 2 #3-3', 'Bogotá', 30, '3211234567', 'tecnico', 'sanitas', '123456789', 'proteccion', 'fna', 'BBVA');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `cod_ventas` int(11) NOT NULL,
  `codigo_factura` varchar(50) NOT NULL,
  `fecha_venta` date NOT NULL,
  `cliente_cod` int(11) NOT NULL,
  `vendedor_cod` int(11) NOT NULL,
  `forma_pago` enum('efectivo','nequi','credito') DEFAULT NULL,
  `estado_pago` enum('pagada','pendiente') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`cod_ventas`, `codigo_factura`, `fecha_venta`, `cliente_cod`, `vendedor_cod`, `forma_pago`, `estado_pago`) VALUES
(1, 'FAC001', '2024-04-01', 1, 1, 'efectivo', 'pagada'),
(2, 'FAC002', '2024-04-02', 2, 2, 'nequi', 'pagada'),
(3, 'FAC003', '2024-04-03', 3, 3, 'credito', 'pendiente'),
(4, 'FAC004', '2024-04-04', 4, 4, 'efectivo', 'pendiente'),
(5, 'FAC005', '2024-04-05', 5, 5, 'nequi', 'pagada'),
(6, 'FAC006', '2024-04-06', 6, 6, 'credito', 'pendiente'),
(7, 'FAC007', '2024-04-07', 7, 7, 'efectivo', 'pagada'),
(8, 'FAC008', '2024-04-08', 8, 8, 'nequi', 'pendiente'),
(9, 'FAC009', '2024-04-09', 9, 9, 'credito', 'pendiente'),
(10, 'FAC010', '2024-04-10', 10, 10, 'efectivo', 'pagada'),
(11, 'FAC011', '2024-04-11', 11, 11, 'nequi', 'pendiente'),
(12, 'FAC012', '2024-04-12', 12, 12, 'credito', 'pagada'),
(13, 'FAC013', '2024-04-13', 13, 13, 'efectivo', 'pagada'),
(14, 'FAC014', '2024-04-14', 14, 14, 'nequi', 'pendiente'),
(15, 'FAC015', '2024-04-15', 15, 15, 'credito', 'pagada'),
(16, 'FAC016', '2024-04-16', 16, 16, 'efectivo', 'pendiente'),
(17, 'FAC017', '2024-04-17', 17, 17, 'nequi', 'pagada'),
(18, 'FAC018', '2024-04-18', 18, 18, 'credito', 'pendiente'),
(19, 'FAC019', '2024-04-19', 19, 19, 'efectivo', 'pagada'),
(20, 'FAC020', '2024-04-20', 20, 20, 'nequi', 'pagada'),
(21, 'FAC021', '2024-04-21', 21, 21, 'credito', 'pendiente'),
(22, 'FAC022', '2024-04-22', 22, 22, 'efectivo', 'pagada'),
(23, 'FAC023', '2024-04-23', 23, 23, 'nequi', 'pendiente'),
(24, 'FAC024', '2024-04-24', 24, 24, 'credito', 'pagada'),
(25, 'FAC025', '2024-04-25', 25, 5, 'efectivo', 'pagada'),
(26, 'FAC026', '2024-04-26', 26, 6, 'nequi', 'pendiente'),
(27, 'FAC027', '2024-04-27', 27, 7, 'credito', 'pendiente'),
(28, 'FAC028', '2024-04-28', 28, 8, 'efectivo', 'pagada'),
(29, 'FAC029', '2024-04-29', 29, 9, 'nequi', 'pendiente'),
(30, 'FAC030', '2024-04-30', 30, 1, 'credito', 'pagada'),
(124, 'FACT-001', '2024-05-10', 1, 10, 'efectivo', 'pagada');

--
-- Disparadores `ventas`
--
DELIMITER $$
CREATE TRIGGER `actualizar_estado_pago` AFTER INSERT ON `ventas` FOR EACH ROW BEGIN
    UPDATE cartera
    SET estado_pago = NEW.estado_pago
    WHERE cliente_cod = NEW.cliente_cod
      AND codigo_factura = NEW.codigo_factura
      AND cod_ventas = NEW.cod_ventas;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_editorial_libtos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_editorial_libtos` (
`nombre_editorial` varchar(50)
,`cuidad` varchar(25)
,`autor` varchar(25)
,`valor_compra` decimal(10,0)
,`valor_venta` decimal(10,0)
,`existencia` bigint(20)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_temas_libros`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_temas_libros` (
`nombre` varchar(50)
,`titulo_libro` varchar(25)
,`valor_compra` decimal(10,0)
,`valor_venta` decimal(10,0)
,`existencia` bigint(20)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_vendedor_cliente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_vendedor_cliente` (
`vendedor` varchar(51)
,`cliente` varchar(51)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_editorial_libtos`
--
DROP TABLE IF EXISTS `vista_editorial_libtos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_editorial_libtos`  AS SELECT `t1`.`nombre_editorial` AS `nombre_editorial`, `t1`.`cuidad` AS `cuidad`, `t2`.`autor` AS `autor`, `t2`.`valor_compra` AS `valor_compra`, `t2`.`valor_venta` AS `valor_venta`, `t2`.`existencia` AS `existencia` FROM (`editorial` `t1` join `libros` `t2`) WHERE `t1`.`cod_editoral` = `t2`.`editorial_cod` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_temas_libros`
--
DROP TABLE IF EXISTS `vista_temas_libros`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_temas_libros`  AS SELECT `t1`.`nombre` AS `nombre`, `t2`.`titulo_libro` AS `titulo_libro`, `t2`.`valor_compra` AS `valor_compra`, `t2`.`valor_venta` AS `valor_venta`, `t2`.`existencia` AS `existencia` FROM (`temas` `t1` join `libros` `t2`) WHERE `t1`.`cod_temas` = `t2`.`temas_cod` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_vendedor_cliente`
--
DROP TABLE IF EXISTS `vista_vendedor_cliente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_vendedor_cliente`  AS SELECT concat(`t1`.`nombre1`,' ',`t1`.`apellido1`) AS `vendedor`, concat(`t2`.`nombre1`,' ',`t2`.`apellido1`) AS `cliente` FROM (`vendedor` `t1` join `cliente` `t2` on(`t1`.`cod_vendedor` = `t2`.`vendedor_cod`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cartera`
--
ALTER TABLE `cartera`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`cod_cliente`),
  ADD KEY `nombre1` (`nombre1`,`apellido1`),
  ADD KEY `vendedor_cod` (`vendedor_cod`);

--
-- Indices de la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  ADD PRIMARY KEY (`cod_detallev`),
  ADD KEY `ventas_cod` (`ventas_cod`),
  ADD KEY `libro_cod` (`libro_cod`);

--
-- Indices de la tabla `editorial`
--
ALTER TABLE `editorial`
  ADD PRIMARY KEY (`cod_editoral`),
  ADD KEY `nombre_editorial` (`nombre_editorial`);

--
-- Indices de la tabla `entrada_cabeza`
--
ALTER TABLE `entrada_cabeza`
  ADD PRIMARY KEY (`cod_entrada`),
  ADD KEY `editorial_cod` (`editorial_cod`),
  ADD KEY `vendedor_cod` (`vendedor_cod`);

--
-- Indices de la tabla `entrada_detalle`
--
ALTER TABLE `entrada_detalle`
  ADD PRIMARY KEY (`cod_edetalle`),
  ADD KEY `entrada_cod` (`entrada_cod`),
  ADD KEY `libro_cod` (`libro_cod`);

--
-- Indices de la tabla `libros`
--
ALTER TABLE `libros`
  ADD PRIMARY KEY (`cod_libro`),
  ADD KEY `temas_cod` (`temas_cod`),
  ADD KEY `editorial_cod` (`editorial_cod`),
  ADD KEY `titulo_libro` (`titulo_libro`);

--
-- Indices de la tabla `nomina_vendedores`
--
ALTER TABLE `nomina_vendedores`
  ADD PRIMARY KEY (`cod_nomina`),
  ADD KEY `fecha_nomina` (`fecha_nomina`),
  ADD KEY `vendedor_cod` (`vendedor_cod`);

--
-- Indices de la tabla `temas`
--
ALTER TABLE `temas`
  ADD PRIMARY KEY (`cod_temas`),
  ADD KEY `nombre` (`nombre`);

--
-- Indices de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  ADD PRIMARY KEY (`cod_vendedor`),
  ADD KEY `nombre1` (`nombre1`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`cod_ventas`),
  ADD KEY `cliente_cod` (`cliente_cod`),
  ADD KEY `vendedor_cod` (`vendedor_cod`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cartera`
--
ALTER TABLE `cartera`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `cod_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  MODIFY `cod_detallev` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT de la tabla `editorial`
--
ALTER TABLE `editorial`
  MODIFY `cod_editoral` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `entrada_cabeza`
--
ALTER TABLE `entrada_cabeza`
  MODIFY `cod_entrada` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT de la tabla `entrada_detalle`
--
ALTER TABLE `entrada_detalle`
  MODIFY `cod_edetalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT de la tabla `libros`
--
ALTER TABLE `libros`
  MODIFY `cod_libro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT de la tabla `nomina_vendedores`
--
ALTER TABLE `nomina_vendedores`
  MODIFY `cod_nomina` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT de la tabla `temas`
--
ALTER TABLE `temas`
  MODIFY `cod_temas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  MODIFY `cod_vendedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `cod_ventas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`vendedor_cod`) REFERENCES `vendedor` (`cod_vendedor`);

--
-- Filtros para la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  ADD CONSTRAINT `detalle_ventas_ibfk_1` FOREIGN KEY (`ventas_cod`) REFERENCES `ventas` (`cod_ventas`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_ventas_ibfk_2` FOREIGN KEY (`libro_cod`) REFERENCES `libros` (`cod_libro`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `entrada_cabeza`
--
ALTER TABLE `entrada_cabeza`
  ADD CONSTRAINT `entrada_cabeza_ibfk_1` FOREIGN KEY (`editorial_cod`) REFERENCES `editorial` (`cod_editoral`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entrada_cabeza_ibfk_2` FOREIGN KEY (`vendedor_cod`) REFERENCES `vendedor` (`cod_vendedor`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `entrada_detalle`
--
ALTER TABLE `entrada_detalle`
  ADD CONSTRAINT `entrada_detalle_ibfk_1` FOREIGN KEY (`entrada_cod`) REFERENCES `entrada_cabeza` (`cod_entrada`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entrada_detalle_ibfk_2` FOREIGN KEY (`libro_cod`) REFERENCES `libros` (`cod_libro`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `libros`
--
ALTER TABLE `libros`
  ADD CONSTRAINT `libros_ibfk_1` FOREIGN KEY (`temas_cod`) REFERENCES `temas` (`cod_temas`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `libros_ibfk_2` FOREIGN KEY (`editorial_cod`) REFERENCES `editorial` (`cod_editoral`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `nomina_vendedores`
--
ALTER TABLE `nomina_vendedores`
  ADD CONSTRAINT `nomina_vendedores_ibfk_1` FOREIGN KEY (`vendedor_cod`) REFERENCES `vendedor` (`cod_vendedor`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`cliente_cod`) REFERENCES `cliente` (`cod_cliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`vendedor_cod`) REFERENCES `vendedor` (`cod_vendedor`) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`root`@`localhost` EVENT `actualizar_estadocartera` ON SCHEDULE EVERY 1 MINUTE STARTS '2024-06-05 17:23:42' ON COMPLETION PRESERVE ENABLE DO CALL actualizar_credito$$

CREATE DEFINER=`root`@`localhost` EVENT `event_netocartera` ON SCHEDULE EVERY 1 DAY STARTS '2024-06-06 18:04:49' ON COMPLETION PRESERVE ENABLE DO CALL actualiza_netocartera()$$

CREATE DEFINER=`root`@`localhost` EVENT `CalcularTotalLibrosPorClienteEvent` ON SCHEDULE EVERY 1 WEEK STARTS '2024-06-05 19:06:51' ON COMPLETION NOT PRESERVE ENABLE DO CALL CalcularTotalLibrosPorCliente$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
