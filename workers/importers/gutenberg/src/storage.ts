/**
 * S3/MinIO storage adapter for book files.
 *
 * In Phase 0 we target local MinIO (docker compose). Same code path works with
 * Cloudflare R2 or Backblaze B2 by swapping endpoint + credentials in env.
 */
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

interface StorageConfig {
  endpoint: string;
  accessKey: string;
  secretKey: string;
  region: string;
  bucket: string;
  forcePathStyle: boolean;
}

function loadConfig(): StorageConfig {
  return {
    endpoint: process.env.S3_ENDPOINT ?? "http://localhost:9000",
    accessKey: process.env.S3_ACCESS_KEY ?? "librarfree",
    secretKey: process.env.S3_SECRET_KEY ?? "librarfree-dev-password",
    region: process.env.S3_REGION ?? "auto",
    bucket: process.env.S3_BUCKET_CONTENT ?? "books-content",
    forcePathStyle: (process.env.S3_FORCE_PATH_STYLE ?? "true") !== "false",
  };
}

let _client: S3Client | null = null;
let _config: StorageConfig | null = null;

function client(): { s3: S3Client; config: StorageConfig } {
  if (_client && _config) return { s3: _client, config: _config };
  _config = loadConfig();
  _client = new S3Client({
    endpoint: _config.endpoint,
    region: _config.region,
    credentials: {
      accessKeyId: _config.accessKey,
      secretAccessKey: _config.secretKey,
    },
    forcePathStyle: _config.forcePathStyle,
  });
  return { s3: _client, config: _config };
}

export interface UploadResult {
  bucket: string;
  key: string;
  url: string;
  byteSize: number;
}

export async function uploadText(key: string, text: string, contentType = "text/plain; charset=utf-8"): Promise<UploadResult> {
  const { s3, config } = client();
  const body = Buffer.from(text, "utf8");

  await s3.send(
    new PutObjectCommand({
      Bucket: config.bucket,
      Key: key,
      Body: body,
      ContentType: contentType,
      CacheControl: "public, max-age=31536000, immutable",
    }),
  );

  const url = `${config.endpoint.replace(/\/$/, "")}/${config.bucket}/${key}`;
  return {
    bucket: config.bucket,
    key,
    url,
    byteSize: body.byteLength,
  };
}
