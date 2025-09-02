CREATE TABLE ventas (
    id_venta INTEGER PRIMARY KEY,
    fecha TEXT,
    hora TEXT,
    producto TEXT,
    precio REAL,
    cantidad INTEGER
);

INSERT INTO ventas (fecha, hora, producto, precio, cantidad) VALUES
('2025-08-15', '19:05', 'pizza_margarita', 12.50, 2),
('2025-08-15', '19:08', 'gaseosa', 3.00, 3),
('2025-08-15', '19:10', 'pizza_pepperoni', 14.00, 1),
('2025-08-15', '19:15', 'cerveza', 4.50, 2),
('2025-08-15', '19:20', 'pizza_margarita', 12.50, 1),
('2025-08-15', '19:30', 'gaseosa', 3.00, 1),
('2025-08-15', '20:00', 'ensalada_cesar', 10.00, 1),
('2025-08-15', '20:15', 'pizza_margarita', 12.50, 3),
('2025-08-15', '20:30', 'cerveza', 4.50, 1),
('2025-08-15', '20:45', 'pizza_pepperoni', 14.00, 2),
('2025-08-16', '12:00', 'ensalada_cesar', 10.00, 2),
('2025-08-16', '12:15', 'pizza_margarita', 12.50, 1),
('2025-08-16', '13:00', 'gaseosa', 3.00, 2),
('2025-08-16', '13:10', 'pizza_pepperoni', 14.00, 1),
('2025-08-16', '13:20', 'pizza_margarita', 12.50, 1),
('2025-08-16', '13:30', 'cerveza', 4.50, 3);