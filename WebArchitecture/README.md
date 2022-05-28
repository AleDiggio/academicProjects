# academicProjects

GESTIONE DI UN LIDO BALNEARE
Alessandro Di Giovanni (0707871)

DESCRIZIONE GENERALE
Lo scopo del progetto è quello di creare un sistema web che simuli quanto più possibile la gestione di un reale lido balneare. Di conseguenza, dal punto di vista dell’utente semplice, egli deve essere in grado di poter usufruire di tutte quelle funzionalità online che facilitano la prenotazione di un lettino/postazione e contemporaneamente dal punto di vista del dipendente e del suo ruolo, presenti quelle funzionalità necessarie alla corretta gestione del lido.

ARCHITETTURA DEL SISTEMA
Tecnologie utilizzate:
1.	Classi Java servlet e JSP, per l’accettazione di richieste http, per la costruzione delle relative pagina web di risposta e per il processo di validazione ed elaborazione dei dati inseriti dal client;
2.	HTML, CSS e JavaScript, per la gestione dell’interfaccia utente;
3.	jQuery, per facilitare alcune operazioni javascript;
4.	Bootstrap 4, praticamente inutilizzato, presente solo per alcuni layout;
5.	Json, come formato di alcuni dati scambiati tra client e server;
6.	Apache Tomcat, quale middleware per il deployment della web application;
7.	Un qualsiasi DB relazionale per la memorizzazione dei dati e connettore jdbc per il collegamento alle classi Java;
8.	Libreria Gson, per usufruire di alcuni metodi di conversione da oggetto java, quale List o Map, in stringhe in formato json.


REQUISITI FUNZIONALI
Generali:
1.	L’interfaccia principale dà la possibilità o di effettuare il login tramite i classici email e password o di registrarsi fornendo alcuni dati anagrafici oltre che le credenziali di accesso.
2.	Una volta effettuato il login, in base alla tipologia l’utente viene reindirizzato alla rispettiva pagina principale: utente base, dipendente o amministratore.
Client side:
•	Funzionalità utente:
1.	Prenotare una postazione selezionando fila e numero e successivamente simulando un pagamento.
2.	Visualizzare graficamente lo stato occupazionale del lido, individuando quindi quali sono le postazioni libere e quali occupate.
3.	Visualizzare i dettagli delle prenotazioni effettuate con possibilità di cancellarle.
4.	Modificare la propria password, in particolare, dopo aver visualizzato i propri dati personali, forniti in fase di registrazione.

•	Funzionalità dipendente:
1.	Visualizzare graficamente lo stato occupazionale del lido.
2.	Liberare contemporaneamente tutte le postazioni del lido.
3.	Gestire una determinata postazione, in particolare, se occupata, visualizzare i dettagli della prenotazione con possibilità di liberarla, se libera, di prenotarla.
•	Funzionalità amministratore:
1.	Aggiungere al sistema un nuovo dipendente o un nuovo amministratore.

Server side:
Server side è stato utilizzato un approccio MVC (model-view-controller), in particolare a partire da una view, la richiesta viene inoltrata a una servlet (control) che in base alla funzionalità richiesta gestisce le chiamate alle classi java che si occupano dell’elaborazioni dei dati e della comunicazione con il DBMS (model) e infine attivano la jsp corretta per restituire il risultato richiesto.
MODELLO DEI DATI
 

NOTE
La gestione della prenotazione è molto semplice: una postazione o è occupata o no, non ho voluto inserire vincoli temporali.
L’utente decide la posizione della postazione e la blocca pagando un prezzo che varia a seconda della fila scelta. Ovviamente l’utente registrato sarà lui a prenotare la sua postazione mentre idealmente per quello al botteghino sarà compito del dipendente.
Per evitare problemi di sincronizzazione e programmazione concorrente, fondamentalmente la gestione della liberazione del lettino è compito interamente del dipendente. Cioè se una persona “va via” il dipendente libera il lettino rendendolo disponibile per qualcun altro; prima o poi, idealmente, questo lido chiuderà e quindi il dipendente tramite l’apposita funzionalità può liberare tutti i lettini, pronti per essere bloccati “un altro giorno”. Anche l’utente registrato può liberare una propria postazione ma quella funzionalità è più intesa come la necessità di doverla annullare prima di essere arrivati al lido per motivi personali.
