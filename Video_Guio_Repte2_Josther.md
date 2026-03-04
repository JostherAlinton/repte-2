# Guió del Vídeo: Repte 2 - Web Estàtica Serverless

**Presentador:** Josther Ozuna

---

## 1. Flux de Dades del Formulari

* **Visual:** Mostra un esquema bàsic a la pantalla o l'arxiu `app.js` on envies les dades.
* **Josther (Veu):** "Hola, soc el Josther. Abans de programar res, vaig dissenyar com viatjaria la informació del formulari. El flux és molt simple: el client (el navegador) envia les dades al nostre API Gateway. Aquest actua de proxy i li passa la petició tal qual a una funció Lambda. Llavors, la Lambda fa la feina de processar i processar les dades, guardant-les en una base de dades DynamoDB."

## 2. Elecció del Runtime de Lambda

* **Visual:** Codi de la Lambda o la configuració a Terraform.
* **Josther (Veu):** "A la Lambda he triat utilitzar Node.js en comptes de Python. Com que la part web ja utilitzava JavaScript, era molt més senzill i pràctic per mi mantenir el mateix llenguatge al backend. A més, per scripts així de curts, Node.js és molt ràpid per arrencar, el que a AWS anomenen 'cold start', assegurant que respon gairebé a l'instant."

## 3. Error Deliberat i CloudWatch Logs

* **Visual:** Codi amb la línia comentada i després mostrant els registres a CloudWatch de AWS.
* **Josther (Veu):** "Per ensenyar com diagnosticar un error quan estem treballant al núvol, he comentat a propòsit la línia del codi que desa la dada a DynamoDB. Això fa que el servidor em digui que tot ha anat bé, però no es guarda res.  Per esbrinar per què, vaig anar a veure els AWS CloudWatch Logs. Afegint uns simples `console.log()` he pogut veure al registre on es parava exactament la meva funció, confirmant ràpidament l'error sense necessitat d'especular."

## 4. Amplify vs S3+CloudFront

* **Visual:** La consola d'AWS Amplify o el resum del pipeline al teu GitHub.
* **Josther (Veu):** "A l'hora de publicar la meva web HTML i CSS estàtica, he usat Amplify enlloc de la mítica dupla de `S3 + CloudFront`. La diferència principal és que Amplify es connecta automàticament al meu GitHub i m'actualitza la pàgina sol cada cop que faig un *push*. `S3 + CloudFront` requereix que t'ho muntis tot a mà per fer això; està bé si controles molt o per rebaixar cèntims sent una empresa gegant, però per a un projecte senzill com el meu, Amplify és la millor eina per estalviar maldecaps."

## 5. Cost de l'Arquitectura: 10K vs 1M visites

* **Visual:** Una pissarra o el bloc de notes amb les diferències al voltant de 0.5$ i 7$.
* **Josther (Veu):** "Hem de parlar de diners. Com que l'arquitectura és completament serverless, si la web només tingués unes 10.000 visites mensuals AWS potser ens costaria uns 50 cèntims ($0.50). Pràcticament gratis donat que l'activitat en Dynamo API Gateway és en modalitat de 'paga-sol-el-que-riddles'. Fins i tot si fóssim super famosos i tinguéssim 1.000.000 de visites, la factura de Cloud ens suposarien tot just 7 dòlars mensuals gràcies a no tenir cap servidor web encès. Més barat, impossible."

## 6. Per què DynamoDB i no RDS?

* **Visual:** La consola aws DynamoDB o el codi simplificat Terraform del `main.tf`.
* **Josther (Veu):** "Finalment, per què he guardat els missatges de contacte a DynamoDB i no pas a un clàssic servidor de dades de PostgreSQL a RDS? Sincerament, molt fàcil. Les meves dades són nom i un text de missatge solt. No existeixen relacions, esquemes grans i no ens calen taules creuades. Amb RDS, hauria d'apagar una instància i tenir un ordinador sencer dedicat corrent i gastant diners 24 hores. Amb DynamoDB tinc el mode sota demanda de cost 0 base i per un formulari estilitzat servex i sobra."
