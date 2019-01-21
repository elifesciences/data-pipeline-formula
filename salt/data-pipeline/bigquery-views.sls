clone biquery-views repo:
    builder.git_latest:
        - name: git@github.com:elifesciences/data-pipeline-bigquery-views
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: master
        - branch: master
        - target: /opt/data-pipeline-bigquery-views
        - force_fetch: True
        - force_checkout: True
        - force_reset: True

    cmd.run:
        - cwd: /opt/data-pipeline-bigquery-views
        - name: docker-compose build
        - require:
            - builder: clone biquery-views repo
        - unless:
            - test -d /vagrant

    file.directory:
        - name: /opt/data-pipeline-bigquery-views
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - cmd: clone biquery-views repo

re-materialise views daily:
    cron.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: cd /opt/data-pipeline-bigquery-views && ./docker-views-cli.sh --dataset={{ pillar.elife.env }} materialize
        - identifier: materialize-views-daily
        # at 1000 every day
        - hour: "10"
        - minute: "0"
        - require:
            - clone biquery-views repo
