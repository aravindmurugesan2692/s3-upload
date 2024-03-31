The web application is packed as docker and hosted in aws ec2 instance.
root@ip-172-31-44-3:~# docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS                   
fcdd754b903b   my-web-app    "/docker-entrypoint.…"   46 hours ago   Created                            
94f7023f4e8a   my-web-app    "/docker-entrypoint.…"   46 hours ago   Created                            
2e56a7f36333   hello-world   "/hello"                 47 hours ago   Exited (0) 47 hours ago         

then ec2 has been created and autoscaling has been attached to that instance 
![image](https://github.com/aravindmurugesan2692/s3-upload/assets/138248609/9677f785-fdf3-42e1-88ed-b8de2abf29d0)

![image](https://github.com/aravindmurugesan2692/s3-upload/assets/138248609/84d88001-c761-401e-9b63-26aabf044700)

