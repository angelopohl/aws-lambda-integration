# AWS-lambda-integration

Esta es la solucion para la actividad Planteada en el laboratorio de infraestructura como codigo "AWS + lambda integration".

Para empezar, el proyecto estara dividido de la siguiente manera:

aws-lambda-integration/
├── README.md
├── src/  
│ ├── upload/

│ │ ├── index.js  
│ │ └── package.json

│ └── crop/

│ ├── index.js  
│ └── package.json

├── iac/

│ ├── main.tf  
│ ├── network.tf  
│ ├── security.tf  
│ ├── storage.tf  
│ ├── compute.tf

│ ├── api.tf  
│ ├── observability.tf  
│ ├── variables.tf  
│ ├── outputs.tf  
│ ├── dev.tfvars  
│ ├── qa.tfvars  
│ └── prod.tfvars 
