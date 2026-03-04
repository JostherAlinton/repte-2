/**
 * contact_handler.js — Funció Lambda
 *
 * Rep el missatge del formulari via API Gateway,
 * el valida i el guarda a DynamoDB com un nou registre.
 *
 * Runtime: Node.js 20.x
 */

// Importem el SDK d'AWS (disponible de sèrie a Lambda)
const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

// Creem el client de DynamoDB
const client = new DynamoDBClient({ region: process.env.AWS_REGION });

// Nom de la taula DynamoDB (la configurem com a variable d'entorn)
const TABLE_NAME = process.env.TABLE_NAME || "contact_messages";

exports.handler = async (event) => {
    console.log("Event rebut:", JSON.stringify(event));

    // Parsegem el body (API Gateway envia les dades com a text JSON)
    let body;
    try {
        body = JSON.parse(event.body);
    } catch (err) {
        return response(400, { error: "Body invàlid: ha de ser JSON" });
    }

    const { name, email, message } = body;

    // Validació bàsica
    if (!name || !email || !message) {
        return response(400, { error: "Falten camps: name, email, message" });
    }

    // Creem un ID únic basat en el timestamp (senzill, serveix per a pràctiques)
    const id = `${Date.now()}`;

    // Guardem el missatge a DynamoDB
    const command = new PutItemCommand({
        TableName: TABLE_NAME,
        Item: {
            id: { S: id },
            name: { S: name },
            email: { S: email },
            message: { S: message },
            createdAt: { S: new Date().toISOString() }
        }
    });

    try {
        await client.send(command);
        console.log(`Missatge guardat amb ID: ${id}`);
        return response(200, { success: true, id });
    } catch (err) {
        // Si hi ha un error, el podem veure a CloudWatch Logs
        console.error("Error guardant a DynamoDB:", err);
        return response(500, { error: "Error intern del servidor" });
    }
};

/** Funció helper per construir la resposta HTTP d'API Gateway */
function response(statusCode, body) {
    return {
        statusCode,
        // Necessari perquè el navegador (des d'un domini diferent) pugui llegir la resposta
        headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        body: JSON.stringify(body)
    };
}
