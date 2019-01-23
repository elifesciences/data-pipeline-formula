bigquery-view docker image:
    docker_image.present:
        # without revision, 'latest' is assumed:
        # https://docs.saltstack.com/en/latest/ref/states/all/salt.states.dockerng.html#salt.states.dockerng.image_present
        - load: elifesciences/data-pipeline-bigquery-views
        # this is a private image and Vagrant machines lack permissions
        - unless:
            - test -d /vagrant

re-materialise views daily:
    cron.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: docker run -e DATA_PIPELINE_BQ_PROJECT=elife-data-pipeline elifesciences/data-pipeline-bigquery-views ./views-cli.sh --dataset={{ pillar.elife.env }} materialize
        - identifier: materialize-views-daily
        # at 1000 every day
        - hour: "10"
        - minute: "0"
        - require:
            - clone biquery-views repo
