data_pipeline:
    nifi:
        aws_access_name: nifidemo-temp
        aws_access_key: dummykey
        aws_secret_access_key: dummysecretkey

        keystore_password: dummyMzRmZDRjYmIwOWIxNjYxNDE
        key_password: dummyYzU5ODU2OGJkMmEwZmQ3MWZjN

        oidc:
            client_id: dummy-client-id
            client_secret: dummy-client-secret

    nifi_registry:
        keystore_password: dummyNzJjMWI2MmJhMGE3ZDhiZ
        key_password: dummyNjZkZDQ3MjQ5ZmYxMTJjMmIy

    bigquery_views:
        revision: latest

elife:
    swap:
        size: 512 # MB

    web_users:
        nifi-registry-: # trailing hyphen not a typo
            username: nifi-registry-user
            password: dummy-password
