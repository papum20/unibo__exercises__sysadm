La seguente soluzione è stata sviluppata con solo i moduli e le feature di Ansible viste a lezione. Per poter inserire in modo automatico e sistematico i vari MAC address di client e server dentro la configurazione di dnsmasq.conf è necessario introdurre ulteriori strumenti che non abbiamo visto durante il corso, pertanto al termine del provision con Ansible dovete inserire a mano i MAC, dentro il dnsmasq.conf sul router, con quelli effettivamente in uso. Una volta effettuata questa modifica basta usare il comando sia su client che su server "sudo dhclient -v" per forzare il lease del DHCP e contestualmente l'assegnazione del server DNS