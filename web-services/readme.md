docker-compose up --build

docker exec -it web-services-flask-1 bash

curl -X POST http://127.0.0.1:5000/iris_post \
   -H 'Content-Type: application/json' \
   -d '{"flower_metrics": "1,2,3,4"}'


curl -X POST http://127.0.0.1:5000/upload \
   -H 'Content-Type: text/csv' \
   -F "file=@data.csv"

curl -X POST -F "file=@test.txt" http://localhost:5000/upload