kubectl apply -f k8s
kubectl set image deployments/travel-brochure-front-deployment travel-brochure-front=jinbay/travel-brochure-front
kubectl set image deployments/travel-brochure-api-deployment travel-brochure-api=jinbay/travel-brochure-api
kubectl set image deployments/travel-brochure-mysql-deployment travel-brochure-mysql=jinbay/travel-brochure-mysql