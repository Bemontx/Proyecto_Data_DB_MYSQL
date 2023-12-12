create database registro_transacciones;
show databases;
use registro_transacciones;
drop database registro_transacciones;

CREATE TABLE Transacciones(
		IdTransaccion int auto_increment not null primary key,
		Fecha_hora datetime,
		Monto_transaccion decimal(10,2),
		Detalles_transaccion text,
		IdCuenta int,
		FOREIGN KEY (IdCuenta) REFERENCES Cuentas_Bancarias(IdCuenta)
);

create table Clientes(
			IdCliente int auto_increment primary key ,
            Nombre varchar(50) not null,
            Apellido varchar(50) not null,
            Num_Identificacion varchar(50),
            Email varchar(60) not null,
            Telefono varchar(50)
);

create table Cuentas_Bancarias(
		IdCuenta int auto_increment not null primary key,
        Tipo_Cuenta varchar(50) not null,
        Numero_Cuenta varchar(50) Not null,
        Saldo decimal(15,2) not null,
        IdTitular int not null,
        foreign key (IdTitular) references Clientes(IdCliente)
);

create table Detalles_metodos_pagos(
		IdDetallesPago int auto_increment not null primary key,
        IdTransaccion int not null,
        Tipo_Tarjeta varchar(50) not null,
        Numero_Tarjeta varchar(50) not null,
        Detalles_Adicionales text,
        foreign key (IdTransaccion) references Transacciones(IdTransaccion)
);



insert into Clientes (Nombre, Apellido, Num_Identificacion, Email, Telefono)
values ('Juan', 'Gomez', '147852', 'juan@gmail.com', '123-456-7890'),
	   ('Pedro', 'Cardozo', '258741', 'juan@gmail.com', '123-456-7890'),
       ('María', 'lpez', '369852', 'maria@gmail.com', '987-654-3210');
       
insert into Cuentas_Bancarias (Tipo_Cuenta, Numero_Cuenta, Saldo, IdTitular)
values ('Corriente', '123456', 1500.00, 1),
	   ('Corriente', '654312', 2200.00, 2),
       ('Ahorros', '987456', 2500.00, 3);
       
insert into Transacciones (Fecha_hora, Monto_transaccion, Detalles_transaccion)
values ('2023-12-01 08:33:00', 90.50, 'Pago Movistar'),
	   ('2023-12-02 02:00:00', 150.50, 'Pago Internet'),
       ('2023-12-03 12:15:00', 200.75, 'Comptas Addidas');
       
insert into Detalles_metodos_pagos (IdTransaccion, Tipo_Tarjeta, Numero_Tarjeta, Detalles_Adicionales)
values (1, 'Débito', '****1234', 'Transacción exitosa'),
       (2, 'Débito', '****1234', 'Transacción exitosa'),
       (3, 'Crédito', '****5678', 'Transacción pendiente');


DELIMITER //
CREATE TRIGGER actualizar_saldo_transaccion
AFTER INSERT ON Transacciones
FOR EACH ROW
BEGIN
	DECLARE saldo_actual DECIMAL(15,2);
	DECLARE saldo_anterior DECIMAL(15,2);
  
  SELECT Saldo INTO saldo_actual FROM Cuentas_Bancarias WHERE IdCuenta = NEW.IdCuenta;

  IF saldo_actual >= NEW.Monto_transaccion THEN
      SELECT Saldo INTO saldo_anterior FROM Cuentas_Bancarias WHERE IdCuenta = NEW.IdCuenta;

      INSERT INTO Registro_Cambios_Saldo (IdCuenta, Saldo_Anterior, Saldo_Nuevo, Fecha_Modificacion)
      VALUES (NEW.IdCuenta, saldo_anterior, saldo_actual - NEW.Monto_transaccion, NOW());

      UPDATE Cuentas_Bancarias SET Saldo = saldo_actual - NEW.Monto_transaccion WHERE IdCuenta = NEW.IdCuenta;
  ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '¡Saldo insuficiente para la transacción!';
  END IF;
END //
DELIMITER ;