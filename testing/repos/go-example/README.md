# sonar 依赖

sonar 只依赖源代码和测试报告文件。所以扫描期间不需要执行 go 单元测试。

如何你修改了源代码或者测试代码，请运行 `make test` 来更新测试报告文件。

# 如何执行扫描

```bash
make scan
```
