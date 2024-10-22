export PYTHONUNBUFFERED=TRUE

export XDG_CACHE_HOME=/tmp/xdg_cache_home
mkdir -pv $XDG_CACHE_HOME/astropy

ls -tlroa /var/log/containers/


(
    id
    whoami
    export HOME_OVERRRIDE=$PWD/runtime-home
    if [ ! -d "$HOME_OVERRRIDE" ]; then
        echo -e "\033[31mHOME_OVERRRIDE $HOME_OVERRRIDE to be created\033[0m"
        mkdir -pv $HOME_OVERRRIDE
    else
        echo -e "\033[31mHOME_OVERRRIDE $HOME_OVERRRIDE already exists\033[0m"
        ls -l $HOME_OVERRRIDE
    fi

    source /init.sh

    # export TMPDIR=/scratch/tmpdir
    # mkdir -pv TMPDIR
    
    # python -c 'import xspec; print(xspec)'

   # it might be better not to change directory, if jobs need to be preserved between restarts
   # WORK_DIR=$PWD/$(date +%Y-%m-%d-%H-%M-%S)-$$
   # mkdir -pv $WORK_DIR
   # cd $WORK_DIR
    echo -e "\033[31mDISPATCHER_CONFIG_FILE $DISPATCHER_CONFIG_FILE\033[0m"

    if [ ${DISPATCHER_GUNICORN:-no} == "yes" ]; then
        gunicorn \
            "cdci_data_analysis.flask_app.app:conf_app(${DISPATCHER_CONFIG_FILE})" \
            --bind 0.0.0.0:8000 \
            --workers 8 \
            --preload \
            --timeout 900 \
            --limit-request-line 0 \
            --log-level debug
    else
        python /cdci_data_analysis/bin/run_osa_cdci_server.py \
            -conf_file ${DISPATCHER_CONFIG_FILE} \
            -debug \
            -use_gunicorn 2>&1 | tee -a /var/log/containers/${CONTAINER_NAME} -
    fi
)