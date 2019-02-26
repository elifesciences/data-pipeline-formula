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

        sensitive_props:
            key: ""
            algorithm: PBEWITHMD5AND256BITAES-CBC-OPENSSL
            provider: BC

    nifi_registry:
        keystore_password: dummyNzJjMWI2MmJhMGE3ZDhiZ
        key_password: dummyNjZkZDQ3MjQ5ZmYxMTJjMmIy

    bigquery_views:
        revision: latest

elife:
    swap:
        path: /ext/swap.1

    web_users:
        nifi-registry-: # trailing hyphen not a typo
            username: nifi-registry-user
            password: dummy-password
