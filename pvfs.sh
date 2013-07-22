#!/bin/bash
# export env
if [ ! -d $HOME/build ]; then
    mkdir $HOME/build
fi
export PVFS2TAB_FILE=$HOME/build/pvfs2tab

# get hostname lists, make sure all hostnames are unique
HOSTS="$( mpiexec ./hostname )"
for HOSTNAME in ${HOSTS} ; do
    echo ${HOSTNAME}
done

# modify hostname in tab file
i=1;
if [ -f ${HOME}/build/pvfs2tab ]; then
    rm ${HOME}/build/pvfs2tab
fi

cp pvfs2tab_tmp ${HOME}/build/pvfs2tab

for HOSTNAME in ${HOSTS} ; do
    TMP="HOST$i"
#    echo "$TMP" 	
    sed -i "s/${TMP}/${HOSTNAME}/g" ${HOME}/build/pvfs2tab
    i=$(( $i + 1 ))
done

# modify hostname in conf file
i=1;
if [ -f ${HOME}/build/pvfs2-fs.conf ]; then
    rm ${HOME}/build/pvfs2-fs.conf
fi

cp pvfs2-fs.conf_tmp ${HOME}/build/pvfs2-fs.conf

for HOSTNAME in ${HOSTS} ; do
    TMP="HOST$i"
    sed -i "s/${TMP}/${HOSTNAME}/g" ${HOME}/build/pvfs2-fs.conf
    i=$(( $i + 1 ))
done

sed -i "s|\/scratch|${TMPDIR}|g" ${HOME}/build/pvfs2-fs.conf
sed -i "s|\/tmp|${TMPDIR}|g" ${HOME}/build/pvfs2-fs.conf

sed -i "s|\/scratch|${TMPDIR}|g" ${HOME}/build/pvfs2tab


# create dir for mnt and storage space
FREEDIR="rm -rf ${TMPDIR}/mnt ${TMPDIR}/pvfs2-storage-space"
MAKEDIR="mkdir -p ${TMPDIR}/mnt/pvfs2 ${TMPDIR}/pvfs2-storage-space"
for HOSTNAME in ${HOSTS} ; do
    ssh  ${HOSTNAME} "${FREEDIR}"
    echo $HOSTNAME DIR DELELETED
    ssh  ${HOSTNAME} "${MAKEDIR}"
    echo $HOSTNAME DIR CREATED
done


# Create storage space and start pvfs server
CREATE="/home/tanghoujun/build/sbin/pvfs2-server ${HOME}/build/pvfs2-fs.conf -f"
START="/home/tanghoujun/build/sbin/pvfs2-server ${HOME}/build/pvfs2-fs.conf"
CKSUM="cksum ${HOME}/build/pvfs2-fs.conf"

for HOSTNAME in ${HOSTS} ; do
    ssh ${HOSTNAME} "${CREATE}"
done

for HOSTNAME in ${HOSTS} ; do
    ssh ${HOSTNAME} "${START}"
done


# Test PVFS2 started
/home/tanghoujun/build/bin/pvfs2-ping -m ${TMPDIR}/mnt/pvfs2
