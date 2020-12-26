# Building the client and running it locally:

### Browser

* `budo --port 9000 --cors`  

# Getting the client from the cloud

Enter jenkins project >> Configure >> “Build” section:  
For Browser set: BROWSER_URL=*url*  
For Mobile set: APP_BUILD_URL=*url*  
  
### Note  
* Without BROWSER_URL tests run on localhost  
* APP_BUILD_URL must be either the URL or dir name in ~/ on the test machine where the client build is  