## Deployment

Hitobito kann wie die meisten Ruby on Rails Applikationen auf verschiedene Arten 
[deployt](http://rubyonrails.org/deploy/) werden. 
Folgende Umsysteme müssen vorgängig eingerichtet werden:

* Ruby >= 1.9.3
* Apache HTTPD
* Phusion Passenger
* MySql
* Memcached
* Sphinx
* Eine Catch-All E-Mail Adresse einer bestimmte Domain für die Mailinglisten (optional)
* SSL Zertifikat (optional)
* Airbrake/Errbit (optional)
 
Um die Applikation zu deployen, werden momentan RPM Packete oder Openshift (experimentell) 
verwendet. Das Script `config/rpm/build_rpm.sh` erstellt mit der Spec Datei 
`config/rpm/rails-app.spec` ein RPM für RHEL/Centos 6. Die Schritte für Openshift sind unter 
`.openshift/README.md` beschrieben. In diesen Skripten sind auch die Befehle hinterlegt, welche bei 
jedem Deployment ausgeführt werden müssen.


### Konfiguration

Um hitobito mit den Umsystemen zu verbinden und zu konfigurieren, können folgende Umgebungsvariablen 
gesetzt werden. Werte ohne Default müssen in der Regel definiert werden. 

| Umgebungsvariable | Beschreibung | Default |
| --- | --- | --- |
| RAILS_HOST_NAME | Öffentlicher Hostname der Applikation. Wird für Links in E-Mails verwendet. | - |
| RAILS_HOST_SSL | Gibt an, ob die Applikation unter HTTPS läuft (`true` or `false`) | `false` |
| RAILS_ROOT_USER_EMAIL | Die E-Mailadresse des Root Users | - |
| RAILS_SECRET_TOKEN | Secret token für die Sessions (128 byte hex). Muss für jede laufende Instanz eindeutig sein. Generierbar mit `rake secret` | - |
| RAILS_DB_NAME | Name der Datenbank | `[environment].sqlite3` |
| RAILS_DB_USERNAME | Benutzername, um auf die Datenbank zu verbinden. | - |
| RAILS_DB_PASSWORD | Passwort, um auf die Datenbank zu verbinden. | - |
| RAILS_DB_HOST | Hostname der Datenbank | - |
| RAILS_DB_PORT | Port der Datenbank | - |
| RAILS_DB_ADAPTER | Datenbank adapter | `sqlite3` |
| RAILS_MAIL_DELIVERY_METHOD | `smtp` oder `sendmail`. Siehe [ActionMailer](http://api.rubyonrails.org/classes/ActionMailer/Base.html) für Details. | `sendmail` |
| RAILS_MAIL_DELIVERY_CONFIG | Eine Komma-separierte `key: value` Liste mit allen erforderlichen E-Mail Sendeeinstellungen der gewählten Methode, z.B. `address: smtp.local, port: 25`. Siehe [ActionMailer](http://api.rubyonrails.org/classes/ActionMailer/Base.html) für gültige Optionen. Wenn diese Variable leer ist, werden die Rails Defaultwerte verwendet. | Rails defaults |
| RAILS_MAIL_PERFORM_DELIVERIES | Kann auf `false` gesetzt werden, falls überhaupt keine E-Mails versendet werden sollen. | `true` |
| RAILS_MAIL_DOMAIN | Der Domainname für die Mailinglisten/Abos | `RAILS_HOST_NAME` |
| RAILS_MAIL_RETRIEVER_TYPE | `pop3` oder `imap`, alles was vom [Mail](https://github.com/mikel/mail) Gem unterstützt wird. | `pop3` |
| RAILS_MAIL_RETRIEVER_CONFIG | Eine Komma-separierte `key: value` Liste mit allen erforderlichen E-Mail Empfangseinstellungen des gewählten Typs, z.B. `address: mailhost.local, port: 995, enable_ssl: true`. Siehe [Mail](https://github.com/mikel/mail#getting-emails-from-a-pop-server) für gültige Optionen. Wenn diese Variable nicht gesetzt ist, funktionieren die Mailinglisten nicht. | - |
| RAILS_SPHINX_HOST | Hostname des Sphinx Servers | 127.0.0.1 |
| RAILS_SPHINX_PORT | Eindeutiger Port des Sphinx Servers. Muss für jede laufende Instanz eindeutig sein. | 9312 |
| MEMCACHE_SERVERS | Komme-getrennte Liste von Memcache Servern in der Form `host:port` | localhost:11211 |
| RAILS_AIRBRAKE_HOST | Hostname der Airbrake/Errbit Instanz, an welche Fehler gesendet werden sollen. Falls diese Variable nicht gesetzt ist, werden keine Fehlermeldungen verschickt. | - |
| RAILS_AIRBRAKE_PORT | Port der Airbrake/Errbit Instanz | 443 |
| RAILS_AIRBRAKE_API_KEY | Airbrake API Key der Applikation | - |
| RAILS_PIWIK_URL | Piwik Server URL | - |
| RAILS_PIWIK_SITE_ID | Piwik ID der Applikation | - |



### Inbetriebnahme

Einmal installiert, müssen zur Inbetriebnahme von hitobito noch folgende Schritte unternommen 
werden:

#### Setup (Entwickler)

1. Integration: Laden der [Seed Daten](#dummy-daten-development-seed).
1. Produktion: Setzen des Passworts des [Root Users](#root-user) über die Passwort vergessen 
Funktion.
1. Erstellen eines Benutzers für den Kunden mit einer Haupt/Admin Rolle.
1. Einrichten einer [Noreply Liste](#no-reply-liste) in einer geeigneten Gruppe.

#### Smoke Tests (Entwickler)

* Full Text Search liefert Resultate (Suchfeld oben rechts)
* Mails werden über Mailing Listen empfangen und weitergeschickt (z.B. via noreply Liste)
* Die Links in den gesendeten Emails sind https (z.B. Passwort vergessen)
* Errbit erhält Fehlermeldungen (Konsole: `rake airbrake:test`)

#### Einrichten (Kunde)

1. Anpassen und Übersetzen der Texte (Admin > Texte).
1. Erfassen von Etikettenformaten, Qualifikationen und Kurstypen.
1. Erfassen von weiteren Gruppen.
1. Erfassen von Personen und diesen ein Login Email schicken.


#### Root User

Die Emailadresse des Root User ist in `RAILS_ROOT_USER_EMAIL` oder im `settings.yml` des
entsprechenden Wagons definiert und wird automatisch über die Seed Daten in die Datenbank geladen. 
Über die Passwort vergessen Funktion kann dafür ein Passwort gesetzt werden. Danach können weitere 
Personen für den Kunden erstellt werden. Der Root User bleibt die einzige Person, mit welcher sich 
Entwickler auf der Produktion einloggen können. Damit haben Entwickler volle Berechtigungen, sind 
aber keiner Gruppe zugewiesen. 

#### No-Reply Liste

Damit jemand bei ungültigen E-Mailadressen oder sonstigen Versandfehlern von E-Mails benachrichtigt 
wird, sollte eine spezielle Mailingliste (in der Applikation unter "Abos" > "Abo erstellen") 
eingerichtet werden, welche auf die Applikations-Sendeadresse lautet (`Settings.email.sender`, z.B. 
`noreply@db.jubla.ch`). Als zusätzlicher Absender muss dabei der verwendete Mailer Daemon definiert 
werden (z.B. `MAILER-DAEMON@puzzle.ch`). Bei dieser Liste sollte eine Person der Organisation als 
Abonnent vorhanden sein, welcher sich um die fehlerhaften Adressen kümmert.

#### Dummy Daten (Development Seed)

Um auf der Integration die Development Seed Daten zu laden, kann folgender Symlink erstellt werden. 
Dies lädt die im Core und dem Wagon definierten Development Seed Daten.

    cd db/seeds && ln -s development/ production
    cd vendor/wagons/hitobito_[wagon]/db/seeds && ln -s development/ production

Alle geseedeten Personen haben Dummy Email Adressen und das selbe Passwort (in den Seed Daten 
definiert). Dadurch kann man sich ohne weiteres als eine andere Person einloggen und die Applikation 
in dieser Rolle testen.

Achtung: Der Symlink sollte nach dem initalen Seeden wieder entfernt werden. Geschieht dies nicht, 
werden für neu (vom Benutzer) angelegten Gruppen bei folgenden Deployements entsprechend Mitglieder 
und Events geseeded.

#### Troubleshooting

* RPM `%preun` Script (z.B. delayed_job workers stoppen) schlägt fehl: Beim Stoppen der Workers wird 
der Applikationscode geladen. In diesem Schritt ist jedoch der alte Code (bzw. Dateien, welche in 
der neuen Version entfernt wurden) noch vorhanden 
(http://www.ibm.com/developerworks/library/l-rpm2/) und kann so zu Loading Problemen führen. Lösung: 
Betreffende Datei ausfindig machen, manuell vom Server löschen und Workers nochmals stoppen 
(`/sbin/service %{name}-workers stop`). Ev. mit weiteren Dateien wiederholen. Sobald das 
funktioniert, die Dateien zu Beginn des `%preun` Abschnitts der Datei `config/rpm/rails-app.spec` 
explizit löschen.
