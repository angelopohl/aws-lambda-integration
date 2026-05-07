const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const s3 = new S3Client({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  console.log("Evento recibido desde API Gateway:", JSON.stringify(event));

  try {
    const bucketName = process.env.BUCKET_NAME;
    const fileName = `${process.env.UPLOAD_PREFIX || "uploads/"}imagen-${Date.now()}.jpg`;

    const imageContent =
      "Contenido simulado de la imagen (base64 decodificado)";

    await s3.send(
      new PutObjectCommand({
        Bucket: bucketName,
        Key: fileName,
        Body: imageContent,
        ContentType: "image/jpeg",
      }),
    );

    console.log(`Imagen guardada exitosamente en S3: ${fileName}`);

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Upload exitoso", file: fileName }),
    };
  } catch (error) {
    console.error("Error al subir la imagen:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Error interno del servidor" }),
    };
  }
};
