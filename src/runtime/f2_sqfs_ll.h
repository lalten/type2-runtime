#pragma once

#include <squashfuse/common.h>

struct fuse_session;
struct fuse_chan;
struct fuse_args;
struct fuse_lowlevel_ops;

typedef struct {
  int fd;
  struct fuse_session *session;
  struct fuse_chan *ch;
} f2_sqfs_ll_chan;

sqfs_err f2_sqfs_ll_mount(f2_sqfs_ll_chan *ch, const char *mountpoint,
                          struct fuse_args *args, struct fuse_lowlevel_ops *ops,
                          size_t ops_size, void *userdata);

void f2_sqfs_ll_unmount(f2_sqfs_ll_chan *ch, const char *mountpoint);
