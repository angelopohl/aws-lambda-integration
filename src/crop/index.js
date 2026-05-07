const {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
} = require("@aws-sdk/client-s3");
const s3 = new S3Client({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  const bucketName = process.env.BUCKET_NAME;

  for (const record of event.Records) {
    try {
      const body = JSON.parse(record.body);
      const s3Event = body.Records[0];
      const originalKey = s3Event.s3.object.key;

      const getObj = await s3.send(
        new GetObjectCommand({
          Bucket: bucketName,
          Key: originalKey,
        }),
      );

      const streamToBuffer = (stream) =>
        new Promise((resolve, reject) => {
          const chunks = [];
          stream.on("data", (chunk) => chunks.push(chunk));
          stream.on("error", reject);
          stream.on("end", () => resolve(Buffer.concat(chunks)));
        });

      const imageBuffer = await streamToBuffer(getObj.Body);

      const processedBuffer = imageBuffer.slice(
        0,
        Math.floor(imageBuffer.length * 0.8),
      );
      const newKey = originalKey.replace("uploads/", "processed/");
      await s3.send(
        new PutObjectCommand({
          Bucket: bucketName,
          Key: newKey,
          Body: processedBuffer,
          ContentType: "image/jpeg",
        }),
      );

      console.log("Procesamiento completado");
    } catch (e) {
      console.error(e);
    }
  }
};
