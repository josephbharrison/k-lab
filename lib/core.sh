#!/usr/bin/env bash

# setup python virtual env
declare platform
[[ $(uname -a | grep -c "Darwin.*arm64") -gt 0 ]] && export DOCKER_DEFAULT_PLATFORM=linux/aarch64

function cook(){
    recipe=$1
    if [[ -d "${LAB_DIR}/recipes/${recipe}" ]]; then
        cp -r "${LAB_DIR}/recipes/${recipe}/." .
    else
        echo "Recipe ${recipe} not found"
        return 1
    fi
}

function set_mode(){
    mode=$1
    case "${mode}" in
        local)  replace '.env.local' '^# \([A-Z_]*=\)' '\1';
                replace '.env.local' '^# APP_\([A-Z]*=\)' 'APP_\1';
                replace '.env.local' '^# CONSUMER_\([A-Z]*=\)' 'CONSUMER_\1';;
        docker) replace '.env.local' '^\([A-Z_]*=\)' '# \1';
                replace '.env.local' '^# APP_\([A-Z]*=\)' 'APP_\1';
                replace '.env.local' '^# CONSUMER_\([A-Z]*=\)' 'CONSUMER_\1';;
    esac
}

function replace(){
    word=$1
    src=$2
    tgt=$2
    echo -e "${word}" | sed "s/${word}/${src}/${tgt}"
}

function split(){
    word=$1
    delim=$2
    echo -e "${word}" | tr "${delim}" '\n'
}

function capitalize(){
    word=$1
    echo -en "${word:0:1}" | tr '[:lower:]' '[:upper:]'
    echo -e "${word:1}"
}

function squish(){
    word=$1
    delim=$2
    replace "${word}" "${delim}" ""
}

function camel_case(){
    data=$1
    delim=$2
    for word in $(split "$data" "$delim")
    do
        cap_word=$(capitalize $word)
        comp_word=${comp_word}${cap_word}
    done
    echo ${comp_word}
}

function cap_words(){
    unset data comp_word cap_word
    data=$1
    delim=$2
    for word in $(split "$data" "$delim")
    do
        cap_word=$(capitalize $word)
        comp_word=${comp_word}${cap_word}${delim}
    done
    # shellcheck disable=SC2001
    echo ${comp_word} | sed 's/-$//'
}

# setup git ignore
function git_ignore(){
    if [[ ! -f .gitignore ]];then
        touch .gitignore
    fi
    venv_c=$(grep -c "^venv/$" .gitignore)

    if [[ ${venv_c} -eq 0 ]];then
        echo "venv/" >> .gitignore
    fi
}

# determine local os
declare os distro
function get_platform(){
    os='unknown'
    unamestr=$(uname | tr "[:upper:]" "[:lower:]")
    if [[ "${unamestr}" == 'linux' ]]; then
        os='linux'
        if [[ -f /etc/os-release ]];then
            distro=$(grep '^ID=' /etc/os-release | awk -F'=' '{ print $2 }')
            [[ -z "$distro" ]] && distro=$(grep ID_LIKE /etc/os-release | awk -F'=' '{ print $2 }')
        else
            distro=$(head -1 /etc/issue | awk '{print $1}' | tr "[:upper:]" "[:lower:]")
        fi
        # assume something other than debian/ubuntu
        if [[ "${distro}" == "\s" ]]; then
            if [[ -f /etc/redhat-release ]]; then
                 distro="redhat"
            else
                 distro="other"
            fi
        fi
    elif [[ "$unamestr" == 'freebsd' ]]; then
        os='freebsd'
    elif [[ "$unamestr" == 'darwin' ]]; then
        os='macosx'
    fi

    if [[ -z "${distro}" ]];then
        echo "${os}"
    else
        echo "${distro}-${os}"
    fi
}

# setup redhat venv
function fedora_venv(){
    sudo dnf -y install python3-virtualenv python3-pip docker docker-compose \
        ansible rpl zlib-devel bzip2 bzip2-devel readline-devel sqlite \
        sqlite-devel openssl-devel xz xz-devel libffi-devel
    PROJ=pyenv-installer
    SCRIPT_URL=https://github.com/pyenv/$PROJ/raw/master/bin/$PROJ
    curl -L $SCRIPT_URL | bash

    export PATH=$PATH:~/.pyenv/bin
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

    py_version=$(python3 --version)
    py_version=${py_version/ /-}
    py_version=$(echo $py_version | tr [:upper:] [:lower:])

    if [[ "${py_version}" != "python-${PY_VERSION}" ]];then
        pyenv install -s ${PY_VERSION}
    fi
    pyenv shell ${PY_VERSION}
    python${PY_VERSION_SHORT} -m venv venv
    sudo systemctl enable docker && sudo systemctl start docker

    sudo chmod 777 /var/run/docker.sock
    alias docker="sudo /usr/bin/docker"
    alias docker-compose="sudo /usr/bin/docker-compose"
}

# setup redhat venv
function redhat_venv(){
    sudo dnf install zlib-devel bzip2 bzip2-devel readline-devel \
        sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel
    sudo systemctl enable docker && sudo systemctl start docker
    python3 -m venv venv
    sudo mv -f /usr/bin/pip /usr/bin/pip.old
    sudo ln -s /usr/bin/pip3 /usr/bin/pip
    sudo chmod 777 /var/run/docker.sock
    alias docker="sudo /usr/bin/docker"
    alias docker-compose="sudo /usr/bin/docker-compose"
}

# setup ubuntu venv
function ubuntu_venv(){
    sudo apt-get update
    sudo apt-get install -y \
        python${PY_VERSION:0:3} \
        python${PY_VERSION:0:1}-venv \
        python${PY_VERSION:0:1}-pip \
        docker.io \
        docker-compose
    sudo usermod -aG docker "$(whoami)"
    python${PY_VERSION:0:1} -m venv venv
    pip install pip --upgrade
}

# setup mac osx venv
function macosx_venv(){
    export PATH="/usr/local/opt/openssl/bin:$PATH"
    export LDFLAGS="-L/usr/local/opt/openssl/lib"
    export CPPFLAGS="-I/usr/local/opt/openssl/include"
    brew update -v &> /dev/null # brew check
    if [[ $? -gt 0 ]];then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    brew list pyenv pyenv-virtualenv docker-compose readline xz &>/dev/null \
        || brew install pyenv pyenv-virtualenv docker-compose readline xz
    if [[ ${PY_VERSION_SHORT} == "2.7" ]];then
        virtualenv -p /usr/bin/python2.7 venv
    else
        py_version=$(python3 --version)
        py_version=${py_version/ /-}
        py_version=$(echo $py_version | tr [:upper:] [:lower:])

        # added for pyenv 2.0.0 -- probably necessary for other OS
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"

        if [[ "${py_version}" != "python-${PY_VERSION}" ]];then
            pyenv install -s ${PY_VERSION}
        fi

        # added for pyenv 2.0.0 -- probably necessary for other OS
        if command -v pyenv 1>/dev/null 2>&1; then
            eval "$(pyenv init --path)"
        fi

        eval "$(pyenv init -)"
        pyenv shell ${PY_VERSION}
        python3 -m venv venv

    fi
}

function setup_venv(){
    operation=$1
    PY_CURRENT=$(python3 --version | awk '{print $2}')
    [[ "${PY_VERSION}" != "${PY_CURRENT}" ]] && \
        [[ -d venv/ ]] && \
        rm -rf venv && \
        deactivate 2> /dev/null
    if [[ ${operation} != clean ]];then
        platform=$(get_platform)
        echo "platform: ${platform}" 1>&2
        case "$platform" in
            redhat-linux)   redhat_venv;;
            fedora-linux)   fedora_venv;;
            ubuntu-linux)   ubuntu_venv;;
            macosx)         macosx_venv;;
        esac
    fi
    # shellcheck disable=SC1090
    [[ -f  ${PROJECT_DIR}/venv/bin/activate ]] && source ${PROJECT_DIR}/venv/bin/activate
    export DEV_ROOT=${VIRTUAL_ENV/\/venv/}
    echo "venv: python-${PY_VERSION}" 1>&2
}

function install_pip(){
    # shellcheck disable=SC1090
    [[ -f  ${PROJECT_DIR}/venv/bin/activate ]] && source ${PROJECT_DIR}/venv/bin/activate
    operation=$1
    if [[ ${operation} != clean ]];then
        if [[ -d ~/.pip.bak/ ]];then
            rm -rf ~/.pip.bak/
        fi

        if [[ -d ~/.pip/ && -d .pip/ ]];then
            mv -f ~/.pip/ ~/.pip.bak/
        fi
        pip install pip --upgrade
    fi
}

function install_dc(){
    # shellcheck disable=SC1090
    [[ -f  ${PROJECT_DIR}/venv/bin/activate ]] && source ${PROJECT_DIR}/venv/bin/activate
    operation=$1
    if [[ ${operation} != clean ]];then
        dc_version=$(docker-compose --version \
            | awk '{ print $3 }' \
            | tr -d ',' \
            | awk -F'.' '{ print $1$2 }')

        if [[ ${dc_version} -lt 123 ]];then
            pip install docker-compose --upgrade &> /dev/null
        fi
    fi
}

function install_req(){
    # shellcheck disable=SC1090
    [[ -f  ${PROJECT_DIR}/venv/bin/activate ]] && source ${PROJECT_DIR}/venv/bin/activate
    operation=$1
    if [[ ${operation} != clean ]];then
        if [[ -d .pip/ ]];then
            cp -r .pip/ ~/.pip/
        fi
        if [[ -f requirements.txt ]];then
            pip install -r requirements.txt &> /dev/null
        fi
    fi
}

function compose(){
    PROJECT=$1
    PROJECT_DIR=$2
    COMPOSE_CMD="docker compose -p ${PROJECT}"
    op=$3
    manifest=$4
    export PROJECT PROJECT_DIR
    # shellcheck disable=SC1090
    [[ -f  ${PROJECT_DIR}/venv/bin/activate ]] && source ${PROJECT_DIR}/venv/bin/activate
    if [[ -d ${PROJECT_DIR}/docker-compose ]];then
        dc_dir=${PROJECT_DIR}/docker-compose
    else
        dc_dir=${CODE_HOME}/k-lab/docker-compose
    fi
    if [[ -n ${manifest} ]];then
        cd ${dc_dir}/${manifest} || exit 0
        [[ -f ignore ]] && return 0
    fi
    if [[ -f install.sh ]];then
        bash install.sh
    elif [[ -f docker-compose.yml ]];then
        if [[ ${OP} == "clean" ]];then
            unset COMPOSE_IGNORE_ORPHANS
            ${COMPOSE_CMD} down --remove-orphans 1>&2
            container_id=$(docker ps -aq --filter name=${manifest}.${PROJECT})
            if [[ -n ${container_id} ]];then
              docker rm ${container_id}
          fi
        else
            export COMPOSE_IGNORE_ORPHANS=true
            if [[ ${OP} == 'build' ]];then
                if [[ -f Dockerfile ]];then
                    [[ -f ${PROJECT_DIR}/.pip/pip.conf ]] && mkdir -p .pip
                    [[ -f ${PROJECT_DIR}/.pip/pip.conf ]] && ln -hf ${PROJECT_DIR}/.pip/pip.conf .pip/
                    [[ -f ${PROJECT_DIR}/requirements.txt ]] && ln -hf ${PROJECT_DIR}/requirements.txt .
                    [[ $VERBOSE ]] && ${COMPOSE_CMD} ${OP} 2>&1 || ${COMPOSE_CMD} -p ${PROJECT} ${OP}
                fi
            elif [[ ${OP} == 'up' ]];then
                [[ $VERBOSE ]] && ${COMPOSE_CMD} ${OP} -d 2>&1 || ${COMPOSE_CMD} ${OP}
            else
                [[ $VERBOSE ]] && ${COMPOSE_CMD} ${OP} 2>&1 || ${COMPOSE_CMD} ${OP}
            fi
        fi
    fi
    if [[ -n "${OP}" && -n ${manifest} ]];then
        if [[ -f .env ]];then
            while IFS='' read -r line || [[ -n "$line" ]]
            do
                echo ${line} >> ${PROJECT_DIR}/.env.tmp
            done < .env
        fi
    fi
    if [[ ${manifest} != "networks" ]];then
        if [[ -z ${manifest} ]];then
            app=${PWD##*/}
            echo "${app}.${PROJECT}: ${op}" 1>&2
        else
            echo "${manifest}.${PROJECT}: ${op}" 1>&2
        fi
    fi
}

function expand(){
    pid=$$
    tmp_file=/tmp/expand.${pid}
    echo 'cat <<END_OF_TEXT' >  ${tmp_file}
    cat "$1"                 >> ${tmp_file}
    echo ''                  >> ${tmp_file}
    echo 'END_OF_TEXT'       >> ${tmp_file}
    bash ${tmp_file} > "$2"
    rm ${tmp_file} "$1"
}

function create_env_file(){
    if [[ -f ${PROJECT_DIR}/.env.local ]];then
        cat "${PROJECT_DIR}/.env.local" >> "${PROJECT_DIR}/.env.tmp"
    fi

    if [[ -f ${PROJECT_DIR}/.env.tmp ]];then
        sed -i'.orig' "s/\${PROJECT}/$PROJECT/" "${PROJECT_DIR}/.env.tmp"
        rm -f "${PROJECT_DIR}/.env.tmp.orig"
        platform=$(get_platform)
        if [[ ${platform} == "macosx" ]];then
            LOCALHOST="docker.for.mac.localhost"
        else
            LOCALHOST="localhost"
        fi
        echo -e "# composer env vars" > "${PROJECT_DIR}/.env.vars"
        echo -e "LOCALHOST=${LOCALHOST}" >> "${PROJECT_DIR}/.env.vars"
        echo -e "USER=${USER}" >> "${PROJECT_DIR}/.env.vars"
        export LOCALHOST
        cat "${PROJECT_DIR}/.env.tmp" >> "${PROJECT_DIR}/.env.vars"
        rm -f "${PROJECT_DIR}/.env.tmp"
        expand "${PROJECT_DIR}/.env.vars" "${PROJECT_DIR}/.env"
    fi
}

function composer(){
    operation=$1
    PROJECT_DIR=${PROJECT_DIR}
    # shellcheck disable=SC1090
    [[ -f  ${PROJECT_DIR}/venv/bin/activate ]] && source "${PROJECT_DIR}/venv/bin/activate"
    [[ -d ${PROJECT_DIR}/docker-compose ]] && dc_dir=${PROJECT_DIR}/docker-compose || dc_dir=${CODE_HOME}/k-lab/docker-compose
    # shellcheck disable=SC1090
    [[ -f ${PROJECT_DIR}/.env.local ]] && source "${PROJECT_DIR}/.env.local"
    [[ -z ${PROJECT} ]] && export PROJECT=${PWD##*/}
    echo "project: ${PROJECT}" 1>&2
    PROJECT=${PROJECT/-worker/}
    export PROJECT

    if [[ -d ${dc_dir} ]];then
        # shellcheck disable=SC2010
        manifests=$(ls -1 ${dc_dir} | grep -v networks)
        # shellcheck disable=SC2116
        manifests=$(echo networks "${manifests}")
        # shellcheck disable=SC2045
        [[ ! -z $COMPOSE ]] && COMPOSE="networks $COMPOSE"
        for manifest in ${COMPOSE}
        do
            compose "${PROJECT}" "${PROJECT_DIR}" "${operation}" "${manifest}"
        done
    fi
}

function compose_local(){
    operation=$1
    # shellcheck disable=SC1090
    [[ -f ${PROJECT_DIR}/.env ]] && source "${PROJECT_DIR}/.env"
    if [[ ${APP_CTRL} != "local" && ! -z ${APP_CTRL} ]];then
        cd "${PROJECT_DIR}" || exit 0
        compose "${PROJECT}" "${PROJECT_DIR}" "${operation}"
    fi
}

function update_hosts(){
    # shellcheck disable=SC1090
    [[ -f  ${PROJECT_DIR}/venv/bin/activate ]] && source "${PROJECT_DIR}/venv/bin/activate"
    if [[ -f ${CODE_HOME}/mac-docker-net/docker-net.sh ]];then
        cd ${CODE_HOME}/mac-docker-net || exit 1
        ./docker-net.sh -H 2> /dev/null
        cd - || exit 1
    elif [[ "${platform}" == "redhat-linux" ]];then
        if [[ -f ${CODE_HOME}/fedora-docker-net/docker-net.sh ]];then
            ${CODE_HOME}/fedora-docker-net/docker-net.sh 2> /dev/null
        fi
    fi
}

function set_aliases(){
    [[ ${os} == 'macosx' ]] && md5_cmd='md5' || md5_cmd='md5sum'
    cd "${PROJECT_DIR}" || exit 1
    # shellcheck disable=SC2016
    aliases='export PROJECT=${PWD##*/}
        [[ -f ${CODE_HOME}/${PROJECT}/.aliases ]] && source ${CODE_HOME}/${PROJECT}/.aliases'
    while read -r alias
    do
        alias_hash=$(echo -e "${alias}" ${md5_cmd})
        exists=0
        if [[ -f ~/.bash_aliases ]];then
            while read -r line
            do
                line_hash=$(echo -e "${line}" ${md5_cmd})
                [[ ${alias_hash} == "${line_hash}" ]] && exists=1 && break
            done < ~/.bash_aliases
        fi
        [[ ${exists} -eq 0 ]] && echo -e "${alias}" >> ~/.bash_aliases
    done <<< "${aliases}"
}

function replace(){
    file=$1
    sexp="$2"
    rexp="$3"
    bak_ext="bak"
    sed -i".${bak_ext}" "s/${sexp}/${rexp}/g" $file
    rm -f ${file}.${bak_ext}
}

function report(){
    [[ ${VERBOSE} == true ]] && echo -e "$@"
}

# get function args
export RES_DESC
function get_args(){
    option="$1"
    desc=$2
    INDENT=40
    arg_str="${option}"
    arg_len=${#arg_str}
    spaces=$((INDENT - arg_len))
    white_space=""
    for (( i = 0; i <= ${spaces}; i++ ))
    do
        white_space=" ${white_space}"
    done
    if [[ ${#white_space} -eq 0 ]];then
        unset desc
    fi
    echo -e "  ${arg_str}${white_space}${desc}"
}

function command_opts(){
    get_args "up" "bring environment up"
    get_args "down" "bring environment down"
    get_args "build" "build containers"
    get_args "clean" "reset the environment"
    get_args "prep" "prepare venv only"
    get_args "recipe -r <recipe>" "configure environment by recipe"
}

function footer_opts(){
    # add example projects to `examples/`
    # get_args "-e | --example <app>" "setup example environment"
    get_args "-m | --mode <local|docker>" "(default: local)"
    get_args "-t | --tag" "python venv version (default: 3.8.5)"
    get_args "-v | --verbose" "verbose output (if available)"
    get_args "-h | --help" "help information (this output)"
}

function usage_footer(){
    echo
    echo "Commands:"
    command_opts | sort -u
    echo
    echo "Options:"
    footer_opts | sort -u
    echo
}
