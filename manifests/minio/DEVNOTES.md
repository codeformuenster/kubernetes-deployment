

```shell
mc config host add cfm https://minio.codeformuenster.org/ minio minio123
```


```python
# Install Minio library.
# $ pip install minio
#
# Import Minio library.
from minio import Minio

# Initialize minioClient with an endpoint and access/secret keys.
minioClient = Minio('play.minio.io:9000',
                access_key='Q3AM3UQ867SPQQA43P2F',
                secret_key='zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
                secure=True)

# Creates a bucket with name mybucket.
try:
    minioClient.make_bucket("mybucket", location="us-east-1")
except ResponseError as err:
    print(err)

# Upload an object 'myobject.ogg' with contents from '/home/john/myfilepath.ogg'.
try:
    minioClient.put_object('parkleit', 'myobject.csv', file_data,
                           file_stat.st_size, content_type='application/csv')

    minioClient.fput_object('mybucket', 'myobject.ogg', '/home/john/myfilepath.ogg')
```
