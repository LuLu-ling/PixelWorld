/// 一次操作（命令模式）：调用方只负责创建并执行，不关心操作怎样完成
abstract interface class Command {
  Future<void> execute();
}
