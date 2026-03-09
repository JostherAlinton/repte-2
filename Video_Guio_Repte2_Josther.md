# Guion del Vídeo: Reto 2 - Web Estática Serverless

**Presentador:** Josther Ozuna

---

## 1. Flujo de Datos del Formulario

* **Visual:** Muestra un esquema básico en la pantalla o el archivo `app.js` donde envías los datos.
* **Josther (Voz):** "Hola, soy Josther. Antes de programar nada, diseñé cómo viajaría la información del formulario. El flujo es muy simple: el cliente (el navegador) envía los datos a nuestro API Gateway. Este actúa de proxy y le pasa la petición tal cual a una función Lambda. Entonces, la Lambda hace el trabajo de procesar los datos, guardándolos en una base de datos DynamoDB."

## 2. Elección del Runtime de Lambda

* **Visual:** Código de la Lambda o la configuración en Terraform.
* **Josther (Voz):** "En la Lambda he elegido utilizar Node.js en vez de Python. Como la parte web ya utilizaba JavaScript, era mucho más sencillo y práctico para mí mantener el mismo lenguaje en el backend. Además, para scripts así de cortos, Node.js es muy rápido para arrancar, lo que en AWS llaman 'cold start', asegurando que responda casi al instante."

## 3. Error Deliberado y CloudWatch Logs

* **Visual:** Código con la línea comentada y después mostrando los registros en CloudWatch de AWS.
* **Josther (Voz):** "Para enseñar cómo diagnosticar un error cuando estamos trabajando en la nube, he comentado a propósito la línea del código que guarda el dato en DynamoDB. Esto hace que el servidor me diga que todo ha ido bien, pero no se guarda nada. Para averiguar por qué, fui a ver los AWS CloudWatch Logs. Añadiendo unos simples `console.log()` he podido ver en el registro dónde se paraba exactamente mi función, confirmando rápidamente el error sin necesidad de especular."

## 4. Amplify vs S3+CloudFront

* **Visual:** La consola de AWS Amplify o el resumen del pipeline en tu GitHub.
* **Josther (Voz):** "A la hora de publicar mi web HTML y CSS estática, he usado Amplify en lugar de la mítica dupla de `S3 + CloudFront`. La diferencia principal es que Amplify se conecta automáticamente a mi GitHub y me actualiza la página solo cada vez que hago un *push*. `S3 + CloudFront` requiere que te lo montes todo a mano para hacer esto; está bien si controlas mucho o para rebajar céntimos siendo una empresa gigante, pero para un proyecto sencillo como el mío, Amplify es la mejor herramienta para ahorrar dolores de cabeza."

## 5. Coste de la Arquitectura: 10K vs 1M visitas

* **Visual:** Una pizarra o el bloc de notas con las diferencias de alrededor de 0.5$ y 7$.
* **Josther (Voz):** "Tenemos que hablar de dinero. Como la arquitectura es completamente serverless, si la web solo tuviera unas 10.000 visitas mensuales AWS quizás nos costaría unos 50 céntimos ($0.50). Prácticamente gratis dado que la actividad en Dynamo API Gateway es en modalidad de 'paga-solo-lo-que-usas'. Incluso si fuésemos súper famosos y tuviéramos 1.000.000 de visitas, la factura de Cloud nos supondría apenas 7 dólares mensuales gracias a no tener ningún servidor web encendido. Más barato, imposible."

## 6. ¿Por qué DynamoDB y no RDS?

* **Visual:** La consola aws DynamoDB o el código simplificado Terraform del `main.tf`.
* **Josther (Voz):** "Finalmente, ¿por qué he guardado los mensajes de contacto en DynamoDB y no en un clásico servidor de datos de PostgreSQL en RDS? Sinceramente, muy fácil. Mis datos son nombre y un texto de mensaje suelto. No existen relaciones, esquemas grandes y no nos hacen falta tablas cruzadas. Con RDS, tendría que hospedar una instancia y tener un ordenador entero dedicado corriendo y gastando dinero 24 horas. Con DynamoDB tengo el modo bajo demanda de coste 0 base y para un formulario simple sirve y sobra."

## 7. Apuntes Rápidos del Código

* **Visual:** Muestra rápido partes del `app.js` de la web, `contact_handler.js` o el Terraform `main.tf`.
* **Josther (Voz):** "Y para terminar, os doy 3 apuntes clave que hacen funcionar el código sin entrar en detalles complejos:
  * **En la web (`app.js`):** Uso la función `fetch()` de JavaScript para agarrar lo que la persona escribe y mandarlo a mi API en un formato paquete llamado JSON.
  * **En el backend (`contact_handler.js`):** Mi Lambda de AWS recibe ese paquete de texto JSON, mira que no venga en blanco y lanza un comando (`PutItemCommand`) para meter directamente la fila en la tabla de DynamoDB.
  * **En la infraestructura (`main.tf`):** Puse en Terraform que mi API Gateway use el modo `AWS_PROXY`. Esto significa que el API Gateway no analiza ni toca nada, solo actúa de tubo que pasa los datos directos entre la web y la Lambda. Así de fácil y rápido."
