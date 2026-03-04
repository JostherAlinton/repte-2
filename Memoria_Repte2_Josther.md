# Memòria del Repte 2: Web Estàtica Serverless

**Autor:** Josther Ozuna
**Cicle:** ASIX

---

## 1. Motiu de selecció del repte

He escollit aquest repte perquè m'apassiona la gestió i l'administració d'entorns web. Em resulta especialment interessant l'evolució de l'arquitectura web que es presenta en aquest projecte: la capacitat de transformar una interfície web aparentment estàtica en una aplicació dinàmica i interactiva a través del núvol. Això s'aconsegueix recollint i emmagatzemant de manera automàtica les dades generades pels usuaris mitjançant tecnologies *serverless*.

A més, el desenvolupament d'aquest repte m'ha permès descobrir i introduir-me de ple en conceptes completament nous per a mi, com avui en dia és la integració i el desplegament continus (CI/CD) utilitzant GitHub Actions. He pogut comprovar de primera mà que GitHub no és només un repositori, sinó una eina fonamental i extremadament potent per a l'automatització, la revisió de codi i l'assegurament de la qualitat en projectes tecnològics.

## 2. Dificultats, Alternatives i Solucions

Durant la implementació del projecte han sorgit diversos reptes tècnics propis del desplegament al núvol, els quals s'han anat resolent pas a pas:

- **Connexió del Frontend amb el Backend:** L'enllaç entre la web estàtica i la funció Lambda es feia a través de l'API Gateway. La dificultat raïa a assegurar que la crida `fetch` del JavaScript enviés les dades correctament i en format JSON.
  - **Solució:** Es va configurar l'API Gateway en format `AWS_PROXY` per passar tot l'esdeveniment HTTP directe a la Lambda, deixant que el codi Node.js processés internament el cos de la petició. També es va establir l'actualització manual de l'Endpoint al fitxer `app.js` un cop finalitzava l'execució de Terraform.

- **Depuració d'errors al núvol:** En aplicacions *serverless*, quan el codi falla (com per exemple en fallar la inserció a DynamoDB), l'error no es veu immediatament a la terminal.
  - **Solució:** Vaig aprendre a utilitzar AWS CloudWatch Logs per monitorar la funció Lambda i fer diagnòstics avançats de problemes mitjançant `console.log`, permetent identificar exactament a quina línia s'aturava l'execució.

- **Utilització de GitHub Actions i Token Security:** Implementar Terraform directament a GitHub Actions va requerir configurar variables d'entorn crítiques.
  - **Solució:** L'ús de "GitHub Secrets" per a protegir les credencials caduques d'AWS Academy (Access Key, Secret Key i Session Token) va permetre que l'entorn de CI/CD executés de manera totalment autònoma i segura les comandes `terraform plan` i `terraform apply`, així com aturar el procés en cas que el *linter* htmlhint detectés errors en l'HTML.

**Alternatives valorades:**
Com a alternativa a temps de disseny, es va analitzar l'allotjament del codi amb **S3 + CloudFront**, ideal per a escalabilitats massives molt econòmiques. No obstant això, es va optar per **AWS Amplify** degut a l'agilitat i integració nativa amb les branques del repositori GitHub. D'altra banda, es va descartar l'ús d'una base de dades relacional com *RDS (MySQL/PostgreSQL)* per decantar-nos cap a **DynamoDB**. Mantenir un RDS 24 hores obert encareix la infraestructura, mentre que per desar missatges d'un menú de contacte, DynamoDB permet un mode de pagament per petició (*Pay-Per-Request*) on el cost és zero quan no hi ha trànsit de dades.

## 3. Nivell de satisfacció

El meu nivell de satisfacció en finalitzar aquest repte és molt alt. Com a estudiant, haver aconseguit dissenyar i posar en marxa una infraestructura completament basada en la filosofia *Cloud Native* resulta altament motivador.

Veure com un simple *git push* cap a GitHub activa automàticament l'anàlisi de sintaxi (*linting*), empaca el codi backend, i llança un desplegament atès exclusivament per codi (Infraestructura com a Codi - IaC amb Terraform), ha estat sens dubte una de les experiències d'aprenentatge més reveladores del curs. M'hi sento molt més familiaritzat i preparat per afrontar els cicles de vida del programari modern i l'administració de sistemes actuals, complint amb l'objectiu d'automatitzar i agilitzar els processos tant com sigui possible.
