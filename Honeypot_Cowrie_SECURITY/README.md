# Proyecto de Monitoreo de Seguridad con Honeypot

## Descripción del Proyecto

Este proyecto demuestra la implementación y el análisis de un honeypot de ciberseguridad utilizando Cowrie en un entorno contenedorizado con Docker y Docker Compose. El objetivo principal es simular un servicio SSH vulnerable para capturar y analizar intentos de conexión, identificando patrones de ataque y comportamientos anómalos.

Habilidades:
* Monitoreo y análisis de logs.
* Gestión de herramientas de seguridad (honeypots).
* Uso de tecnologías de virtualización (Docker).

## Tecnologías Utilizadas

* **Cowrie**: Un honeypot de baja interacción que emula un servidor SSH.
* **Docker**: Plataforma para la creación, gestión y ejecución de contenedores.
* **Docker Compose**: Herramienta para definir y ejecutar aplicaciones multi-contenedor.

## Cómo Utilizar

1.  **Clona este repositorio**:
    ```bash
    git clone [https://github.com/tu_usuario/tu_repositorio.git](https://github.com/tu_usuario/tu_repositorio.git)
    cd tu_repositorio
    ```

2.  **Levanta el servicio**:
    Asegúrate de tener Docker y Docker Compose instalados. Luego, ejecuta el siguiente comando para iniciar el honeypot en segundo plano:
    ```bash
    docker-compose up -d
    ```

3.  **Probar el Honeypot**:
    Para simular un ataque, puedes intentar conectarte al honeypot. Usa un cliente SSH para probar con el usuario y contraseña `root/password`.

    ```bash
    ssh -p 2222 root@localhost
    ```

    Cuando te pida la contraseña, usa `password`. La conexión será exitosa, demostrando que el honeypot está funcionando.

## Análisis de Logs

Todos los intentos de conexión y los comandos ejecutados quedan registrados. Los logs se almacenan de forma permanente en la carpeta `cowrie_data/var/log/`.

Aquí tienes un ejemplo de cómo se ve un intento de inicio de sesión exitoso en el log:


```json
{
"eventid":"cowrie.login.success",
"username":"root",
"password":"password",
"message":"login attempt [root/password] successful",
"src_ip":"127.0.0.1"
}