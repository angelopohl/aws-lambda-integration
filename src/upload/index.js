exports.handler = async (event) => {
  console.log(
    "Mensajes recibidos desde SQS (Batch):",
    JSON.stringify(event.Records),
  );

  const batchItemFailures = [];

  for (const record of event.Records) {
    try {
      console.log(`Procesando mensaje ID: ${record.messageId}`);

      console.log("Recorte simulado completado con éxito.");
    } catch (error) {
      console.error(`Error procesando mensaje ${record.messageId}:`, error);
      batchItemFailures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures };
};
