To automatically set up PVFS2, do the following:

1. compile hostname.c by make
2. run sh pvfs.sh

RADAR specific:
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/tanghoujun/build/lib

PVFS is mounted to ${TMPDIR}/mnt/pvfs2

pvfs2-fs.conf_tmp and pvfs2tab_tmp need to be modified if not using 4 nodes as pvfs2 servers
