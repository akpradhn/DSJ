## Day 14 : Exploring Mongo Atlas 

![MongoChart](https://github.com/akpradhn/DSJ/blob/master/code-for-30-days/D14_mongo_atlas/mongo_chart.png)

Objective : We will create a script to record network speed and upload it to a server (MongoDb) and visualize the data using mongo chart.


- Create A Cluster
- Create A User
- Allow Network Access




Issues
-
Issue1 : [ The "dnspython" module must be installed to use mongodb+srv:// URIs
](https://stackoverflow.com/questions/52930341/pymongo-mongodbsrv-dnspython-must-be-installed-error)

Solution : [pymongo[tls,srv]==3.6.1](https://github.com/getredash/redash/issues/2603)

Issue2 : pymongo.errors.ServerSelectionTimeoutError: SSL handshake failed: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:841),SSL handshake failed: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:841),SSL handshake failed: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:841)

Solution : [Allow ssl]('https://stackoverflow.com/questions/54484890/ssl-handshake-issue-with-pymongo-on-python3')