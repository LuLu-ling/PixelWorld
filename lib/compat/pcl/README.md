# PCL / PCL-CE 兼容层

这个目录只负责读写旧版 PCL、PCL-CE 的文件格式和路径，不属于启动器核心逻辑。

- `import.dart`：检测并导入 PCL-CE 设置、游戏文件夹和账户
- `instance_config.dart`：读写 `versions/<id>/PCL/config.v1.yml` 与旧版 `setup.ini`
- `paths.dart`：`PCL.ini`、`PCLCE` 目录等兼容路径

`lib/core/pcl_import.dart` 和 `lib/core/instance_config.dart` 只是 re-export，
调用方可以继续使用原来的 import；以后移除兼容功能时，只需要删除这两个文件和本目录。
