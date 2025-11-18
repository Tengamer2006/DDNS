Configura una infraestructura con un sistema de DHCP y DNS (DDNS) en Linux, con las siguientes características:

Cada servidor debe estar en MV Linux independientes.
Cada servidor ha de tener una tarjeta externa en modo puente y la otra interna.
Los servidores se 'veran' por la tarjeta interna. El direccionamiento IP de la red interna lo eliges tú.
El servidor DHCP reparte como DNS la dirección del server DNS que estás configurando.
Configura cada servicio en una MV y finalmente comprueba como un cliente se conecta, adquiere configuración IP y esto se registra en el servidor DNS.
Ten en cuenta que puedes llegar a modificar los siguientes documentos:

Fichero de configuración de red de ambas MV.
Fichero de configuracion de dhcp(dhcp4-server.conf y dhcp-ddns-server.conf)
Fichero con la clave que hayas usado para DDNS.
Fichero named.conf.local y named.conf.options.
Fichero de zona inversa y directa.
Debes entregar tu proyecto DDNS en una estructura Vagrant con todo lo necesario para la correcta puesta en marcha de todos los servicios de manera automatizada.
