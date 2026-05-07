const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const s3 = new S3Client({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  try {
    const bucketName = process.env.BUCKET_NAME;
    const fileName = `${process.env.UPLOAD_PREFIX || "uploads/"}imagen-${Date.now()}.jpg`;

    const imageBuffer = event.body
      ? Buffer.from(event.body, event.isBase64Encoded ? "base64" : "utf8")
      : Buffer.from("imagen_simulada");

    await s3.send(
      new PutObjectCommand({
        Bucket: bucketName,
        Key: fileName,
        Body: imageBuffer,
        ContentType: "image/jpeg",
      }),
    );

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Upload exitoso", file: fileName }),
    };
  } catch (error) {
    return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
  }
};
