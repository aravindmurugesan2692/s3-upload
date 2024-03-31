ec2 has been created and autoscaling has been attached to that instance 
![image](https://github.com/aravindmurugesan2692/s3-upload/assets/138248609/9677f785-fdf3-42e1-88ed-b8de2abf29d0)

Docker images
The web application is packed as docker and hosted in aws ec2 instance.
root@ip-172-31-44-3:~# docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS                   
fcdd754b903b   my-web-app    "/docker-entrypoint.…"   46 hours ago   Created                            
94f7023f4e8a   my-web-app    "/docker-entrypoint.…"   46 hours ago   Created                            
2e56a7f36333   hello-world   "/hello"                 47 hours ago   Exited (0) 47 hours ago         

![image](https://github.com/aravindmurugesan2692/s3-upload/assets/138248609/84d88001-c761-401e-9b63-26aabf044700)
loadbalancer attached to ec2 instance 

![image](https://github.com/aravindmurugesan2692/s3-upload/assets/138248609/24a7b308-5e4a-4f63-bba7-28960b7ce3de)

cloud frond has been set to loadbalancer to reduce the latency

![image](https://github.com/aravindmurugesan2692/s3-upload/assets/138248609/bf6087f5-458f-40a7-8879-5e97d630c073)


s3 bucket policy

![image](https://github.com/aravindmurugesan2692/s3-upload/assets/138248609/ed33823c-ecac-4fc0-ad18-717d84f94720)

i am policy

![image](https://github.com/aravindmurugesan2692/s3-upload/assets/138248609/1d29d487-2d6e-417d-92d8-85ac2568ae72)

target group

![image](https://github.com/aravindmurugesan2692/s3-upload/assets/138248609/c6531b24-6473-49a2-bb83-59c8885e2c03)


