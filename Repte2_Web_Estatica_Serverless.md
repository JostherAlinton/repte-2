# 📝 Repte 2 — Web estàtica amb Amplify, GitHub Actions i API Gateway + Lambda

## 1. Diagrama i Flux de Dades (Passos de Reflexió Previs)

Abans d'escriure cap línia de codi, he dissenyat el flux de dades del formulari:

```
[Navegador de l'usuari]
        │
        │ 1. L'usuari omple el formulari i clica "Enviar"
        │ 2. app.js fa fetch(POST) amb les dades en format JSON
        ▼
[API Gateway — endpoint /contact]
        │
        │ 3. API Gateway rep la petició HTTP i l'envia a Lambda (format AWS_PROXY)
        ▼
[Lambda — contact_handler.js (Node.js 20.x)]
        │
        │ 4. Lambda valida els camps (name, email, message)
        │ 5. Si tot és OK, escriu un nou element a DynamoDB
        ▼
[DynamoDB — Taula: contact_messages]
        │
        │ 6. Lambda retorna HTTP 200 { success: true } a API Gateway
        ▼
[API Gateway → Navegador]
        │
        │ 7. app.js rep la resposta i mostra "✅ Missatge enviat!"
```

---

## 2. Estructura del Projecte

```
repte-2/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          ← Workflow de CI/CD amb GitHub Actions
├── src/
│   ├── index.html             ← Pàgina web estàtica (portfolio)
│   ├── style.css              ← Estils moderns (glassmorphism)
│   └── app.js                 ← JavaScript del formulari (envia dades a API GW)
├── lambda/
│   └── contact_handler.js     ← Funció Lambda: rep el formulari i guarda a DynamoDB
└── terraform/
    ├── provider.tf            ← Configuració del provider AWS
    ├── variables.tf           ← Variables (regió, nom del projecte, token GitHub)
    ├── dynamodb.tf            ← Taula DynamoDB per guardar missatges
    ├── lambda.tf              ← Funció Lambda i el seu empaquetat ZIP
    ├── api_gateway.tf         ← API REST amb endpoint POST /contact
    └── outputs.tf             ← Mostra la URL de l'API un cop desplegada
```

---

## 3. Explicació dels Fitxers

### La web: `src/index.html`, `style.css`, `app.js`

- **`index.html`**: Pàgina de portfolio amb una capçalera, secció de projectes i un formulari de contacte. Molt senzilla però visualment atractiva.
- **`style.css`**: Estil modern amb colors violetes/rosa, efecte `glassmorphism` (panells translúcids), i micro-animacions en les targetes i els botons.
- **`app.js`**: Escolta l'event `submit` del formulari. Quan l'usuari prem el botó, recull els valors dels camps (nom, correu, missatge), els envia en format JSON a l'endpoint de l'API Gateway via `fetch()`, i mostra un missatge de confirmació o error. **Important**: Cal actualitzar la constant `API_ENDPOINT` amb la URL real que mostra `terraform output api_gateway_endpoint`.

### La Lambda: `lambda/contact_handler.js` (Node.js 20.x)

**Per què Node.js i no Python?**

- El SDK v3 d'AWS per a JavaScript té una sintaxi molt clara amb `async/await`, ideal per a principiants.
- El *cold start* de Node.js (el temps que tarda Lambda a arrencar per primer cop) és dels més baixos, al voltant de 100-300ms.
- Python seria una alternativa igual de vàlida (i potser més familiar si coneixes scripting), però com que el formulari és JavaScript, té sentit mantenir el mateix ecosistema al backend.

El handler rep l'event d'API Gateway, parseja el body JSON, el valida i crida `PutItemCommand` de DynamoDB per crear un nou element amb un ID basat en el timestamp actual.

### DynamoDB: `terraform/dynamodb.tf`

He triat DynamoDB en comptes de RDS per un motiu clau: **els missatges d'un formulari de contacte són dades simples i sense relacions entre elles**. No hi ha `JOIN`s, ni relacions de clau forana, ni esquemes complexos. DynamoDB és perfecte per a aquest cas:

- **No cal administrar cap servidor** (és serverless, com la Lambda).
- **Mode `PAY_PER_REQUEST`**: no paguem res mentre no hi ha peticions. Per a un portfolio amb poca activitat, el cost és pràcticament zero.

Si haguéssim utilitzat RDS, hauríem de mantenir una instància corrent les 24h, amb el cost corresponent (~$15-25/mes de mínim).

### API Gateway: `terraform/api_gateway.tf`

He creat una API REST bàsica amb un sol recurs (`/contact`) i un sol mètode (`POST`). El punt més important és que he triat la integració de tipus **`AWS_PROXY`**: significa que API Gateway envia l'event HTTP complet (headers, body, IP del client...) directament a la Lambda, sense transformar res. Això és el setup més estàndard i fàcil d'entendre.

### GitHub Actions: `.github/workflows/ci-cd.yml`

El pipeline té 2 passes:

1. **`lint`**: Comprova que l'HTML no té errors (amb `htmlhint`). Si l'HTML té errors que el Linter detecta, el pipeline s'atura i **no arriba mai a desplegar**.
2. **`deploy`**: (Només s'executa si el linting passa) Configura les credencials d'AWS usant *secrets* de GitHub, i executa `terraform apply` per desplegar o actualitzar la infraestructura automàticament.

> **Important per a AWS Academy:** Les credencials canvien cada sessió. Hauràs d'actualitzar els secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` i `AWS_SESSION_TOKEN` al repositori GitHub cada vegada que iniciïs una nova sessió al Learner Lab.

---

## 4. Com Desplegar Pas a Pas

### Pas 1: Preparació

```bash
# Clonar el repositori (o crear-ne un de nou a GitHub amb el codi)
git init
git add .
git commit -m "Initial commit: Repte 2 portfolio"
git remote add origin https://github.com/josther-ozuna/portfolio-repte2.git
git push -u origin main
```

### Pas 2: Configurar secrets a GitHub

A el repositori GitHub → Settings → Secrets and variables → Actions, afegir:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `GH_TOKEN` (Personal Access Token de GitHub amb permisos `repo`)

### Pas 3: El primer desplegament

El simple fet de fer `git push origin main` activarà el workflow de GitHub Actions. Podràs veure el progrès en temps real a la pestanya **Actions** del repositori.

### Pas 4: Actualitzar l'endpoint a app.js

Un cop el Terraform hagi acabat, al log del GitHub Action veuràs:

```
api_gateway_endpoint = "https://abc123.execute-api.us-east-1.amazonaws.com/prod/contact"
```

Substitueix la constant `API_ENDPOINT` a `src/app.js` per aquesta URL, fes commit i push.

### Pas 5: Verificació

```bash
# Provar l'API directament des de la línia de comandes
curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Josther","email":"test@test.com","message":"Hola!"}'

# Comprovar que s'ha guardat a DynamoDB
aws dynamodb scan --table-name contact_messages
```

---

## 5. Error Deliberat i Diagnosi amb CloudWatch Logs

Un cop tot funciona, he introduït un error a `contact_handler.js` comentant la línia que desa a DynamoDB:

```js
// LÍNIA ELIMINADA INTENCIONADAMENT:
// await client.send(command);  <-- Comentat!
return response(200, { success: true, id }); // Retorna OK... però no ha desat res!
```

**Resultat**: L'API retorna 200 OK (sembla que funciona), però a DynamoDB no apareix cap nou registre.

**Diagnosi a CloudWatch Logs:**

1. Accedir a AWS Console → CloudWatch → Log groups.
2. Cercar `/aws/lambda/portfolio-repte2-contact-handler`.
3. Al log de l'última invocació veuràs: `Missatge guardat amb ID: ...` però... si afegim un `console.log` abans del `send` i un altre just després:

```
[LOG] Guardant missatge...
[LOG] ← (Aquí no apareix res, perquè la línia del 'send' estava comentada)
```

Amb les línies de log ben col·locades, és fàcil saber exactament on s'ha aturat l'execució. Això és la utilitat principal de CloudWatch per depurar Lambdas.

---

## 6. Secció de Reflexió

### Diferència entre Amplify i S3+CloudFront per servir contingut estàtic

| Característica | AWS Amplify | S3 + CloudFront |
|---|---|---|
| **Facilitat** | Molt fàcil, connecta directament amb GitHub | Requereix configurar el bucket + distribució + invalidació de cache |
| **CI/CD integrat** | ✅ Sí, automàtic per branca | ❌ Cal configurar-ho manualment (ex: GitHub Actions) |
| **Preu** | Paguem per build i per GB servit (~$0.01/min build) | Només paguem per S3 i per transferència CloudFront (més barat per a grans volums) |
| **Control** | Menys control (Amplify decideix moltes coses) | Control total de la distribució |
| **Preview per PR** | ✅ Sí, auto-genera URLs per cada PR | ❌ Cal automació addicional |

**Conclusió**: Amplify és ideal per a projectes petits i ràpids. S3+CloudFront és millor per a grans plataformes on el cost de CloudFront per volum és molt menor.

### Cost estimat: 10.000 vs 1.000.000 visites/mes

**10.000 visites/mes (tràfic baix, ex: portfolio personal):**

- Amplify Hosting: ~$0.01 per build + $0.15/GB → ~$0.50/mes
- Lambda: 10.000 invocacions × gratuït (1M invocacions gratis/mes) → **$0.00**
- API Gateway: 10.000 peticions × 0.0035/10K peticions → **$0.00**
- DynamoDB: pay-per-request, prou baix → **~$0.01**
- **Total estimat: ~$0.51/mes** ✅

**1.000.000 visites/mes (tràfic mig-alt):**

- Amplify Hosting: $1 + cost de transferència (~15 GB) → ~$3.00/mes
- Lambda: al Tier gratuït, però si supera 1M → 0.20$/M sol·licituds → **~$0.20**
- API Gateway: 1M peticions × $3.50/M → **~$3.50**
- DynamoDB: ~100K escriptures → **~$0.13**
- **Total estimat: ~$6.83/mes** ✅

### Per què DynamoDB i no RDS?

- **DynamoDB** és *serverless*: no paguem cap màquina parada. Escala automàticament. Per a dades simples (missatges de formulari) no necessitem SQL ni relacions.
- **RDS** és un servidor de base de dades gestionat per AWS, però **sempre en funcionament** (mínim ~$15-25/mes). Aporta potència per a esquemes complexos amb `JOIN`s, transaccions i dades relacionals.
- Per al formulari de contacte, totes les dades d'un missatge caben en un sol element de DynamoDB. **No hi ha res que justifiqui el cost d'una RDS**.

### Alternativa On-Premises

Si haguéssim de muntar tot això sense el núvol:

1. **Nginx** servint els fitxers estàtics (`/var/www/html/`) a la màquina local.
2. **Backend Flask (Python) o Express (Node.js)** exposant una ruta `POST /contact` que llegeix el body i l'insereix a SQLite (per a proves) o PostgreSQL (per a producció).
3. **CI/CD**: Un repositori local a **Gitea** (equivalent a GitHub *self-hosted*), amb **Drone CI** o **Jenkins** fent la compilació/linting i el desplegament automàtic amb scripts de shell.
4. **Base de dades**: PostgreSQL a la mateixa màquina o a un servidor dedicat.

**Desavantatge clau**: Necessitem mantenir i administrar els servidors nosaltres mateixos. Al núvol, Lambda i DynamoDB funcionen sols sense cap administració.
