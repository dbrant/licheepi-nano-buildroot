# use this to iterate on changes to config without rebuilding the entire
# image from scratch; ensure to clean the right stamps/folders to correctly
# trigger rebuild with Buildroot

ARG BASE_IMAGE=unframework/licheepi-nano-buildroot
ARG BASE_VERSION=latest

FROM $BASE_IMAGE:$BASE_VERSION AS local

#RUN apt-get install -qy nasm pkg-config python3 zlib1g-dev build-essential

# copy newest version of local files
WORKDIR /root/licheepi-nano
COPY board/ board/
COPY configs/ configs/
COPY package/ package/
COPY \
    Config.in \
    external.desc \
    external.mk \
    ./

# in case the repo was checked out in Windows, explicitly remove CR characters from text files.
RUN find /root/licheepi-nano/ -type f ! \( -name '*.bmp' -o -name '*.nes' \) -exec sed -i 's/\r$//' {} \;

# reset Buildroot config and trigger Linux kernel rebuild
WORKDIR /root/buildroot


RUN BR2_EXTERNAL=/root/licheepi-nano make nesemu2

#RUN BR2_EXTERNAL=/root/licheepi-nano make licheepi_nano_defconfig


RUN cd output/build/uboot-v2021.01-f1c100s-4/ && rm .stamp_built .stamp_*installed
RUN cd output/build/host-uboot-tools-2021.07/ && rm .stamp_built .stamp_*installed
RUN cd output/build/linux-custom/ && rm .stamp_dotconfig .stamp_configured .stamp_built .stamp_*installed
RUN cd output/build/linux-firmware-20221214/ && rm .stamp_built .stamp_*installed

# re-run build
RUN make

# expose built image files in standalone root folder
FROM scratch AS localout
COPY --from=local /root/buildroot/output/images/ .
