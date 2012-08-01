#!/bin/bash
#tar czvf /tmp/archivosMERAN.tar.gz /usr/share/meran
rm -fr /usr/share/meran
#tar czvf /tmp/configuracionMERAN.tar.gz /etc/meran
rm -fr /etc/meran
#tar czvf /tmp/configuracionAPACHE-MERAN.tar.gz /etc/apache2/sites-available/jaula* 
a2dissite jaula-ssl
a2dissite jaula-opac