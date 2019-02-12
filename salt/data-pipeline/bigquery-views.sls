bigquery-view docker image:
    cmd.run:
        # pull but not if already present, to avoid accidental updates
        - name: docker run elifesciences/data-pipeline-bigquery-views:{{ pillar.data_pipeline.bigquery_views.revision }} sh
        # this is a private image and Vagrant machines lack permissions
        - unless:
            - test -d /vagrant

re-materialise views daily:
    cron.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: docker run --rm -e DATA_PIPELINE_BQ_PROJECT=elife-data-pipeline elifesciences/data-pipeline-bigquery-views:{{ pillar.data_pipeline.bigquery_views.revision }} ./views-cli.sh --dataset={{ pillar.elife.env }} materialize-views
        - identifier: materialize-views-daily
        # at 1000 every day
        - hour: "10"
        - minute: "0"
        - require:
            - bigquery-view docker image
