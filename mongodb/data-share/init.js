use mydb
db.sample_collection.insert({"fName":"Sachin", "lName": "Shukla"})

use mydb2
db.sample_collection2.insert({"fName":"Sachin2", "lName": "Shukla2"})


use admin
db.createUser(
  {
    user: "sachin",
    pwd: "123456",
    roles: [ { role: "readWrite", db: "mydb" },{ role: "readWrite", db: "mydb2" } ]
  }
)