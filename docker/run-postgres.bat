docker run  --restart unless-stopped -d --name postgres -v /home/khai/postgres_data:/var/lib/postgresql/data -p 5432:5432 -e POSTGRES_PASSWORD=1234 postgres