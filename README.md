# Procesador de Imágenes Serverless (AWS + Terraform)

Este proyecto despliega una arquitectura orientada a eventos en AWS que permite cargar imágenes a través de una API, almacenarlas en S3 y procesarlas automáticamente (redimensionamiento y compresión) mediante colas SQS y funciones Lambda, todo dentro de una red privada (VPC).

## Requisitos Previos

- Terraform (v1.5.0+)
- Node.js (v20.x)
- AWS CLI configurado con credenciales de administrador.
- Postman o similar para pruebas.

## Configuración Inicial

Para proteger la configuración del entorno, el archivo de variables no está incluido en el repositorio. Siga estos pasos para preparar el despliegue:

1. **Clonar el repositorio:**

   ```bash
   git clone <url-de-tu-repo>
   cd <nombre-carpeta>
   ```

2. **Crear el archivo de variables:**

   En la carpeta `/iac`, cree un archivo llamado `dev.tfvars` con el siguiente contenido (ajuste los nombres para evitar colisiones globales en S3):

   ```hcl
   project_name = "aws-lambda-integration"
   environment  = "dev"
   region       = "us-east-1"
   # El nombre del bucket debe ser único en todo AWS
   bucket_name  = "tu-nombre-lab-upao-final" 
   ```

3. **Inicializar Terraform:**

   ```bash
   cd iac
   terraform init
   ```

## Despliegue

Para levantar toda la infraestructura:

```bash
terraform apply -var-file="dev.tfvars" -auto-approve
```

Al finalizar, Terraform entregará un Output llamado `api_endpoint`. Cópielo para las pruebas.

## Pruebas (Postman)

- **Método:** POST
- **URL:** `<api_endpoint_obtenido>`
- **Body:** Seleccione binary y cargue una imagen `.jpg` o `.png`.

**Verificación:**
- Revise el bucket en la carpeta `uploads/` para ver la imagen original.
- Espere unos segundos y revise la carpeta `processed/` para ver la imagen con tamaño reducido (80% del original).

## Arquitectura y Seguridad

- **VPC:** Las Lambdas operan en subredes privadas sin salida directa a Internet.
- **VPC Endpoints:** Se utilizan endpoints de S3 y SQS para que el tráfico nunca salga de la red de AWS, optimizando seguridad y costos.
- **Resiliencia:** Uso de dos Zonas de Disponibilidad y una DLQ (Dead Letter Queue) para manejar mensajes de SQS fallidos.

## Limpieza

Para evitar cargos innecesarios en AWS, ejecute:

```bash
terraform destroy -var-file="dev.tfvars" -auto-approve
```
