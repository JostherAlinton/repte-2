/** app.js — Lògica del formulari de contacte
 *
 * Quan l'usuari envia el formulari, recollim les dades,
 * les enviem via fetch() a l'endpoint d'API Gateway (POST /contact),
 * i mostrem un missatge d'èxit o error a l'usuari.
 */

// ⬇️ CANVIA AQUESTA URL per la que et mostri el 'outputs.tf' un cop fet 'terraform apply'
const API_ENDPOINT = "https://adnmdxv1xa.execute-api.us-east-1.amazonaws.com/prod/contact";

// Esperem que la pàgina s'hagi carregat completament
document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("contactForm");
    const submitBtn = document.getElementById("submitBtn");
    const msgEl = document.getElementById("formMsg");

    form.addEventListener("submit", async (event) => {
        // Evitem que la pàgina es recarregui (comportament per defecte del formulari HTML)
        event.preventDefault();

        // Recollim els valors dels camps del formulari
        const name = document.getElementById("name").value.trim();
        const email = document.getElementById("email").value.trim();
        const message = document.getElementById("message").value.trim();

        // Validació bàsica
        if (!name || !email || !message) {
            showMsg("Si us plau, omple tots els camps.", "error");
            return;
        }

        // Desactivem el botó mentre s'envia per evitar dobles clics
        submitBtn.disabled = true;
        submitBtn.textContent = "Enviant...";

        try {
            // Enviem les dades al backend (API Gateway → Lambda → DynamoDB)
            const response = await fetch(API_ENDPOINT, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ name, email, message })
            });

            if (response.ok) {
                showMsg("Missatge enviat correctament! Et respondré aviat.", "success");
                form.reset();
            } else {
                // La Lambda ens ha tornat un error
                showMsg("Error del servidor. Torna-ho a intentar.", "error");
            }
        } catch (err) {
            // Error de xarxa (ex: no hi ha connexió o la URL és incorrecta)
            console.error("Error de xarxa:", err);
            showMsg("No s'ha pogut connectar al servidor.", "error");
        } finally {
            // Tornem a activar el botó
            submitBtn.disabled = false;
            submitBtn.textContent = "Enviar missatge ✉️";
        }
    });

    /** Mostra un missatge de feedback a l'usuari */
    function showMsg(text, type) {
        msgEl.textContent = text;
        msgEl.className = `form-feedback ${type}`;
    }
});
