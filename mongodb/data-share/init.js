use mydb
db.sample.insert({"name":"sample"})
use admin
db.createUser(
  {
    user: "sachin",
    pwd: "123456",
    roles: [ { role: "readWrite", db: "mydb" } ]
  }
)