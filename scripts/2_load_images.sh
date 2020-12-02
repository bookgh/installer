#!/bin/bash

BASE_DIR=$(dirname "$0")
# shellcheck source=./util.sh
source "${BASE_DIR}/utils.sh"
IMAGE_DIR=images

cd "${BASE_DIR}" || return

function load_image_files() {
    echo_green "\n>>> 加载镜像"
    images=$(get_images)
    for image in ${images};do
        echo ""
        filename=$(basename ${image}).tar
        filename_windows=${filename/:/_}
        if [[ -f ${IMAGE_DIR}/${filename_windows} ]];then
            filename=${filename_windows}
        fi
        if [[ ! -f ${IMAGE_DIR}/${filename} ]];then
            echo_red "镜像文件没有发现: ${IMAGE_DIR}/${filename}"
            continue
        fi

        echo -n "${image} <= ${IMAGE_DIR}/${filename}: "
        md5_filename=$(basename "${image}").md5
        md5_path=${IMAGE_DIR}/${md5_filename}
        image_id=$(docker inspect -f "{{.ID}}" "${image}" 2> /dev/null || echo "")
        saved_id=""

        if [[ -f "${md5_path}" ]];then
          saved_id=$(cat "${md5_path}")
        fi
        if [[ ${image_id} != "${saved_id}" ]];then
            docker load < "${IMAGE_DIR}/${filename}"
        else
            echo "has loaded, pass"
        fi

    done
}

function pull_image() {
    echo_green "\n>>> 二、拉取镜像"
    images=$(get_images public)
    i=1
    for image in ${images};do
      echo_yellow "$i. ${image}"
      docker pull "${image}"
      echo ""
      (( i++ )) || true
    done
}

if  [[ -d "${IMAGE_DIR}" && -f "${IMAGE_DIR}/redis:alpine.tar" ]];then
  load_image_files
else
  pull_image
fi


